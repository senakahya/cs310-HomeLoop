import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeloop/data/home_store.dart';
import 'package:homeloop/main.dart';
import 'package:homeloop/widgets/floating_tab_bar.dart';

void main() {
  setUp(() => HomeStore.instance.leaveHousehold());

  Future<void> openSetup(WidgetTester tester) async {
    await tester.pumpWidget(const HomeLoopApp());
    await tester.enterText(
        find.byType(TextFormField).first, 'test@homeloop.app');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
  }

  testWidgets('Creating a household opens the success destination',
      (tester) async {
    await openSetup(tester);
    await tester.tap(find.text('Create a household'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Test Flat');
    await tester.tap(find.text('Create household'));
    await tester.pumpAndSettle();

    expect(find.text('Test Flat'), findsOneWidget);
    expect(HomeStore.instance.household?.name, 'Test Flat');

    final bar = find.byType(FloatingTabBar);
    for (final (index, icon) in [
      (1, Icons.shopping_cart_outlined),
      (2, Icons.kitchen_outlined),
      (3, Icons.account_balance_wallet_outlined),
      (0, Icons.home_outlined),
    ]) {
      await tester.tap(find.descendant(of: bar, matching: find.byIcon(icon)));
      await tester.pumpAndSettle();
      expect(tester.widget<FloatingTabBar>(bar).currentIndex, index);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Joining allows retry and opens household member management',
      (tester) async {
    await openSetup(tester);
    final joinOption = find.text('Join with a code');
    await tester.scrollUntilVisible(joinOption, 150);
    await tester.tap(joinOption);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pump();
    await tester.tap(find.text('Join household'));
    await tester.pumpAndSettle();

    expect(find.textContaining("This code doesn't match"), findsOneWidget);
    expect(HomeStore.instance.household, isNull);

    await tester.enterText(find.byType(TextField), '482913');
    await tester.pump();
    await tester.tap(find.text('Join household'));
    await tester.pumpAndSettle();

    expect(find.text('Sunny Flat'), findsOneWidget);

    await tester.tap(find.text('Sunny Flat'));
    await tester.pumpAndSettle();
    expect(find.text('Invite code'), findsOneWidget);

    final store = HomeStore.instance;
    final originalMembers = store.members.toList();
    addTearDown(() => store.members
      ..clear()
      ..addAll(originalMembers));

    await tester.tap(find.byTooltip('Member options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from household'));
    await tester.pumpAndSettle();
    expect(store.members, hasLength(originalMembers.length));

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(store.members, hasLength(originalMembers.length - 1));
  });
}
