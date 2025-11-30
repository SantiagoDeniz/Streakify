import 'dart:convert';

/// Tipos de recurrencia para actividades
enum RecurrenceType {
  daily, // Todos los días
  everyNDays, // Cada N días
  specificDays, // Días específicos de la semana
  weekdays, // Solo días de semana (L-V)
  weekends, // Solo fines de semana (S-D)
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.daily:
        return 'Todos los días';
      case RecurrenceType.everyNDays:
        return 'Cada N días';
      case RecurrenceType.specificDays:
        return 'Días específicos';
      case RecurrenceType.weekdays:
        return 'Solo días de semana';
      case RecurrenceType.weekends:
        return 'Solo fines de semana';
    }
  }

  String toJson() => name;

  static RecurrenceType fromJson(String value) {
    return RecurrenceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecurrenceType.daily,
    );
  }
}

class Activity {
  String id;
  String name;
  int streak;
  DateTime? lastCompleted;
  DateTime? nextProtectorAvailable;
  bool active;
  bool protectorUsed;
  String? categoryId; // ID de la categoría
  List<String> tags; // Lista de tags

  // Configuración de notificaciones
  bool notificationsEnabled;
  int notificationHour;
  int notificationMinute;
  String? customMessage;

  // Personalización visual
  String?
      customIcon; // Nombre del icono (ej: 'fitness_center', 'book', 'water_drop')
  String? customColor; // Color en formato hex (ej: '#FF5722')
  int displayOrder; // Orden de visualización para drag & drop

  // Configuración de recurrencia
  RecurrenceType recurrenceType; // Tipo de recurrencia
  int recurrenceInterval; // Para everyNDays: cada cuántos días
  List<int> recurrenceDays; // Para specificDays: lista de días (1=Lun, 7=Dom)
  DateTime? startDate; // Fecha de inicio de la actividad (para cálculos)

  // Meta y objetivos
  int?
      targetDays; // Meta de días para completar esta actividad (null = sin meta)

  // Gestión de actividades
  bool isArchived; // Si está archivada (no se muestra en la lista principal)

  // Sistema de rachas mejorado
  int allowedFailures; // Rachas flexibles: fallos permitidos por semana (0 = estricto)
  int weeklyFailureCount; // Contador de fallos en la semana actual
  List<int> freeDays; // Días libres (1=Lun, 7=Dom) - no cuentan para racha

  // Rachas parciales (completar X de Y días)
  int? partialGoalRequired; // Cuántos días completar (ej: 5)
  int? partialGoalTotal; // De cuántos días totales (ej: 7)
  int weeklyCompletionCount; // Contador de días completados esta semana

  // Múltiples completaciones diarias
  int dailyCompletionCount; // Cuántas veces se completó hoy
  int dailyGoal; // Meta de completaciones por día (default: 1)

  // Sistema de congelamiento
  bool isFrozen; // Si la racha está congelada
  DateTime? frozenUntil; // Hasta cuándo está congelada
  String?
      freezeReason; // Razón del congelamiento (vacaciones, enfermedad, etc.)

  // Sistema avanzado de protectores
  int streakPoints; // Puntos de racha ganados por esta actividad
  int monthlyProtectorUses; // Contador de protectores usados este mes
  DateTime? lastProtectorReset; // Última vez que se reseteó el contador mensual

  Activity({
    required this.id,
    required this.name,
    this.streak = 0,
    this.lastCompleted,
    this.nextProtectorAvailable,
    this.active = true,
    this.protectorUsed = false,
    this.categoryId,
    List<String>? tags,
    this.notificationsEnabled = false,
    this.notificationHour = 20,
    this.notificationMinute = 0,
    this.customMessage,
    this.customIcon,
    this.customColor,
    this.displayOrder = 0,
    this.recurrenceType = RecurrenceType.daily,
    this.recurrenceInterval = 1,
    List<int>? recurrenceDays,
    this.startDate,
    this.targetDays,
    this.isArchived = false,
    this.allowedFailures = 0,
    this.weeklyFailureCount = 0,
    List<int>? freeDays,
    this.partialGoalRequired,
    this.partialGoalTotal,
    this.weeklyCompletionCount = 0,
    this.dailyCompletionCount = 0,
    this.dailyGoal = 1,
    this.isFrozen = false,
    this.frozenUntil,
    this.freezeReason,
    this.streakPoints = 0,
    this.monthlyProtectorUses = 0,
    this.lastProtectorReset,
  })  : tags = tags ?? [],
        recurrenceDays = recurrenceDays ?? [],
        freeDays = freeDays ?? [];

