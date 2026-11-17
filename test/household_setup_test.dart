import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeloop/data/home_store.dart';
import 'package:homeloop/main.dart';

void main() {
  setUp(() => HomeStore.instance.leaveHousehold());

  Future<void> openSetup(WidgetTester tester) async {
    await tester.pumpWidget(const HomeLoopApp());
    await tester.tap(find.text('Set up your household'));
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

    await tester.tap(find.text('Manage household'));
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
