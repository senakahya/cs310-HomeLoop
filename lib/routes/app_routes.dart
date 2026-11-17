import 'package:flutter/material.dart';

import '../screens/household/choose_household_screen.dart';
import '../screens/household/create_household_screen.dart';
import '../screens/household/join_household_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const login = '/';
  static const chooseHousehold = '/household/choose';
  static const createHousehold = '/household/create';
  static const joinHousehold = '/household/join';
  static const main = '/main';

  static const inventoryForm = '/inventory/form';
  static const inventoryDetail = '/inventory/detail';

  static final householdRoutes = <String, WidgetBuilder>{
    chooseHousehold: (_) => const ChooseHouseholdScreen(),
    createHousehold: (_) => const CreateHouseholdScreen(),
    joinHousehold: (_) => const JoinHouseholdScreen(),
  };
}
