import 'package:flutter/foundation.dart';

import '../models/expense.dart';
import '../models/household.dart';
import '../models/inventory_item.dart';
import '../models/member.dart';
import '../models/shopping_item.dart';
import 'formatters.dart';

/// In-memory data for Step 2.2 (placeholder data, no Firebase yet).
///
/// Screens listen to this object with a ListenableBuilder and rebuild
/// whenever notifyListeners() is called. In Step 3 the lists will come
/// from Cloud Firestore instead.
class HomeStore extends ChangeNotifier {
  HomeStore._() {
    _loadSampleData();
  }

  /// The one shared instance used by every screen.
  static final HomeStore instance = HomeStore._();

  int _nextId = 100;
  String _id(String prefix) => '$prefix${_nextId++}';

  // ---------------------------------------------------------------- members
  final List<Member> members = [];
  String currentUserId = 'sena';
  Household? household;

  Member get currentUser => memberById(currentUserId);

  Member memberById(String id) {
    return members.firstWhere(
      (m) => m.id == id,
      orElse: () => Member(id: id, name: 'Former member', colorHex: '9DA49F'),
    );
  }

  /// "you" for the current user, otherwise the member's name.
  String displayName(String memberId) =>
      memberId == currentUserId ? 'you' : memberById(memberId).name;

  String get currency => household?.currencySymbol ?? '₺';

  void createHousehold(String name, Currency currency) {
    household = Household(
      name: name,
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
      inviteCode: '482913',
    );
    notifyListeners();
  }

  /// Returns false when the code does not belong to a household (S05·a).
  bool joinHousehold(String code) {
    if (code != '482913') return false;
    household ??= Household(
      name: 'Sunny Flat',
      currencyCode: 'TRY',
      currencySymbol: '₺',
      inviteCode: '482913',
    );
    notifyListeners();
    return true;
  }

  void renameHousehold(String name) {
    household?.name = name;
    notifyListeners();
  }

  void removeMember(String memberId) {
    members.removeWhere((m) => m.id == memberId);
    notifyListeners();
  }

