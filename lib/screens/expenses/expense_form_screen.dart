import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../models/expense.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';
import '../../widgets/member_avatar.dart';

/// S16 · Add / edit a shared expense. It is always split equally.
class ExpenseFormScreen extends StatefulWidget {
  /// null = new expense, otherwise edit this expense.
  final String? expenseId;
  const ExpenseFormScreen({super.key, this.expenseId});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final HomeStore store = HomeStore.instance;
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _title = TextEditingController();
  late String _paidById = store.currentUserId;
  DateTime _date = Fmt.today();
  Expense? _editing;

  @override
  void initState() {
    super.initState();
    final id = widget.expenseId;
    if (id != null) {
      _editing = store.expenseById(id);
      final e = _editing;
      if (e != null) {
        _amount.text = e.amount.toStringAsFixed(2);
        _title.text = e.title;
        _paidById = e.paidById;
        _date = e.date;
      }
    }
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    super.dispose();
  }

  double get _amountValue => double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: Fmt.today().subtract(const Duration(days: 365)),
      lastDate: Fmt.today(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final title = _title.text.trim();
    final editing = _editing;
    if (editing != null) {
      store.updateExpense(editing, title, _amountValue, _paidById, _date);
      Navigator.of(context).pop();
    } else {
      final created = store.addExpense(title: title, amount: _amountValue, paidById: _paidById, date: _date);
      // Save → S17 (expense detail)
      Navigator.of(context).pushReplacementNamed(AppRoutes.expenseDetail, arguments: created.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final share = store.shareOf(_amountValue);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            children: [
              ScreenHeader(
                title: _editing == null ? 'Add expense' : 'Edit expense',
                leadingIcon: Icons.close_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Amount',
                controller: _amount,
                hint: '0.00',
                prefixText: '${store.currency} ',
                icon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                validator: (v) {
                  final value = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (value == null) return 'Enter the amount';
                  if (value <= 0) return 'Amount must be more than 0';
                  if (value > 1000000) return 'Amount is too large';
                  return null;
                },
              ),
              AppTextField(
                label: 'Description',
                controller: _title,
                hint: 'e.g. Water delivery',
                icon: Icons.receipt_long_outlined,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Add a short description';
                  if (value.length > 40) return 'Use 40 characters or fewer';
                  return null;
                },
              ),
              PickerField(label: 'Date', value: Fmt.friendlyDay(_date), onTap: _pickDate),
              const FieldLabel('Paid by'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final m in store.members)
                    PillChip(
                      label: m.id == store.currentUserId ? 'You' : m.name,
                      selected: m.id == _paidById,
                      leading: MemberAvatar(member: m, size: 24),
                      onTap: () => setState(() => _paidById = m.id),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Split equally', style: AppTextStyles.bodyStrong),
                              Text('Between all ${store.members.length} members', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Text(Fmt.money(share, store.currency), style: AppTextStyles.number.copyWith(fontSize: 17)),
                        const Text(' each', style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AvatarStack(members: store.members),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xl),
                child: Text('Uneven splits are an optional extension (not in the core scope).',
                    style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
              ),
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
          Expanded(child: AppButton(label: 'Save', onPressed: _save)),
        ],
      ),
    );
  }
}
