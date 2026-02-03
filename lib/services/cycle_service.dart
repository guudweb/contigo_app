class CycleInfo {
  final int cycleDay;
  final String phase;
  final int cycleLength;
  final int periodLength;
  final int daysUntilPeriod;

  CycleInfo({
    required this.cycleDay,
    required this.phase,
    required this.cycleLength,
    required this.periodLength,
    required this.daysUntilPeriod,
  });
}

class CycleService {
  static CycleInfo getCycleInfo(
      DateTime lastPeriod, int cycleLength, int periodLength) {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final startNormalized =
        DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day);

    final diffDays = todayNormalized.difference(startNormalized).inDays;
    final cycleDay = (diffDays % cycleLength) + 1;

    final ovDay = cycleLength - 14;
    String phase;

    if (cycleDay <= periodLength) {
      phase = 'menstrual';
    } else if (cycleDay <= ovDay - 2) {
      phase = 'follicular';
    } else if (cycleDay <= ovDay + 2) {
      phase = 'ovulation';
    } else if (cycleDay <= cycleLength - 6) {
      phase = 'luteal_early';
    } else {
      phase = 'luteal_late';
    }

    final daysUntilPeriod = cycleLength - cycleDay + 1;

    return CycleInfo(
      cycleDay: cycleDay,
      phase: phase,
      cycleLength: cycleLength,
      periodLength: periodLength,
      daysUntilPeriod: daysUntilPeriod,
    );
  }

  static String getPhaseForDay(int dayNum, int cycleLength, int periodLength) {
    final ovDay = cycleLength - 14;
    if (dayNum <= periodLength) return 'menstrual';
    if (dayNum <= ovDay - 2) return 'follicular';
    if (dayNum <= ovDay + 2) return 'ovulation';
    if (dayNum <= cycleLength - 6) return 'luteal_early';
    return 'luteal_late';
  }

  static DateTime getDateForCycleDay(
      DateTime lastPeriod, int cycleLength, int targetDay) {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final startNormalized =
        DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day);

    final diffDays = todayNormalized.difference(startNormalized).inDays;
    final currentCycleDay = (diffDays % cycleLength) + 1;

    final daysDiff = targetDay - currentCycleDay;
    return todayNormalized.add(Duration(days: daysDiff));
  }
}
