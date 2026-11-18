import 'package:flutter/material.dart';

import 'data/home_store.dart';
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
        AppRoutes.main: (context) => Scaffold(
              appBar: AppBar(title: const Text('HomeLoop')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListenableBuilder(
                      listenable: HomeStore.instance,
                      builder: (_, __) => Text(
                        HomeStore.instance.household?.name ?? 'HomeLoop',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.household,
                      ),
                      child: const Text('Manage household'),
                    ),
                  ],
                ),
              ),
            ),
      },
    );
  }
}
