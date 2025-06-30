import 'package:budgetbuddy_project/common/app_strings.dart';
import 'package:intl/intl.dart';

String formatMoney(num amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );
  return formatter.format(amount);
}
