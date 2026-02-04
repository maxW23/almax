class DateUtilsFunction {
  /// حساب الوقت المتبقي حتى اليوم الأول من الشهر القادم.
  static String calculateTimeUntilNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final duration = nextMonth.difference(now);

    if (duration.isNegative) return "00:00:00:00"; // إذا انتهى الوقت المتبقي

    final days = duration.inDays.toString().padLeft(2, '0');
    final hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return "$days:$hours:$minutes:$seconds";
  }
}
