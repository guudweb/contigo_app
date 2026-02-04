import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cycle_config.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/cycle_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _nameController = TextEditingController();
  DateTime? _lastPeriodDate;
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _showAdvanced = false;
  bool _showNotificationSettings = false;

  // Notification settings
  bool _notificationsEnabled = true;
  int _notificationsPerDay = 3;
  bool _usePhaseRecommendation = true;

  bool get _isValid => _lastPeriodDate != null;

  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
  }

  void _loadExistingConfig() {
    final config = StorageService.getConfig();
    if (config != null) {
      setState(() {
        _nameController.text = config.partnerName ?? '';
        _lastPeriodDate = config.lastPeriodDate;
        _cycleLength = config.cycleLength;
        _periodLength = config.periodLength;
        _notificationsEnabled = config.notificationsEnabled;
        _notificationsPerDay = config.notificationsPerDay;
        _usePhaseRecommendation = config.usePhaseRecommendation;
      });
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? now,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_isValid) return;

    final config = CycleConfig(
      partnerName: _nameController.text.isEmpty ? null : _nameController.text,
      lastPeriodDate: _lastPeriodDate!,
      cycleLength: _cycleLength,
      periodLength: _periodLength,
      notificationsEnabled: _notificationsEnabled,
      notificationsPerDay: _notificationsPerDay,
      usePhaseRecommendation: _usePhaseRecommendation,
    );

    await StorageService.saveConfig(config);

    // Request notification permissions and schedule if enabled
    if (_notificationsEnabled) {
      final hasPermission = await NotificationService.requestPermissions();
      if (hasPermission) {
        await NotificationService.scheduleNotifications(
          lastPeriod: _lastPeriodDate!,
          cycleLength: _cycleLength,
          periodLength: _periodLength,
          notificationsPerDay: _usePhaseRecommendation
              ? NotificationService.getRecommendedNotifications(
                  _getCurrentPhase())
              : _notificationsPerDay,
          notificationsEnabled: _notificationsEnabled,
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  String _getCurrentPhase() {
    if (_lastPeriodDate == null) return 'follicular';
    final cycleInfo = CycleService.getCycleInfo(
      _lastPeriodDate!,
      _cycleLength,
      _periodLength,
    );
    return cycleInfo.phase;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Column(
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Contigo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu guía para acompañarla mejor',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          const Text(
                            'Nombre de tu pareja (opcional)',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Ej: María',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Date field
                          const Text(
                            'Fecha del último período *',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMedium),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: AppTheme.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _lastPeriodDate != null
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(_lastPeriodDate!)
                                        : 'Seleccionar fecha',
                                    style: TextStyle(
                                      color: _lastPeriodDate != null
                                          ? AppTheme.textPrimary
                                          : AppTheme.textMuted,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: AppTheme.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Advanced settings toggle
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showAdvanced = !_showAdvanced;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.tune,
                                    color: AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Configuración del ciclo',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    _showAdvanced
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: AppTheme.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Advanced settings content
                          if (_showAdvanced) ...[
                            const SizedBox(height: 16),

                            // Cycle length slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Duración del ciclo',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '$_cycleLength días',
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _cycleLength.toDouble(),
                              min: 21,
                              max: 35,
                              divisions: 14,
                              activeColor: AppTheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  _cycleLength = value.round();
                                });
                              },
                            ),

                            // Period length slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Duración del período',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '$_periodLength días',
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _periodLength.toDouble(),
                              min: 2,
                              max: 8,
                              divisions: 6,
                              activeColor: AppTheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  _periodLength = value.round();
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notification settings card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Notification toggle header
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showNotificationSettings =
                                    !_showNotificationSettings;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  color: AppTheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Notificaciones',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _notificationsEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _notificationsEnabled = value;
                                    });
                                  },
                                  activeColor: AppTheme.primary,
                                ),
                                Icon(
                                  _showNotificationSettings
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: AppTheme.textMuted,
                                ),
                              ],
                            ),
                          ),

                          if (_notificationsEnabled &&
                              _showNotificationSettings) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Use phase recommendation toggle
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ajustar según fase',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Más notificaciones en fases sensibles',
                                        style: TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _usePhaseRecommendation,
                                  onChanged: (value) {
                                    setState(() {
                                      _usePhaseRecommendation = value;
                                    });
                                  },
                                  activeColor: AppTheme.primary,
                                ),
                              ],
                            ),

                            if (!_usePhaseRecommendation) ...[
                              const SizedBox(height: 20),

                              // Manual notification count
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Notificaciones por día',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '$_notificationsPerDay',
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _notificationsPerDay.toDouble(),
                                min: 1,
                                max: 4,
                                divisions: 3,
                                activeColor: AppTheme.primary,
                                onChanged: (value) {
                                  setState(() {
                                    _notificationsPerDay = value.round();
                                  });
                                },
                              ),

                              // Time indicators
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '1',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '2',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '3',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '4',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Info about notification times
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _usePhaseRecommendation
                                          ? 'Las notificaciones se ajustan automáticamente: 2-3 en fases normales, 3-4 en fases sensibles'
                                          : 'Recibirás $_notificationsPerDay notificación${_notificationsPerDay > 1 ? 'es' : ''} al día distribuidas entre 9am y 8pm',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 12,
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

                  const SizedBox(height: 16),

                  // Privacy badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: AppTheme.success,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Todos los datos se guardan localmente en tu dispositivo',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isValid ? _saveAndContinue : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      disabledBackgroundColor: AppTheme.border,
                    ),
                    child: const Text(
                      'Comenzar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
