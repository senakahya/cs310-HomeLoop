/// The shared home. Every member of a household sees the same lists.
class Household {
  String name;
  String currencyCode;
  String currencySymbol;
  final String inviteCode;

  Household({
    required this.name,
    required this.currencyCode,
    required this.currencySymbol,
    required this.inviteCode,
  });
}

/// Currencies a household can choose from (S04).
class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency(this.code, this.symbol, this.name);

  static const List<Currency> all = [
    Currency('TRY', '₺', 'Turkish lira'),
    Currency('EUR', '€', 'Euro'),
    Currency('USD', r'$', 'US dollar'),
    Currency('GBP', '£', 'British pound'),
  ];
}
