import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/transaction.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/msisdn.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_fields.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/data/preferences_controller.dart';

final FutureProviderFamily<PaymentLink, String> paymentLinkProvider =
    FutureProvider.family<PaymentLink, String>(
      (Ref ref, String token) =>
          ref.read(apiClientProvider).paymentLinks.resolve(token),
    );

/// The result of the payment the user just made, keyed by link token.
///
/// `POST /payment-links/r/:token/pay` returns a reference that the public
/// resolve payload does not contain, so it is parked here for the redirect back
/// to `/pay/:token`. The link is then re-resolved, which is what makes the
/// settled screen authoritative rather than trusting local state.
final StateProviderFamily<PaymentResult?, String> lastPaymentResultProvider =
    StateProvider.family<PaymentResult?, String>(
      (Ref ref, String token) => null,
    );

/// Settle a payment link.
///
/// Public on purpose: `/pay/:token` is the one screen a buyer can complete
/// without an account, exactly as the website allows. No gateway is wired
/// server-side, so the confirmation says the payment was *recorded*, never that
/// a bank confirmed it.
class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({required this.token, super.key});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PaymentLink> value = ref.watch(paymentLinkProvider(token));

    return value.when(
      loading: () => const Scaffold(body: AppSkeletonList()),
      error: (Object error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorState(
          error: error,
          onRetry: () => ref.invalidate(paymentLinkProvider(token)),
        ),
      ),
      data: (PaymentLink link) {
        if (link.status == PaymentLinkStatus.paid) {
          return _Settled(
            link: link,
            result: ref.read(lastPaymentResultProvider(token)),
          );
        }
        if (link.status == PaymentLinkStatus.expired) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).paymentTitle),
            ),
            body: AppEmptyState(
              title: AppLocalizations.of(context).paymentExpires,
              icon: Icons.timer_off_outlined,
            ),
          );
        }
        if (link.status == PaymentLinkStatus.cancelled) {
          // Terminal, but not paid: showing the pay form here would invite the
          // user to pay a link the payee already withdrew.
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).paymentTitle),
            ),
            body: AppEmptyState(
              title: AppLocalizations.of(context).paymentCancelled,
              icon: Icons.cancel_outlined,
            ),
          );
        }
        return _PayForm(link: link, token: token);
      },
    );
  }
}

class _PayForm extends ConsumerStatefulWidget {
  const _PayForm({required this.link, required this.token});

  final PaymentLink link;
  final String token;

  @override
  ConsumerState<_PayForm> createState() => _PayFormState();
}

