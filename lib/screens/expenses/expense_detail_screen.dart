import 'package:flutter/material.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../models/expense.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/headers.dart';
import '../../widgets/member_avatar.dart';
import '../../widgets/status_badge.dart';

/// S17 · Expense detail – who paid and each member's equal share.
class ExpenseDetailScreen extends StatelessWidget {
  final String expenseId;
  const ExpenseDetailScreen({super.key, required this.expenseId});

  Future<void> _delete(BuildContext context, Expense expense) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete this expense?',
      message: '${expense.title} will be removed and everyone\'s balances will be recalculated.',
      confirmLabel: 'Delete',
      danger: true,
      icon: Icons.delete_outline_rounded,
    );
    if (ok && context.mounted) {
      HomeStore.instance.removeExpense(expense);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final expense = store.expenseById(expenseId);
        if (expense == null) {
          return const Scaffold(body: Center(child: Text('This expense was deleted.')));
        }
        final share = store.shareOf(expense.amount);
        final payer = store.memberById(expense.paidById);
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              children: [
                ScreenHeader(
                  title: 'Expense',
                  actions: [
                    CircleIconButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit',
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.expenseForm, arguments: expense.id),
                    ),
                    CircleIconButton(
                      icon: Icons.delete_outline_rounded,
                      iconColor: AppColors.red,
                      tooltip: 'Delete',
                      onTap: () => _delete(context, expense),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: IconTile(
                    icon: expense.category.icon,
                    size: 54,
                    background: AppColors.indigoSoft,
                    foreground: AppColors.indigo,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(expense.title, textAlign: TextAlign.center, style: AppTextStyles.bodyStrong.copyWith(fontSize: 16)),
                Text(Fmt.money(expense.amount, store.currency),
                    textAlign: TextAlign.center, style: AppTextStyles.amount.copyWith(fontSize: 34)),
                Text(
                  '${Fmt.dayYear(expense.date)} · added by ${store.memberById(expense.addedById).name}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Row(
                    children: [
                      MemberAvatar(member: payer, size: 38),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Paid by', style: AppTextStyles.caption),
                            Text(
                              payer.id == store.currentUserId ? '${payer.name} (you)' : payer.name,
                              style: AppTextStyles.bodyStrong,
                            ),
                          ],
                        ),
                      ),
                      Text(Fmt.moneyShort(expense.amount, store.currency), style: AppTextStyles.bodyStrong),
                    ],
                  ),
                ),
                SectionHeader(
                  title: 'Split equally · ${store.members.length} × ${Fmt.moneyShort(share, store.currency)}',
                ),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      for (int i = 0; i < store.members.length; i++) ...[
                        if (i > 0) const RowDivider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              MemberAvatar(member: store.members[i], size: 32),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  store.members[i].id == store.currentUserId
                                      ? '${store.members[i].name} (you)'
                                      : store.members[i].name,
                                  style: AppTextStyles.bodyStrong,
                                ),
                              ),
                              StatusBadge(
                                text: store.members[i].id == expense.paidById ? 'paid' : 'owes ${payer.name}',
                                tone: store.members[i].id == expense.paidById ? BadgeTone.success : BadgeTone.warning,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(Fmt.moneyShort(share, store.currency), style: AppTextStyles.bodyStrong),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
          bottomNavigationBar: BottomActions(
            children: [
              Expanded(
                child: AppButton(
                  label: 'View balances',
                  icon: Icons.balance_rounded,
                  style: AppButtonStyle.secondary,
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.balances),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
