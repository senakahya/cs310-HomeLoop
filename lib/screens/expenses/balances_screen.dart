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
import '../../widgets/headers.dart';
import '../../widgets/member_avatar.dart';

/// S18 · Balances – net balance of every member and suggested payments.
/// When nobody owes anything, the "All settled up" state is shown (S18·a).
class BalancesScreen extends StatelessWidget {
  const BalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final balances = store.balances;
            final payments = store.suggestedPayments;
            final mine = balances[store.currentUserId] ?? 0;
            final settled = payments.isEmpty;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              children: [
                const ScreenHeader(title: 'Balances'),
                const SizedBox(height: AppSpacing.sm),
                if (settled)
                  const _AllSettled()
                else
                  _PositionCard(balance: mine, currency: store.currency),
                const SectionHeader(title: 'Net balances'),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      for (int i = 0; i < store.members.length; i++) ...[
                        if (i > 0) const RowDivider(),
                        _BalanceRow(
                          name: store.members[i].id == store.currentUserId
                              ? '${store.members[i].name} (you)'
                              : store.members[i].name,
                          avatar: MemberAvatar(member: store.members[i], size: 36),
                          value: balances[store.members[i].id] ?? 0,
                          currency: store.currency,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!settled) ...[
                  SectionHeader(title: 'Suggested payments · ${payments.length}'),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                    child: Column(
                      children: [
                        for (int i = 0; i < payments.length; i++) ...[
                          if (i > 0) const RowDivider(),
                          _PaymentRow(payment: payments[i]),
                        ],
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.sm, AppSpacing.xs, 0),
                    child: Text('Suggestions keep the number of payments low.', style: AppTextStyles.caption),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  final double balance;
  final String currency;
  const _PositionCard({required this.balance, required this.currency});

  @override
  Widget build(BuildContext context) {
    final owed = balance >= 0;
    final text = owed
        ? "You're owed ${Fmt.moneyShort(balance, currency)}"
        : 'You owe ${Fmt.moneyShort(-balance, currency)}';
    return AppCard(
      color: owed ? AppColors.primaryTint : AppColors.redSoft,
      shadow: false,
      child: Row(
        children: [
          IconTile(
            icon: Icons.handshake_outlined,
            size: 44,
            background: owed ? AppColors.primary : AppColors.red,
            foreground: Colors.white,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your position', style: AppTextStyles.caption),
                Text(
                  text,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 20,
                    color: owed ? AppColors.primary : AppColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllSettled extends StatelessWidget {
  const _AllSettled();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(28)),
            child: const Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('All settled up', style: AppTextStyles.title.copyWith(fontSize: 20)),
          const SizedBox(height: AppSpacing.xs),
          const Text('No payments needed right now.', style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String name;
  final Widget avatar;
  final double value;
  final String currency;

  const _BalanceRow({required this.name, required this.avatar, required this.value, required this.currency});

  @override
  Widget build(BuildContext context) {
    String label = 'Settled';
    Color color = AppColors.muted;
    String amount = Fmt.moneyShort(0, currency);
    if (value > 0.009) {
      label = 'gets back';
      color = AppColors.primary;
      amount = '+${Fmt.moneyShort(value, currency)}';
    } else if (value < -0.009) {
      label = 'owes';
      color = AppColors.red;
      amount = Fmt.moneyShort(value, currency);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyStrong),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(amount, style: AppTextStyles.number.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final SuggestedPayment payment;
  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    final from = store.memberById(payment.fromId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          MemberAvatar(member: from, size: 34),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(from.name, style: AppTextStyles.bodyStrong),
                Text('pays ${store.memberById(payment.toId).name}', style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(Fmt.moneyShort(payment.amount, store.currency), style: AppTextStyles.bodyStrong),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: 'Record',
            small: true,
            expand: false,
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.recordPayment, arguments: payment),
          ),
        ],
      ),
    );
  }
}
