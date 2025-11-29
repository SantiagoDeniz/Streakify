import '../models/activity.dart';
import '../models/protector.dart';
import 'database_helper.dart';
import 'protector_service.dart';

/// Servicio para gestionar puntos de racha
class StreakPointsService {
  final DatabaseHelper _db = DatabaseHelper();
  final ProtectorService _protectorService = ProtectorService();

  // Costos de protectores en puntos
  static const int oneDayProtectorCost = 50;
  static const int threeDaysProtectorCost = 120;
  static const int weeklyProtectorCost = 250;

  /// Calcular puntos totales basados en todas las actividades
  Future<int> getTotalPoints() async {
    final activities = await _db.getAllActivities();
    int total = 0;

    for (var activity in activities) {
      total += calculatePoints(activity);
    }

    return total;
  }

  /// Calcular puntos de una actividad individual
  int calculatePoints(Activity activity) {
    // Puntos base: 10 puntos por cada día de racha
    int points = activity.streak * 10;

    // Bonus por rachas largas
    if (activity.streak >= 100) {
      points += 500; // Bonus platino
    } else if (activity.streak >= 50) {
      points += 200; // Bonus oro
    } else if (activity.streak >= 30) {
      points += 100; // Bonus plata
    } else if (activity.streak >= 7) {
      points += 25; // Bonus bronce
    }

    // Agregar puntos acumulados manualmente (por ejemplo, de logros)
    points += activity.streakPoints;

    return points;
  }

  /// Obtener costo de un protector según su tipo
  int getProtectorCost(ProtectorType type) {
    switch (type) {
      case ProtectorType.oneDay:
        return oneDayProtectorCost;
      case ProtectorType.threeDays:
        return threeDaysProtectorCost;
      case ProtectorType.weekly:
        return weeklyProtectorCost;
    }
  }

  /// Comprar un protector con puntos
  Future<bool> purchaseProtector({
    required ProtectorType type,
    String? activityId,
  }) async {
    final cost = getProtectorCost(type);
    final totalPoints = await getTotalPoints();

    // Verificar si tiene suficientes puntos
    if (totalPoints < cost) {
      return false;
    }

    // Descontar puntos (distribuir el costo entre las actividades)
    await _deductPoints(cost);

    // Otorgar el protector
    await _protectorService.grantProtector(
      type: type,
      source: ProtectorSource.purchased,
      activityId: activityId,
    );

    return true;
  }

  /// Descontar puntos del total (público para ser usado por otros servicios)
  Future<void> deductPoints(int amount) async {
    final activities = await _db.getAllActivities();

    // Ordenar por puntos disponibles (mayor a menor)
    activities.sort((a, b) => calculatePoints(b).compareTo(calculatePoints(a)));

    int remaining = amount;

    for (var activity in activities) {
      if (remaining <= 0) break;

      final availablePoints = activity.streakPoints;
      if (availablePoints > 0) {
        final toDeduct =
            availablePoints >= remaining ? remaining : availablePoints;
        activity.streakPoints -= toDeduct;
        remaining -= toDeduct;
        await _db.updateActivity(activity);
      }
    }

    // Si aún quedan puntos por descontar, usar puntos de racha base
    // (esto es conceptual, en la práctica los puntos de racha no se descuentan)
    // Solo descontamos de streakPoints que son puntos "extra"
  }

  /// Descontar puntos del total (versión privada para uso interno)
  Future<void> _deductPoints(int amount) async {
    await deductPoints(amount);
  }

  /// Agregar puntos bonus a una actividad
  Future<void> addBonusPoints(String activityId, int points) async {
    final activity = await _db.getActivity(activityId);
    if (activity == null) return;

    activity.streakPoints += points;
    await _db.updateActivity(activity);
  }

  /// Obtener desglose de puntos por actividad
  Future<Map<String, int>> getPointsBreakdown() async {
    final activities = await _db.getAllActivities();
    final Map<String, int> breakdown = {};

    for (var activity in activities) {
      breakdown[activity.id] = calculatePoints(activity);
    }

    return breakdown;
  }

  /// Verificar si puede comprar un protector
  Future<bool> canAffordProtector(ProtectorType type) async {
    final cost = getProtectorCost(type);
    final totalPoints = await getTotalPoints();
    return totalPoints >= cost;
  }

  /// Obtener puntos disponibles (solo puntos bonus, no de racha)
  Future<int> getAvailableBonusPoints() async {
    final activities = await _db.getAllActivities();
    int total = 0;

    for (var activity in activities) {
      total += activity.streakPoints;
    }

    return total;
  }
}
