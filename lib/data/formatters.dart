/// Small helpers that turn numbers and dates into display text.
/// (No extra packages needed.)
class Fmt {
  Fmt._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// 1500 -> "₺1,500.00"
  static String money(double value, String symbol) {
    final negative = value < 0;
    final cents = (value.abs() * 100).round();
    final whole = cents ~/ 100;
    final rest = (cents % 100).toString().padLeft(2, '0');
    return '${negative ? '−' : ''}$symbol${_thousands(whole)}.$rest';
  }

  /// 950 -> "₺950", 12.5 -> "₺12.50"
  static String moneyShort(double value, String symbol) {
    final cents = (value.abs() * 100).round();
    if (cents % 100 == 0) {
      return '${value < 0 ? '−' : ''}$symbol${_thousands(cents ~/ 100)}';
    }
    return money(value, symbol);
  }

  static String _thousands(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  /// 2.0 -> "2", 0.5 -> "0.5"
  static String qty(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
  }

  /// "Nov 4"
  static String day(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  /// "Nov 4, 2026"
  static String dayYear(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

  /// "Today, Nov 4" / "Nov 2"
  static String friendlyDay(DateTime d) {
    if (daysFromToday(d) == 0) return 'Today, ${day(d)}';
    if (daysFromToday(d) == -1) return 'Yesterday, ${day(d)}';
    return day(d);
  }

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static int daysFromToday(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    return date.difference(today()).inDays;
  }

  /// Text for an expiry badge: "Expired", "Today", "Tomorrow", "In 3 days", "Nov 18", "Mar 2027".
  static String expiry(DateTime? d) {
    if (d == null) return 'No expiry date';
    final days = daysFromToday(d);
    if (days < 0) return 'Expired';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days <= 3) return 'In $days days';
    if (d.year != today().year) return '${_months[d.month - 1]} ${d.year}';
    return day(d);
  }
}
