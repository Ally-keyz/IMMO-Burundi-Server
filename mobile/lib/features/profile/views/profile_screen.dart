import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/responsive.dart';
import '../../../core/models/user.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../auth/data/auth_state.dart';
import '../data/account_provider.dart';

/// `You` tab.
///
/// There is no inbox, so this is the account hub: identity, visits, payments,
/// saved, then settings and the legal documents.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthState auth = ref.watch(authControllerProvider);
    final AppPalette p = AppPalette.of(context);

    if (auth is! AuthSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tabYou)),
        body: AppEmptyState(
          title: l10n.youSignedOutTitle,
          message: l10n.youSignedOutBody,
          icon: Icons.person_outline_rounded,
          actionLabel: l10n.authLogin,
          onAction: () => context.push('/auth/sign-in'),
        ),
      );
    }

    final AppUser user = auth.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabYou)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(accountSummaryProvider),
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.huge),
          children: <Widget>[
            ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageMargin,
                      AppSpacing.lg,
                      AppSpacing.pageMargin,
                      AppSpacing.xl,
                    ),
                    child: Row(
                      children: <Widget>[
                        AppImage(
                          url: user.photoUrl,
                          height: 64,
                          width: 64,
                          borderRadius: AppRadii.brPill,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                user.fullName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email.isNotEmpty ? user.email : user.phone,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: p.textSecondary),
                              ),
                              if (user.needsAccountSetup) ...<Widget>[
                                const SizedBox(height: AppSpacing.xs),
                                AppBadge.semantic(
                                  'partial',
                                  label: l10n.authSetupRemaining,
                                ),
                              ],
                            ],
                          ),
                        ),
                        AppIconButton(
                          icon: Icons.edit_outlined,
                          tooltip: l10n.youEditProfile,
                          onPressed: () => context.push('/you/edit'),
                        ),
                      ],
                    ),
                  ),
                  const _AccountCounters(),
                  _Group(
                    children: <_Row>[
                      _Row(
                        icon: Icons.favorite_border_rounded,
                        label: l10n.tabSaved,
                        onTap: () => context.go('/saved'),
                      ),
                      _Row(
                        icon: Icons.calendar_month_outlined,
                        label: l10n.youMyVisits,
                        onTap: () => context.push('/you/visits'),
                      ),
                      _Row(
                        icon: Icons.account_balance_wallet_outlined,
                        label: l10n.youMyPayments,
                        onTap: () => context.push('/you/payments'),
                      ),
                      _Row(
                        icon: Icons.forum_outlined,
                        label: l10n.enquiriesTitle,
                        onTap: () => context.push('/you/enquiries'),
                      ),
                      _Row(
                        icon: Icons.description_outlined,
                        label: l10n.applicationsTitle,
                        onTap: () => context.push('/you/applications'),
                      ),
                    ],
                  ),
                  _Group(
                    children: <_Row>[
                      _Row(
                        icon: Icons.settings_outlined,
                        label: l10n.settingsTitle,
                        onTap: () => context.push('/you/settings'),
                      ),
                      _Row(
                        icon: Icons.notifications_none_rounded,
                        label: l10n.settingsNotifications,
                        onTap: () =>
                            context.push('/you/settings/notifications'),
                      ),
                      _Row(
                        icon: Icons.language_rounded,
                        label: l10n.settingsLanguage,
                        onTap: () => context.push('/you/settings/language'),
                      ),
                    ],
                  ),
                  _Group(
                    children: <_Row>[
                      _Row(
                        icon: Icons.info_outline_rounded,
                        label: l10n.aboutTitle,
                        onTap: () => context.push('/about'),
                      ),
                      _Row(
                        icon: Icons.gavel_rounded,
                        label: l10n.settingsTerms,
                        onTap: () => context.push('/legal/terms'),
                      ),
                      _Row(
                        icon: Icons.privacy_tip_outlined,
                        label: l10n.settingsPrivacy,
                        onTap: () => context.push('/legal/privacy'),
                      ),
                      _Row(
                        icon: Icons.cookie_outlined,
                        label: l10n.legalCookiesTitle,
                        onTap: () => context.push('/legal/cookies'),
                      ),
                      _Row(
                        icon: Icons.verified_outlined,
                        label: l10n.legalVerificationTitle,
                        onTap: () => context.push('/legal/verification'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: TextButton.icon(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: Text(l10n.settingsSignOut),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Views, enquiries and favourites counts, so the tab answers "what is going on
/// with my account" without opening three subpages.
class _AccountCounters extends ConsumerWidget {
  const _AccountCounters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AccountSummary> summary = ref.watch(
      accountSummaryProvider,
    );

    return summary.maybeWhen(
      data: (AccountSummary data) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          0,
          AppSpacing.pageMargin,
          AppSpacing.lg,
        ),
        child: Row(
          children: <Widget>[
            _Counter(label: l10n.accountViews, value: data.views),
            _Divider(),
            _Counter(label: l10n.accountEnquiries, value: data.enquiries),
            _Divider(),
            _Counter(label: l10n.accountSaved, value: data.saved),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: <Widget>[
        Text(
          '$value',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppPalette.of(context).textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppPalette.of(context).border);
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<_Row> children;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        0,
        AppSpacing.pageMargin,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(color: p.field, borderRadius: AppRadii.brMd),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) Divider(height: 1, color: p.border),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: p.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
