import 'dart:convert';

/// Modelo para almacenar las preferencias de notificaciones del usuario
class NotificationPreferences {
  // Notificaciones contextuales
  bool contextualNotificationsEnabled;

  // Alertas de riesgo
  bool riskAlertsEnabled;
  int riskAlertHoursBefore; // Horas antes de medianoche para alertar

  // Resúmenes diarios
  bool dailySummaryEnabled;
  int morningSummaryHour;
  int morningSummaryMinute;
  int eveningSummaryHour;
  int eveningSummaryMinute;

  // Frases motivacionales
  bool motivationalQuotesEnabled;

  // Notificaciones de logros
  bool achievementNotificationsEnabled;

  // Recordatorios progresivos
  bool progressiveRemindersEnabled;
  int firstReminderHour; // Hora del primer recordatorio (ej: 12:00)
  int secondReminderHour; // Hora del segundo recordatorio (ej: 18:00)
  int finalReminderHour; // Hora del recordatorio final (ej: 22:00)

  // Modo No Molestar
  bool doNotDisturbEnabled;
  int doNotDisturbStartHour;
  int doNotDisturbStartMinute;
  int doNotDisturbEndHour;
  int doNotDisturbEndMinute;

  // Auto-ajuste de horarios óptimos (ML)
  bool autoAdjustNotificationTimes;
  int minCompletionsForAutoAdjust;
  double confidenceThresholdForAutoAdjust;

  NotificationPreferences({
    this.contextualNotificationsEnabled = true,
    this.riskAlertsEnabled = true,
    this.riskAlertHoursBefore = 2,
    this.dailySummaryEnabled = true,
    this.morningSummaryHour = 8,
    this.morningSummaryMinute = 0,
    this.eveningSummaryHour = 20,
    this.eveningSummaryMinute = 0,
    this.motivationalQuotesEnabled = true,
    this.achievementNotificationsEnabled = true,
    this.progressiveRemindersEnabled = true,
    this.firstReminderHour = 12,
    this.secondReminderHour = 18,
    this.finalReminderHour = 22,
    this.doNotDisturbEnabled = false,
    this.doNotDisturbStartHour = 22,
    this.doNotDisturbStartMinute = 0,
    this.doNotDisturbEndHour = 7,
    this.doNotDisturbEndMinute = 0,
    this.autoAdjustNotificationTimes = false,
    this.minCompletionsForAutoAdjust = 7,
    this.confidenceThresholdForAutoAdjust = 0.6,
  });

  /// Verifica si estamos en modo No Molestar
  bool isInDoNotDisturbMode() {
    if (!doNotDisturbEnabled) return false;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = doNotDisturbStartHour * 60 + doNotDisturbStartMinute;
    final endMinutes = doNotDisturbEndHour * 60 + doNotDisturbEndMinute;

    // Si el período cruza la medianoche
    if (startMinutes > endMinutes) {
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    } else {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() => {
        'contextualNotificationsEnabled': contextualNotificationsEnabled,
        'riskAlertsEnabled': riskAlertsEnabled,
        'riskAlertHoursBefore': riskAlertHoursBefore,
        'dailySummaryEnabled': dailySummaryEnabled,
        'morningSummaryHour': morningSummaryHour,
        'morningSummaryMinute': morningSummaryMinute,
        'eveningSummaryHour': eveningSummaryHour,
        'eveningSummaryMinute': eveningSummaryMinute,
        'motivationalQuotesEnabled': motivationalQuotesEnabled,
        'achievementNotificationsEnabled': achievementNotificationsEnabled,
        'progressiveRemindersEnabled': progressiveRemindersEnabled,
        'firstReminderHour': firstReminderHour,
        'secondReminderHour': secondReminderHour,
        'finalReminderHour': finalReminderHour,
        'doNotDisturbEnabled': doNotDisturbEnabled,
        'doNotDisturbStartHour': doNotDisturbStartHour,
        'doNotDisturbStartMinute': doNotDisturbStartMinute,
        'doNotDisturbEndHour': doNotDisturbEndHour,
        'doNotDisturbEndMinute': doNotDisturbEndMinute,
        'autoAdjustNotificationTimes': autoAdjustNotificationTimes,
        'minCompletionsForAutoAdjust': minCompletionsForAutoAdjust,
        'confidenceThresholdForAutoAdjust': confidenceThresholdForAutoAdjust,
      };

  /// Crea desde JSON
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      contextualNotificationsEnabled:
          json['contextualNotificationsEnabled'] ?? true,
      riskAlertsEnabled: json['riskAlertsEnabled'] ?? true,
      riskAlertHoursBefore: json['riskAlertHoursBefore'] ?? 2,
      dailySummaryEnabled: json['dailySummaryEnabled'] ?? true,
      morningSummaryHour: json['morningSummaryHour'] ?? 8,
      morningSummaryMinute: json['morningSummaryMinute'] ?? 0,
      eveningSummaryHour: json['eveningSummaryHour'] ?? 20,
      eveningSummaryMinute: json['eveningSummaryMinute'] ?? 0,
      motivationalQuotesEnabled: json['motivationalQuotesEnabled'] ?? true,
      achievementNotificationsEnabled:
          json['achievementNotificationsEnabled'] ?? true,
      progressiveRemindersEnabled: json['progressiveRemindersEnabled'] ?? true,
      firstReminderHour: json['firstReminderHour'] ?? 12,
      secondReminderHour: json['secondReminderHour'] ?? 18,
      finalReminderHour: json['finalReminderHour'] ?? 22,
      doNotDisturbEnabled: json['doNotDisturbEnabled'] ?? false,
      doNotDisturbStartHour: json['doNotDisturbStartHour'] ?? 22,
      doNotDisturbStartMinute: json['doNotDisturbStartMinute'] ?? 0,
      doNotDisturbEndHour: json['doNotDisturbEndHour'] ?? 7,
      doNotDisturbEndMinute: json['doNotDisturbEndMinute'] ?? 0,
      autoAdjustNotificationTimes: json['autoAdjustNotificationTimes'] ?? false,
      minCompletionsForAutoAdjust: json['minCompletionsForAutoAdjust'] ?? 7,
      confidenceThresholdForAutoAdjust: json['confidenceThresholdForAutoAdjust'] ?? 0.6,
    );
  }