  // Para JSON (usado por widget y exportación)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'streak': streak,
        'lastCompleted': lastCompleted?.toIso8601String(),
        'nextProtectorAvailable': nextProtectorAvailable?.toIso8601String(),
        'active': active,
        'protectorUsed': protectorUsed,
        'categoryId': categoryId,
        'tags': tags,
        'notificationsEnabled': notificationsEnabled,
        'notificationHour': notificationHour,
        'notificationMinute': notificationMinute,
        'customMessage': customMessage,
        'customIcon': customIcon,
        'customColor': customColor,
        'displayOrder': displayOrder,
        'recurrenceType': recurrenceType.toJson(),
        'recurrenceInterval': recurrenceInterval,
        'recurrenceDays': recurrenceDays,
        'startDate': startDate?.toIso8601String(),
        'targetDays': targetDays,
        'isArchived': isArchived,
        'allowedFailures': allowedFailures,
        'weeklyFailureCount': weeklyFailureCount,
        'freeDays': freeDays,
        'partialGoalRequired': partialGoalRequired,
        'partialGoalTotal': partialGoalTotal,
        'weeklyCompletionCount': weeklyCompletionCount,
        'dailyCompletionCount': dailyCompletionCount,
        'dailyGoal': dailyGoal,
        'isFrozen': isFrozen,
        'frozenUntil': frozenUntil?.toIso8601String(),
        'freezeReason': freezeReason,
        'streakPoints': streakPoints,
        'monthlyProtectorUses': monthlyProtectorUses,
        'lastProtectorReset': lastProtectorReset?.toIso8601String(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      streak: json['streak'] ?? 0,
      lastCompleted: json['lastCompleted'] != null
          ? DateTime.parse(json['lastCompleted'])
          : null,
      nextProtectorAvailable: json['nextProtectorAvailable'] != null
          ? DateTime.parse(json['nextProtectorAvailable'])
          : null,
      active: json['active'] ?? true,
      protectorUsed: json['protectorUsed'] ?? false,
      categoryId: json['categoryId'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      notificationHour: json['notificationHour'] ?? 20,
      notificationMinute: json['notificationMinute'] ?? 0,
      customMessage: json['customMessage'],
      customIcon: json['customIcon'],
      customColor: json['customColor'],
      displayOrder: json['displayOrder'] ?? 0,
      recurrenceType: json['recurrenceType'] != null
          ? RecurrenceTypeExtension.fromJson(json['recurrenceType'])
          : RecurrenceType.daily,
      recurrenceInterval: json['recurrenceInterval'] ?? 1,
      recurrenceDays: json['recurrenceDays'] != null
          ? List<int>.from(json['recurrenceDays'])
          : [],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      targetDays: json['targetDays'],
      isArchived: json['isArchived'] ?? false,
      allowedFailures: json['allowedFailures'] ?? 0,
      weeklyFailureCount: json['weeklyFailureCount'] ?? 0,
      freeDays:
          json['freeDays'] != null ? List<int>.from(json['freeDays']) : [],
      partialGoalRequired: json['partialGoalRequired'],
      partialGoalTotal: json['partialGoalTotal'],
      weeklyCompletionCount: json['weeklyCompletionCount'] ?? 0,
      dailyCompletionCount: json['dailyCompletionCount'] ?? 0,
      dailyGoal: json['dailyGoal'] ?? 1,
      isFrozen: json['isFrozen'] ?? false,
      frozenUntil: json['frozenUntil'] != null
          ? DateTime.parse(json['frozenUntil'])
          : null,
      freezeReason: json['freezeReason'],
      streakPoints: json['streakPoints'] ?? 0,
      monthlyProtectorUses: json['monthlyProtectorUses'] ?? 0,
      lastProtectorReset: json['lastProtectorReset'] != null
          ? DateTime.parse(json['lastProtectorReset'])
          : null,
    );
  }

