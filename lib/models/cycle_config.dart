import 'package:hive/hive.dart';

part 'cycle_config.g.dart';

@HiveType(typeId: 0)
class CycleConfig extends HiveObject {
  @HiveField(0)
  String? partnerName;

  @HiveField(1)
  DateTime lastPeriodDate;

  @HiveField(2)
  int cycleLength;

  @HiveField(3)
  int periodLength;

  @HiveField(4)
  bool notificationsEnabled;

  @HiveField(5)
  int notificationsPerDay;

  @HiveField(6)
  bool usePhaseRecommendation;

  CycleConfig({
    this.partnerName,
    required this.lastPeriodDate,
    this.cycleLength = 28,
    this.periodLength = 5,
    this.notificationsEnabled = true,
    this.notificationsPerDay = 3,
    this.usePhaseRecommendation = true,
  });
}
