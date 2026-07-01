/// Money on the 4U wire is always integer halalas (1 SAR = 100 halalas).
/// This is the only place that converts them for display — widgets must never
/// divide by 100 inline. Integer math throughout: no doubles, no rounding drift.
class Money {
  Money._();

  static const String _arSymbol = 'ر.س';
  static const String _enSymbol = 'SAR';

  /// Amount only, always two decimals: 1250 -> "12.50", -90 -> "-0.90".
  static String amount(int halalas) {
    final sign = halalas < 0 ? '-' : '';
    final abs = halalas.abs();
    final fraction = (abs % 100).toString().padLeft(2, '0');
    return '$sign${abs ~/ 100}.$fraction';
  }

  /// Localized amount with currency: "12.50 ر.س" (ar) / "SAR 12.50" (en).
  static String format(int halalas, {required bool arabic}) => arabic
      ? '${amount(halalas)} $_arSymbol'
      : '$_enSymbol ${amount(halalas)}';

  /// For built widgets that render a riyal double — display only, never math.
  static double asRiyals(int halalas) => halalas / 100;
}
