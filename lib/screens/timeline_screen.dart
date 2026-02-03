import 'package:flutter/material.dart';
import '../data/phases.dart';
import '../models/cycle_config.dart';
import '../services/cycle_service.dart';
import '../theme/app_theme.dart';

class TimelineScreen extends StatelessWidget {
  final CycleInfo cycleInfo;
  final CycleConfig config;

  const TimelineScreen({
    super.key,
    required this.cycleInfo,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final cycleLength = cycleInfo.cycleLength;
    final periodLength = cycleInfo.periodLength;
    final currentDay = cycleInfo.cycleDay;

    // Calculate grid rows
    final numRows = (cycleLength / 7).ceil();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 100,
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
                    padding: const EdgeInsets.fromLTRB(56, 8, 20, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Calendario del ciclo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Día $currentDay de $cycleLength',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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
                // Phase legend
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leyenda de fases',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: phases.entries.map((entry) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: entry.value.bgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  entry.value.icon,
                                  size: 14,
                                  color: entry.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  entry.value.name,
                                  style: TextStyle(
                                    color: entry.value.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Calendar grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: List.generate(numRows, (rowIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (colIndex) {
                            final dayNum = rowIndex * 7 + colIndex + 1;
                            if (dayNum > cycleLength) {
                              return const SizedBox(width: 44, height: 56);
                            }

                            final dayPhase = CycleService.getPhaseForDay(
                              dayNum,
                              cycleLength,
                              periodLength,
                            );
                            final dayPhaseData = phases[dayPhase]!;
                            final isToday = dayNum == currentDay;

                            return Container(
                              width: 44,
                              height: 56,
                              decoration: BoxDecoration(
                                color: dayPhaseData.bgColor,
                                borderRadius: BorderRadius.circular(10),
                                border: isToday
                                    ? Border.all(
                                        color: AppTheme.primary,
                                        width: 2.5,
                                      )
                                    : null,
                                boxShadow: isToday
                                    ? [
                                        BoxShadow(
                                          color:
                                              AppTheme.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
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
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Icon(
                                    dayPhaseData.icon,
                                    size: 16,
                                    color: dayPhaseData.color,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                // Phase descriptions
                const Text(
                  'Descripción de fases',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                ...phases.entries.map((entry) {
                  final phase = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: phase.color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: phase.bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            phase.icon,
                            color: phase.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                phase.name,
                                style: TextStyle(
                                  color: phase.color,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                phase.desc,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: phase.bgColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  phase.intensity,
                                  style: TextStyle(
                                    color: phase.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
