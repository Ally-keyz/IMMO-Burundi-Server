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
enum LegalKind { terms, privacy }

/// Terms & Conditions and Privacy Policy.
///
/// The website hardcodes both documents in its own page components
/// (`apps/web/src/pages/legal/`) and the API does not serve them, so the app
/// bundles a verbatim copy as markdown. Shipping the same words matters more
/// than a fancier layout: a legal document that quietly differs from the site is
/// worse than one that looks plainer.
///
/// The bodies are English-only, exactly like the site's. The headings and
/// chrome are translated; the document text is not, so a mismatch is visible
/// rather than hidden.
class LegalScreen extends StatefulWidget {
  const LegalScreen({required this.kind, super.key});

  final LegalKind kind;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late final Future<String> _body = rootBundle.loadString(switch (widget.kind) {
    LegalKind.terms => 'assets/legal/terms.md',
    LegalKind.privacy => 'assets/legal/privacy.md',
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final String title = switch (widget.kind) {
      LegalKind.terms => l10n.legalTermsTitle,
      LegalKind.privacy => l10n.legalPrivacyTitle,
    };

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
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _Bullet(:final String text) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      bottom: AppSpacing.xs,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('•  ', style: TextStyle(color: p.textSecondary)),
                        Expanded(
                          child: Text(
                            text,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Paragraph(:final String text) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  _Muted(:final String text) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      text,
                      style: Theme.of(
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

  Future<void> _openOnSite(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Uri url = Uri.parse(
      '${AppConfig.siteUrl}/${widget.kind == LegalKind.terms ? 'terms' : 'privacy'}',
    );
    final bool opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (opened || !context.mounted) return;
    AppSnack.show(context, l10n.errorGeneric, isError: true);
  }
}

/// Just enough markdown for these two documents: `#`/`##` headings, `-`
/// bullets, and paragraphs. A full parser would be a dependency for four shapes.
sealed class _Block {
  const _Block();
}

class _Heading extends _Block {
  const _Heading(this.text);

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

    if (line.startsWith('## ')) {
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
