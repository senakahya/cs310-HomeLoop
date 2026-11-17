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
import '../../widgets/feedback_widgets.dart';
import '../../widgets/headers.dart';

/// S15 · Shared expenses – history, totals and the way to Balances.
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    void add() => Navigator.of(context).pushNamed(AppRoutes.expenseForm);

    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final all = store.expensesSorted;
          final thisWeek = all.where((e) => Fmt.daysFromToday(e.date) > -7).toList();
          final earlier = all.where((e) => Fmt.daysFromToday(e.date) <= -7).toList();
          final balance = store.balances[store.currentUserId] ?? 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.tabBarSpace),
            children: [
              LargeTitleHeader(
                title: 'Expenses',
                subtitle: Text('Split equally · ${store.members.length} members'),
                trailing: CircleIconButton(icon: Icons.add_rounded, dark: true, tooltip: 'Add expense', onTap: add),
              ),
              if (all.isEmpty)
                EmptyState( // S15·a
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.indigo,
                  background: AppColors.indigoSoft,
                  title: 'No expenses yet',
                  message: 'Log a shared purchase or bill and HomeLoop splits it equally between members.',
                  buttonLabel: 'Add first expense',
                  onPressed: add,
                )
              else ...[
                _SummaryCard(
                  total: store.totalExpenses,
                  share: store.shareOf(store.totalExpenses),
                  paid: store.paidBy(store.currentUserId),
                  balance: balance,
                  currency: store.currency,
                  onBalances: () => Navigator.of(context).pushNamed(AppRoutes.balances),
                ),
                if (thisWeek.isNotEmpty) ...[
                  const SectionHeader(title: 'This week'),
                  _ExpenseGroup(expenses: thisWeek),
                ],
                if (earlier.isNotEmpty) ...[
                  const SectionHeader(title: 'Earlier'),
                  _ExpenseGroup(expenses: earlier),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double total;
  final double share;
  final double paid;
  final double balance;
  final String currency;
  final VoidCallback onBalances;

  const _SummaryCard({
    required this.total,
    required this.share,
    required this.paid,
    required this.balance,
    required this.currency,
    required this.onBalances,
  });

  @override
  Widget build(BuildContext context) {
    String balanceText = 'everyone is settled';
    if (balance > 0.009) balanceText = "you're owed ${Fmt.moneyShort(balance, currency)}";
    if (balance < -0.009) balanceText = 'you owe ${Fmt.moneyShort(-balance, currency)}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.indigo, Color(0xFF7377EA)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Open expenses', style: AppTextStyles.caption.copyWith(color: AppColors.whiteMuted)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(Fmt.money(total, currency),
                          style: AppTextStyles.amount.copyWith(color: Colors.white, fontSize: 28)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Your share ${Fmt.moneyShort(share, currency)}',
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('You paid ${Fmt.moneyShort(paid, currency)}',
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Material(
            color: const Color(0x29FFFFFF),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onBalances,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.balance_rounded, size: 17, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Balances · $balanceText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(color: Colors.white),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseGroup extends StatelessWidget {
  final List<Expense> expenses;
  const _ExpenseGroup({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (int i = 0; i < expenses.length; i++) ...[
            if (i > 0) const RowDivider(),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.expenseDetail, arguments: expenses[i].id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    IconTile(
                      icon: expenses[i].category.icon,
                      background: AppColors.indigoSoft,
                      foreground: AppColors.indigo,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(expenses[i].title,
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyStrong),
                          const SizedBox(height: 2),
                          Text(
                            'Paid by ${store.displayName(expenses[i].paidById)} · ${Fmt.day(expenses[i].date)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Fmt.moneyShort(expenses[i].amount, store.currency), style: AppTextStyles.bodyStrong),
                        Text(
                          'your share ${Fmt.moneyShort(store.shareOf(expenses[i].amount), store.currency)}',
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
