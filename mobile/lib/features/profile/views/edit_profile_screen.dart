import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/responsive.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/msisdn.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../auth/data/auth_state.dart';
import '../../auth/views/sign_in_screen.dart';
import '../data/account_provider.dart';

/// Account settings — the mobile equivalent of the website's `SettingsPage`
/// (`apps/web/src/pages/SettingsPage.tsx`).
///
/// Three sections, because those are the three the site exposes that this app
/// does not already cover elsewhere:
///
///  * **Profile photo** — pick, upload to `POST /files/upload`, then save the
///    returned URL with `PATCH /users/:id`. Removing a photo is the same PATCH
///    with an empty `photoUrl`, which is what the site does.
///  * **Personal information** — first name, last name, phone and email.
///  * **Security** — a password change, which needs the current password.
///
/// Appearance, language and currency stay on the settings screen: they are
/// device preferences the site also keeps local, and duplicating them here would
/// mean two places changing the same thing.
///
/// `address` is deliberately absent. It is not in the API's `EDITABLE_FIELDS`,
/// so the server ignores it — a field that silently does nothing is worse than no
/// field at all.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Personal information.
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  // Security.
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  String? _savedPersonal;
  String? _fieldError;
  String? _personalError;
  String? _passwordError;
  String? _photoError;

  bool _savingPersonal = false;
  bool _savingPassword = false;
  bool _busyPhoto = false;

  /// The picked-but-not-yet-uploaded image. The website downscales to a 512px
  /// JPEG before uploading; `image_picker` does the same job natively, which
  /// also keeps the request comfortably under the API's 5 MB cap.
  String? _pendingPhotoPath;

  static const int _minPassword = 8;

  /// `MAX_IMAGE_BYTES` in `apps/api/src/modules/files/files.service.ts`. Checked
  /// before the upload so an oversized file never leaves the device.
  static const int _maxUploadBytes = 5 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    final AppUser user = _readUser() ?? const AppUser(id: '');
    _firstName = TextEditingController(text: user.firstName);
    _lastName = TextEditingController(text: user.lastName);
    _phone = TextEditingController(text: user.phone);
    _email = TextEditingController(text: user.email);
    _savedPersonal = _personalSnapshot();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  /// The signed-in user, watched so the avatar and name update the moment a save
  /// lands — `AuthController.updateUser` replaces the cached user in place.
  AppUser? _readUser() {
    final AuthState auth = ref.read(authControllerProvider);
    return auth is AuthSignedIn ? auth.user : null;
  }

  String _personalSnapshot() =>
      '${_firstName.text.trim()}|${_lastName.text.trim()}|'
      '${_phone.text.trim()}|${_email.text.trim()}';

  bool get _personalDirty => _personalSnapshot() != _savedPersonal;

  /// Clears a validation error the moment the user starts fixing the field.
  void _clearFieldError() {
    if (_fieldError == null) return;
    setState(() => _fieldError = null);
  }

  // ---------------------------------------------------------------------------
  // Personal information
  // ---------------------------------------------------------------------------

  Future<void> _savePersonal() async {
    FocusScope.of(context).unfocus();
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppUser? user = _readUser();
    if (user == null) {
      setState(() => _personalError = l10n.errorGeneric);
      return;
    }

    final String firstName = _firstName.text.trim();
    final String lastName = _lastName.text.trim();
    final String phone = _phone.text.trim();
    final String email = _email.text.trim();

    final bool emailProvided = email.isNotEmpty;
    // `PATCH /users/:id` runs no zod validation, so the shape of these values is
    // this screen's responsibility. The site sends them raw; the app checks them
    // first so a typo is not written to the account.
    final String? fieldError = firstName.isEmpty && lastName.isEmpty
        ? l10n.authNameRequired
        : (!isValidBurundiMsisdn(phone)
              // The site has no "invalid number" string of its own and reuses
              // this one, so the app does the same rather than inventing a key.
              ? l10n.authPhoneRequired
              : (emailProvided && !_emailShape.hasMatch(email)
                    ? l10n.profileEmailInvalid
                    : null));

    setState(() {
      _fieldError = fieldError;
      _personalError = null;
    });
    if (fieldError != null) return;

    setState(() => _savingPersonal = true);
    try {
      final AppUser updated = await ref
          .read(apiClientProvider)
          .users
          .update(
            user.id,
            firstName: firstName,
            lastName: lastName,
            // Stored as the bare national number, which is what sign-up sends and
            // what sign-in and payment look up. The field shows it grouped.
            phone: normalizeMsisdn(phone),
            // Always sent, empty included: the service assigns any field that is
            // present, so omitting it would keep the old value and sending an
            // empty string is how a user clears it.
            email: email.toLowerCase(),
          );
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).updateUser(updated);
      // The counts and the payments/visits tabs all key off the account, so they
      // are told to reload rather than waiting for a pull-to-refresh.
      ref.invalidate(accountSummaryProvider);
      setState(() {
        _fieldError = null;
        _personalError = null;
        _savedPersonal = _personalSnapshot();
      });
      AppSnack.show(context, l10n.profilePersonalSaved);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _personalError = e.message);
    } on Object {
      if (!mounted) return;
      setState(() => _personalError = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _savingPersonal = false);
    }
  }

  /// The same shape the sign-up screen accepts, minus the local part rules that
  /// would reject addresses the API itself accepts.
  static final RegExp _emailShape = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // ---------------------------------------------------------------------------
  // Security
  // ---------------------------------------------------------------------------

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppUser? user = _readUser();
    if (user == null) {
      setState(() => _passwordError = l10n.errorGeneric);
      return;
    }

    final String current = _currentPassword.text;
    final String next = _newPassword.text;

    final String? error = current.isEmpty
        ? l10n.authPasswordRequired
        : (next.length < _minPassword
              ? l10n.profilePasswordTooShort
              : (next != _confirmPassword.text
                    ? l10n.authPasswordMismatch
                    : null));

    setState(() => _passwordError = error);
    if (error != null) return;

    setState(() => _savingPassword = true);
    try {
      await ref
          .read(apiClientProvider)
          .users
          .update(user.id, currentPassword: current, password: next);
      if (!mounted) return;
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      setState(() => _passwordError = null);
      AppSnack.show(context, l10n.dashboardPasswordChanged);
    } on ApiException catch (e) {
      if (!mounted) return;
      // Both are 400s, not 401s: a wrong current password must not end the
      // session, so they are translated rather than shown as server English.
      setState(
        () => _passwordError =
            e.code == ApiException.wrongPassword ||
                e.code == ApiException.currentPasswordRequired
            ? l10n.profileWrongPassword
            : e.message,
      );
    } on Object {
      if (!mounted) return;
      setState(() => _passwordError = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Profile photo
  // ---------------------------------------------------------------------------

  Future<void> _pickPhoto() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _photoError = null);

    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    if (await picked.length() > _maxUploadBytes) {
      setState(() => _photoError = l10n.profilePhotoTooLarge);
      return;
    }
    setState(() => _pendingPhotoPath = picked.path);
  }

  Future<void> _savePhoto() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String path = _pendingPhotoPath ?? '';
    final AppUser? user = _readUser();
    if (path.isEmpty || user == null) return;

    setState(() {
      _busyPhoto = true;
      _photoError = null;
    });
    try {
      final ApiClient api = ref.read(apiClientProvider);
      final String url = await api.files.upload(filePath: path);
      final AppUser updated = await api.users.update(user.id, photoUrl: url);
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).updateUser(updated);
      setState(() {
        _busyPhoto = false;
        _pendingPhotoPath = null;
      });
      AppSnack.show(context, l10n.profilePhotoUpdated);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(
        () => _photoError = switch (e.code) {
          ApiException.unsupportedFileType => l10n.profilePhotoInvalid,
          ApiException.fileTooLarge => l10n.profilePhotoTooLarge,
          ApiException.emptyFile => l10n.profilePhotoFailed,
          _ => e.message,
        },
      );
    } on Object {
      if (!mounted) return;
      setState(() => _photoError = l10n.profilePhotoFailed);
    } finally {
      if (mounted) setState(() => _busyPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppUser? user = _readUser();
    if (user == null) return;

    setState(() {
      _busyPhoto = true;
      _photoError = null;
    });
    try {
      final AppUser updated = await ref
          .read(apiClientProvider)
          .users
          // An empty string is the documented way to drop the photo. Sending
          // null would leave it untouched, because the service only assigns the
          // fields that are present.
          .update(user.id, photoUrl: '');
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).updateUser(updated);
      setState(() {
        _busyPhoto = false;
        _pendingPhotoPath = null;
      });
      AppSnack.show(context, l10n.profilePhotoRemoved);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busyPhoto = false;
        _photoError = e.message;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _busyPhoto = false;
        _photoError = l10n.errorGeneric;
      });
    }
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthState auth = ref.watch(authControllerProvider);

    if (auth is! AuthSignedIn) {
      // The session ended while the screen was open. The global error handler has
      // already signed the user out, so point them at sign-in rather than showing
      // a form that could not save.
      return Scaffold(
        appBar: AppBar(title: Text(l10n.youEditProfile)),
        body: AppEmptyState(
          title: l10n.youSignedOutTitle,
          message: l10n.youSignedOutBody,
          icon: Icons.person_outline_rounded,
          actionLabel: l10n.authLogin,
          onAction: () => context.go('/auth/sign-in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.youEditProfile)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.huge),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: <Widget>[
            ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _PhotoSection(
                    photoUrl: auth.user.photoUrl,
                    pendingPath: _pendingPhotoPath,
                    busy: _busyPhoto,
                    error: _photoError,
                    onPick: _pickPhoto,
                    onSave: _savePhoto,
                    onDiscard: () => setState(() => _pendingPhotoPath = null),
                    onRemove: _removePhoto,
                  ),
                  _PersonalSection(
                    firstName: _firstName,
                    lastName: _lastName,
                    phone: _phone,
                    email: _email,
                    fieldError: _fieldError,
                    error: _personalError,
                    saving: _savingPersonal,
                    dirty: _personalDirty,
                    onChanged: _clearFieldError,
                    onSave: _savePersonal,
                  ),
                  _SecuritySection(
                    current: _currentPassword,
                    next: _newPassword,
                    confirm: _confirmPassword,
                    error: _passwordError,
                    saving: _savingPassword,
                    onSubmit: _changePassword,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card section with a title, a line of explanation and a body — the website's
/// settings panes stacked vertically instead of behind a sidebar.
class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.hint,
    required this.child,
  });

  final String title;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.xl,
        AppSpacing.pageMargin,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(
            hint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photoUrl,
    required this.pendingPath,
    required this.busy,
    required this.error,
    required this.onPick,
    required this.onSave,
    required this.onDiscard,
    required this.onRemove,
  });

  final String? photoUrl;
  final String? pendingPath;
  final bool busy;
  final String? error;
  final VoidCallback onPick;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final VoidCallback onRemove;

  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hasStored = photoUrl != null && photoUrl!.isNotEmpty;

    return _SectionShell(
      title: l10n.profilePhotoSection,
      hint: l10n.profilePhotoHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // A picked file is previewed straight off disk; only a saved photo
              // goes through the network image widget.
              if (pendingPath != null)
                ClipOval(
                  child: Image.file(
                    File(pendingPath!),
                    width: _size,
                    height: _size,
                    fit: BoxFit.cover,
                  ),
                )
              else
                AppImage(
                  url: photoUrl,
                  width: _size,
                  height: _size,
                  borderRadius: AppRadii.brPill,
                  memCacheWidth: 200,
                ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    AppButton.secondary(
                      label: l10n.profilePhotoChoose,
                      icon: Icons.photo_camera_outlined,
                      expand: false,
                      onPressed: busy ? null : onPick,
                    ),
                    if (pendingPath != null) ...<Widget>[
                      AppButton.primary(
                        label: l10n.commonSave,
                        expand: false,
                        loading: busy,
                        onPressed: onSave,
                      ),
                      AppButton.text(
                        label: l10n.commonCancel,
                        expand: false,
                        onPressed: busy ? null : onDiscard,
                      ),
                    ] else if (hasStored)
                      AppButton.text(
                        label: l10n.profilePhotoRemove,
                        expand: false,
                        color: AppColors.danger,
                        onPressed: busy ? null : onRemove,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (busy) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.profilePhotoUploading,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
          if (error != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            AuthErrorBanner(message: error!),
          ],
        ],
      ),
    );
  }
}

