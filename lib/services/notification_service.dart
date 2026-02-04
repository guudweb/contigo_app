import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import '../data/phases.dart';
import '../services/cycle_service.dart';
import '../services/storage_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Notification IDs
  static const int _baseNotificationId = 1000;
  static const int _reminderNotificationId = 2000;

  // Default notification times (hours)
  static const List<int> _defaultTimes = [9, 13, 17, 20]; // 9am, 1pm, 5pm, 8pm

  static Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to home screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  static Future<bool> requestPermissions() async {
    // Request notification permission for Android 13+
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> checkPermissions() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Schedule daily notifications based on user preferences and cycle phase
  static Future<void> scheduleNotifications({
    required DateTime lastPeriod,
    required int cycleLength,
    required int periodLength,
    required int notificationsPerDay,
    required bool notificationsEnabled,
  }) async {
    if (!notificationsEnabled || notificationsPerDay == 0) {
      await cancelAllNotifications();
      return;
    }

    // Cancel existing notifications first
    await cancelAllNotifications();

    // Get current cycle info
    final cycleInfo = CycleService.getCycleInfo(lastPeriod, cycleLength, periodLength);
    final phaseData = phases[cycleInfo.phase];

    if (phaseData == null) return;

    // Calculate times based on number of notifications
    final times = _getNotificationTimes(notificationsPerDay);

    // Schedule notifications for today and tomorrow
    for (int dayOffset = 0; dayOffset < 2; dayOffset++) {
      final date = DateTime.now().add(Duration(days: dayOffset));

      // Calculate phase for this day
      final dayNum = ((cycleInfo.cycleDay + dayOffset - 1) % cycleLength) + 1;
      final dayPhase = CycleService.getPhaseForDay(dayNum, cycleLength, periodLength);
      final dayPhaseData = phases[dayPhase]!;

      for (int i = 0; i < times.length; i++) {
        final scheduledDate = DateTime(
          date.year,
          date.month,
          date.day,
          times[i],
          0,
        );

        // Skip if time has passed
        if (scheduledDate.isBefore(DateTime.now())) continue;

        final notificationId = _baseNotificationId + (dayOffset * 10) + i;

        await _scheduleNotification(
          id: notificationId,
          title: _getNotificationTitle(dayPhaseData, i, times.length),
          body: _getNotificationBody(dayPhaseData, i),
          scheduledDate: scheduledDate,
          payload: dayPhase,
        );
      }
    }
  }

  /// Schedule reminder notification if no recommendations completed
  static Future<void> scheduleReminderIfNeeded({
    required int notificationsPerDay,
    required bool notificationsEnabled,
  }) async {
    if (!notificationsEnabled) return;

    final sentToday = StorageService.getTodayMessagesSent();

    if (sentToday == 0) {
      // No messages sent today, schedule a reminder
      final now = DateTime.now();

      // Schedule reminder for 2 hours from now if before 8pm
      if (now.hour < 20) {
        final reminderTime = now.add(const Duration(hours: 2));

        await _scheduleNotification(
          id: _reminderNotificationId,
          title: '💝 Tu pareja te necesita',
          body: 'Aún no has enviado ningún mensaje hoy. Un pequeño gesto puede hacer una gran diferencia.',
          scheduledDate: reminderTime,
          payload: 'reminder',
        );
      }
    }
  }

  /// Get notification times based on count
  static List<int> _getNotificationTimes(int count) {
    switch (count) {
      case 1:
        return [10]; // 10am
      case 2:
        return [9, 19]; // 9am, 7pm
      case 3:
        return [9, 14, 20]; // 9am, 2pm, 8pm
      case 4:
        return [9, 13, 17, 20]; // 9am, 1pm, 5pm, 8pm
      default:
        return _defaultTimes.take(count).toList();
    }
  }

  /// Get notification title based on phase and time of day
  static String _getNotificationTitle(PhaseData phase, int index, int total) {
    final timeOfDay = index == 0 ? 'Buenos días' :
                      index == total - 1 ? 'Buenas noches' : 'Hola';

    return '$timeOfDay 💙';
  }

  /// Get notification body based on phase
  static String _getNotificationBody(PhaseData phase, int index) {
    final messages = _getPhaseMessages(phase.name);
    return messages[index % messages.length];
  }

  /// Get messages for each phase
  static List<String> _getPhaseMessages(String phaseName) {
    switch (phaseName) {
      case 'Menstrual':
        return [
          'Es momento de enviar un mensaje de apoyo suave. Recuerda: menos palabras, más presencia.',
          'Tu pareja puede necesitar compañía sin presión hoy.',
          'Un mensaje corto y cálido puede hacer mucho.',
        ];
      case 'Folicular':
        return [
          'Buen momento para un mensaje motivador. ¡Su energía está subiendo!',
          'Reconoce algo que haya logrado recientemente.',
          'Es un buen día para proponer algo juntos.',
        ];
      case 'Ovulación':
        return [
          'Momento ideal para un cumplido específico y detallado.',
          'Celebra sus cualidades únicas hoy.',
          'Dile algo que admiras de ella.',
        ];
      case 'Lútea':
        return [
          'Recuérdale que está haciendo un gran trabajo.',
          'La autocrítica puede estar alta. Tu validación importa.',
          'Un mensaje gentil puede marcar la diferencia.',
        ];
      case 'Premenstrual':
        return [
          '⚠️ Fase sensible: Valida sus emociones sin intentar arreglarlas.',
          'Recuérdale que NO es una carga para ti.',
          'Tu presencia incondicional es lo más valioso ahora.',
          'Un mensaje corto y cálido, sin esperar respuesta.',
        ];
      default:
        return [
          'Es momento de enviar un mensaje de apoyo.',
          'Tu pareja agradecerá saber que piensas en ella.',
        ];
    }
  }

  /// Schedule a single notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'contigo_notifications',
      'Recordatorios de Contigo',
      channelDescription: 'Notificaciones para enviar mensajes de apoyo',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF2563EB),
      enableVibration: true,
      playSound: true,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint('Scheduled notification $id for $scheduledDate');
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Show immediate notification (for testing)
  static Future<void> showTestNotification() async {
    final androidDetails = AndroidNotificationDetails(
      'contigo_notifications',
      'Recordatorios de Contigo',
      channelDescription: 'Notificaciones para enviar mensajes de apoyo',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF2563EB),
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _notifications.show(
      0,
      '💙 Contigo',
      'Las notificaciones están funcionando correctamente.',
      details,
    );
  }

  /// Get recommended notifications per day based on phase
  static int getRecommendedNotifications(String phase) {
    switch (phase) {
      case 'menstrual':
        return 3; // "2-3 mensajes cortos"
      case 'follicular':
        return 2;
      case 'ovulation':
        return 2;
      case 'luteal_early':
        return 3;
      case 'luteal_late':
        return 4; // "3-4 mensajes al día"
      default:
        return 2;
    }
  }
}
