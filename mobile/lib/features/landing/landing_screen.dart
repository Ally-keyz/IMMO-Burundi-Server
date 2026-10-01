import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_buttons.dart';
import '../../l10n/generated/app_localizations.dart';

/// The signed-out front door.
///
/// Browsing is public, so this is a *pitch* screen, not a login wall: the
/// language is the first thing offered, because the app ships in French, English
/// and Swahili and picking the wrong one is the most common first-run problem.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        // Scrollable rather than a plain Column: at a large system font scale
        // the content plus the legal strip no longer fits a short screen. The
        // two spacers collapse to nothing before anything would be clipped.
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Spacer(),
                        Lottie.asset(
                          'assets/lottie/home.json',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.homeTagline,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.homeSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const Spacer(),
                        AppButton.primary(
                          label: l10n.navBrowse,
                          onPressed: () => context.go('/home'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: AppButton.secondary(
                                label: l10n.navLogin,
                                onPressed: () =>
                                    context.push('/auth/sign-in'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppButton.secondary(
                                label: l10n.navRegister,
                                onPressed: () =>
                                    context.push('/auth/sign-up'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // The website's footer drops its legal links for
                        // signed-in users, so a signed-out visitor has no other
                        // way to reach the terms they just agreed to.
                        const _LegalStrip(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LegalStrip extends StatelessWidget {
  const _LegalStrip();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        _LegalLink(l10n.settingsTerms, () => context.push('/legal/terms')),
        _LegalLink(l10n.settingsPrivacy, () => context.push('/legal/privacy')),
        _LegalLink(l10n.legalCookiesTitle, () => context.push('/legal/cookies')),
        _LegalLink(
          l10n.legalVerificationTitle,
          () => context.push('/legal/verification'),
        ),
        _LegalLink(l10n.aboutTitle, () => context.push('/about')),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        minimumSize: const Size(0, AppSpacing.tapTarget),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
      ),
    );
  }
}