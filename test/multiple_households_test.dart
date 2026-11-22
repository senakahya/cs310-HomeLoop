import 'package:flutter_test/flutter_test.dart';
import 'package:homeloop/data/home_store.dart';
import 'package:homeloop/models/expense.dart';
import 'package:homeloop/models/household.dart';
import 'package:homeloop/models/inventory_item.dart';
import 'package:homeloop/models/member.dart';

void main() {
  test('Switching preserves separate household data, currencies and ownership',
      () {
    final store = HomeStore.demo();
    final first = store.household!;
    final firstMembers = store.members.toList();
    final firstShopping = store.shoppingItems.toList();
    final firstInventory = store.inventory.toList();
    final firstExpenses = store.expenses.toList();
    final firstBalances = Map<String, double>.from(store.balances);

    store.createHousehold('Weekend Home', Currency.all[1]);
    final second = store.household!;
    expect(store.households, [first, second]);
    expect(second.inviteCode, isNot(first.inviteCode));
    expect(second.inviteCode, matches(RegExp(r'^\d{6}$')));
    expect(store.currentUser.name, 'Sena');
    expect(store.currentUser.isOwner, isTrue);
    expect(store.members, hasLength(1));
    expect(store.currency, '€');
    expect(store.shoppingItems, isEmpty);
    expect(store.inventory, isEmpty);
    expect(store.expenses, isEmpty);
    expect(store.settlements, isEmpty);

    store.addShoppingItem('Coffee', 1, 'pack');
    store.addInventory(
        name: 'Rice',
        quantity: 2,
        unit: 'kg',
        location: StorageLocation.pantry);
    final expense = store.addExpense(
        title: 'Weekend groceries',
        amount: 25,
        paidById: store.currentUserId,
        date: DateTime(2026, 11, 22),
        category: ExpenseCategory.groceries);
    store.members.add(
        const Member(id: 'roommate', name: 'Roommate', colorHex: '3D7DD8'));
    store.recordPayment('sena', 'roommate', 1, DateTime(2026, 11, 22));
    store.renameHousehold('Weekend Home Updated');

    expect(store.switchHousehold(first.inviteCode), isTrue);
    expect(store.household, same(first));
    expect(store.members, orderedEquals(firstMembers));
    expect(store.shoppingItems, orderedEquals(firstShopping));
    expect(store.inventory, orderedEquals(firstInventory));
    expect(store.expenses, orderedEquals(firstExpenses));
    expect(store.balances, firstBalances);
    expect(store.settlements, isEmpty);
    expect(store.currency, '₺');

    expect(store.switchHousehold(second.inviteCode), isTrue);
    expect(store.household?.name, 'Weekend Home Updated');
    expect(store.shoppingItems.single.name, 'Coffee');
    expect(store.inventory.single.name, 'Rice');
    expect(store.expenses.single, same(expense));
    expect(store.settlements, hasLength(1));
    expect(store.currency, '€');
  });

  test(
      'Joining and leaving affect only the selected membership, preserving history',
      () {
    final store = HomeStore.demo();
    final first = store.household!;
    final expenses = store.expenses.toList();
    final balances = Map<String, double>.from(store.balances);
    store.createHousehold('Second Home', Currency.all.first);
    final second = store.household!;

    expect(store.joinHousehold('000000'), isFalse);
    expect(store.switchHousehold('000000'), isFalse);
    expect(store.household, same(second));
    expect(store.joinHousehold(first.inviteCode), isTrue);
    expect(store.joinHousehold(first.inviteCode), isTrue);
    expect(store.households, hasLength(2));

    store.leaveHousehold();
    expect(store.household, same(second));
    expect(store.households, [second]);
    expect(store.switchHousehold(first.inviteCode), isFalse);
    expect(store.shoppingItems, isEmpty);
    expect(store.joinHousehold(first.inviteCode), isTrue);
    expect(store.expenses, orderedEquals(expenses));
    expect(store.balances, balances);

    store.leaveHousehold();
    store.leaveHousehold();
    expect(store.household, isNull);
    expect(store.households, isEmpty);
    expect(store.currentUser.name, 'Sena');
    expect(store.currentUser.isOwner, isFalse);
    expect(store.expenses, isEmpty);
    expect(store.joinHousehold(second.inviteCode), isTrue);
    expect(store.household, same(second));
    expect(store.members, hasLength(1));
  });
}
