import 'package:flutter/material.dart';

class PhaseData {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String desc;
  final String intensity;
  final String frequencyTip;
  final String? alert;

  const PhaseData({
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.desc,
    required this.intensity,
    required this.frequencyTip,
    this.alert,
  });
}

final Map<String, PhaseData> phases = {
  'menstrual': PhaseData(
    name: 'Menstrual',
    icon: Icons.nightlight_round,
    color: Color(0xFFE11D48),
    bgColor: Color(0xFFFFF1F2),
    desc: 'Energía baja · Sensibilidad alta',
    intensity: 'Muy suave',
    frequencyTip: '2-3 mensajes cortos. Menos palabras, más presencia.',
    alert: 'Mayor riesgo de crisis emocional en personas con depresión',
  ),
  'follicular': PhaseData(
    name: 'Folicular',
    icon: Icons.eco,
    color: Color(0xFF16A34A),
    bgColor: Color(0xFFF0FDF4),
    desc: 'Energía creciente · Optimismo',
    intensity: 'Motivador',
    frequencyTip: 'Buen momento para mensajes más largos y propositivos.',
    alert: null,
  ),
  'ovulation': PhaseData(
    name: 'Ovulación',
    icon: Icons.wb_sunny,
    color: Color(0xFFD97706),
    bgColor: Color(0xFFFFFBEB),
    desc: 'Pico de energía · Confianza',
    intensity: 'Energético',
    frequencyTip: 'Puede recibir bien cumplidos detallados y planes juntos.',
    alert: null,
  ),
  'luteal_early': PhaseData(
    name: 'Lútea',
    icon: Icons.spa,
    color: Color(0xFF7C3AED),
    bgColor: Color(0xFFF5F3FF),
    desc: 'Energía descendente · Autocrítica',
    intensity: 'Gentil',
    frequencyTip: 'Aumenta frecuencia gradualmente. Valida más, exige menos.',
    alert: 'La autocrítica aumenta. Refuerza que lo que hace es suficiente.',
  ),
  'luteal_late': PhaseData(
    name: 'Premenstrual',
    icon: Icons.shield,
    color: Color(0xFF2563EB),
    bgColor: Color(0xFFEFF6FF),
    desc: 'Mayor vulnerabilidad · Ansiedad amplificada',
    intensity: 'Máxima delicadeza',
    frequencyTip: '3-4 mensajes al día. Cortos, cálidos, sin esperar respuesta.',
    alert:
        'Fase crítica: La ansiedad y depresión se amplifican. Prioriza validar sobre motivar.',
  ),
};
