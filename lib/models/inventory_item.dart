import 'package:flutter/material.dart';

enum StorageLocation { fridge, freezer, pantry }

extension StorageLocationX on StorageLocation {
  String get label {
    switch (this) {
      case StorageLocation.fridge:
        return 'Fridge';
      case StorageLocation.freezer:
        return 'Freezer';
      case StorageLocation.pantry:
        return 'Pantry';
    }
  }

  IconData get icon {
    switch (this) {
      case StorageLocation.fridge:
        return Icons.kitchen_outlined;
      case StorageLocation.freezer:
        return Icons.ac_unit_rounded;
      case StorageLocation.pantry:
        return Icons.inventory_2_outlined;
    }
  }
}

/// The same product bought on different days is kept as separate batches,
/// because each batch can have its own expiry date.
class InventoryBatch {
  final String id;
  double quantity;

  /// Date printed on the package. Null = the package has no expiry date.
  DateTime? expiry;

  InventoryBatch({required this.id, required this.quantity, this.expiry});
}

/// A product in the kitchen inventory (S11).
class InventoryItem {
  final String id;
  String name;
  String unit;
  StorageLocation location;
  final List<InventoryBatch> batches;

  InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.location,
    required this.batches,
  });

  double get totalQuantity {
    double total = 0;
    for (final b in batches) {
      total += b.quantity;
    }
    return total;
  }

  /// The soonest expiry date of all batches (null if no batch has a date).
  DateTime? get nextExpiry {
    DateTime? soonest;
    for (final b in batches) {
      final e = b.expiry;
      if (e != null && (soonest == null || e.isBefore(soonest))) {
        soonest = e;
      }
    }
    return soonest;
  }

  static const List<String> units = ['pcs', 'g', 'kg', 'mL', 'L', 'pack', 'jar'];
}
