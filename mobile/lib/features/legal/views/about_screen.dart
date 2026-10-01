import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../l10n/generated/app_localizations.dart';

/// `You > About`, and reachable from the landing and sign-up screens.
///
/// The website splits its About page across i18n keys and hardcoded JSX, and its
/// `fr` layer is missing the four value descriptions while `sw` has none - so a
/// French or Swahili visitor reads English prose under a translated heading.
/// The app therefore builds the page from l10n and supplies the missing
/// translations itself (see `tool/app_translations.*.json`).
///
/// Contact details are configuration, not copy, so they come from `AppConfig`
/// rather than l10n - which also stops the email address drifting between the
/// app and the website the way `contact.listEmail` already has.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.lg,
          AppSpacing.pageMargin,
          AppSpacing.huge,
        ),
        children: <Widget>[
          Text(
            l10n.aboutHeroTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.aboutHeroSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: p.textSecondary),
          ),

          _Section(title: l10n.aboutMissionTitle),
          Text(
            l10n.aboutMissionBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.aboutMissionBodyLong,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          _Section(title: l10n.aboutValuesTitle),
          _Value(
            icon: Icons.verified_user_outlined,
            title: l10n.aboutValuesTrust,
            body: l10n.aboutValuesTrustDesc,
          ),
          _Value(
            icon: Icons.visibility_outlined,
            title: l10n.aboutValuesTransparency,
            body: l10n.aboutValuesTransparencyDesc,
          ),
          _Value(
            icon: Icons.workspace_premium_outlined,
            title: l10n.aboutValuesQuality,
            body: l10n.aboutValuesQualityDesc,
          ),
          _Value(
            icon: Icons.language_rounded,
            title: l10n.aboutValuesAccessibility,
            body: l10n.aboutValuesAccessibilityDesc,
          ),

          _Section(title: l10n.aboutContactTitle),
          Text(
            l10n.contactSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ContactRow(
            icon: Icons.phone_outlined,
            label: l10n.contactPhoneLabel,
            value: AppConfig.contactPhone,
            onTap: () => _launch(
              context,
              Uri(scheme: 'tel', path: AppConfig.contactPhone),
            ),
          ),
          _ContactRow(
            icon: Icons.chat_rounded,
            label: l10n.contactWhatsappLabel,
            value: AppConfig.contactPhone,
            onTap: () => _launch(
              context,
              Uri.parse(
                'https://wa.me/${AppConfig.contactPhone.replaceAll('+', '')}',
              ),
            ),
          ),
          _ContactRow(
            icon: Icons.mail_outline_rounded,
            label: l10n.contactEmailLabel,
            value: AppConfig.contactEmail,
            onCopy: () => _copy(context, AppConfig.contactEmail),
            onTap: () => _launch(
              context,
              Uri(
                scheme: 'mailto',
                path: AppConfig.contactEmail,
                query: 'subject=${Uri.encodeComponent(l10n.aboutEmailSubject)}',
              ),
            ),
          ),
          _ContactRow(
            icon: Icons.location_on_outlined,
            label: l10n.contactAddressLabel,
            value: AppConfig.contactAddress,
            onCopy: () => _copy(context, AppConfig.contactAddress),
          ),
          _ContactRow(
            icon: Icons.public_rounded,
            label: l10n.aboutWebsite,
            value: AppConfig.siteUrl,
            onTap: () => _launch(context, Uri.parse(AppConfig.siteUrl)),
          ),

          const SizedBox(height: AppSpacing.xl),
          const _VersionBlock(),
        ],
      ),
    );
  }

  static Future<void> _launch(BuildContext context, Uri target) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool opened = await launchUrl(
      target,
      // `mailto:` and `tel:` have no in-app handler; sending them to a browser
      // hands off to whatever the user actually uses.
      mode: LaunchMode.externalApplication,
    );
    if (opened || !context.mounted) return;
    AppSnack.show(context, l10n.errorNoAppForLink, isError: true);
  }

  static Future<void> _copy(BuildContext context, String value) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) AppSnack.show(context, l10n.aboutCopied);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _Value extends StatelessWidget {
  const _Value({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: p.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 18, color: p.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: p.textTertiary),
                    ),
                    const SizedBox(height: 1),
                    Text(value, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              if (onCopy != null)
                IconButton(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: AppLocalizations.of(context).aboutCopy,
                  visualDensity: VisualDensity.compact,
                ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: p.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Version, build environment, and the legal documents.
///
/// The website's `/about` page has no version block; the app adds one because a
/// store listing and a bug report both need it, and it is the natural place for
/// the document links the footer hides from signed-in users.
class _VersionBlock extends ConsumerWidget {
  const _VersionBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: p.field, borderRadius: AppRadii.brMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                l10n.settingsVersion,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: p.textSecondary),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppConfig.appVersion,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              Text(
                AppConfig.environment.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: p.textTertiary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          _Link(
            icon: Icons.description_outlined,
            label: l10n.settingsTerms,
            onTap: () => context.push('/legal/terms'),
          ),
          _Link(
            icon: Icons.privacy_tip_outlined,
            label: l10n.settingsPrivacy,
            onTap: () => context.push('/legal/privacy'),
          ),
          _Link(
            icon: Icons.cookie_outlined,
            label: l10n.legalCookiesTitle,
            onTap: () => context.push('/legal/cookies'),
          ),
          _Link(
            icon: Icons.verified_outlined,
            label: l10n.legalVerificationTitle,
            onTap: () => context.push('/legal/verification'),
          ),
        ],
      ),
    );
  }
}

class _Link extends ConsumerWidget {
  const _Link({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPalette p = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.brSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: p.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.textTertiary),
          ],
        ),
      ),
    );
  }
}
