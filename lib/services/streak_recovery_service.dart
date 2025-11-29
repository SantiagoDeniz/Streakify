import 'package:uuid/uuid.dart';
import '../models/streak_recovery.dart';
import 'database_helper.dart';
import 'database_protector_extension.dart';
import 'streak_points_service.dart';

/// Servicio para gestionar recuperación de rachas
class StreakRecoveryService {
  final DatabaseHelper _db = DatabaseHelper();
  final StreakPointsService _pointsService = StreakPointsService();

  /// Recuperar una racha perdida con penalización
  Future<StreakRecovery?> recoverStreak({
    required String activityId,
    required int originalStreak,
    double penaltyPercentage = 0.2, // 20% de penalización por defecto
  }) async {
    final activity = await _db.getActivity(activityId);
    if (activity == null) return null;

    // Calcular penalización
    final penaltyDays = StreakRecovery.calculatePenalty(
      originalStreak,
      percentage: penaltyPercentage,
    );

    final recoveredStreak = originalStreak - penaltyDays;

    // Calcular costo en puntos
    final pointsCost = StreakRecovery.calculatePointsCost(originalStreak);

    // Verificar si tiene suficientes puntos
    final totalPoints = await _pointsService.getTotalPoints();
    if (totalPoints < pointsCost) {
      return null; // No tiene suficientes puntos
    }

    // Crear registro de recuperación
    final recovery = StreakRecovery(
      id: const Uuid().v4(),
      activityId: activityId,
      originalStreak: originalStreak,
      recoveredStreak: recoveredStreak,
      penaltyDays: penaltyDays,
      penaltyPercentage: penaltyPercentage,
      lostAt: activity.lastCompleted ?? DateTime.now(),
      recoveredAt: DateTime.now(),
      pointsCost: pointsCost,
    );

    // Guardar en base de datos
    final db = await _db.database;
    await db.insertStreakRecovery(recovery);

    // Descontar puntos
    await _pointsService.deductPoints(pointsCost);

    // Actualizar la actividad con la racha recuperada
    activity.streak = recoveredStreak;
    activity.lastCompleted = DateTime.now();
    await _db.updateActivity(activity);

    return recovery;
  }

  /// Verificar si puede recuperar una racha
  Future<bool> canRecoverStreak({
    required String activityId,
    required int originalStreak,
  }) async {
    final pointsCost = StreakRecovery.calculatePointsCost(originalStreak);
    final totalPoints = await _pointsService.getTotalPoints();
    return totalPoints >= pointsCost;
  }

  /// Obtener historial de recuperaciones de una actividad
  Future<List<StreakRecovery>> getRecoveryHistory(String activityId) async {
    final db = await _db.database;
    return await db.getStreakRecoveriesByActivity(activityId);
  }

  /// Obtener todas las recuperaciones
  Future<List<StreakRecovery>> getAllRecoveries() async {
    final db = await _db.database;
    return await db.getAllStreakRecoveries();
  }

  /// Obtener estadísticas de recuperaciones
  Future<Map<String, dynamic>> getRecoveryStats(String activityId) async {
    final recoveries = await getRecoveryHistory(activityId);

    if (recoveries.isEmpty) {
      return {
        'totalRecoveries': 0,
        'totalDaysLost': 0,
        'totalPointsSpent': 0,
        'averagePenalty': 0.0,
      };
    }

    int totalDaysLost = 0;
    int totalPointsSpent = 0;

    for (var recovery in recoveries) {
      totalDaysLost += recovery.penaltyDays;
      totalPointsSpent += recovery.pointsCost;
    }

    return {
      'totalRecoveries': recoveries.length,
      'totalDaysLost': totalDaysLost,
      'totalPointsSpent': totalPointsSpent,
      'averagePenalty': totalDaysLost / recoveries.length,
    };
  }

  /// Calcular vista previa de recuperación (sin ejecutarla)
  Map<String, dynamic> previewRecovery({
    required int originalStreak,
    double penaltyPercentage = 0.2,
  }) {
    final penaltyDays = StreakRecovery.calculatePenalty(
      originalStreak,
      percentage: penaltyPercentage,
    );

    final recoveredStreak = originalStreak - penaltyDays;
    final pointsCost = StreakRecovery.calculatePointsCost(originalStreak);

    return {
      'originalStreak': originalStreak,
      'penaltyDays': penaltyDays,
      'recoveredStreak': recoveredStreak,
      'pointsCost': pointsCost,
      'penaltyPercentage': penaltyPercentage,
    };
  }
}
