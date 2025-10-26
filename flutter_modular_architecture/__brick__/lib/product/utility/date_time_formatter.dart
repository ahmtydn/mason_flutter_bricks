import 'package:intl/intl.dart';

class DateTimeFormatter {
  String formatWithSeconds(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }
}