  /// Convierte a Map para SQLite
  Map<String, dynamic> toMap() => {
        'contextualNotificationsEnabled': contextualNotificationsEnabled ? 1 : 0,
        'riskAlertsEnabled': riskAlertsEnabled ? 1 : 0,
        'riskAlertHoursBefore': riskAlertHoursBefore,
        'dailySummaryEnabled': dailySummaryEnabled ? 1 : 0,
        'morningSummaryHour': morningSummaryHour,
        'morningSummaryMinute': morningSummaryMinute,
        'eveningSummaryHour': eveningSummaryHour,
        'eveningSummaryMinute': eveningSummaryMinute,
        'motivationalQuotesEnabled': motivationalQuotesEnabled ? 1 : 0,
        'achievementNotificationsEnabled':
            achievementNotificationsEnabled ? 1 : 0,
        'progressiveRemindersEnabled': progressiveRemindersEnabled ? 1 : 0,
        'firstReminderHour': firstReminderHour,
        'secondReminderHour': secondReminderHour,
        'finalReminderHour': finalReminderHour,
        'doNotDisturbEnabled': doNotDisturbEnabled ? 1 : 0,
        'doNotDisturbStartHour': doNotDisturbStartHour,
        'doNotDisturbStartMinute': doNotDisturbStartMinute,
        'doNotDisturbEndHour': doNotDisturbEndHour,
        'doNotDisturbEndMinute': doNotDisturbEndMinute,
        'autoAdjustNotificationTimes': autoAdjustNotificationTimes ? 1 : 0,
        'minCompletionsForAutoAdjust': minCompletionsForAutoAdjust,
        'confidenceThresholdForAutoAdjust': confidenceThresholdForAutoAdjust,
      };

