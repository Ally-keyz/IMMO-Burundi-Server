import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/models/property.dart';
import '../../../core/models/transaction.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Public availability: `GET /visits/sessions/property/:id` needs no session, so
/// a signed-out visitor still sees when viewings are possible.
final FutureProviderFamily<List<VisitSession>, String> visitSessionsProvider =
    FutureProvider.family<List<VisitSession>, String>(
      (Ref ref, String propertyId) =>
          ref.read(apiClientProvider).visits.sessionsForProperty(propertyId),
    );

/// `Send enquiry` sheet. Returns `true` when a real `POST /enquiries` record was
/// created, so the caller can show the confirmation on its own still-mounted
/// context rather than reaching through a popped sheet's context.
Future<bool> showEnquirySheet(
  BuildContext context,
  PropertyDetail property,
) async =>
    await AppSheet.show<bool>(
      context,
      (BuildContext _) => _EnquiryForm(property: property),
    ) ??
    false;

class _EnquiryForm extends ConsumerStatefulWidget {
  const _EnquiryForm({required this.property});

  final PropertyDetail property;

  @override
  ConsumerState<_EnquiryForm> createState() => _EnquiryFormState();
}

class _EnquiryFormState extends ConsumerState<_EnquiryForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _message = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _busy = true);

    try {
      await ref
          .read(apiClientProvider)
          .enquiries
          .create(
            propertyId: widget.property.id,
            subject: _subject.text.trim(),
            message: _message.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on Object {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnack.show(context, l10n.errorGeneric, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.property.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _subject,
              label: l10n.enquirySubject,
              hint: l10n.enquirySubject,
              textInputAction: TextInputAction.next,
              maxLength: 140,
              validator: (String? value) =>
                  (value == null || value.trim().isEmpty)
                  ? l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _message,
              label: l10n.enquiryMessage,
              hint: l10n.enquiryMessage,
              minLines: 4,
              maxLines: 6,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              validator: (String? value) =>
                  (value == null || value.trim().isEmpty)
                  ? l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.primary(
              label: l10n.enquirySend,
              loading: _busy,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// `Book a visit` sheet. Returns the booking reference when a booking was
/// created, so the caller can show the confirmation on its own still-mounted
/// context rather than reaching through a popped sheet's context.
Future<String?> showVisitSheet(
  BuildContext context,
  PropertyDetail property,
) async => await AppSheet.show<String>(
  context,
  (BuildContext _) => _VisitForm(property: property),
);

class _VisitForm extends ConsumerStatefulWidget {
  const _VisitForm({required this.property});

  final PropertyDetail property;

  @override
  ConsumerState<_VisitForm> createState() => _VisitFormState();
}

class _VisitFormState extends ConsumerState<_VisitForm> {
  VisitSession? _session;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  int _people = 1;
  final TextEditingController _notes = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _busy = true);

    try {
      final VisitBooking booking = _session != null
          ? await ref
                .read(apiClientProvider)
                .visits
                .bookSession(
                  visitSessionId: _session!.id,
                  numberOfPeople: _people,
                  notes: _notes.text,
                )
          : await ref
                .read(apiClientProvider)
                .visits
                .bookAnyTime(
                  propertyId: widget.property.id,
                  preferredDate: _date,
                  startTime: formatTimeOfDay(_time),
                  numberOfPeople: _people,
                  notes: _notes.text,
                );

      if (!mounted) return;
      Navigator.of(context).pop(
        booking.bookingReference.isEmpty
            ? l10n.bookingSuccess
            : booking.bookingReference,
      );
    } on Object {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnack.show(context, l10n.errorGeneric, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<VisitSession>> sessions = ref.watch(
      visitSessionsProvider(widget.property.id),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            sessions.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object _, StackTrace _) => Text(
                l10n.errorGeneric,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              data: (List<VisitSession> list) => _Sessions(
                sessions: list,
                selected: _session,
                anyTimeLabel: l10n.bookingAnyTime,
                emptyLabel: l10n.bookingNoSessions,
                onSelect: (VisitSession? session) =>
                    setState(() => _session = session),
              ),
            ),
            if (_session == null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton.secondary(
                      label: l10n.bookingPickDate,
                      icon: Icons.calendar_month_outlined,
                      onPressed: _busy ? null : _pickDate,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton.secondary(
                      label: formatTimeOfDay(_time),
                      icon: Icons.schedule_rounded,
                      onPressed: _busy ? null : _pickTime,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Text(l10n.bookingNumberOfPeople),
                const Spacer(),
                IconButton(
                  onPressed: _people > 1 && !_busy
                      ? () => setState(() => _people--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                Text(
                  '$_people',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: _people < 20 && !_busy
                      ? () => setState(() => _people++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _notes,
              label: l10n.bookingNotes,
              hint: l10n.bookingNotes,
              maxLines: 3,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.primary(
              label: l10n.bookingConfirm,
              loading: _busy,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(now) ? now : _date,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }
}

class _Sessions extends StatelessWidget {
  const _Sessions({
    required this.sessions,
    required this.selected,
    required this.anyTimeLabel,
    required this.emptyLabel,
    required this.onSelect,
  });

  final List<VisitSession> sessions;
  final VisitSession? selected;
  final String anyTimeLabel;
  final String emptyLabel;
  final ValueChanged<VisitSession?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Text(emptyLabel, style: Theme.of(context).textTheme.bodyMedium);
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final VisitSession session in sessions)
          AppChip(
            label: '${session.startTime} – ${session.endTime}',
            selected: selected?.id == session.id,
            // Tapping the live selection clears it and returns to any-time.
            onTap: () => onSelect(selected?.id == session.id ? null : session),
          ),
      ],
    );
  }
}

/// The API takes `startTime` as `HH:mm`.
String formatTimeOfDay(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
