import 'package:intl/intl.dart';

class DateUi {
  static DateTime parse(String date) => DateFormat('dd/MM/yyyy').parse(date);

  static String format(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
}