class _PayFormState extends ConsumerState<_PayForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  MobileMoneyProvider _provider = MobileMoneyProvider.lumicash;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _busy = true);

    try {
      final PaymentResult result = await ref
          .read(apiClientProvider)
          .paymentLinks
          .pay(
            token: widget.token,
            provider: _provider,
            // The API wants the bare 8-digit national number.
            payerPhone: nationalMsisdn(_phone.text),
          );
      if (!mounted) return;
      // Re-resolve so the settled screen comes from the server's view of the
      // link, not from the optimistic local copy.
      ref.read(lastPaymentResultProvider(widget.token).notifier).state = result;
      ref.invalidate(paymentLinkProvider(widget.token));
      context.go('/pay/${widget.token}');
    } on Object {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnack.show(context, l10n.errorGeneric, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final Formatters f = Formatters(l10n.localeName);
    final AppCurrency currency = ref.watch(
      preferencesProvider.select((PreferencesState s) => s.currency),
    );
    final double rate =
        ref.watch(exchangeRateProvider).valueOrNull?.usdToBif ??
        AppConfig.fallbackUsdToBif;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.lg,
            AppSpacing.pageMargin,
            AppSpacing.huge,
          ),
          children: <Widget>[
            if (widget.link.propertyImage != null) ...<Widget>[
              AppImage(
                url: widget.link.propertyImage,
                height: 160,
                width: double.infinity,
                borderRadius: AppRadii.brLg,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (widget.link.propertyTitle.isNotEmpty)
              Text(
                widget.link.propertyTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: AppSpacing.lg),
            _Field(
              label: l10n.paymentAmountDue,
              value: f.price(
                widget.link.amount,
                widget.link.currency,
                currency,
                rate,
              ),
              emphasise: true,
            ),
            if (widget.link.payeeName.isNotEmpty)
              _Field(label: l10n.paymentPayee, value: widget.link.payeeName),
            if (widget.link.note != null && widget.link.note!.isNotEmpty)
              _Field(label: l10n.paymentTitle, value: widget.link.note!),
            if (widget.link.expiresAt != null)
              _Field(
                label: l10n.paymentExpires,
                value: f.dateTime(widget.link.expiresAt),
              ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.paymentMethod,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: p.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final MobileMoneyProvider provider
                    in MobileMoneyProvider.values)
                  AppChip(
                    // The API value is an enum name; the user should read
                    // "Lumicash" and see it in Lumicash's own red.
                    label: _providerLabel(l10n, provider),
                    selectedColor: _providerColor(provider),
                    selected: _provider == provider,
                    onTap: () => setState(() => _provider = provider),
                  ),
              ],
            ),
            // The dialling code and the network are what a payer actually looks
            // for when matching a screenshot from their handset to the operator
            // they are paying through.
            _Field(
              label: l10n.paymentMethod,
              value: '${_provider.ussd} · ${_provider.network}',
            ),
            const SizedBox(height: AppSpacing.lg),
            PhoneField(
              controller: _phone,
              label: l10n.paymentPayerPhone,
              // The form used to validate nothing here, so a malformed number
              // was sent to the API and came back as a server error.
              validator: (String? value) => isValidBurundiMsisdn(value ?? '')
                  ? null
                  : l10n.paymentPhoneInvalid,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: l10n.paymentConfirm,
              loading: _busy,
              onPressed: _busy ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            // The API records the payment without a gateway, so the app is
            // explicit rather than implying a bank confirmation.
            Text(
              l10n.paymentRecordedNote,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Localized operator name.
String _providerLabel(AppLocalizations l10n, MobileMoneyProvider provider) =>
    switch (provider) {
      MobileMoneyProvider.lumicash => l10n.payProviderLUMICASH,
      MobileMoneyProvider.ecocash => l10n.payProviderECOCASH,
      MobileMoneyProvider.ihela => l10n.payProviderIHELA,
    };

/// The operator's own brand colour.
Color _providerColor(MobileMoneyProvider provider) => switch (provider) {
  MobileMoneyProvider.lumicash => AppColors.lumicash,
  MobileMoneyProvider.ecocash => AppColors.ecocash,
  MobileMoneyProvider.ihela => AppColors.ihela,
};

class _Settled extends ConsumerWidget {
  const _Settled({required this.link, this.result});

  final PaymentLink link;
  final PaymentResult? result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Formatters f = Formatters(l10n.localeName);
    final String reference = result?.paymentReference ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentTitle)),
      body: ListView(
        padding: AppSpacing.page,
        children: <Widget>[
          const SizedBox(height: AppSpacing.xxl),
          const Center(
            child: Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: AppColors.verified,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              l10n.paymentSuccess,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (reference.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                '${l10n.paymentReference} $reference',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          if (result?.paidAt != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                f.dateTime(result!.paidAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPalette.of(context).textSecondary,
                ),
              ),
            ),
          ],
          if (result?.propertyMarkedSold == true) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            AppBadge.semantic(
              'verified',
              label: l10n.propertySold,
              icon: Icons.sell_outlined,
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          if (link.propertyId.isNotEmpty)
            AppButton.primary(
              label: l10n.propertySimilar,
              onPressed: () =>
                  context.pushReplacement('/property/${link.propertyId}'),
            ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppPalette.of(context).textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: emphasise
                ? Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
