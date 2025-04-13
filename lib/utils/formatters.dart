import 'package:intl/intl.dart';

class Formatters {
  // Format currency amount
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format date to readable format
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format date with time
  static String formatDateWithTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(date);
  }

  // Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 10) return phoneNumber;

    return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
  }
}
