import 'package:flutter/material.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/headers.dart';
import '../../widgets/member_avatar.dart';

/// S06 · Home – daily overview of the household.
class HomeScreen extends StatelessWidget {
  /// Switches the bottom tab (1 = Shopping, 2 = Inventory, 3 = Expenses).
  final ValueChanged<int> onOpenTab;

  const HomeScreen({super.key, required this.onOpenTab});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final toBuy = store.toBuy;
          final expiring = store.expiringSoon;
          final balance = store.balances[store.currentUserId] ?? 0;
          final payments = store.suggestedPayments.length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm,
                AppSpacing.screen, AppSpacing.tabBarSpace),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Tooltip(
                        message: 'View household',
                        child: Material(
                          color: AppColors.surface,
                          shape: const StadiumBorder(
                            side: BorderSide(color: AppColors.line),
                          ),
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.household),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.home_outlined, size: 16),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      store.household?.name ?? 'Household',
                                      style: AppTextStyles.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded,
                                      size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    tooltip: 'Profile',
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profile),
                    icon: MemberAvatar(member: store.currentUser, size: 42),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('${_greeting()},\n${store.currentUser.name}',
                  style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.lg),
              _BalanceHero(
                balance: balance,
                currency: store.currency,
                payments: payments,
                onSettle: () =>
                    Navigator.of(context).pushNamed(AppRoutes.balances),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SummaryTile(
                      icon: Icons.shopping_cart_outlined,
                      color: AppColors.primary,
                      background: AppColors.primarySoft,
                      count: toBuy.length,
                      label: 'items to buy',
                      detail: toBuy.isEmpty
                          ? 'Nothing to buy right now'
                          : toBuy.take(3).map((i) => i.name).join(', ') +
                              (toBuy.length > 3
                                  ? ' and ${toBuy.length - 3} more'
                                  : ''),
                      onTap: () => onOpenTab(1),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SummaryTile(
                      icon: Icons.kitchen_outlined,
                      color: AppColors.amber,
                      background: AppColors.amberSoft,
                      count: expiring.length,
                      label: 'expiring soon',
                      detail: expiring.isEmpty
                          ? 'Nothing expires in the next 3 days'
                          : expiring
                              .take(2)
                              .map((i) =>
                                  '${i.name} ${Fmt.expiry(i.nextExpiry).toLowerCase()}')
                              .join(' · '),
                      onTap: () => onOpenTab(2),
                    ),
                  ),
                ],
              ),
              const SectionHeader(title: 'Quick actions'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(
                    icon: Icons.add_rounded,
                    label: 'Add to list',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.shoppingItem),
                  ),
                  _QuickAction(
                    icon: Icons.kitchen_outlined,
                    label: 'Add food',
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.inventoryForm),
                  ),
                  _QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: 'Add expense',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.expenseForm),
                  ),
                  _QuickAction(
                    icon: Icons.person_add_alt_outlined,
                    label: 'Invite',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.household),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  final double balance;
  final String currency;
  final int payments;
  final VoidCallback onSettle;

  const _BalanceHero({
    required this.balance,
    required this.currency,
    required this.payments,
    required this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    String amount;
    String detail;
    if (balance > 0.009) {
      amount = '+${Fmt.money(balance, currency)}';
      detail =
          "You're owed · $payments suggested payment${payments == 1 ? '' : 's'}";
    } else if (balance < -0.009) {
      amount = Fmt.money(balance, currency);
      detail =
          'You owe · $payments suggested payment${payments == 1 ? '' : 's'}';
    } else {
      amount = Fmt.money(0, currency);
      detail = 'All settled up';
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.hero)),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x1AE6D8BC), width: 22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your balance',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.whiteMuted)),
                      const SizedBox(height: AppSpacing.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          amount,
                          style: AppTextStyles.amount.copyWith(
                            color: balance < -0.009
                                ? const Color(0xFFF0C4C8)
                                : AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(detail,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.whiteMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Material(
                  color: AppColors.accent,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: onSettle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Text('Settle up',
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700)),
                    ),
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

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final int count;
  final String label;
  final String detail;
  final VoidCallback onTap;

  const _SummaryTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.count,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: color),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('$count', style: AppTextStyles.title.copyWith(fontSize: 24)),
              Text(label,
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.ink, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.ink2, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 18,
                        offset: Offset(0, 8),
                        spreadRadius: -10),
                  ],
                ),
                child: Icon(icon, color: AppColors.ink, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.ink2,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
