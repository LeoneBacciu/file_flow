import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateMisc {
  static DateTime parse(String date) => DateFormat('dd/MM/yyyy').parse(date);

  static String format(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
}

extension DateTimeRangeContainsExtension on DateTimeRange {
  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }
}
