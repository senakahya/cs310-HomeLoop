/// One line of the shared shopping list (S08).
class ShoppingItem {
  final String id;
  String name;
  double quantity;
  String unit;
  final String addedById;

  bool isPurchased;
  String? boughtById;
  DateTime? purchasedOn;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.addedById,
    this.isPurchased = false,
    this.boughtById,
    this.purchasedOn,
  });

  static const List<String> units = ['pcs', 'kg', 'g', 'L', 'pack', 'bottle', 'loaf', 'jar'];
}