class _PersonalSection extends StatelessWidget {
  const _PersonalSection({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.fieldError,
    required this.error,
    required this.saving,
    required this.dirty,
    required this.onChanged,
    required this.onSave,
  });

  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController phone;
  final TextEditingController email;

  /// Client-side validation, shown inline under the fields.
  final String? fieldError;

  /// The server's answer, shown as a banner.
  final String? error;
  final bool saving;
  final bool dirty;

  /// Fires on any keystroke in any of the four fields. The value is not used —
  /// the section only needs to know that something changed, so a stale
  /// validation error can be cleared and the Save button can re-enable.
  final VoidCallback onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return _SectionShell(
      title: l10n.profilePersonalSection,
      hint: l10n.profilePersonalHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppTextField(
            controller: firstName,
            label: l10n.authFirstName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: lastName,
            label: l10n.authLastName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: AppSpacing.lg),
          PhoneField(
            controller: phone,
            label: l10n.authPhone,
            hint: l10n.authPhonePlaceholder,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: AppSpacing.lg),
          EmailField(
            controller: email,
            label: l10n.authEmail,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onSave(),
          ),
          if (fieldError != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              fieldError!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
          if (error != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            AuthErrorBanner(message: error!),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: l10n.commonSave,
            loading: saving,
            // Disabled until something actually changed, so a stray tap cannot
            // fire a no-op PATCH.
            onPressed: dirty && !saving ? onSave : null,
          ),
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({
    required this.current,
    required this.next,
    required this.confirm,
    required this.error,
    required this.saving,
    required this.onSubmit,
  });

  final TextEditingController current;
  final TextEditingController next;
  final TextEditingController confirm;
  final String? error;
  final bool saving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return _SectionShell(
      title: l10n.profileSecuritySection,
      hint: l10n.profileSecurityHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PasswordField(
            controller: current,
            label: l10n.profileCurrentPassword,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          PasswordField(
            controller: next,
            label: l10n.profileNewPassword,
            hint: l10n.profilePasswordHint,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          PasswordField(
            controller: confirm,
            label: l10n.authConfirmPassword,
            onSubmitted: (_) => onSubmit(),
          ),
          if (error != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            AuthErrorBanner(message: error!),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: l10n.commonSave,
            icon: Icons.lock_outline_rounded,
            loading: saving,
            onPressed: saving ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}
