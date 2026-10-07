import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/responsive.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/transaction.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../data/enquiry_providers.dart';

/// `GET /api/rental-applications/my`, with withdraw where the API allows it.
///
/// `SUBMITTED`, `UNDER_REVIEW` and `SHORTLISTED` can still be withdrawn; after
/// that the decision is the agent's and the button disappears rather than
/// offering an action the server will reject.
class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  Future<void> _withdraw(
    BuildContext context,
    WidgetRef ref,
    RentalApplication application,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: Text(l10n.applyWithdrawTitle),
            content: Text(l10n.applyWithdrawBody),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.commonCancel),
              ),
              AppButton.text(
                label: l10n.applyWithdrawConfirm,
                expand: false,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;

    final bool ok = await ref
        .read(transactionControllerProvider.notifier)
        .withdraw(application.id);
    if (!context.mounted) return;

    if (ok) {
      AppSnack.show(context, l10n.applyWithdrawn);
      return;
    }
    final Object? error = ref.read(transactionControllerProvider).error;
    AppSnack.show(
      context,
      transactionErrorMessage(error, l10n.commonError),
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.applicationsTitle)),
        body: AppEmptyState(
          title: l10n.savedRequiresSignIn,
          message: l10n.enquirySignInRequired,
          icon: Icons.description_outlined,
          actionLabel: l10n.authLogin,
          onAction: () => context.push('/auth/sign-in'),
        ),
      );
    }

    final AsyncValue<Paginated<RentalApplication>> value = ref.watch(
      myApplicationsProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.applicationsTitle)),
      body: value.when(
        loading: () => const AppSkeletonList(),
        error: (Object error, _) => AppErrorState(
          error: error,
          onRetry: () => ref.invalidate(myApplicationsProvider),
        ),
        data: (Paginated<RentalApplication> page) {
          if (page.items.isEmpty) {
            return AppEmptyState(
              title: l10n.applicationsEmpty,
              message: l10n.applicationsEmptyDesc,
              icon: Icons.description_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myApplicationsProvider),
            child: ResponsiveCenter(
              child: ListView.separated(
                padding: AppSpacing.page,
                itemCount: page.items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (BuildContext context, int i) {
                  final RentalApplication application = page.items[i];
                  return _ApplicationTile(
                    application: application,
                    busy: ref.watch(transactionControllerProvider).isLoading,
                    onWithdraw: () => _withdraw(context, ref, application),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({
    required this.application,
    required this.busy,
    required this.onWithdraw,
  });

  final RentalApplication application;
  final bool busy;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Formatters f = Formatters(l10n.localeName);

    final (String label, String colour) = switch (application.status) {
      RentalApplicationStatus.submitted => (
        l10n.applyStatusSubmitted,
        'neutral',
      ),
      RentalApplicationStatus.underReview => (
        l10n.applyStatusUnderReview,
        'partial',
      ),
      RentalApplicationStatus.shortlisted => (
        l10n.applyStatusShortlisted,
        'verified',
      ),
      RentalApplicationStatus.accepted => (
        l10n.applyStatusAccepted,
        'verified',
      ),
      RentalApplicationStatus.rejected => (l10n.applyStatusRejected, 'danger'),
      RentalApplicationStatus.withdrawn => (
        l10n.applyStatusWithdrawn,
        'neutral',
      ),
    };

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  application.property?.localizedTitle(l10n.localeName) ??
                      l10n.applicationsRentApplication,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              AppBadge.semantic(colour, label: label),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _Line(
            icon: Icons.groups_outlined,
            text:
                '${l10n.applyOccupants}: ${application.totalOccupants}'
                ' · ${l10n.applyChildren}: ${application.numberOfChildren}',
          ),
          if (application.moveInDate != null)
            _Line(
              icon: Icons.event_available_outlined,
              text:
                  '${l10n.applyMoveInDate}: ${f.date(application.moveInDate!)}',
            ),
          if (application.occupation.isNotEmpty)
            _Line(
              icon: Icons.work_outline,
              text: '${l10n.applyOccupation}: ${application.occupation}',
            ),
          _Line(
            icon: Icons.payments_outlined,
            text: application.advanceAvailable
                ? l10n.applyAdvanceYes
                : l10n.applyAdvanceNo,
          ),
          if (application.reviewNotes != null &&
              application.reviewNotes!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.applyReviewNotes,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              application.reviewNotes!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            f.date(application.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          // The two actions and their labels are longer in French and Swahili
          // than in English, and a row of text buttons does not survive that:
          // Wrap moves the second one onto its own line instead of overflowing.
          if (application.canWithdraw || application.propertyId.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: <Widget>[
                if (application.canWithdraw)
                  AppButton.text(
                    label: l10n.applyWithdraw,
                    expand: false,
                    color: Theme.of(context).colorScheme.error,
                    onPressed: busy ? null : onWithdraw,
                  ),
                if (application.propertyId.isNotEmpty)
                  AppButton.text(
                    label: l10n.applicationsViewProperty,
                    expand: false,
                    onPressed: () =>
                        context.push('/property/${application.propertyId}'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: Theme.of(context).hintColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
