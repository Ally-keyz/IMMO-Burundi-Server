import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Which document to show.
///
/// Every kind maps 1:1 to a page on the website (`/terms`, `/privacy`,
/// `/cookies`, `/verification-disclaimer`). The About page is deliberately not
/// here: it is marketing prose rather than a document, and the site translates
/// parts of it, so it is built from l10n instead - see `AboutScreen`.
enum LegalKind { terms, privacy, cookies, verification }

/// Where each document lives on the website, for the "read on site" link.
extension LegalKindSite on LegalKind {
  String get assetPath => switch (this) {
    LegalKind.terms => 'assets/legal/terms.md',
    LegalKind.privacy => 'assets/legal/privacy.md',
    LegalKind.cookies => 'assets/legal/cookies.md',
    LegalKind.verification => 'assets/legal/verification.md',
  };

  String get sitePath => switch (this) {
    LegalKind.terms => 'terms',
    LegalKind.privacy => 'privacy',
    LegalKind.cookies => 'cookies',
    LegalKind.verification => 'verification-disclaimer',
  };
}

/// Legal documents: Terms, Privacy, Cookies and the Verification Disclaimer.
///
/// The website hardcodes all four in its own page components
/// (`apps/web/src/pages/legal/`) and the API does not serve them, so the app
/// bundles a verbatim copy as markdown. Shipping the same words matters more
/// than a fancier layout: a legal document that quietly differs from the site is
/// worse than one that looks plainer.
///
/// The bodies are English-only, exactly like the site's. The headings and
/// chrome are translated; the document text is not, so a mismatch is visible
/// rather than hidden.
class LegalScreen extends StatefulWidget {
  const LegalScreen({required this.kind, this.loadBody, super.key});

  final LegalKind kind;

  /// Overrides how the markdown is obtained.
  ///
  /// Defaults to the bundled asset. Tests pass a `Future.value` instead because
  /// `rootBundle` only answers the first load in a `testWidgets` file and hangs
  /// on every later one — a platform-channel quirk that has nothing to do with
  /// the screen, but which otherwise makes anything past the first document
  /// untestable.
  final Future<String> Function()? loadBody;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late final Future<String> _body =
      widget.loadBody?.call() ?? rootBundle.loadString(widget.kind.assetPath);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final String title = widget.kind.title(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: _body,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppSkeletonList();
          }
          if (snapshot.hasError) {
            return AppErrorState(error: snapshot.error!);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageMargin,
              AppSpacing.lg,
              AppSpacing.pageMargin,
              AppSpacing.huge,
            ),
            children: <Widget>[
              _richText(
                context,
                title,
                Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final _Block block in _parseMarkdown(snapshot.data!))
                switch (block) {
                  _Heading(:final String text) => Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xl,
                      bottom: AppSpacing.xs,
                    ),
                    child: _richText(
                      context,
                      text,
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _Callout(:final String text) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.partial.withValues(alpha: 0.10),
                      borderRadius: AppRadii.brSm,
                      border: Border.all(
                        color: AppColors.partial.withValues(alpha: 0.35),
                      ),
                    ),
                    child: _richText(context, text, _bodyStyle),
                  ),
                  _Bullet(:final String text) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      bottom: AppSpacing.xs,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('â€¢  ', style: TextStyle(color: p.textSecondary)),
                        Expanded(child: _richText(context, text, _bodyStyle)),
                      ],
                    ),
                  ),
                  _Paragraph(:final String text) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _richText(context, text, _bodyStyle),
                  ),
                  _Muted(:final String text) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _richText(
                      context,
                      text,
                      Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
                    ),
                  ),
                },
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () => _openOnSite(context),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(l10n.legalReadOnSite),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Cached so every block shares one lookup instead of resolving the theme per
  /// line.
  TextStyle? get _bodyStyle => Theme.of(context).textTheme.bodyMedium;

  Future<void> _openOnSite(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Uri url = Uri.parse('${AppConfig.siteUrl}/${widget.kind.sitePath}');
    final bool opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (opened || !context.mounted) return;
    AppSnack.show(context, l10n.errorGeneric, isError: true);
  }
}

extension LegalKindTitle on LegalKind {
  String title(AppLocalizations l10n) => switch (this) {
    LegalKind.terms => l10n.legalTermsTitle,
    LegalKind.privacy => l10n.legalPrivacyTitle,
    LegalKind.cookies => l10n.legalCookiesTitle,
    LegalKind.verification => l10n.legalVerificationTitle,
  };
}

/// Renders [source] with `**bold**` runs turned into real bold spans.
///
/// The website's documents use `<strong>` for the leading phrase of a list item
/// (the cookie types, the verification levels), so the bold spans are real
/// content rather than styling noise â€” printing the asterisks would be a visible
/// difference from the site.
///
/// An unterminated `**` is treated as literal text rather than throwing, since a
/// stray marker in a bundled asset should degrade to plain copy.
Text _richText(BuildContext context, String source, TextStyle? style) {
  final List<TextSpan> spans = <TextSpan>[];
  int index = 0;

  while (index < source.length) {
    final int open = source.indexOf('**', index);
    if (open == -1) {
      spans.add(TextSpan(text: source.substring(index)));
      break;
    }
    final int close = source.indexOf('**', open + 2);
    if (close == -1) {
      spans.add(TextSpan(text: source.substring(index)));
      break;
    }
    if (open > index) {
      spans.add(TextSpan(text: source.substring(index, open)));
    }
    spans.add(
      TextSpan(
        text: source.substring(open + 2, close),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
    index = close + 2;
  }

  return Text.rich(TextSpan(style: style, children: spans));
}

/// Just enough markdown for these documents: `#`/`##` headings, `>` callouts,
/// `-` bullets, `**bold**` runs and paragraphs. A full parser would be a
/// dependency for these shapes.
///
/// The website's documents use `<strong>` for the leading phrase of a list item
/// (the cookie types, the verification levels), so the bold spans are real
/// content rather than styling noise â€” rendering the asterisks would be a visible
/// difference from the site.
sealed class _Block {
  const _Block();
}

class _Heading extends _Block {
  const _Heading(this.text);

  final String text;
}

/// The amber block on the Verification Disclaimer page. It is the same two
/// sentences as the API's `VERIFICATION_DISCLAIMER` constant, so it is worth
/// marking as a callout rather than reading as body copy.
class _Callout extends _Block {
  const _Callout(this.text);

  final String text;
}

class _Bullet extends _Block {
  const _Bullet(this.text);

  final String text;
}

class _Paragraph extends _Block {
  const _Paragraph(this.text);

  final String text;
}

class _Muted extends _Block {
  const _Muted(this.text);

  final String text;
}

List<_Block> _parseMarkdown(String source) {
  final List<_Block> blocks = <_Block>[];

  for (final String raw in source.split('\n')) {
    final String line = raw.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('> ')) {
      blocks.add(_Callout(line.substring(2)));
    } else if (line.startsWith('## ')) {
      blocks.add(_Heading(line.substring(3)));
    } else if (line.startsWith('# ')) {
      blocks.add(_Muted(line.substring(2)));
    } else if (line.startsWith('- ')) {
      blocks.add(_Bullet(line.substring(2)));
    } else {
      blocks.add(_Paragraph(line));
    }
  }

  return blocks;
}
