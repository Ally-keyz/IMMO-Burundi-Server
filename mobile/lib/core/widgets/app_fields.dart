import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/utils/msisdn.dart';

/// Text field matching the site's inputs: 12dp radius, field background, no
/// visible label until the field is focused or filled.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.controller,
    super.key,
    this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.enabled = true,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.onSubmitted,
    this.onChanged,
    this.formatter,
    this.autofocus = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final bool enabled;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  /// Fires alongside the widget's own rebuild, so a parent can clear a
  /// form-level error the moment the user starts correcting it.
  final ValueChanged<String>? onChanged;

  final TextInputFormatter? formatter;
  final bool autofocus;

  /// Enquiry messages and notes need a real multi-line box; every other field in
  /// the app is a single line.
  final int minLines;
  final int maxLines;

  /// Optional, because most fields validate in the controller that owns the
  /// submit button. Sheets that only collect a free-text body use it.
  final String? Function(String? value)? validator;

  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;
  late bool _hasText = widget.controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (_hasText != widget.controller.text.isNotEmpty) {
      setState(() => _hasText = widget.controller.text.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obscure and multi-line are mutually exclusive: a hidden field is always
    // one line, so a caller cannot ask for both and get an unreadable box.
    final bool multiline = !widget.obscure && widget.maxLines > 1;

    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: multiline ? TextInputType.multiline : widget.keyboardType,
      textInputAction: multiline
          ? TextInputAction.newline
          : widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: <TextInputFormatter>[
        if (widget.formatter != null) widget.formatter!,
      ],
      onSubmitted: widget.onSubmitted,
      onChanged: (String value) {
        setState(() {});
        widget.onChanged?.call(value);
      },
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        alignLabelWithHint: multiline,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20),
        suffixIcon:
            widget.suffix ??
            (widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null),
      ),
    );
  }
}

/// Burundi phone input: stores `+257…` and formats it the way the site shows
/// it, so the value the user types is the value the API receives.
class PhoneField extends StatelessWidget {
  const PhoneField({
    required this.controller,
    super.key,
    this.label,
    this.hint,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.validator,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onSubmitted;

  /// See [AppTextField.onChanged] - used to clear a server-side field error
  /// while the user is correcting it.
  final ValueChanged<String>? onChanged;
  final String? errorText;

  /// Without this a `Form` containing a [PhoneField] validates nothing, so
  /// `FormState.validate()` reports success on an empty or malformed number.
  final String? Function(String? value)? validator;

  final bool enabled;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: controller,
    label: label,
    hint: hint,
    keyboardType: TextInputType.phone,
    textInputAction: TextInputAction.next,
    prefixIcon: Icons.phone_outlined,
    enabled: enabled,
    errorText: errorText,
    validator: validator,
    onSubmitted: onSubmitted,
    onChanged: onChanged,
    formatter: const MsisdnFormatter(),
  );
}

/// Email input with the same shape as [AppTextField].
class EmailField extends StatelessWidget {
  const EmailField({
    required this.controller,
    super.key,
    this.label,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;

  /// Fires on every keystroke, so a form can track dirtiness and clear a stale
  /// validation error as soon as the user starts fixing it.
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: controller,
    label: label,
    hint: hint,
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    prefixIcon: Icons.mail_outline_rounded,
    enabled: enabled,
    errorText: errorText,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
  );
}

/// Password input with a show/hide toggle.
class PasswordField extends StatelessWidget {
  const PasswordField({
    required this.controller,
    super.key,
    this.label,
    this.hint,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: controller,
    label: label,
    hint: hint,
    obscure: true,
    prefixIcon: Icons.lock_outline_rounded,
    textInputAction: textInputAction,
    enabled: enabled,
    errorText: errorText,
    onSubmitted: onSubmitted,
  );
}

/// Form wrapper: applies the page padding and unfocus-on-tap behaviour so
/// tapping whitespace dismisses the keyboard.
class AppForm extends StatelessWidget {
  const AppForm({
    required this.children,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    behavior: HitTestBehavior.opaque,
    child: ListView(
      padding: padding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          children[i],
        ],
      ],
    ),
  );
}
