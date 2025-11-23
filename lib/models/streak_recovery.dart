/// Modelo para recuperación de racha con penalización
class StreakRecovery {
  String id;
  String activityId;
  int originalStreak; // Racha original antes de perderse
  int recoveredStreak; // Racha recuperada (con penalización)
  int penaltyDays; // Días de penalización aplicados
  double penaltyPercentage; // Porcentaje de penalización (ej: 0.2 = 20%)
  DateTime lostAt; // Cuándo se perdió la racha
  DateTime recoveredAt; // Cuándo se recuperó
  int pointsCost; // Puntos de racha gastados en la recuperación

  StreakRecovery({
    required this.id,
    required this.activityId,
    required this.originalStreak,
    required this.recoveredStreak,
    required this.penaltyDays,
    required this.penaltyPercentage,
    required this.lostAt,
    required this.recoveredAt,
    required this.pointsCost,
  });

  /// Calcular penalización basada en la racha original
  static int calculatePenalty(int originalStreak, {double percentage = 0.2}) {
    // Penalización mínima de 1 día, máxima de 30 días
    final penalty = (originalStreak * percentage).ceil();
    return penalty.clamp(1, 30);
  }

  /// Calcular costo en puntos para recuperar racha
  static int calculatePointsCost(int originalStreak) {
    // Costo base: 10 puntos por cada día de racha
    // Mínimo 50 puntos, máximo 500 puntos
    final cost = originalStreak * 10;
    return cost.clamp(50, 500);
  }

  /// Para SQLite
  Map<String, dynamic> toMap() => {
        'id': id,
        'activityId': activityId,
        'originalStreak': originalStreak,
        'recoveredStreak': recoveredStreak,
        'penaltyDays': penaltyDays,
        'penaltyPercentage': penaltyPercentage,
        'lostAt': lostAt.toIso8601String(),
        'recoveredAt': recoveredAt.toIso8601String(),
        'pointsCost': pointsCost,
      };

  factory StreakRecovery.fromMap(Map<String, dynamic> map) {
    return StreakRecovery(
      id: map['id'],
      activityId: map['activityId'],
      originalStreak: map['originalStreak'],
      recoveredStreak: map['recoveredStreak'],
      penaltyDays: map['penaltyDays'],
      penaltyPercentage: map['penaltyPercentage'],
      lostAt: DateTime.parse(map['lostAt']),
      recoveredAt: DateTime.parse(map['recoveredAt']),
      pointsCost: map['pointsCost'],
    );
  }

  /// Para JSON (exportación)
  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': activityId,
        'originalStreak': originalStreak,
        'recoveredStreak': recoveredStreak,
        'penaltyDays': penaltyDays,
        'penaltyPercentage': penaltyPercentage,
        'lostAt': lostAt.toIso8601String(),
        'recoveredAt': recoveredAt.toIso8601String(),
        'pointsCost': pointsCost,
      };

  factory StreakRecovery.fromJson(Map<String, dynamic> json) {
    return StreakRecovery(
      id: json['id'],
      activityId: json['activityId'],
      originalStreak: json['originalStreak'],
      recoveredStreak: json['recoveredStreak'],
      penaltyDays: json['penaltyDays'],
      penaltyPercentage: json['penaltyPercentage'],
      lostAt: DateTime.parse(json['lostAt']),
      recoveredAt: DateTime.parse(json['recoveredAt']),
      pointsCost: json['pointsCost'],
    );
  }
}
