import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TabBarItem {
  final String label;
  final IconData icon;
  const TabBarItem(this.label, this.icon);
}

/// Dark floating tab bar. The active tab is a champagne pill with its label.
class FloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<TabBarItem> items = [
    TabBarItem('Home', Icons.home_outlined),
    TabBarItem('Shopping', Icons.shopping_cart_outlined),
    TabBarItem('Inventory', Icons.kitchen_outlined),
    TabBarItem('Expenses', Icons.account_balance_wallet_outlined),
  ];

  const FloatingTabBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(33),
        boxShadow: const [
          BoxShadow(color: Color(0x661F2522), blurRadius: 30, offset: Offset(0, 18), spreadRadius: -14),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              flex: i == currentIndex ? 2 : 1,
              child: Semantics(
                button: true,
                selected: i == currentIndex,
                label: items[i].label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i == currentIndex ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[i].icon,
                          size: 21,
                          color: i == currentIndex ? AppColors.ink : const Color(0x8CFFFFFF),
                        ),
                        if (i == currentIndex) ...[
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              items[i].label,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: AppTextStyles.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
