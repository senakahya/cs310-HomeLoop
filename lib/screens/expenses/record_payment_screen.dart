import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../models/expense.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback_widgets.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';
import '../../widgets/member_avatar.dart';

/// S19 · Record a payment that was already made outside the app.
/// "Record payment" opens the confirmation dialog S19·a.
class RecordPaymentScreen extends StatefulWidget {
  final SuggestedPayment payment;
  const RecordPaymentScreen({super.key, required this.payment});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final HomeStore store = HomeStore.instance;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount =
      TextEditingController(text: widget.payment.amount.toStringAsFixed(2));
  DateTime _date = Fmt.today();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: Fmt.today().subtract(const Duration(days: 60)),
      lastDate: Fmt.today(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _record() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amount.text.replaceAll(',', '.'));
    final from = store.memberById(widget.payment.fromId);
    final to = store.memberById(widget.payment.toId);

    final ok = await showConfirmDialog(
      context,
      title: 'Record ${Fmt.moneyShort(amount, store.currency)} payment?',
      message: '${from.name} → ${to.name}. Balances will update for everyone in ${store.household?.name ?? 'the household'}.',
      confirmLabel: 'Record',
      header: Row(
        children: [
          MemberAvatar(member: from, size: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.arrow_forward_rounded, color: AppColors.faint, size: 18),
          ),
          MemberAvatar(member: to, size: 40),
        ],
      ),
    );
    if (!ok || !mounted) return;
    store.recordPayment(from.id, to.id, amount, _date);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment recorded: ${from.name} → ${to.name}')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final from = store.memberById(widget.payment.fromId);
    final to = store.memberById(widget.payment.toId);
    String who(String name, String id) => id == store.currentUserId ? '$name (you)' : name;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            children: [
              const ScreenHeader(title: 'Record a payment', leadingIcon: Icons.close_rounded),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(child: _Person(label: 'From', name: who(from.name, from.id), avatar: MemberAvatar(member: from, size: 52))),
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 26),
                    Expanded(child: _Person(label: 'To', name: who(to.name, to.id), avatar: MemberAvatar(member: to, size: 52))),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Amount',
                controller: _amount,
                prefixText: '${store.currency} ',
                icon: Icons.payments_outlined,
                helper: 'Suggested amount. You can record a partial payment.',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                validator: (v) {
                  final value = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (value == null) return 'Enter the amount';
                  if (value <= 0) return 'Amount must be more than 0';
                  if (value > widget.payment.amount + 0.001) {
                    return 'Can be at most ${Fmt.money(widget.payment.amount, store.currency)}';
                  }
                  return null;
                },
              ),
              PickerField(label: 'Date', value: Fmt.friendlyDay(_date), onTap: _pickDate),
              const InfoNote(
                tone: NoteTone.warning,
                text: "HomeLoop doesn't move money. Record a payment that was already made in cash or by bank transfer.",
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActions(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancel',
              style: AppButtonStyle.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: 2, child: AppButton(label: 'Record payment', onPressed: _record)),
        ],
      ),
    );
  }
}

class _Person extends StatelessWidget {
  final String label;
  final String name;
  final Widget avatar;

  const _Person({required this.label, required this.name, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        avatar,
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.caption),
        Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyStrong),
      ],
    );
  }
}