  void leaveHousehold() {
    household = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------- shopping
  final List<ShoppingItem> shoppingItems = [];

  List<ShoppingItem> get toBuy =>
      shoppingItems.where((i) => !i.isPurchased).toList();

  List<ShoppingItem> get purchased {
    final list = shoppingItems.where((i) => i.isPurchased).toList();
    list.sort((a, b) => (b.purchasedOn ?? DateTime(2000))
        .compareTo(a.purchasedOn ?? DateTime(2000)));
    return list;
  }

  void addShoppingItem(String name, double quantity, String unit) {
    shoppingItems.insert(
      0,
      ShoppingItem(
        id: _id('s'),
        name: name,
        quantity: quantity,
        unit: unit,
        addedById: currentUserId,
      ),
    );
    notifyListeners();
  }

  void updateShoppingItem(ShoppingItem item, String name, double quantity, String unit) {
    item.name = name;
    item.quantity = quantity;
    item.unit = unit;
    notifyListeners();
  }

  /// Removes the item and returns its old position (used for "Undo").
  int removeShoppingItem(ShoppingItem item) {
    final index = shoppingItems.indexOf(item);
    shoppingItems.remove(item);
    notifyListeners();
    return index;
  }

  void restoreShoppingItem(ShoppingItem item, int index) {
    shoppingItems.insert(index.clamp(0, shoppingItems.length), item);
    notifyListeners();
  }

  /// S10: records who bought the items. It does NOT change inventory or expenses.
  void markPurchased(List<String> itemIds, String buyerId, DateTime date) {
    for (final item in shoppingItems) {
      if (itemIds.contains(item.id)) {
        item.isPurchased = true;
        item.boughtById = buyerId;
        item.purchasedOn = date;
      }
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------- inventory
  final List<InventoryItem> inventory = [];

  /// Sorted by the soonest expiry date; items without a date go last.
  List<InventoryItem> get inventorySorted {
    final list = List<InventoryItem>.from(inventory);
    list.sort((a, b) {
      final ea = a.nextExpiry;
      final eb = b.nextExpiry;
      if (ea == null && eb == null) return a.name.compareTo(b.name);
      if (ea == null) return 1;
      if (eb == null) return -1;
      return ea.compareTo(eb);
    });
    return list;
  }

  List<InventoryItem> get expiringSoon {
    return inventorySorted.where((i) {
      final e = i.nextExpiry;
      return e != null && Fmt.daysFromToday(e) <= 3;
    }).toList();
  }

  InventoryItem? inventoryById(String id) {
    for (final i in inventory) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// Adds food. If the same product already exists in the same place,
  /// the new package becomes a new batch of that product.
  void addInventory({
    required String name,
    required double quantity,
    required String unit,
    required StorageLocation location,
    DateTime? expiry,
  }) {
    final batch = InventoryBatch(id: _id('b'), quantity: quantity, expiry: expiry);
    for (final item in inventory) {
      if (item.name.toLowerCase() == name.toLowerCase() &&
          item.location == location &&
          item.unit == unit) {
        item.batches.add(batch);
        notifyListeners();
        return;
      }
    }
    inventory.add(InventoryItem(
      id: _id('i'),
      name: name,
      unit: unit,
      location: location,
      batches: [batch],
    ));
    notifyListeners();
  }

  void updateInventory({
    required InventoryItem item,
    required InventoryBatch batch,
    required String name,
    required double quantity,
    required String unit,
    required StorageLocation location,
    DateTime? expiry,
  }) {
    item.name = name;
    item.unit = unit;
    item.location = location;
    batch.quantity = quantity;
    batch.expiry = expiry;
    notifyListeners();
  }

  int removeInventoryItem(InventoryItem item) {
    final index = inventory.indexOf(item);
    inventory.remove(item);
    notifyListeners();
    return index;
  }

  void restoreInventoryItem(InventoryItem item, int index) {
    inventory.insert(index.clamp(0, inventory.length), item);
    notifyListeners();
  }

  /// S14: reduces a batch after food is consumed or discarded.
  /// Returns true if the whole product is now used up and removed.
  bool useStock(InventoryItem item, InventoryBatch batch, double amount) {
    batch.quantity = batch.quantity - amount;
    if (batch.quantity <= 0.0001) item.batches.remove(batch);
    final used = item.batches.isEmpty;
    if (used) inventory.remove(item);
    notifyListeners();
    return used;
  }

  // ---------------------------------------------------------------- expenses
  final List<Expense> expenses = [];
  final List<Settlement> settlements = [];

  List<Expense> get expensesSorted {
    final list = List<Expense>.from(expenses);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Expense? expenseById(String id) {
    for (final e in expenses) {
      if (e.id == id) return e;
    }
    return null;
  }

  double get totalExpenses {
    double total = 0;
    for (final e in expenses) {
      total += e.amount;
    }
    return total;
  }

  double shareOf(double amount) => members.isEmpty ? 0 : amount / members.length;

  double paidBy(String memberId) {
    double total = 0;
    for (final e in expenses) {
      if (e.paidById == memberId) total += e.amount;
    }
    return total;
  }

  Expense addExpense({
    required String title,
    required double amount,
    required String paidById,
    required DateTime date,
    ExpenseCategory category = ExpenseCategory.other,
  }) {
    final expense = Expense(
      id: _id('e'),
      title: title,
      amount: amount,
      paidById: paidById,
      date: date,
      category: category,
      addedById: currentUserId,
    );
    expenses.add(expense);
    notifyListeners();
    return expense;
  }

  void updateExpense(Expense e, String title, double amount, String paidById, DateTime date) {
    e.title = title;
    e.amount = amount;
    e.paidById = paidById;
    e.date = date;
    notifyListeners();
  }

  void removeExpense(Expense e) {
    expenses.remove(e);
    notifyListeners();
  }

  /// Net balance of each member: positive = gets money back, negative = owes.
  Map<String, double> get balances {
    final result = <String, double>{};
    for (final m in members) {
      result[m.id] = 0;
    }
    for (final e in expenses) {
      final share = shareOf(e.amount);
      for (final m in members) {
        result[m.id] = result[m.id]! - share;
      }
      if (result.containsKey(e.paidById)) {
        result[e.paidById] = result[e.paidById]! + e.amount;
      }
    }
    for (final s in settlements) {
      if (result.containsKey(s.fromId)) result[s.fromId] = result[s.fromId]! + s.amount;
      if (result.containsKey(s.toId)) result[s.toId] = result[s.toId]! - s.amount;
    }
    // round to cents
    result.updateAll((key, value) => (value * 100).roundToDouble() / 100);
    return result;
  }

  /// A simple way to settle up with few payments: the member who owes the most
  /// pays the member who gets back the most, and so on.
  List<SuggestedPayment> get suggestedPayments {
    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];
    balances.forEach((id, value) {
      if (value < -0.009) debtors.add(MapEntry(id, -value));
      if (value > 0.009) creditors.add(MapEntry(id, value));
    });
    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    final payments = <SuggestedPayment>[];
    int d = 0;
    int c = 0;
    final debt = debtors.map((e) => e.value).toList();
    final credit = creditors.map((e) => e.value).toList();
    while (d < debtors.length && c < creditors.length) {
      final amount = debt[d] < credit[c] ? debt[d] : credit[c];
      payments.add(SuggestedPayment(
        fromId: debtors[d].key,
        toId: creditors[c].key,
        amount: (amount * 100).roundToDouble() / 100,
      ));
      debt[d] -= amount;
      credit[c] -= amount;
      if (debt[d] < 0.01) d++;
      if (credit[c] < 0.01) c++;
    }
    return payments;
  }

  /// S19: records a payment that was made outside the app.
  void recordPayment(String fromId, String toId, double amount, DateTime date) {
    settlements.add(Settlement(fromId: fromId, toId: toId, amount: amount, date: date));
    notifyListeners();
  }

  // ---------------------------------------------------------------- sample data
  void _loadSampleData() {
    final today = Fmt.today();
    DateTime inDays(int n) => today.add(Duration(days: n));

    members.addAll(const [
      Member(id: 'sena', name: 'Sena', colorHex: 'E07A5F', isOwner: true),
      Member(id: 'zisan', name: 'Zişan', colorHex: '3D7DD8'),
      Member(id: 'ebrar', name: 'Ebrar', colorHex: '8E6CCF'),
      Member(id: 'deniz', name: 'Deniz', colorHex: '2A9D8F'),
    ]);

    household = Household(
      name: 'Sunny Flat',
      currencyCode: 'TRY',
      currencySymbol: '₺',
      inviteCode: '482913',
    );

    shoppingItems.addAll([
      ShoppingItem(id: 's1', name: 'Milk', quantity: 2, unit: 'L', addedById: 'zisan'),
      ShoppingItem(id: 's2', name: 'Eggs', quantity: 12, unit: 'pcs', addedById: 'sena'),
      ShoppingItem(id: 's3', name: 'Tomatoes', quantity: 1, unit: 'kg', addedById: 'ebrar'),
      ShoppingItem(id: 's4', name: 'Olive oil', quantity: 1, unit: 'bottle', addedById: 'deniz'),
      ShoppingItem(id: 's5', name: 'Bread', quantity: 1, unit: 'loaf', addedById: 'sena'),
      ShoppingItem(
        id: 's6', name: 'Pasta', quantity: 3, unit: 'pack', addedById: 'zisan',
        isPurchased: true, boughtById: 'ebrar', purchasedOn: inDays(-1),
      ),
      ShoppingItem(
        id: 's7', name: 'Toilet paper', quantity: 1, unit: 'pack', addedById: 'deniz',
        isPurchased: true, boughtById: 'sena', purchasedOn: inDays(-2),
      ),
    ]);

    inventory.addAll([
      InventoryItem(id: 'i1', name: 'Yogurt', unit: 'g', location: StorageLocation.fridge,
          batches: [InventoryBatch(id: 'b1', quantity: 500, expiry: inDays(1))]),
      InventoryItem(id: 'i2', name: 'Milk', unit: 'L', location: StorageLocation.fridge, batches: [
        InventoryBatch(id: 'b2', quantity: 1, expiry: inDays(2)),
        InventoryBatch(id: 'b3', quantity: 2, expiry: inDays(10)),
      ]),
      InventoryItem(id: 'i3', name: 'Eggs', unit: 'pcs', location: StorageLocation.fridge,
          batches: [InventoryBatch(id: 'b4', quantity: 6, expiry: inDays(14))]),
      InventoryItem(id: 'i4', name: 'Chicken breast', unit: 'kg', location: StorageLocation.freezer,
          batches: [InventoryBatch(id: 'b5', quantity: 1, expiry: inDays(38))]),
      InventoryItem(id: 'i5', name: 'Rice', unit: 'kg', location: StorageLocation.pantry,
          batches: [InventoryBatch(id: 'b6', quantity: 2)]),
      InventoryItem(id: 'i6', name: 'Tomato paste', unit: 'jar', location: StorageLocation.pantry,
          batches: [InventoryBatch(id: 'b7', quantity: 1, expiry: inDays(140))]),
    ]);

    expenses.addAll([
      Expense(id: 'e1', title: 'Groceries — Migros', amount: 840, paidById: 'sena',
          date: inDays(-1), addedById: 'sena', category: ExpenseCategory.groceries),
      Expense(id: 'e2', title: 'Internet bill', amount: 480, paidById: 'zisan',
          date: inDays(-3), addedById: 'zisan', category: ExpenseCategory.internet),
      Expense(id: 'e3', title: 'Cleaning supplies', amount: 220, paidById: 'ebrar',
          date: inDays(-5), addedById: 'ebrar', category: ExpenseCategory.cleaning),
      Expense(id: 'e4', title: 'Electricity bill', amount: 660, paidById: 'sena',
          date: inDays(-7), addedById: 'sena', category: ExpenseCategory.bills),
    ]);
  }
}
