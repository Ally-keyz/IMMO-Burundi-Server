import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/responsive.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/preferences_controller.dart';

/// Language picker.
///
/// The active language is the *profile* language for a signed-in user, so the
/// choice is written back to the account as well as to local preferences - that
/// is what the website does and what makes a new device pick the language up.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const List<({String code, String endonym})> _languages =
      <({String code, String endonym})>[
        (code: 'fr', endonym: 'Francais'),
        (code: 'en', endonym: 'English'),
        (code: 'sw', endonym: 'Kiswahili'),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String current = ref.watch(preferencesProvider).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsLanguage)),
      // One RadioGroup owns the selection for the whole list, which is also what
      // gives the tiles arrow-key and space-bar navigation.
      body: RadioGroup<String>(
        groupValue: current,
        onChanged: (String? value) => _apply(context, ref, value),
        child: ListView(
          padding: AppSpacing.page,
          children: <Widget>[
            ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final ({String code, String endonym}) language
                      in _languages)
                    RadioListTile<String>(
                      value: language.code,
                      // The endonym is how a speaker of that language writes its own
                      // name, so it is never translated - a French speaker looking for
                      // Kiswahili would not find it under "Swahili".
                      title: Text(language.endonym),
                      secondary: Text(
                        language.code.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.brand),
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

  Future<void> _apply(BuildContext context, WidgetRef ref, String? code) async {
    if (code == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    await ref.read(preferencesProvider.notifier).setLanguage(code);
    if (!context.mounted) return;
    // The sheet-level confirmation reads better in the language just chosen.
    AppSnack.show(context, l10n.languageChanged);
  }
}
