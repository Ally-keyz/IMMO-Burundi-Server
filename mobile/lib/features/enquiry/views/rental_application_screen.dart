import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/responsive.dart';
import '../../../core/models/property.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../auth/data/auth_state.dart';
import '../data/enquiry_providers.dart';

/// `POST /api/rental-applications`.
///
/// Every field here is required by the API and none of them can be inferred on
/// the server from the session: the applicant is applying to live in someone
/// else's flat, so the agent needs the household, not the account holder's name.
/// The profile pre-fills what it knows (name, phone, email) so the common case
/// is three fields and a date.
///
/// `advanceAvailable` is a boolean the API requires, so it is asked as a yes/no
/// choice rather than left out — an unanswered switch silently posts `false`,
/// which reads to an agent as "no advance", the worst possible default.
class RentalApplicationScreen extends ConsumerStatefulWidget {
  const RentalApplicationScreen({
    required this.propertyId,
    this.property,
    super.key,
  });

  final String propertyId;
  final PropertySummary? property;

  @override
  ConsumerState<RentalApplicationScreen> createState() =>
      _RentalApplicationScreenState();
}

class _RentalApplicationScreenState
    extends ConsumerState<RentalApplicationScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _occupation = TextEditingController();
  final TextEditingController _occupants = TextEditingController(text: '1');
  final TextEditingController _children = TextEditingController(text: '0');

  bool _prefilled = false;
  bool _advance = false;
  DateTime? _moveIn;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _occupation.dispose();
    _occupants.dispose();
    _children.dispose();
    super.dispose();
  }

  Future<void> _pickMoveIn() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _moveIn ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) setState(() => _moveIn = picked);
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_moveIn == null) {
      AppSnack.show(
        context,
        AppLocalizations.of(context).applyMoveInRequired,
        isError: true,
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool sent = await ref
        .read(transactionControllerProvider.notifier)
        .applyToRent(
          propertyId: widget.propertyId,
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          address: _address.text.trim(),
          totalOccupants: int.tryParse(_occupants.text.trim()) ?? 1,
          numberOfChildren: int.tryParse(_children.text.trim()) ?? 0,
          occupation: _occupation.text.trim(),
          advanceAvailable: _advance,
          moveInDate: _moveIn!,
        );
    if (!mounted) return;

    if (sent) {
      AppSnack.show(context, l10n.applySubmitted);
      context.pop();
      return;
    }
    final Object? error = ref.read(transactionControllerProvider).error;
    if (error == null) return;

    // The listing can change type between opening the form and submitting it,
    // so the server's rejection still has to read as something the applicant
    // can act on rather than a raw exception.
    if (error is ApiException && error.code == 'NOT_A_RENTAL') {
      AppSnack.show(context, l10n.applyNotARental, isError: true);
      return;
    }
    AppSnack.show(context, _messageFor(error), isError: true);
  }

  /// The API's own message, or a generic one.
  String _messageFor(Object error) =>
      transactionErrorMessage(error, AppLocalizations.of(context).errorGeneric);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    _prefillFromProfile();

    final bool busy = ref.watch(transactionControllerProvider).isLoading;
    final AsyncValue<void> state = ref.watch(transactionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.applicationsRentApplication)),
      body: Form(
        key: _form,
        child: ResponsiveScrollView(
          // Two columns from 840dp: nine fields in one column on a tablet is a
          // very long scroll for what is mostly independent short inputs.
          maxWidth: Breakpoints.isDesktop(context) ? 860 : 640,
          padding: AppSpacing.page,
          children: <Widget>[
            if (widget.property != null) ...<Widget>[
              Text(
                widget.property!.localizedTitle(l10n.localeName),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppTextField(
              controller: _name,
              label: l10n.applyFullName,
              textCapitalization: TextCapitalization.words,
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.md),
            PhoneField(
              controller: _phone,
              label: l10n.applyPhone,
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.md),
            EmailField(
              controller: _email,
              label: l10n.applyEmail,
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _address,
              label: l10n.applyAddress,
              textCapitalization: TextCapitalization.sentences,
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    controller: _occupants,
                    label: l10n.applyOccupants,
                    keyboardType: TextInputType.number,
                    validator: _count,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: _children,
                    label: l10n.applyChildren,
                    keyboardType: TextInputType.number,
                    validator: _count,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _occupation,
              label: l10n.applyOccupation,
              textCapitalization: TextCapitalization.sentences,
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.md),
            _MoveInField(value: _moveIn, onTap: _pickMoveIn),
            SwitchListTile.adaptive(
              value: _advance,
              onChanged: (bool v) => setState(() => _advance = v),
              title: Text(
                l10n.applyAdvanceAvailable,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                l10n.applyAdvanceHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            if (state.hasError) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              _FormError(
                error: state.error!,
                messageFor: _messageFor,
                onDismiss: () =>
                    ref.read(transactionControllerProvider.notifier).reset(),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              label: l10n.commonSubmit,
              loading: busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  /// Fills name, phone and email from the session once.
  ///
  /// The API wants the applicant's details, not the account holder's, so the
  /// fields are editable — but typing a name and an email the user already gave
  /// us is busywork with a typo risk, and it is the same three values on every
  /// application.
  void _prefillFromProfile() {
    if (_prefilled) return;
    final AuthState auth = ref.read(authControllerProvider);
    if (auth.user == null) return;
    _prefilled = true;

    final AppUser user = auth.user!;
    if (_name.text.isEmpty) _name.text = user.fullName;
    if (_phone.text.isEmpty) _phone.text = user.phone;
    if (_email.text.isEmpty) _email.text = user.email;
    if (_address.text.isEmpty && user.address != null) {
      _address.text = user.address!;
    }
  }

  String? _required(String? value) => (value == null || value.trim().isEmpty)
      ? AppLocalizations.of(context).validationRequired
      : null;

  /// Counts must be whole numbers, and occupants cannot be zero — a household of
  /// nobody is not an application, and the API would reject it after the upload.
  String? _count(String? value) {
    final int? n = int.tryParse((value ?? '').trim());
    if (n == null) return AppLocalizations.of(context).validationNumber;
    if (n < 0) return AppLocalizations.of(context).validationNumber;
    return null;
  }
}

/// An inline failure notice inside the form.
///
/// [AppErrorState] is the wrong widget here: it is a full-page state with a
/// "retry" action, and retrying a failed *submission* would re-post it. This
/// reports what went wrong and lets the applicant fix it and press submit again.
class _FormError extends StatelessWidget {
  const _FormError({
    required this.error,
    required this.messageFor,
    required this.onDismiss,
  });

  final Object error;
  final String Function(Object error) messageFor;
  final VoidCallback onDismiss;

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
              messageFor(error),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            color: theme.colorScheme.onErrorContainer,
            icon: const Icon(Icons.close_rounded),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          ),
        ],
      ),
    );
  }
}

class _MoveInField extends StatelessWidget {
  const _MoveInField({required this.value, required this.onTap});

  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Formatters f = Formatters(l10n.localeName);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.applyMoveInDate,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          value == null ? l10n.applyMoveInPick : f.date(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? Theme.of(context).hintColor : null,
          ),
        ),
      ),
    );
  }
}