  // Para SQLite (almacenamiento local)
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'streak': streak,
        'lastCompleted': lastCompleted?.toIso8601String(),
        'nextProtectorAvailable': nextProtectorAvailable?.toIso8601String(),
        'active': active ? 1 : 0, // SQLite usa INTEGER para booleanos
        'protectorUsed': protectorUsed ? 1 : 0,
        'categoryId': categoryId,
        'tags': jsonEncode(tags), // Guardar tags como JSON string
        'notificationsEnabled': notificationsEnabled ? 1 : 0,
        'notificationHour': notificationHour,
        'notificationMinute': notificationMinute,
        'customMessage': customMessage,
        'customIcon': customIcon,
        'customColor': customColor,
        'displayOrder': displayOrder,
        'recurrenceType': recurrenceType.toJson(),
        'recurrenceInterval': recurrenceInterval,
        'recurrenceDays': jsonEncode(recurrenceDays),
        'startDate': startDate?.toIso8601String(),
        'targetDays': targetDays,
        'isArchived': isArchived ? 1 : 0,
        'allowedFailures': allowedFailures,
        'weeklyFailureCount': weeklyFailureCount,
        'freeDays': jsonEncode(freeDays),
        'partialGoalRequired': partialGoalRequired,
        'partialGoalTotal': partialGoalTotal,
        'weeklyCompletionCount': weeklyCompletionCount,
        'dailyCompletionCount': dailyCompletionCount,
        'dailyGoal': dailyGoal,
        'isFrozen': isFrozen ? 1 : 0,
        'frozenUntil': frozenUntil?.toIso8601String(),
        'freezeReason': freezeReason,
        'streakPoints': streakPoints,
        'monthlyProtectorUses': monthlyProtectorUses,
        'lastProtectorReset': lastProtectorReset?.toIso8601String(),
      };

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      streak: map['streak'] ?? 0,
      lastCompleted: map['lastCompleted'] != null
          ? DateTime.parse(map['lastCompleted'])
          : null,
      nextProtectorAvailable: map['nextProtectorAvailable'] != null
          ? DateTime.parse(map['nextProtectorAvailable'])
          : null,
      active: map['active'] == 1, // Convertir INTEGER a bool
      protectorUsed: map['protectorUsed'] == 1,
      categoryId: map['categoryId'],
      tags:
          map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : [],
      notificationsEnabled: map['notificationsEnabled'] == 1,
      notificationHour: map['notificationHour'] ?? 20,
      notificationMinute: map['notificationMinute'] ?? 0,
      customMessage: map['customMessage'],
      customIcon: map['customIcon'],
      customColor: map['customColor'],
      displayOrder: map['displayOrder'] ?? 0,
      recurrenceType: map['recurrenceType'] != null
          ? RecurrenceTypeExtension.fromJson(map['recurrenceType'])
          : RecurrenceType.daily,
      recurrenceInterval: map['recurrenceInterval'] ?? 1,
      recurrenceDays: map['recurrenceDays'] != null
          ? List<int>.from(jsonDecode(map['recurrenceDays']))
          : [],
      startDate:
          map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      targetDays: map['targetDays'],
      isArchived: map['isArchived'] == 1,
      allowedFailures: map['allowedFailures'] ?? 0,
      weeklyFailureCount: map['weeklyFailureCount'] ?? 0,
      freeDays: map['freeDays'] != null
          ? List<int>.from(jsonDecode(map['freeDays']))
          : [],
      partialGoalRequired: map['partialGoalRequired'],
      partialGoalTotal: map['partialGoalTotal'],
      weeklyCompletionCount: map['weeklyCompletionCount'] ?? 0,
      dailyCompletionCount: map['dailyCompletionCount'] ?? 0,
      dailyGoal: map['dailyGoal'] ?? 1,
      isFrozen: map['isFrozen'] == 1,
      frozenUntil: map['frozenUntil'] != null
          ? DateTime.parse(map['frozenUntil'])
          : null,
      freezeReason: map['freezeReason'],
      streakPoints: map['streakPoints'] ?? 0,
      monthlyProtectorUses: map['monthlyProtectorUses'] ?? 0,
      lastProtectorReset: map['lastProtectorReset'] != null
          ? DateTime.parse(map['lastProtectorReset'])
          : null,
    );
  }

  /// Verifica si la actividad debe completarse hoy según su recurrencia
  bool shouldCompleteToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = now.weekday; // 1=Lunes, 7=Domingo

    switch (recurrenceType) {
      case RecurrenceType.daily:
        return true;

      case RecurrenceType.everyNDays:
        if (startDate == null) return true;
        final daysSinceStart = today.difference(startDate!).inDays;
        return daysSinceStart % recurrenceInterval == 0;

      case RecurrenceType.specificDays:
        return recurrenceDays.contains(weekday);

      case RecurrenceType.weekdays:
        return weekday >= 1 && weekday <= 5; // Lunes a Viernes

      case RecurrenceType.weekends:
        return weekday == 6 || weekday == 7; // Sábado y Domingo
    }
  }

  /// Obtiene descripción legible de la recurrencia
  String getRecurrenceDescription() {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return 'Todos los días';

      case RecurrenceType.everyNDays:
        return 'Cada $recurrenceInterval ${recurrenceInterval == 1 ? 'día' : 'días'}';

      case RecurrenceType.specificDays:
        if (recurrenceDays.isEmpty) return 'Ningún día';
        final dayNames = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        final selectedDays = recurrenceDays.map((d) => dayNames[d]).join(', ');
        return selectedDays;

      case RecurrenceType.weekdays:
        return 'Lunes a Viernes';

      case RecurrenceType.weekends:
        return 'Sábado y Domingo';
    }
  }

  /// Verifica si hoy es un día libre (no cuenta para racha)
  bool isTodayFreeDay() {
    final weekday = DateTime.now().weekday;
    return freeDays.contains(weekday);
  }

  /// Calcula el progreso hacia la meta (0.0 a 1.0)
  double getGoalProgress() {
    if (targetDays == null || targetDays! <= 0) return 0.0;
    return (streak / targetDays!).clamp(0.0, 1.0);
  }

  /// Verifica si la meta se ha alcanzado
  bool hasReachedGoal() {
    if (targetDays == null) return false;
    return streak >= targetDays!;
  }

  /// Días restantes para alcanzar la meta
  int daysRemainingToGoal() {
    if (targetDays == null) return 0;
    final remaining = targetDays! - streak;
    return remaining > 0 ? remaining : 0;
  }

  /// Verifica si tiene racha parcial activa
  bool hasPartialGoal() {
    return partialGoalRequired != null && partialGoalTotal != null;
  }

  /// Progreso de racha parcial semanal (0.0 a 1.0)
  double getPartialGoalProgress() {
    if (!hasPartialGoal()) return 0.0;
    return (weeklyCompletionCount / partialGoalRequired!).clamp(0.0, 1.0);
  }

  /// Verifica si cumplió la meta parcial esta semana
  bool hasMetPartialGoal() {
    if (!hasPartialGoal()) return false;
    return weeklyCompletionCount >= partialGoalRequired!;
  }

  /// Días restantes para cumplir meta parcial esta semana
  int daysRemainingForPartialGoal() {
    if (!hasPartialGoal()) return 0;
    final remaining = partialGoalRequired! - weeklyCompletionCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Verifica si permite múltiples completaciones diarias
  bool allowsMultipleCompletions() {
    return dailyGoal > 1;
  }

  /// Progreso de completaciones diarias (0.0 a 1.0)
  double getDailyCompletionProgress() {
    return (dailyCompletionCount / dailyGoal).clamp(0.0, 1.0);
  }

  /// Verifica si completó todas las veces del día
  bool hasCompletedDailyGoal() {
    return dailyCompletionCount >= dailyGoal;
  }

  /// Completaciones restantes para hoy
  int remainingDailyCompletions() {
    final remaining = dailyGoal - dailyCompletionCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Verifica si está congelada actualmente
  bool isCurrentlyFrozen() {
    if (!isFrozen) return false;
    if (frozenUntil == null) return true; // Congelado indefinidamente
    return DateTime.now().isBefore(frozenUntil!);
  }

  /// Días restantes de congelamiento
  int daysRemainingFrozen() {
    if (!isCurrentlyFrozen()) return 0;
    if (frozenUntil == null) return -1; // Indefinido
    return frozenUntil!.difference(DateTime.now()).inDays + 1;
  }

  /// Descripción del estado de racha parcial
  String getPartialGoalDescription() {
    if (!hasPartialGoal()) return '';
    return 'Completar $partialGoalRequired de $partialGoalTotal días por semana';
  }

  /// Descripción del estado de múltiples completaciones
  String getDailyGoalDescription() {
    if (dailyGoal == 1) return '';
    return 'Completar $dailyGoal veces al día';
  }

  /// Crear una copia de la actividad con cambios opcionales
  Activity copyWith({
    String? id,
    String? name,
    int? streak,
    DateTime? lastCompleted,
    DateTime? nextProtectorAvailable,
    bool? active,
    bool? protectorUsed,
    String? categoryId,
    List<String>? tags,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
    String? customMessage,
    String? customIcon,
    String? customColor,
    int? displayOrder,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    List<int>? recurrenceDays,
    DateTime? startDate,
    int? targetDays,
    bool? isArchived,
    int? allowedFailures,
    int? weeklyFailureCount,
    List<int>? freeDays,
    int? partialGoalRequired,
    int? partialGoalTotal,
    int? weeklyCompletionCount,
    int? dailyCompletionCount,
    int? dailyGoal,
    bool? isFrozen,
    DateTime? frozenUntil,
    String? freezeReason,
    int? streakPoints,
    int? monthlyProtectorUses,
    DateTime? lastProtectorReset,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      streak: streak ?? this.streak,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      nextProtectorAvailable:
          nextProtectorAvailable ?? this.nextProtectorAvailable,
      active: active ?? this.active,
      protectorUsed: protectorUsed ?? this.protectorUsed,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      customMessage: customMessage ?? this.customMessage,
      customIcon: customIcon ?? this.customIcon,
      customColor: customColor ?? this.customColor,
      displayOrder: displayOrder ?? this.displayOrder,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      startDate: startDate ?? this.startDate,
      targetDays: targetDays ?? this.targetDays,
      isArchived: isArchived ?? this.isArchived,
      allowedFailures: allowedFailures ?? this.allowedFailures,
      weeklyFailureCount: weeklyFailureCount ?? this.weeklyFailureCount,
      freeDays: freeDays ?? this.freeDays,
      partialGoalRequired: partialGoalRequired ?? this.partialGoalRequired,
      partialGoalTotal: partialGoalTotal ?? this.partialGoalTotal,
      weeklyCompletionCount:
          weeklyCompletionCount ?? this.weeklyCompletionCount,
      dailyCompletionCount: dailyCompletionCount ?? this.dailyCompletionCount,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      isFrozen: isFrozen ?? this.isFrozen,
      frozenUntil: frozenUntil ?? this.frozenUntil,
      freezeReason: freezeReason ?? this.freezeReason,
      streakPoints: streakPoints ?? this.streakPoints,
      monthlyProtectorUses: monthlyProtectorUses ?? this.monthlyProtectorUses,
      lastProtectorReset: lastProtectorReset ?? this.lastProtectorReset,
    );
  }
}