  /// Crea desde Map de SQLite
  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      contextualNotificationsEnabled:
          map['contextualNotificationsEnabled'] == 1,
      riskAlertsEnabled: map['riskAlertsEnabled'] == 1,
      riskAlertHoursBefore: map['riskAlertHoursBefore'] ?? 2,
      dailySummaryEnabled: map['dailySummaryEnabled'] == 1,
      morningSummaryHour: map['morningSummaryHour'] ?? 8,
      morningSummaryMinute: map['morningSummaryMinute'] ?? 0,
      eveningSummaryHour: map['eveningSummaryHour'] ?? 20,
      eveningSummaryMinute: map['eveningSummaryMinute'] ?? 0,
      motivationalQuotesEnabled: map['motivationalQuotesEnabled'] == 1,
      achievementNotificationsEnabled:
          map['achievementNotificationsEnabled'] == 1,
      progressiveRemindersEnabled: map['progressiveRemindersEnabled'] == 1,
      firstReminderHour: map['firstReminderHour'] ?? 12,
      secondReminderHour: map['secondReminderHour'] ?? 18,
      finalReminderHour: map['finalReminderHour'] ?? 22,
      doNotDisturbEnabled: map['doNotDisturbEnabled'] == 1,
      doNotDisturbStartHour: map['doNotDisturbStartHour'] ?? 22,
      doNotDisturbStartMinute: map['doNotDisturbStartMinute'] ?? 0,
      doNotDisturbEndHour: map['doNotDisturbEndHour'] ?? 7,
      doNotDisturbEndMinute: map['doNotDisturbEndMinute'] ?? 0,
      autoAdjustNotificationTimes: map['autoAdjustNotificationTimes'] == 1,
      minCompletionsForAutoAdjust: map['minCompletionsForAutoAdjust'] ?? 7,
      confidenceThresholdForAutoAdjust: map['confidenceThresholdForAutoAdjust'] ?? 0.6,
    );
  }

  /// Copia con modificaciones
  NotificationPreferences copyWith({
    bool? contextualNotificationsEnabled,
    bool? riskAlertsEnabled,
    int? riskAlertHoursBefore,
    bool? dailySummaryEnabled,
    int? morningSummaryHour,
    int? morningSummaryMinute,
    int? eveningSummaryHour,
    int? eveningSummaryMinute,
    bool? motivationalQuotesEnabled,
    bool? achievementNotificationsEnabled,
    bool? progressiveRemindersEnabled,
    int? firstReminderHour,
    int? secondReminderHour,
    int? finalReminderHour,
    bool? doNotDisturbEnabled,
    int? doNotDisturbStartHour,
    int? doNotDisturbStartMinute,
    int? doNotDisturbEndHour,
    int? doNotDisturbEndMinute,
    bool? autoAdjustNotificationTimes,
    int? minCompletionsForAutoAdjust,
    double? confidenceThresholdForAutoAdjust,
  }) {
    return NotificationPreferences(
      contextualNotificationsEnabled:
          contextualNotificationsEnabled ?? this.contextualNotificationsEnabled,
      riskAlertsEnabled: riskAlertsEnabled ?? this.riskAlertsEnabled,
      riskAlertHoursBefore: riskAlertHoursBefore ?? this.riskAlertHoursBefore,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      morningSummaryHour: morningSummaryHour ?? this.morningSummaryHour,
      morningSummaryMinute: morningSummaryMinute ?? this.morningSummaryMinute,
      eveningSummaryHour: eveningSummaryHour ?? this.eveningSummaryHour,
      eveningSummaryMinute: eveningSummaryMinute ?? this.eveningSummaryMinute,
      motivationalQuotesEnabled:
          motivationalQuotesEnabled ?? this.motivationalQuotesEnabled,
      achievementNotificationsEnabled: achievementNotificationsEnabled ??
          this.achievementNotificationsEnabled,
      progressiveRemindersEnabled:
          progressiveRemindersEnabled ?? this.progressiveRemindersEnabled,
      firstReminderHour: firstReminderHour ?? this.firstReminderHour,
      secondReminderHour: secondReminderHour ?? this.secondReminderHour,
      finalReminderHour: finalReminderHour ?? this.finalReminderHour,
      doNotDisturbEnabled: doNotDisturbEnabled ?? this.doNotDisturbEnabled,
      doNotDisturbStartHour:
          doNotDisturbStartHour ?? this.doNotDisturbStartHour,
      doNotDisturbStartMinute:
          doNotDisturbStartMinute ?? this.doNotDisturbStartMinute,
      doNotDisturbEndHour: doNotDisturbEndHour ?? this.doNotDisturbEndHour,
      doNotDisturbEndMinute:
          doNotDisturbEndMinute ?? this.doNotDisturbEndMinute,
      autoAdjustNotificationTimes:
          autoAdjustNotificationTimes ?? this.autoAdjustNotificationTimes,
      minCompletionsForAutoAdjust:
          minCompletionsForAutoAdjust ?? this.minCompletionsForAutoAdjust,
      confidenceThresholdForAutoAdjust:
          confidenceThresholdForAutoAdjust ?? this.confidenceThresholdForAutoAdjust,
    );
  }
}
