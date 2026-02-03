import 'package:hive_flutter/hive_flutter.dart';
import '../models/cycle_config.dart';
import '../models/history_entry.dart';

class StorageService {
  static const String configBoxName = 'config';
  static const String historyBoxName = 'history';
  static const String configKey = 'cycle_config';

  static late Box<CycleConfig> _configBox;
  static late Box<HistoryEntry> _historyBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CycleConfigAdapter());
    Hive.registerAdapter(HistoryEntryAdapter());

    _configBox = await Hive.openBox<CycleConfig>(configBoxName);
    _historyBox = await Hive.openBox<HistoryEntry>(historyBoxName);
  }

  // Config methods
  static CycleConfig? getConfig() {
    return _configBox.get(configKey);
  }

  static Future<void> saveConfig(CycleConfig config) async {
    await _configBox.put(configKey, config);
  }

  static Future<void> deleteConfig() async {
    await _configBox.delete(configKey);
  }

  static bool hasConfig() {
    return _configBox.containsKey(configKey);
  }

  // History methods
  static List<HistoryEntry> getHistory() {
    return _historyBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<HistoryEntry> getHistoryForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _historyBox.values.where((entry) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      return entryDate == dateOnly;
    }).toList();
  }

  static List<HistoryEntry> getTodayHistory() {
    return getHistoryForDate(DateTime.now());
  }

  static Future<void> addHistoryEntry(HistoryEntry entry) async {
    await _historyBox.add(entry);
  }

  static int getTotalMessagesSent() {
    return _historyBox.length;
  }

  static int getTodayMessagesSent() {
    return getTodayHistory().length;
  }

  static Set<String> getTodaySentCategories() {
    return getTodayHistory().map((e) => e.category).toSet();
  }

  static bool isCategorySentToday(String category) {
    return getTodaySentCategories().contains(category);
  }

  static Map<String, List<HistoryEntry>> getHistoryGroupedByDate() {
    final history = getHistory();
    final grouped = <String, List<HistoryEntry>>{};

    for (final entry in history) {
      final dateKey = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(entry);
    }

    return grouped;
  }
}
