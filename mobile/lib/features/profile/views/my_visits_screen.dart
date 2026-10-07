import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/models/enums.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/responsive.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/transaction.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';

/// The user's own visit bookings, with cancel where the API allows it.
final FutureProvider<Paginated<VisitBooking>> myVisitsProvider =
    FutureProvider<Paginated<VisitBooking>>(
      (Ref ref) => ref.read(apiClientProvider).visits.myBookings(pageSize: 50),
    );

final StateNotifierProvider<MyVisitsController, AsyncValue<void>>
myVisitsControllerProvider =
    StateNotifierProvider<MyVisitsController, AsyncValue<void>>(
      MyVisitsController.new,
    );

/// Cancel is the only mutation on this screen, and the API is idempotent, so a
/// plain async wrapper with a busy state is enough.
class MyVisitsController extends StateNotifier<AsyncValue<void>> {
  MyVisitsController(this._ref) : super(const AsyncValue<void>.data(null));

  final Ref _ref;

  Future<void> cancel(String bookingId) async {
    if (state.isLoading) return;
    state = const AsyncValue<void>.loading();
    try {
      await _ref.read(apiClientProvider).visits.cancel(bookingId);
      _ref.invalidate(myVisitsProvider);
      state = const AsyncValue<void>.data(null);
    } on Object catch (e, s) {
      state = AsyncValue<void>.error(e, s);
    }
  }
}

class MyVisitsScreen extends ConsumerWidget {
  const MyVisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookingMyVisits)),
        body: AppEmptyState(
          title: l10n.savedRequiresSignIn,
          message: l10n.bookingSignInRequired,
          icon: Icons.calendar_month_outlined,
          actionLabel: l10n.authLogin,
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    final AsyncValue<Paginated<VisitBooking>> value = ref.watch(
      myVisitsProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingMyVisits)),
      body: value.when(
        loading: () => const AppSkeletonList(),
        error: (Object error, _) => AppErrorState(
          error: error,
          onRetry: () => ref.invalidate(myVisitsProvider),
        ),
        data: (Paginated<VisitBooking> page) {
          if (page.items.isEmpty) {
            return AppEmptyState(
              title: l10n.bookingMyVisits,
              message: l10n.bookingNoSessions,
              icon: Icons.event_busy_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myVisitsProvider),
            child: ResponsiveCenter(
              child: ListView.separated(
                padding: AppSpacing.page,
                itemCount: page.items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (BuildContext context, int i) =>
                    _VisitTile(booking: page.items[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VisitTile extends ConsumerWidget {
  const _VisitTile({required this.booking});

  final VisitBooking booking;

  bool get _cancellable =>
      booking.status == VisitBookingStatus.pending ||
      booking.status == VisitBookingStatus.confirmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final Formatters f = Formatters(l10n.localeName);
    final bool busy = ref.watch(myVisitsControllerProvider).isLoading;

    final (String label, String colour) = switch (booking.status) {
      VisitBookingStatus.confirmed => (l10n.bookingSuccess, 'verified'),
      VisitBookingStatus.completed => (l10n.bookingMyVisits, 'neutral'),
      VisitBookingStatus.cancelled => (l10n.commonCancel, 'danger'),
      VisitBookingStatus.noShow => (l10n.commonCancel, 'danger'),
      VisitBookingStatus.pending => (l10n.bookingAnyTime, 'partial'),
    };

    // A scheduled session has a `startTime`; an any-time request carries the
    // date the visitor asked for instead.
    final String when = booking.startTime.isNotEmpty
        ? '${booking.preferredDate ?? ''} · ${booking.startTime}'
        : (booking.preferredDate ?? f.date(booking.createdAt));

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(color: p.field, borderRadius: AppRadii.brMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  when.trim(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              AppBadge.semantic(colour, label: label),
            ],
          ),
          if (booking.property != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              booking.property!.localizedTitle(l10n.localeName),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: p.textSecondary),
            ),
          ],
          if (booking.bookingReference.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${l10n.bookingReference} ${booking.bookingReference}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: p.textTertiary),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${l10n.bookingNumberOfPeople} ${booking.numberOfPeople}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          if (booking.notes != null && booking.notes!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(booking.notes!, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (_cancellable) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton.text(
                label: l10n.commonCancel,
                color: AppColors.danger,
                expand: false,
                onPressed: busy
                    ? null
                    : () => ref
                          .read(myVisitsControllerProvider.notifier)
                          .cancel(booking.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
