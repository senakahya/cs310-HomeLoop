import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/expenses/balances_screen.dart';
import '../screens/expenses/expense_detail_screen.dart';
import '../screens/expenses/expense_form_screen.dart';
import '../screens/expenses/record_payment_screen.dart';
import '../screens/household/choose_household_screen.dart';
import '../screens/household/create_household_screen.dart';
import '../screens/household/household_screen.dart';
import '../screens/household/join_household_screen.dart';
import '../screens/inventory/inventory_detail_screen.dart';
import '../screens/inventory/inventory_form_screen.dart';
import '../screens/inventory/stock_update_screen.dart';
import '../screens/recipes/recipe_detail_screen.dart';
import '../screens/recipes/recipe_ideas_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/shopping/confirm_purchase_screen.dart';
import '../screens/shopping/shopping_item_form_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const login = '/';
  static const signup = '/signup';
  static const chooseHousehold = '/household/choose';
  static const createHousehold = '/household/create';
  static const joinHousehold = '/household/join';
  static const main = '/main';
  static const household = '/household';

  static const shoppingItem = '/shopping/item';
  static const confirmPurchase = '/shopping/confirm';

  static const inventoryForm = '/inventory/form';
  static const inventoryDetail = '/inventory/detail';
  static const stockUpdate = '/inventory/stock';

  static const expenseForm = '/expenses/form';
  static const expenseDetail = '/expenses/detail';
  static const balances = '/balances';
  static const recordPayment = '/balances/record';

  static const recipeIdeas = '/recipes'; // S20
  static const recipeDetail = '/recipes/detail'; // S21

  static final mainRoutes = <String, WidgetBuilder>{
    main: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return MainShell(initialTab: args is int ? args : 0);
    },
  };

  static final householdRoutes = <String, WidgetBuilder>{
    chooseHousehold: (_) => const ChooseHouseholdScreen(),
    createHousehold: (_) => const CreateHouseholdScreen(),
    joinHousehold: (_) => const JoinHouseholdScreen(),
    household: (_) => const HouseholdScreen(),
  };

  static final authRoutes = <String, WidgetBuilder>{
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
  };

  static final shoppingRoutes = <String, WidgetBuilder>{
    shoppingItem: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return ShoppingItemFormScreen(item: args is ShoppingItem ? args : null);
    },
    confirmPurchase: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return ConfirmPurchaseScreen(
        itemIds: args is List<String> ? args : const [],
      );
    },
  };

  static final inventoryRoutes = <String, WidgetBuilder>{
    inventoryForm: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return InventoryFormScreen(
        args: args is InventoryFormArgs ? args : const InventoryFormArgs(),
      );
    },
    inventoryDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return InventoryDetailScreen(itemId: args is String ? args : '');
    },
    stockUpdate: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as StockUpdateArgs;
      return StockUpdateScreen(args: args);
    },
  };

  /// S16–S19 · Expenses and balances.
  static final expenseRoutes = <String, WidgetBuilder>{
    expenseForm: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return ExpenseFormScreen(expenseId: args is String ? args : null);
    },
    expenseDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return ExpenseDetailScreen(expenseId: args is String ? args : '');
    },
    balances: (_) => const BalancesScreen(),
    recordPayment: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return RecordPaymentScreen(payment: args as SuggestedPayment);
    },
  };

  /// S20–S21 · Recipe ideas (AI assistant, placeholder data in Step 2.2).
  static final recipeRoutes = <String, WidgetBuilder>{
    recipeIdeas: (_) => const RecipeIdeasScreen(),
    recipeDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return args is Recipe ? RecipeDetailScreen(recipe: args) : const RecipeIdeasScreen();
    },
  };
}
