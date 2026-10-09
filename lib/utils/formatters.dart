import 'package:intl/intl.dart';

/// Formats [value] using Indian digit grouping (1,00,000) and the given
/// currency [symbol]. Whole amounts are shown without decimals.
String formatMoney(double value, String symbol, {bool signed = false}) {
  final isWhole = value == value.roundToDouble();
  final fmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: isWhole ? 0 : 2,
  );
  final body = fmt.format(value.abs()).trim();
  final sign = value < 0 ? '-' : (signed && value > 0 ? '+' : '');
  return '$sign$symbol $body';
}

/// Short axis labels: 1.2k, 1L, 2.5Cr ...
String formatCompact(double v) {
  String trim(double n) =>
      n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
  if (v >= 10000000) return '${trim(v / 10000000)}Cr';
  if (v >= 100000) return '${trim(v / 100000)}L';
  if (v >= 1000) return '${trim(v / 1000)}k';
  return trim(v);
}

String formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

/// "Today", "Yesterday" or a date - used to group the transaction list.
String friendlyDay(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat('EEE, dd MMM yyyy').format(d);
}
