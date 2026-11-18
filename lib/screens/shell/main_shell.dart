import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../widgets/floating_tab_bar.dart';
import '../expenses/expenses_screen.dart';
import '../home/home_screen.dart';
import '../inventory/inventory_screen.dart';
import '../shopping/shopping_list_screen.dart';

/// The four main tabs (Home · Shopping · Inventory · Expenses)
/// with a floating bottom tab bar.
class MainShell extends StatefulWidget {
  final int initialTab;
  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialTab.clamp(0, FloatingTabBar.items.length - 1);

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: [
              HomeScreen(onOpenTab: _select),
              const ShoppingListScreen(),
              const InventoryScreen(),
              const ExpensesScreen(),
            ],
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 18),
              child: FloatingTabBar(currentIndex: _index, onTap: _select),
            ),
          ),
        ],
      ),
    );
  }
}
