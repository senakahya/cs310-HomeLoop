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
        AppRoutes.login: (context) => Scaffold(
              appBar: AppBar(title: const Text('HomeLoop')),
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AppRoutes.chooseHousehold),
                  child: const Text('Set up your household'),
                ),
              ),
            ),
        AppRoutes.main: (_) => Scaffold(
              appBar: AppBar(title: const Text('HomeLoop')),
              body: Center(
                child: Text(HomeStore.instance.household?.name ?? 'HomeLoop'),
              ),
            ),
      },
    );
  }
}
