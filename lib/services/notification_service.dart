import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/activity.dart';
import '../models/notification_preferences.dart';
import '../models/achievement.dart';
import '../utils/motivational_quotes.dart';
import 'dart:math';

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

  // ========== NOTIFICACIONES INTELIGENTES (PUNTO 4.1) ==========

  /// Muestra una notificación contextual basada en el progreso del usuario
  Future<void> showContextualNotification({
    required Activity activity,
    required NotificationPreferences prefs,
  }) async {
    if (!prefs.contextualNotificationsEnabled) return;
    if (prefs.isInDoNotDisturbMode()) return;

    await initialize();

    String message;
    final streak = activity.streak;

    // Mensajes según el progreso
    if (streak >= 100) {
      message = '¡Increíble! Llevas $streak días consecutivos en "${activity.name}"! 🏆';
    } else if (streak >= 50) {
      message = '¡Impresionante! $streak días de racha en "${activity.name}"! 💎';
    } else if (streak >= 30) {
      message = '¡Excelente! Ya llevas $streak días sin fallar en "${activity.name}"! 🌟';
    } else if (streak >= 14) {
      message = '¡Genial! Dos semanas completadas en "${activity.name}"! 🎉';
    } else if (streak >= 7) {
      message = '¡Felicidades! Una semana completa en "${activity.name}"! 🔥';
    } else if (streak >= 3) {
      message = '¡Vas por buen camino! $streak días seguidos en "${activity.name}"! 💪';
    } else {
      message = '¡Sigue así! Cada día cuenta en "${activity.name}"! ⭐';
    }

    // Agregar frase motivacional si está habilitado
    if (prefs.motivationalQuotesEnabled) {
      message += '\n\n${MotivationalQuotes.getContextualQuote(QuoteContext.perseverance)}';
    }

    await showInstantNotification(
      title: '🎊 ¡Progreso Destacado!',
      body: message,
    );
  }

  /// Programa alertas de riesgo para actividades que pueden perder la racha
  Future<void> scheduleRiskAlerts({
    required List<Activity> activities,
    required NotificationPreferences prefs,
  }) async {
    if (!prefs.riskAlertsEnabled) return;
    await initialize();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calcular hora de alerta (X horas antes de medianoche)
    final alertTime = DateTime(
      now.year,
      now.month,
      now.day,
      24 - prefs.riskAlertHoursBefore,
      0,
    );

    // Si ya pasó la hora de alerta hoy, programar para mañana
    var scheduledDate = alertTime.isBefore(now)
        ? alertTime.add(const Duration(days: 1))
        : alertTime;

    // Contar actividades pendientes con racha activa
    final pendingActivities = activities.where((activity) {
      if (!activity.active || activity.isArchived) return false;
      if (activity.isCurrentlyFrozen()) return false;
      if (!activity.shouldCompleteToday()) return false;

      // Verificar si ya se completó hoy
      final lastCompleted = activity.lastCompleted;
      if (lastCompleted != null) {
        final lastCompletedDate = DateTime(
          lastCompleted.year,
          lastCompleted.month,
          lastCompleted.day,
        );
        if (lastCompletedDate.isAtSameMomentAs(today)) {
          return false; // Ya completada hoy
        }
      }

      return activity.streak > 0; // Solo alertar si tiene racha activa
    }).toList();

    if (pendingActivities.isEmpty) return;

    // Crear mensaje de alerta
    String message;
    if (pendingActivities.length == 1) {
      message =
          '⚠️ Tienes 1 actividad pendiente: "${pendingActivities.first.name}". ¡No pierdas tu racha de ${pendingActivities.first.streak} días!';
    } else {
      message =
          '⚠️ Tienes ${pendingActivities.length} actividades pendientes. ¡No pierdas tus rachas!';
    }

    if (prefs.motivationalQuotesEnabled) {
      message += '\n\n${MotivationalQuotes.getContextualQuote(QuoteContext.resilience)}';
    }

    await _notifications.zonedSchedule(
      1000, // ID para alertas de riesgo
      '🚨 Alerta de Racha',
      message,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'risk_alerts',
          'Alertas de Riesgo',
          channelDescription: 'Alertas antes de perder rachas',
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

  /// Programa resúmenes diarios (mañana y noche)
  Future<void> scheduleDailySummaries({
    required List<Activity> activities,
    required NotificationPreferences prefs,
  }) async {
    if (!prefs.dailySummaryEnabled) return;
    await initialize();

    final now = DateTime.now();

    // ===== RESUMEN MATUTINO =====
    var morningDate = DateTime(
      now.year,
      now.month,
      now.day,
      prefs.morningSummaryHour,
      prefs.morningSummaryMinute,
    );

    if (morningDate.isBefore(now)) {
      morningDate = morningDate.add(const Duration(days: 1));
    }

    // Contar actividades que deben completarse hoy
    final todayActivities = activities.where((a) {
      return a.active &&
          !a.isArchived &&
          !a.isCurrentlyFrozen() &&
          a.shouldCompleteToday();
    }).length;

    String morningMessage =
        '☀️ Buenos días! Tienes $todayActivities ${todayActivities == 1 ? 'actividad' : 'actividades'} para hoy.';

    if (prefs.motivationalQuotesEnabled) {
      morningMessage +=
          '\n\n${MotivationalQuotes.getContextualQuote(QuoteContext.daily)}';
    }

    await _notifications.zonedSchedule(
      2000, // ID para resumen matutino
      '🌅 Resumen del Día',
      morningMessage,
      tz.TZDateTime.from(morningDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Resúmenes Diarios',
          channelDescription: 'Resúmenes de actividades del día',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // ===== RESUMEN NOCTURNO =====
    var eveningDate = DateTime(
      now.year,
      now.month,
      now.day,
      prefs.eveningSummaryHour,
      prefs.eveningSummaryMinute,
    );

    if (eveningDate.isBefore(now)) {
      eveningDate = eveningDate.add(const Duration(days: 1));
    }

    // Este mensaje se generará dinámicamente al momento de la notificación
    // Por ahora usamos un mensaje genérico
    String eveningMessage = '🌙 Revisa tu progreso del día en Streakify';

    if (prefs.motivationalQuotesEnabled) {
      eveningMessage +=
          '\n\n${MotivationalQuotes.getContextualQuote(QuoteContext.inspiration)}';
    }

    await _notifications.zonedSchedule(
      2001, // ID para resumen nocturno
      '🌃 Resumen Nocturno',
      eveningMessage,
      tz.TZDateTime.from(eveningDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Resúmenes Diarios',
          channelDescription: 'Resúmenes de actividades del día',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Muestra notificación cuando se desbloquea un logro
  Future<void> showAchievementNotification({
    required Achievement achievement,
    required NotificationPreferences prefs,
  }) async {
    if (!prefs.achievementNotificationsEnabled) return;
    if (prefs.isInDoNotDisturbMode()) return;

    await initialize();

    String message = achievement.description;

    if (prefs.motivationalQuotesEnabled) {
      message +=
          '\n\n${MotivationalQuotes.getContextualQuote(QuoteContext.achievement)}';
    }

    await showInstantNotification(
      title: '🏆 ¡Logro Desbloqueado!',
      body: '${achievement.icon} ${achievement.name}\n$message',
    );
  }

  /// Programa recordatorios progresivos a lo largo del día
  Future<void> scheduleProgressiveReminders({
    required List<Activity> activities,
    required NotificationPreferences prefs,
  }) async {
    if (!prefs.progressiveRemindersEnabled) return;
    await initialize();

    final now = DateTime.now();

    // Contar actividades pendientes
    final pendingCount = activities.where((a) {
      return a.active &&
          !a.isArchived &&
          !a.isCurrentlyFrozen() &&
          a.shouldCompleteToday();
    }).length;

    if (pendingCount == 0) return;

    // ===== PRIMER RECORDATORIO (suave) =====
    var firstReminderDate = DateTime(
      now.year,
      now.month,
      now.day,
      prefs.firstReminderHour,
      0,
    );

    if (firstReminderDate.isBefore(now)) {
      firstReminderDate = firstReminderDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      3000,
      '📝 Recordatorio Suave',
      'Tienes $pendingCount ${pendingCount == 1 ? 'actividad' : 'actividades'} para hoy. ¡Aún tienes tiempo! ⏰',
      tz.TZDateTime.from(firstReminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'progressive_reminders',
          'Recordatorios Progresivos',
          channelDescription: 'Recordatorios que aumentan en urgencia',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // ===== SEGUNDO RECORDATORIO (moderado) =====
    var secondReminderDate = DateTime(
      now.year,
      now.month,
      now.day,
      prefs.secondReminderHour,
      0,
    );

    if (secondReminderDate.isBefore(now)) {
      secondReminderDate = secondReminderDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      3001,
      '⏰ Recordatorio',
      'No olvides completar tus actividades de hoy. ¡Mantén tus rachas! 🔥',
      tz.TZDateTime.from(secondReminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'progressive_reminders',
          'Recordatorios Progresivos',
          channelDescription: 'Recordatorios que aumentan en urgencia',
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

    // ===== RECORDATORIO FINAL (urgente) =====
    var finalReminderDate = DateTime(
      now.year,
      now.month,
      now.day,
      prefs.finalReminderHour,
      0,
    );

    if (finalReminderDate.isBefore(now)) {
      finalReminderDate = finalReminderDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      3002,
      '🚨 ¡Última Oportunidad!',
      '¡No pierdas tus rachas! Completa tus actividades antes de que termine el día. 💪',
      tz.TZDateTime.from(finalReminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'progressive_reminders',
          'Recordatorios Progresivos',
          channelDescription: 'Recordatorios que aumentan en urgencia',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Reprograma todas las notificaciones inteligentes
  Future<void> rescheduleAllSmartNotifications({
    required List<Activity> activities,
    required NotificationPreferences prefs,
  }) async {
    await initialize();

    // Cancelar notificaciones inteligentes anteriores
    await _notifications.cancel(1000); // Risk alerts
    await _notifications.cancel(2000); // Morning summary
    await _notifications.cancel(2001); // Evening summary
    await _notifications.cancel(3000); // First reminder
    await _notifications.cancel(3001); // Second reminder
    await _notifications.cancel(3002); // Final reminder

    // Reprogramar si están habilitadas
    if (prefs.riskAlertsEnabled) {
      await scheduleRiskAlerts(activities: activities, prefs: prefs);
    }

    if (prefs.dailySummaryEnabled) {
      await scheduleDailySummaries(activities: activities, prefs: prefs);
    }

    if (prefs.progressiveRemindersEnabled) {
      await scheduleProgressiveReminders(activities: activities, prefs: prefs);
    }
  }

  /// Muestra una notificación motivacional aleatoria
  Future<void> showMotivationalNotification({
    required NotificationPreferences prefs,
  }) async {
    if (!prefs.motivationalQuotesEnabled) return;
    if (prefs.isInDoNotDisturbMode()) return;

    await initialize();

    final quote = MotivationalQuotes.getRandomQuote();

    await showInstantNotification(
      title: '💫 Motivación del Día',
      body: quote,
    );
  }
}

