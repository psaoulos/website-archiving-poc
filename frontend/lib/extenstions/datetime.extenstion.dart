extension DateOnlyCompare on DateTime {
  /// Checks if the date called upon is the same day as the [other].
  bool isSameDate(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }
}
