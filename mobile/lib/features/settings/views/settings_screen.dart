import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/responsive.dart';
import '../../../core/models/enums.dart';
import '../../../core/utils/app_cache.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../l10n/enum_labels.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../data/preferences_controller.dart';

/// Settings hub: appearance, language, currency, notifications, about, sign out.
///
/// Language and currency apply immediately rather than behind a Save button -
/// the website persists them the moment they are picked.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PreferencesState state = ref.watch(preferencesProvider);
    final bool signedIn = ref.watch(authControllerProvider).isSignedIn;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.huge),
        children: <Widget>[
          ResponsiveCenter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (signedIn) ...<Widget>[
                  _Header(l10n.settingsAccount),
                  _Tile(
                    icon: Icons.person_outline_rounded,
                    label: l10n.youEditProfile,
                    onTap: () => context.push('/you/edit'),
                  ),
                ],
                _Header(l10n.settingsAppearance),
                _ThemePicker(
                  value: state.themeMode,
                  onChanged: (ThemeMode mode) =>
                      ref.read(preferencesProvider.notifier).setThemeMode(mode),
                ),
                _Header(l10n.settingsGeneral),
                _Tile(
                  icon: Icons.language_rounded,
                  label: l10n.settingsLanguage,
                  value: state.languageCode.toUpperCase(),
                  onTap: () => context.push('/you/settings/language'),
                ),
                _Tile(
                  icon: Icons.payments_outlined,
                  label: l10n.settingsCurrency,
                  value: state.currency.code,
                  onTap: () => _pickCurrency(context, ref),
                ),
                _Tile(
                  icon: Icons.notifications_none_rounded,
                  label: l10n.settingsNotifications,
                  onTap: () => context.push('/you/settings/notifications'),
                ),
                _Header(l10n.settingsAbout),
                _Tile(
                  icon: Icons.info_outline_rounded,
                  label: l10n.aboutTitle,
                  onTap: () => context.push('/about'),
                ),
                _Tile(
                  icon: Icons.gavel_rounded,
                  label: l10n.settingsTerms,
                  onTap: () => context.push('/you/settings/terms'),
                ),
                _Tile(
                  icon: Icons.privacy_tip_outlined,
                  label: l10n.settingsPrivacy,
                  onTap: () => context.push('/you/settings/privacy'),
                ),
                _Tile(
                  icon: Icons.cookie_outlined,
                  label: l10n.legalCookiesTitle,
                  onTap: () => context.push('/you/settings/cookies'),
                ),
                _Tile(
                  icon: Icons.verified_outlined,
                  label: l10n.legalVerificationTitle,
                  onTap: () => context.push('/you/settings/verification'),
                ),
                _Header(l10n.settingsStorage),
                _Tile(
                  icon: Icons.cleaning_services_outlined,
                  label: l10n.settingsClearCache,
                  onTap: () => _clearCache(context, ref),
                ),
                _Header(l10n.settingsHelp),
                _Tile(
                  icon: Icons.phone_outlined,
                  label: l10n.contactPhoneLabel,
                  value: AppConfig.contactPhone,
                  onTap: () => _launch(
                    context,
                    Uri(scheme: 'tel', path: AppConfig.contactPhone),
                  ),
                ),
                _Tile(
                  icon: Icons.mail_outline_rounded,
                  label: l10n.contactEmailLabel,
                  value: AppConfig.contactEmail,
                  onTap: () => _launch(
                    context,
                    Uri(scheme: 'mailto', path: AppConfig.contactEmail),
                  ),
                ),
                _Tile(
                  icon: Icons.public_rounded,
                  label: l10n.aboutWebsite,
                  value: Uri.parse(AppConfig.siteUrl).host,
                  onTap: () => _launch(context, AppConfig.sitePath('')),
                ),
                if (signedIn) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  Padding(
                    padding: AppSpacing.page,
                    child: OutlinedButton(
                      onPressed: () => _confirmSignOut(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        minimumSize: const Size(0, AppSpacing.tapTarget),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.brMd,
                        ),
                      ),
                      child: Text(l10n.settingsSignOut),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Empties the on-device image cache and the stored recent searches.
  ///
  /// Neither is required for correctness — the cache refills itself and the
  /// searches are the user's own history — so this is a courtesy action for
  /// reclaiming storage, not a repair.
  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    await AppCache.clear();
    await ref.read(preferencesProvider.notifier).clearSearchHistory();
    if (!context.mounted) return;
    AppSnack.show(context, l10n.settingsCacheCleared);
  }

  static Future<void> _launch(BuildContext context, Uri uri) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (opened || !context.mounted) return;
    AppSnack.show(context, l10n.errorNoAppForLink, isError: true);
  }

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppCurrency current = ref.read(preferencesProvider).currency;

    final AppCurrency? picked = await AppSheet.show<AppCurrency>(
      context,
      (BuildContext sheetContext) => RadioGroup<AppCurrency>(
        groupValue: current,
        onChanged: (AppCurrency? value) =>
            Navigator.of(sheetContext).pop(value),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final AppCurrency currency in AppCurrency.values)
                RadioListTile<AppCurrency>(
                  value: currency,
                  title: Text(currency.label(l10n)),
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );

    if (picked == null) return;
    await ref.read(preferencesProvider.notifier).setCurrency(picked);
    if (context.mounted) AppSnack.show(context, l10n.currencyChanged);
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);

    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: Text(l10n.settingsSignOut),
            content: Text(l10n.settingsSignOutConfirm),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.settingsSignOut),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    await ref.read(authControllerProvider.notifier).signOut();
    if (navigator.mounted) navigator.pop();
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.pageMargin,
      AppSpacing.xl,
      AppSpacing.pageMargin,
      AppSpacing.sm,
    ),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppPalette.of(context).textSecondary,
      ),
    ),
  );
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: AppSpacing.page,
      child: SegmentedButton<ThemeMode>(
        segments: <ButtonSegment<ThemeMode>>[
          ButtonSegment<ThemeMode>(
            value: ThemeMode.system,
            label: Text(l10n.settingsThemeSystem),
            icon: const Icon(Icons.brightness_auto_outlined, size: 18),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            label: Text(l10n.settingsThemeLight),
            icon: const Icon(Icons.light_mode_outlined, size: 18),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            label: Text(l10n.settingsThemeDark),
            icon: const Icon(Icons.dark_mode_outlined, size: 18),
          ),
        ],
        selected: <ThemeMode>{value},
        showSelectedIcon: false,
        onSelectionChanged: (Set<ThemeMode> selection) =>
            onChanged(selection.first),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageMargin,
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
              if (value != null)
                Text(
                  value!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: p.textSecondary),
                ),
              if (onTap != null) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.chevron_right_rounded, color: p.textTertiary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
