// ─────────────────────────────────────────────────────────────────────────────
// date_helper.dart  –  Utility functions for formatting dates and times.
//
// We use the `intl` package (by the Dart/Flutter team) for locale-aware
// date formatting. DateFormat patterns follow Java's SimpleDateFormat notation:
//   EEEE = full weekday name  (e.g., "Monday")
//   MMMM = full month name    (e.g., "January")
//   MMM  = short month name   (e.g., "Jan")
//   d    = day of month       (e.g., "5")
//   y    = 4-digit year       (e.g., "2024")
//   HH   = 24-hour hours      (e.g., "22")
//   mm   = minutes            (e.g., "30")
// ─────────────────────────────────────────────────────────────────────────────

import 'package:intl/intl.dart';

/// Static utility class for consistent date and time formatting throughout the app.
class DateHelper {
  /// Formats a DateTime as a full date string.
  ///
  /// Example: DateTime(2024, 4, 15) → "Monday, April 15, 2024"
  ///
  /// Used in sleep history detail screens to show the full date of a record.
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  /// Formats a DateTime as a 24-hour time string.
  ///
  /// Example: DateTime(2024, 4, 15, 22, 30) → "22:30"
  ///
  /// Used when displaying sleep times and wake times.
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Formats a DateTime as a short date abbreviation.
  ///
  /// Example: DateTime(2024, 4, 15) → "Apr 15"
  ///
  /// Used in chart labels and compact history list items.
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Parses a 24-hour time string into a DateTime object.
  ///
  /// Example: "22:30" → DateTime with time 22:30 (date portion is today)
  ///
  /// Used when the backend returns time strings that need to be displayed
  /// using Flutter's time picker or formatted further.
  static DateTime parseTime(String time) {
    return DateFormat('HH:mm').parse(time);
  }
}
