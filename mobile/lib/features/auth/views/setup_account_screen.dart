import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/responsive.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_controller.dart';
import 'sign_in_screen.dart';

/// Finish setting up an invited account (`immo://setup-account/<token>`).
///
/// The flow mirrors the website: `GET /auth/setup/:token` first, so an expired
/// or already-used link fails with a clear message *before* the user types a
/// password, then `POST /auth/setup` sets it and signs them straight in.
class SetupAccountScreen extends ConsumerStatefulWidget {
  const SetupAccountScreen({required this.token, super.key});

  final String token;

  @override
  ConsumerState<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends ConsumerState<SetupAccountScreen> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _busy = false;
  String? _passwordError;
  String? _confirmError;
  String? _formError;
  String? _email;
  String? _name;
  bool _linkValid = true;

  static const int _minPassword = 8;

  @override
  void initState() {
    super.initState();
    unawaited(_loadInfo());
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _loadInfo() async {
    try {
      final SetupAccountInfo info = await ref
          .read(authControllerProvider.notifier)
          .setupInfo(widget.token);
      if (!mounted) return;
      setState(() {
        _email = info.email;
        _name = <String?>[
          info.firstName,
          info.lastName,
        ].whereType<String>().where((String part) => part.isNotEmpty).join(' ');
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _linkValid = false;
        _formError = e.message;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _linkValid = false;
        _formError = 'Something went wrong.';
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final AppLocalizations l10n = AppLocalizations.of(context);

    final String? passwordError = _password.text.length < _minPassword
        ? l10n.authPasswordPlaceholder
        : null;
    final String? confirmError = _confirm.text != _password.text
        ? l10n.authPasswordMismatch
        : null;

    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
      _formError = null;
    });
    if (passwordError != null || confirmError != null) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .completeSetup(token: widget.token, newPassword: _password.text);
      if (mounted) context.go('/home');
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
      appBar: AppBar(title: Text(l10n.authCreateAccount)),
      body: SafeArea(
        child: ResponsiveScrollView(
          children: <Widget>[
            if (_name != null && _name!.isNotEmpty) ...<Widget>[
              Text(_name!, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (_email != null && _email!.isNotEmpty)
              Text(
                _email!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
            if (!_linkValid) ...<Widget>[
              AuthErrorBanner(message: _formError ?? ''),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: l10n.authLogin,
                onPressed: () => context.pushReplacement('/auth/sign-in'),
              ),
            ] else ...<Widget>[
              PasswordField(
                controller: _password,
                label: l10n.authPassword,
                hint: l10n.authPasswordPlaceholder,
                textInputAction: TextInputAction.next,
                errorText: _passwordError,
              ),
              const SizedBox(height: AppSpacing.lg),
              PasswordField(
                controller: _confirm,
                label: l10n.authConfirmPassword,
                errorText: _confirmError,
                onSubmitted: (_) => _submit(),
              ),
              if (_formError != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                AuthErrorBanner(message: _formError!),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: l10n.authCreateAccount,
                loading: _busy,
                onPressed: _submit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
