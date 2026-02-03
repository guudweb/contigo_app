import 'package:flutter/material.dart';
import '../data/phases.dart';
import '../theme/app_theme.dart';

class PhaseIndicator extends StatelessWidget {
  final String phase;
  final int cycleDay;
  final bool isCompact;

  const PhaseIndicator({
    super.key,
    required this.phase,
    required this.cycleDay,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final phaseData = phases[phase]!;

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: phaseData.bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(phaseData.icon, size: 16, color: phaseData.color),
            const SizedBox(width: 6),
            Text(
              phaseData.name,
              style: TextStyle(
                color: phaseData.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: phaseData.bgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              phaseData.icon,
              size: 28,
              color: phaseData.color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Día $cycleDay',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: phaseData.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        phaseData.intensity,
                        style: TextStyle(
                          color: phaseData.bgColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  phaseData.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phaseData.desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PhaseChip extends StatelessWidget {
  final String phase;
  final bool isSelected;

  const PhaseChip({
    super.key,
    required this.phase,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final phaseData = phases[phase]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? phaseData.color : phaseData.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: phaseData.color,
          width: isSelected ? 0 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            phaseData.icon,
            size: 14,
            color: isSelected ? Colors.white : phaseData.color,
          ),
          const SizedBox(width: 4),
          Text(
            phaseData.name,
            style: TextStyle(
              color: isSelected ? Colors.white : phaseData.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
