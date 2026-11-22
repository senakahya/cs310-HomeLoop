import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeloop/data/home_store.dart';
import 'package:homeloop/main.dart';
import 'package:homeloop/models/household.dart';
import 'package:homeloop/screens/household/choose_household_screen.dart';
import 'package:homeloop/screens/profile/profile_screen.dart';
import 'package:homeloop/screens/shell/main_shell.dart';

void main() {
  final store = HomeStore.instance;
  Household? originalHousehold;

  setUp(() {
    originalHousehold = store.household;
    store.household = null;
    store.joinHousehold('482913');
  });

  tearDown(() => store.household = originalHousehold);

  Future<void> logIn(WidgetTester tester) async {
    await tester.enterText(
        find.byType(TextFormField).first, 'test@homeloop.app');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
  }

  Future<void> openHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HomeLoopApp());
    await logIn(tester);
  }

  testWidgets('Profile signs out without leaving the household',
      (tester) async {
    await openHome(tester);
    final household = store.household;
    final members = store.members.toList();

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text(store.currentUser.name), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(store.household, same(household));
    expect(store.members, orderedEquals(members));
    expect(Navigator.of(tester.element(find.text('Welcome back'))).canPop(),
        isFalse);

    await logIn(tester);
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Sunny Flat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Household shortcut opens S07 with one tap and leaving requires confirmation',
      (tester) async {
    await openHome(tester);
    final household = store.household;
    final expenses = store.expenses.toList();
    final balances = Map<String, double>.from(store.balances);
    final shopping = store.shoppingItems.toList();
    final inventory = store.inventory.toList();

    await tester.tap(find.byTooltip('View household'));
    await tester.pumpAndSettle();
    expect(find.text('Invite code'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);

    final leave = find.text('Leave household');
    await tester.scrollUntilVisible(leave, 200);
    await tester.tap(leave);
    await tester.pumpAndSettle();
    expect(find.text('Leave household?'), findsOneWidget);
    expect(find.textContaining('You will stay signed in'), findsOneWidget);
    expect(store.household, same(household));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.household, same(household));
    expect(find.text('Invite code'), findsOneWidget);

    await tester.tap(leave);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: leave));
    await tester.pumpAndSettle();

    expect(store.household, isNull);
    expect(store.expenses, orderedEquals(expenses));
    expect(store.balances, balances);
    expect(store.shoppingItems, orderedEquals(shopping));
    expect(store.inventory, orderedEquals(inventory));
    expect(find.byType(ChooseHouseholdScreen), findsOneWidget);
    expect(Navigator.of(tester.element(find.text('Set up your home'))).canPop(),
        isFalse);

    final profile = find.text('Profile');
    await tester.scrollUntilVisible(profile, 200);
    await tester.tap(profile);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text(store.currentUser.name), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
