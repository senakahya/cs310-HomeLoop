import 'package:flutter/material.dart';

import '../models/shopping_item.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/household/choose_household_screen.dart';
import '../screens/household/create_household_screen.dart';
import '../screens/household/household_screen.dart';
import '../screens/household/join_household_screen.dart';
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

  static const expenseForm = '/expenses/form';
  static const expenseDetail = '/expenses/detail';
  static const balances = '/balances';

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
}
