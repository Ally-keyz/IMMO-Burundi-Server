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

/// `GET /api/enquiries` — what this user has sent and what came back.
///
/// Read-only by design: `enquiriesApi.setStatus` and `.inbox` are the agent's
/// side of the conversation and the app does not ship an agent surface.
class MyEnquiriesScreen extends ConsumerWidget {
  const MyEnquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.enquiriesTitle)),
        body: AppEmptyState(
          title: l10n.savedRequiresSignIn,
          message: l10n.enquirySignInRequired,
          icon: Icons.forum_outlined,
          actionLabel: l10n.authLogin,
          onAction: () => context.push('/auth/sign-in'),
        ),
      );
    }

    final AsyncValue<Paginated<Enquiry>> value = ref.watch(myEnquiriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.enquiriesTitle)),
      body: value.when(
        loading: () => const AppSkeletonList(),
        error: (Object error, _) => AppErrorState(
          error: error,
          onRetry: () => ref.invalidate(myEnquiriesProvider),
        ),
        data: (Paginated<Enquiry> page) {
          if (page.items.isEmpty) {
            return AppEmptyState(
              title: l10n.enquiriesEmpty,
              message: l10n.enquiriesEmptyDesc,
              icon: Icons.forum_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myEnquiriesProvider),
            child: ResponsiveCenter(
              child: ListView.separated(
                padding: AppSpacing.page,
                itemCount: page.items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (BuildContext context, int i) =>
                    _EnquiryTile(enquiry: page.items[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EnquiryTile extends StatelessWidget {
  const _EnquiryTile({required this.enquiry});

  final Enquiry enquiry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Formatters f = Formatters(l10n.localeName);

    final (String label, String colour) = switch (enquiry.status) {
      EnquiryStatus.fresh => (l10n.enquiryStatusNEW, 'neutral'),
      EnquiryStatus.open => (l10n.enquiryStatusOPEN, 'partial'),
      EnquiryStatus.inProgress => (l10n.enquiryStatusINPROGRESS, 'partial'),
      EnquiryStatus.responded => (l10n.enquiryStatusRESPONDED, 'verified'),
      EnquiryStatus.dealAgreed => (l10n.enquiryStatusDEALAGREED, 'verified'),
      EnquiryStatus.closed => (l10n.enquiryStatusCLOSED, 'neutral'),
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
                  enquiry.subject.isEmpty ? l10n.enquiryTitle : enquiry.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              AppBadge.semantic(colour, label: label),
            ],
          ),
          if (enquiry.property != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              enquiry.property!.localizedTitle(l10n.localeName),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (enquiry.message.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              enquiry.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (enquiry.response != null && enquiry.response!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            // The agent's answer is the only reason to re-open this screen, so it
            // is the one part that gets its own labelled block.
            Text(
              l10n.enquiryAgentReply,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              enquiry.response!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            f.date(enquiry.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          if (enquiry.propertyId.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton.text(
                label: l10n.applicationsViewProperty,
                expand: false,
                onPressed: () =>
                    context.push('/property/${enquiry.propertyId}'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
