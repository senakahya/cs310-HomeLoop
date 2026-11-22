import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HomeLoopApp());
}

class HomeLoopApp extends StatelessWidget {
  const HomeLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLoop',
      theme: AppTheme.light,
      routes: {
        ...AppRoutes.householdRoutes,
        ...AppRoutes.authRoutes,
        ...AppRoutes.shoppingRoutes,
        ...AppRoutes.expenseRoutes,
        ...AppRoutes.inventoryRoutes,
        ...AppRoutes.mainRoutes,
        ...AppRoutes.recipeRoutes,
      },
    );
  }
}
