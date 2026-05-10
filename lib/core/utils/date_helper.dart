import 'package:intl/intl.dart';

class DateHelper {
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static DateTime parseTime(String time) {
    return DateFormat('HH:mm').parse(time);
  }
}
