import 'package:intl/intl.dart';

class NumberFormatter {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  /// Formats a number as currency with thousand separators
  /// Example: 1234.56 -> "Rp 1,234.56"
  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  /// Formats a number with thousand separators (no currency symbol)
  /// Example: 1234.56 -> "1,234.56"
  static String formatNumber(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }
}