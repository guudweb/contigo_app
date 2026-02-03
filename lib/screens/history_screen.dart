import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/phases.dart';
import '../models/cycle_config.dart';
import '../models/history_entry.dart';
import '../services/cycle_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final CycleConfig config;

  const HistoryScreen({
    super.key,
    required this.config,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, List<HistoryEntry>> _groupedHistory = {};
  int _totalMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _groupedHistory = StorageService.getHistoryGroupedByDate();
      _totalMessages = StorageService.getTotalMessagesSent();
    });
  }

  String _getShareMethodIcon(String method) {
    switch (method) {
      case 'whatsapp':
        return '📱';
      case 'telegram':
        return '✈️';
      case 'copy':
        return '📋';
      default:
        return '✉️';
    }
  }

  String _formatDate(String dateKey) {
    final parts = dateKey.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == yesterday) {
      return 'Ayer';
    } else {
      return DateFormat('EEEE d MMMM', 'es').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate completion percentage
    final daysWithMessages = _groupedHistory.length;
    final completionPercent = daysWithMessages > 0
        ? ((_totalMessages / (daysWithMessages * 3)) * 100).clamp(0, 100).toInt()
        : 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with stats
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.send,
                                value: _totalMessages.toString(),
                                label: 'Mensajes enviados',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.calendar_today,
                                value: '$daysWithMessages',
                                label: 'Días activos',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          if (_groupedHistory.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay mensajes enviados',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tus mensajes aparecerán aquí',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dateKey = _groupedHistory.keys.toList()[index];
                    final entries = _groupedHistory[dateKey]!;

                    // Get phase for this date
                    final dateParts = dateKey.split('-');
                    final date = DateTime(
                      int.parse(dateParts[0]),
                      int.parse(dateParts[1]),
                      int.parse(dateParts[2]),
                    );
                    final cycleInfo = CycleService.getCycleInfo(
                      widget.config.lastPeriodDate,
                      widget.config.cycleLength,
                      widget.config.periodLength,
                    );

                    // Calculate phase for this specific date
                    final diffDays = date
                        .difference(DateTime(
                          widget.config.lastPeriodDate.year,
                          widget.config.lastPeriodDate.month,
                          widget.config.lastPeriodDate.day,
                        ))
                        .inDays;
                    final cycleDay =
                        (diffDays % widget.config.cycleLength) + 1;
                    final phase = CycleService.getPhaseForDay(
                      cycleDay,
                      widget.config.cycleLength,
                      widget.config.periodLength,
                    );
                    final phaseData = phases[phase]!;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: phaseData.bgColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(11),
                                topRight: Radius.circular(11),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  phaseData.icon,
                                  color: phaseData.color,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDate(dateKey),
                                        style: TextStyle(
                                          color: phaseData.color,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        phaseData.name,
                                        style: TextStyle(
                                          color: phaseData.color.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${entries.length} mensaje${entries.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: phaseData.color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Entries
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.success.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: AppTheme.success,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.category,
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              entry.prompt,
                                              style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _getShareMethodIcon(entry.shareMethod),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: _groupedHistory.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
