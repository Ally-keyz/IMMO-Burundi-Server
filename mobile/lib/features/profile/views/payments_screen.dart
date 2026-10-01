import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/transaction.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';

/// Enquiries, because a payment is nearly always the end of an enquiry thread
/// and the user needs to see which property each one belongs to.
final FutureProvider<Paginated<Enquiry>> myEnquiriesProvider =
    FutureProvider<Paginated<Enquiry>>(
      (Ref ref) => ref.read(apiClientProvider).enquiries.mine(pageSize: 50),
    );

/// `You > Payments`.
///
/// The API has no "my payments" list - a payment is only visible through the
/// link that created it - so this screen shows the enquiry and visit history and
/// links out to the public payment screen. Showing an empty Payments tab would be
/// inventing a backend.
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.youMyPayments)),
        body: AppEmptyState(
          title: l10n.savedRequiresSignIn,
          message: l10n.youSignedOutBody,
          icon: Icons.account_balance_wallet_outlined,
          actionLabel: l10n.authLogin,
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.youMyPayments),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: l10n.accountEnquiries),
              Tab(text: l10n.bookingMyVisits),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[_Enquiries(), _VisitShortcut()],
        ),
      ),
    );
  }
}

class _Enquiries extends ConsumerWidget {
  const _Enquiries();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Paginated<Enquiry>> value = ref.watch(myEnquiriesProvider);

    return value.when(
      loading: () => const AppSkeletonList(),
      error: (Object error, _) => AppErrorState(
        error: error,
        onRetry: () => ref.invalidate(myEnquiriesProvider),
      ),
      data: (Paginated<Enquiry> page) {
        if (page.items.isEmpty) {
          return AppEmptyState(
            title: l10n.accountEnquiries,
            message: l10n.enquirySent,
            icon: Icons.forum_outlined,
          );
        }
        return ListView.separated(
          padding: AppSpacing.page,
          itemCount: page.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (BuildContext context, int i) =>
              _EnquiryTile(enquiry: page.items[i]),
        );
      },
    );
  }
}

class _EnquiryTile extends ConsumerWidget {
  const _EnquiryTile({required this.enquiry});

  final Enquiry enquiry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final Formatters f = Formatters(l10n.localeName);

    final (String label, String colour) = switch (enquiry.status) {
      EnquiryStatus.open => (l10n.enquiryLabelOpen, 'partial'),
      EnquiryStatus.inProgress => (l10n.enquiryLabelInProgress, 'partial'),
      EnquiryStatus.responded => (l10n.enquiryLabelResponded, 'verified'),
      EnquiryStatus.dealAgreed => (l10n.enquiryLabelDealAgreed, 'verified'),
      EnquiryStatus.closed => (l10n.enquiryLabelClosed, 'neutral'),
    };

    return Material(
      color: p.field,
      borderRadius: AppRadii.brMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enquiry.propertyId.isEmpty
            ? null
            : () => context.push('/property/${enquiry.propertyId}'),
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          enquiry.property?.localizedTitle(l10n.localeName) ??
                              enquiry.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          enquiry.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: p.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppBadge.semantic(colour, label: label),
                ],
              ),
              if (enquiry.response != null && enquiry.response!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.verified.withValues(alpha: 0.08),
                    borderRadius: AppRadii.brSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.enquiryAgentReply,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        enquiry.response!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Text(
                f.date(enquiry.createdAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: p.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Payments are opened by link, so this is a route out rather than a list.
class _VisitShortcut extends StatelessWidget {
  const _VisitShortcut();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return AppEmptyState(
      title: l10n.paymentTitle,
      message: l10n.paymentAmountDue,
      icon: Icons.qr_code_2_rounded,
      actionLabel: l10n.bookingMyVisits,
      onAction: () => context.push('/you/visits'),
    );
  }
}
