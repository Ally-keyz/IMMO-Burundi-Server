import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      onPressed: () => context.push('/auth/sign-in'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.secondary(
                      label: l10n.navRegister,
                      onPressed: () => context.push('/auth/sign-up'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
