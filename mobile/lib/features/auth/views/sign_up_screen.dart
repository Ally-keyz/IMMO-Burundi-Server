import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/msisdn.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_controller.dart';
import 'sign_in_screen.dart';

/// Create an account.
///
/// The API takes first name, last name, phone, email and password
/// (`POST /auth/register`). Name is split on the first space so a single field
/// still produces the two the API wants.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _busy = false;
  bool _agreed = false;
  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _formError;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// Minimum the API accepts; mirrored here so the user is not told "invalid"
  /// by the server after typing a password the form could have flagged.
  static const int _minPassword = 8;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final AppLocalizations l10n = AppLocalizations.of(context);

    final String name = _name.text.trim();
    final String phoneText = _phone.text.trim();
    final String email = _email.text.trim();

    final String? nameError = name.isEmpty ? l10n.authNameRequired : null;
    final String? phoneError = isValidBurundiMsisdn(phoneText)
        ? null
        : l10n.authPhoneRequired;
    final String? emailError =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : '${l10n.authEmail} ${l10n.commonRequired}';
    final String? passwordError = _password.text.length < _minPassword
        ? l10n.authPasswordPlaceholder
        : null;
    final String? confirmError = _confirm.text != _password.text
        ? l10n.authPasswordMismatch
        : null;

    setState(() {
      _nameError = nameError;
      _phoneError = phoneError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
      _formError = null;
    });
    if (nameError != null ||
        phoneError != null ||
        emailError != null ||
        passwordError != null ||
        confirmError != null) {
      return;
    }
    if (!_agreed) {
      setState(() => _formError = l10n.authTerms);
      return;
    }

    final List<String> parts = name.split(RegExp(r'\s+'));
    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            firstName: parts.first,
            lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
            phone: normalizeMsisdn(phoneText),
            email: email,
            password: _password.text,
          );
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
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: <Widget>[
            Text(l10n.authSignUpTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.authSignUpSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              controller: _name,
              label: l10n.authFullName,
              hint: l10n.authNamePlaceholder,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              errorText: _nameError,
            ),
            const SizedBox(height: AppSpacing.lg),
            PhoneField(
              controller: _phone,
              label: l10n.authPhone,
              hint: l10n.authPhonePlaceholder,
              errorText: _phoneError,
            ),
            const SizedBox(height: AppSpacing.lg),
            EmailField(
              controller: _email,
              label: l10n.authEmail,
              hint: l10n.authEmailPlaceholder,
              errorText: _emailError,
            ),
            const SizedBox(height: AppSpacing.lg),
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
            const SizedBox(height: AppSpacing.lg),
            _TermsCheckbox(
              value: _agreed,
              l10n: l10n,
              onChanged: (bool value) => setState(() => _agreed = value),
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
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(l10n.authHasAccount, style: theme.textTheme.bodyMedium),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.authLogin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.l10n,
    required this.onChanged,
  });

  final bool value;
  final AppLocalizations l10n;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: (bool? v) => onChanged(v ?? false),
              activeColor: AppColors.brand,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.brSm),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodySmall,
                children: <InlineSpan>[
                  TextSpan(text: '${l10n.authTermsPrefix} '),
                  TextSpan(
                    text: l10n.authTermsLink,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: null,
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
