import 'package:flutter/material.dart';

enum ExpenseCategory { groceries, bills, internet, cleaning, other }

extension ExpenseCategoryX on ExpenseCategory {
  IconData get icon {
    switch (this) {
      case ExpenseCategory.groceries:
        return Icons.shopping_basket_outlined;
      case ExpenseCategory.bills:
        return Icons.bolt_outlined;
      case ExpenseCategory.internet:
        return Icons.wifi_rounded;
      case ExpenseCategory.cleaning:
        return Icons.water_drop_outlined;
      case ExpenseCategory.other:
        return Icons.receipt_long_outlined;
    }
  }
}

/// A shared purchase or bill. It is always split equally between all members.
class Expense {
  final String id;
  String title;
  double amount;
  String paidById;
  DateTime date;
  ExpenseCategory category;
  final String addedById;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidById,
    required this.date,
    required this.addedById,
    this.category = ExpenseCategory.other,
  });
}

/// A payment that was made outside the app (cash, bank transfer).
/// HomeLoop only records it; it never moves money.
class Settlement {
  final String fromId;
  final String toId;
  final double amount;
  final DateTime date;

  const Settlement({
    required this.fromId,
    required this.toId,
    required this.amount,
    required this.date,
  });
}

/// A suggested payment shown on the Balances screen (S18).
class SuggestedPayment {
  final String fromId;
  final String toId;
  final double amount;

  const SuggestedPayment({
    required this.fromId,
    required this.toId,
    required this.amount,
  });
}
