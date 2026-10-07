import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/responsive.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/msisdn.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_controller.dart';
import '../data/auth_return_path.dart';

/// Sign in.
///
/// One field accepts either a phone number or an email address, because the API
/// resolves the identifier itself (`POST /auth/login` takes `identifier`) and
/// the website behaves the same way. Two tabs would mean the same endpoint
/// called two different ways for no gain.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.from});

  /// Location to return to after signing in, from `?from=`.
  final String? from;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _identifier = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _busy = false;
  String? _identifierError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _looksLikePhone => !_identifier.text.contains('@');

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final AppLocalizations l10n = AppLocalizations.of(context);

    final String identifierText = _identifier.text.trim();
    final String identifierError;
    if (identifierText.isEmpty) {
      identifierError = l10n.authPhoneRequired;
    } else if (identifierText.contains('@')) {
      final bool valid = RegExp(
        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      ).hasMatch(identifierText);
      // No dedicated "invalid email" string exists in the site's translations,
      // so compose one from the label plus the shared "required" word. That
      // keeps it localised without inventing a key the export script would wipe.
      identifierError = valid ? '' : '${l10n.authEmail} ${l10n.commonRequired}';
    } else {
      identifierError = isValidBurundiMsisdn(identifierText)
          ? ''
          : l10n.authPhoneRequired;
    }

    final String passwordError = _password.text.isEmpty
        ? l10n.authPasswordRequired
        : '';

    setState(() {
      _identifierError = identifierError.isEmpty ? null : identifierError;
      _passwordError = passwordError.isEmpty ? null : passwordError;
      _formError = null;
    });
    if (identifierError.isNotEmpty || passwordError.isNotEmpty) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            identifier: _looksLikePhone
                ? normalizeMsisdn(identifierText)
                : identifierText,
            password: _password.text,
          );
      if (mounted) context.go(authReturnPath(widget.from) ?? '/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _formError = e.message);
    } on Object {
      if (!mounted) return;
      setState(() => _formError = 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ResponsiveScrollView(
          children: <Widget>[
            Text(l10n.authWelcomeBack, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.authLogInSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              controller: _identifier,
              label: '${l10n.authPhone} / ${l10n.authEmail}',
              hint:
                  '${l10n.authPhonePlaceholder} / ${l10n.authEmailPlaceholder}',
              prefixIcon: Icons.alternate_email_rounded,
              textInputAction: TextInputAction.next,
              errorText: _identifierError,
              onChanged: (_) => setState(() => _formError = null),
            ),
            const SizedBox(height: AppSpacing.lg),
            PasswordField(
              controller: _password,
              label: l10n.authPassword,
              hint: l10n.authPasswordPlaceholder,
              errorText: _passwordError,
              onSubmitted: (_) => _submit(),
            ),
            if (_formError != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              _ErrorBanner(message: _formError!),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              label: l10n.authLogin,
              loading: _busy,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Flexible on the text so a long translation wraps instead of pushing the
            // link off the edge; the row is only as wide as it needs to be, so
            // it centres as a pair.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    l10n.authNoAccount,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  // Registration has to end up in the same place sign-in does,
                  // or the applicant loses the form they were sent here for.
                  onPressed: () {
                    final String? from = authReturnPath(widget.from);
                    context.push(
                      from == null
                          ? '/auth/sign-up'
                          : '/auth/sign-up?from=${Uri.encodeQueryComponent(from)}',
                    );
                  },
                  child: Text(l10n.authRegister),
                ),
              ],
            ),
            // No "forgot password" link: the API has no reset endpoint, and a
            // dead link on the primary sign-in screen is worse than none.
          ],
        ),
      ),
    );
  }
}

/// Inline API error. The server's `message` is already localised per request
/// language, so it is shown verbatim.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Public so the sign-up and setup screens reuse the same styling.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => _ErrorBanner(message: message);
}
