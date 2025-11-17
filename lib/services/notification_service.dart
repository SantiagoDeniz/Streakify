import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/activity.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar zonas horarias
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Aquí puedes manejar cuando el usuario toca la notificación
    print('Notificación tocada: ${response.payload}');
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = '🔥 Streakify',
    String body = '¡No olvides completar tus actividades de hoy!',
  }) async {
    await initialize();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0, // ID de la notificación
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Recordatorios Diarios',
          channelDescription: 'Recordatorios para completar tus actividades',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMultipleReminders({
    required List<int> hours, // Lista de horas para recordatorios
  }) async {
    await initialize();

    for (int i = 0; i < hours.length; i++) {
      final hour = hours[i];
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, 0);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        i + 1, // ID único para cada notificación
        '🔥 Streakify',
        '¡Hora de completar tus actividades!',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Recordatorios Diarios',
            channelDescription: 'Recordatorios para completar tus actividades',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await initialize();

    await _notifications.show(
      999, // ID único para notificaciones instantáneas
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant',
          'Notificaciones Instantáneas',
          channelDescription: 'Notificaciones inmediatas',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // ========== NOTIFICACIONES POR ACTIVIDAD ==========

  /// Programa una notificación diaria para una actividad específica
  /// Usa el ID de la actividad como ID de notificación para evitar conflictos
  Future<void> scheduleActivityNotification(Activity activity) async {
    await initialize();

    // Si las notificaciones no están habilitadas, no programar
    if (!activity.notificationsEnabled) {
      return;
    }

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      activity.notificationHour,
      activity.notificationMinute,
    );

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Mensaje personalizado o mensaje por defecto
    final message = activity.customMessage?.isNotEmpty == true
        ? activity.customMessage!
        : '¡Es hora de completar "${activity.name}"!';

    await _notifications.zonedSchedule(
      activity.id.hashCode, // ID único basado en el ID de la actividad
      '🔥 ${activity.name}',
      message,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'activity_reminders',
          'Recordatorios de Actividades',
          channelDescription: 'Recordatorios personalizados por actividad',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: activity.id, // Para identificar la actividad al tocar
    );
  }

  /// Cancela la notificación de una actividad específica
  Future<void> cancelActivityNotification(Activity activity) async {
    await _notifications.cancel(activity.id.hashCode);
  }

  /// Reprograma todas las notificaciones para una lista de actividades
  /// Útil al iniciar la app para asegurar que todas las notificaciones estén programadas
  Future<void> rescheduleAllActivityNotifications(
      List<Activity> activities) async {
    await initialize();

    // Cancelar todas las notificaciones de actividades primero
    for (final activity in activities) {
      await cancelActivityNotification(activity);
    }

    // Reprogramar solo las que tienen notificaciones habilitadas
    for (final activity in activities) {
      if (activity.notificationsEnabled) {
        await scheduleActivityNotification(activity);
      }
    }
  }

  /// Actualiza la notificación de una actividad (cancela y reprograma)
  Future<void> updateActivityNotification(Activity activity) async {
    await cancelActivityNotification(activity);
    if (activity.notificationsEnabled) {
      await scheduleActivityNotification(activity);
    }
  }
}
