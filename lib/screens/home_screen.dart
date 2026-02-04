import 'package:flutter/material.dart';
import '../data/phases.dart';
import '../data/recommendations.dart';
import '../models/cycle_config.dart';
import '../services/cycle_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/phase_indicator.dart';
import '../widgets/recommendation_card.dart';
import 'detail_screen.dart';
import 'history_screen.dart';
import 'setup_screen.dart';
import 'timeline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CycleConfig? _config;
  CycleInfo? _cycleInfo;
  Set<String> _sentCategories = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _scheduleNotifications();
  }

  void _loadData() {
    final config = StorageService.getConfig();
    if (config != null) {
      final cycleInfo = CycleService.getCycleInfo(
        config.lastPeriodDate,
        config.cycleLength,
        config.periodLength,
      );
      setState(() {
        _config = config;
        _cycleInfo = cycleInfo;
        _sentCategories = StorageService.getTodaySentCategories();
      });
    }
  }

  Future<void> _scheduleNotifications() async {
    final config = StorageService.getConfig();
    if (config == null) return;

    final cycleInfo = CycleService.getCycleInfo(
      config.lastPeriodDate,
      config.cycleLength,
      config.periodLength,
    );

    // Get the number of notifications based on settings
    final notificationsCount = config.usePhaseRecommendation
        ? NotificationService.getRecommendedNotifications(cycleInfo.phase)
        : config.notificationsPerDay;

    // Schedule daily notifications
    await NotificationService.scheduleNotifications(
      lastPeriod: config.lastPeriodDate,
      cycleLength: config.cycleLength,
      periodLength: config.periodLength,
      notificationsPerDay: notificationsCount,
      notificationsEnabled: config.notificationsEnabled,
    );

    // Schedule reminder if no messages sent today
    await NotificationService.scheduleReminderIfNeeded(
      notificationsPerDay: notificationsCount,
      notificationsEnabled: config.notificationsEnabled,
    );
  }

  void _navigateToDetail(Recommendation rec) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          recommendation: rec,
          phase: _cycleInfo!.phase,
        ),
      ),
    );
    _loadData(); // Reload to update sent status
  }

  @override
  Widget build(BuildContext context) {
    if (_config == null || _cycleInfo == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final phaseData = phases[_cycleInfo!.phase]!;
    final phaseRecs = recommendations[_cycleInfo!.phase] ?? [];
    final totalRecs = phaseRecs.length;
    final sentCount = phaseRecs
        .where((r) => _sentCategories.contains(r.category))
        .length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/app_icon.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Contigo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SetupScreen(),
                                ),
                              );
                              _loadData();
                            },
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Phase indicator
                      PhaseIndicator(
                        phase: _cycleInfo!.phase,
                        cycleDay: _cycleInfo!.cycleDay,
                      ),

                      // Alert if present
                      if (phaseData.alert != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(
                              color: AppTheme.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppTheme.warning,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  phaseData.alert!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Partner name greeting
                if (_config!.partnerName != null &&
                    _config!.partnerName!.isNotEmpty) ...[
                  Text(
                    'Acompañando a ${_config!.partnerName}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Main recommendation card
                if (phaseRecs.isNotEmpty) ...[
                  HighlightedRecommendationCard(
                    recommendation: phaseRecs.first,
                    phaseColor: phaseData.color,
                    onTap: () => _navigateToDetail(phaseRecs.first),
                  ),
                  const SizedBox(height: 20),
                ],

                // Frequency tip
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: phaseData.bgColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.send,
                        color: phaseData.color,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          phaseData.frequencyTip,
                          style: TextStyle(
                            color: phaseData.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progreso de hoy',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$sentCount de $totalRecs',
                          style: TextStyle(
                            color: phaseData.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalRecs > 0 ? sentCount / totalRecs : 0,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation(phaseData.color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Other recommendations title
                if (phaseRecs.length > 1) ...[
                  const Text(
                    'Otras recomendaciones',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Recommendation list
                ...phaseRecs.skip(1).map(
                      (rec) => RecommendationCard(
                        recommendation: rec,
                        phaseColor: phaseData.color,
                        isSent: _sentCategories.contains(rec.category),
                        onTap: () => _navigateToDetail(rec),
                      ),
                    ),

                const SizedBox(height: 24),

                // Mini timeline
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TimelineScreen(
                          cycleInfo: _cycleInfo!,
                          config: _config!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Próximos 7 días',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Ver calendario',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppTheme.primary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) {
                            final dayNum = ((_cycleInfo!.cycleDay + i - 1) %
                                    _cycleInfo!.cycleLength) +
                                1;
                            final dayPhase = CycleService.getPhaseForDay(
                              dayNum,
                              _cycleInfo!.cycleLength,
                              _cycleInfo!.periodLength,
                            );
                            final dayPhaseData = phases[dayPhase]!;
                            final isToday = i == 0;

                            return Container(
                              width: 40,
                              height: 48,
                              decoration: BoxDecoration(
                                color: dayPhaseData.bgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: isToday
                                    ? Border.all(
                                        color: AppTheme.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayNum.toString(),
                                    style: TextStyle(
                                      color: dayPhaseData.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Icon(
                                    dayPhaseData.icon,
                                    size: 14,
                                    color: dayPhaseData.color,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // History button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(config: _config!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Ver historial de mensajes'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
