import 'package:hive/hive.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 1)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String phase;

  @HiveField(2)
  String category;

  @HiveField(3)
  String prompt;

  @HiveField(4)
  String? message;

  @HiveField(5)
  String shareMethod; // 'copy', 'whatsapp', 'telegram'

  HistoryEntry({
    required this.date,
    required this.phase,
    required this.category,
    required this.prompt,
    this.message,
    required this.shareMethod,
  });
}
