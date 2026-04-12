class AmountFormatter {
  AmountFormatter._(); // prevent instantiation

  /// If whole number → show as int, else show 2 decimal places
  /// 100.0 → "100" | 100.50 → "100.50" | 1000.75 → "1,000.75"
  static String format(double amount) {
    final String formatted = amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);

    return formatted.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  /// Accepts dynamic (int or double) — safe to pass any numeric value
  static String formatDynamic(dynamic amount) {
    if (amount == null) return '0';
    return format((amount as num).toDouble());
  }
}