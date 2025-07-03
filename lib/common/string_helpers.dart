import 'package:intl/intl.dart';

String formatMoney(num amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );
  return formatter.format(amount);
}
