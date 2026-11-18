import 'package:flutter/material.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/feedback_widgets.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';
import '../../widgets/member_avatar.dart';

/// S10 · Confirm purchase – records WHO bought the selected items and WHEN.
/// It does not add anything to the inventory or expenses automatically.
class ConfirmPurchaseScreen extends StatefulWidget {
  final List<String> itemIds;

  const ConfirmPurchaseScreen({super.key, required this.itemIds});

  @override
  State<ConfirmPurchaseScreen> createState() => _ConfirmPurchaseScreenState();
}

class _ConfirmPurchaseScreenState extends State<ConfirmPurchaseScreen> {
  final HomeStore store = HomeStore.instance;
  late String _buyerId = store.currentUserId;
  DateTime _date = Fmt.today();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: Fmt.today().subtract(const Duration(days: 30)),
      lastDate: Fmt.today(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _confirm() {
    store.markPurchased(widget.itemIds, _buyerId, _date);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final items = store.shoppingItems.where((i) => widget.itemIds.contains(i.id)).toList();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          children: [
            const ScreenHeader(title: 'Confirm purchase'),
            SectionHeader(title: '${items.length} item${items.length == 1 ? '' : 's'}'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const RowDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: Text(items[i].name, style: AppTextStyles.bodyStrong)),
                          Text('${Fmt.qty(items[i].quantity)} ${items[i].unit}', style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SectionHeader(title: 'Who bought these?'),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.md,
              children: [
                for (final m in store.members)
                  GestureDetector(
                    onTap: () => setState(() => _buyerId = m.id),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MemberAvatar(member: m, size: 46, selected: m.id == _buyerId),
                        const SizedBox(height: 6),
                        Text(
                          m.id == store.currentUserId ? 'You' : m.name,
                          style: AppTextStyles.caption.copyWith(
                            color: m.id == _buyerId ? AppColors.ink : AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PickerField(label: 'Date', value: Fmt.friendlyDay(_date), onTap: _pickDate),
            const InfoNote(
              tone: NoteTone.warning,
              text: 'This only updates the shopping list. Add food to Inventory or log the cost in Expenses separately.',
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: BottomActions(
        children: [
          Expanded(
            child: AppButton(
              label: 'Mark as purchased',
              icon: Icons.check_rounded,
              onPressed: items.isEmpty ? null : _confirm,
            ),
          ),
        ],
      ),
    );
  }
}
