import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeloop/data/home_store.dart';
import 'package:homeloop/models/household.dart';
import 'package:homeloop/routes/app_routes.dart';
import 'package:homeloop/theme/app_theme.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  final store = HomeStore.instance;
  setUp(store.resetDemo);

  Future<void> openHome(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      initialRoute: AppRoutes.main,
      routes: {
        ...AppRoutes.mainRoutes,
        ...AppRoutes.householdRoutes,
        ...AppRoutes.authRoutes,
      },
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('Name opens settings directly; arrow creates and switches homes',
      (tester) async {
    await openHome(tester);
    await tester.tap(find.byTooltip('View household'));
    await tester.pumpAndSettle();
    expect(find.text('Invite code'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Switch household'));
    await tester.pumpAndSettle();
    expect(find.text('Your households'), findsOneWidget);
    final checked = tester.widgetList<CheckedPopupMenuItem<String>>(
        find.byType(CheckedPopupMenuItem<String>));
    expect(checked.single.checked, isTrue);
    await tester.tap(find.text('Create a household'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Weekend Home');
    await tester.tap(find.text('Create household'));
    await tester.pumpAndSettle();
    expect(store.households, hasLength(2));
    expect(find.text('Weekend Home'), findsOneWidget);
    expect(store.shoppingItems, isEmpty);

    await tester.tap(find.byTooltip('Switch household'));
    await tester.pumpAndSettle();
    expect(find.text('Sunny Flat'), findsOneWidget);
    expect(find.text('Join with a code'), findsOneWidget);
    await tester.tap(find.byWidgetPredicate((widget) =>
        widget is CheckedPopupMenuItem<String> && widget.value == '482913'));
    await tester.pumpAndSettle();
    expect(store.household?.name, 'Sunny Flat');
    expect(store.shoppingItems, isNotEmpty);
    expect(
        Navigator.of(tester.element(find.byTooltip('View household'))).canPop(),
        isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Leaving one home returns to the other and rejoining restores data',
      (tester) async {
    store.createHousehold('A household with a long name', Currency.all[1]);
    final second = store.household!;
    store.addShoppingItem('Coffee', 1, 'pack');
    await openHome(tester, width: 320);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('View household'));
    await tester.pumpAndSettle();
    final leave = find.text('Leave household');
    await tester.scrollUntilVisible(leave, 200);
    await tester.tap(leave);
    await tester.pumpAndSettle();
    expect(find.textContaining('switch to Sunny Flat'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.household, same(second));
    await tester.tap(leave);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: leave));
    await tester.pumpAndSettle();
    expect(store.household?.name, 'Sunny Flat');
    expect(store.households, hasLength(1));

    await tester.tap(find.byTooltip('Switch household'));
    await tester.pumpAndSettle();
    expect(find.text(second.name), findsNothing);
    await tester.tap(find.text('Join with a code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), second.inviteCode);
    await tester.pump();
    await tester.tap(find.text('Join household'));
    await tester.pumpAndSettle();
    expect(store.household, same(second));
    expect(store.shoppingItems.single.name, 'Coffee');
    expect(store.households, hasLength(2));
    expect(tester.takeException(), isNull);
  });
}
