// date_utils.dart
import 'package:intl/intl.dart';

class DateUtils {
  // Format date as "23 November 2021"
  static String formatFullDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  // Format date as "Nov 2021"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  // Calculate days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  // Calculate next period date based on cycle length
  static DateTime calculateNextPeriod(
    DateTime lastPeriodStart,
    int cycleLength,
  ) {
    return lastPeriodStart.add(Duration(days: cycleLength));
  }

  // Get the list of dates for the current week
  static List<DateTime> datesOfWeek(DateTime date) {
    final int weekday = date.weekday;
    return List.generate(
      7,
      (index) => date.subtract(Duration(days: weekday - index - 1)),
    );
  }
}
