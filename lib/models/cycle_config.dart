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

  CycleConfig({
    this.partnerName,
    required this.lastPeriodDate,
    this.cycleLength = 28,
    this.periodLength = 5,
  });
}
