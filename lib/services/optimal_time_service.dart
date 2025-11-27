import '../models/activity.dart';
import '../models/completion_history.dart';
import 'database_helper.dart';

/// Servicio para analizar patrones de completación y determinar horarios óptimos
class OptimalTimeService {
  final DatabaseHelper _db = DatabaseHelper();

  /// Analiza el historial de completaciones para encontrar el horario óptimo
  /// Retorna un mapa con 'hour', 'minute', 'confidence'
  Future<Map<String, dynamic>?> getOptimalTimeRecommendation(
      String activityId) async {
    final completions = await _db.getCompletionHistory(activityId);

    if (!hasEnoughDataForAnalysis(completions)) {
      return null;
    }

    final distribution = _getHourlyCompletionDistribution(completions);
    final optimalHour = _findOptimalHour(distribution);
    final optimalMinute = _calculateAverageMinute(completions, optimalHour);
    final confidence = _calculateConfidenceScore(distribution, optimalHour);

    return {
      'hour': optimalHour,
      'minute': optimalMinute,
      'confidence': confidence,
    };
  }

  /// Obtiene la distribución de completaciones por hora del día
  Future<Map<int, int>> getHourlyCompletionDistribution(
      String activityId) async {
    final completions = await _db.getCompletionHistory(activityId);
    return _getHourlyCompletionDistribution(completions);
  }

  /// Verifica si hay suficientes datos para hacer un análisis confiable
  bool hasEnoughDataForAnalysis(List<CompletionHistory> completions,
      {int minCompletions = 7}) {
    return completions.length >= minCompletions;
  }

  /// Calcula el score de confianza basado en la consistencia de los datos
  /// Retorna un valor entre 0.0 y 1.0
  double getConfidenceScore(String activityId, List<CompletionHistory> completions) {
    if (completions.isEmpty) return 0.0;

    final distribution = _getHourlyCompletionDistribution(completions);
    final optimalHour = _findOptimalHour(distribution);
    return _calculateConfidenceScore(distribution, optimalHour);
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Crea un mapa de hora → cantidad de completaciones
  Map<int, int> _getHourlyCompletionDistribution(
      List<CompletionHistory> completions) {
    final Map<int, int> distribution = {};

    for (var completion in completions) {
      final hour = completion.completedAt.hour;
      distribution[hour] = (distribution[hour] ?? 0) + 1;
    }

    return distribution;
  }

  /// Encuentra la hora con más completaciones
  int _findOptimalHour(Map<int, int> distribution) {
    if (distribution.isEmpty) return 20; // Default: 8 PM

    int maxHour = 20;
    int maxCount = 0;

    distribution.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        maxHour = hour;
      }
    });

    return maxHour;
  }

  /// Calcula el minuto promedio dentro de la hora óptima
  int _calculateAverageMinute(
      List<CompletionHistory> completions, int optimalHour) {
    final completionsInHour = completions
        .where((c) => c.completedAt.hour == optimalHour)
        .toList();

    if (completionsInHour.isEmpty) return 0;

    final totalMinutes = completionsInHour.fold<int>(
      0,
      (sum, c) => sum + c.completedAt.minute,
    );

    return (totalMinutes / completionsInHour.length).round();
  }

  /// Calcula el score de confianza basado en la concentración de completaciones
  /// Alta confianza si 60%+ de las completaciones están en la hora óptima
  double _calculateConfidenceScore(
      Map<int, int> distribution, int optimalHour) {
    if (distribution.isEmpty) return 0.0;

    final totalCompletions = distribution.values.fold<int>(0, (a, b) => a + b);
    final optimalHourCount = distribution[optimalHour] ?? 0;

    // Calcular el porcentaje de completaciones en la hora óptima
    final concentration = optimalHourCount / totalCompletions;

    // Calcular la dispersión (cuántas horas diferentes se usan)
    final hoursUsed = distribution.keys.length;
    final dispersionPenalty = hoursUsed > 12 ? 0.2 : 0.0;

    // Score final: concentración alta = confianza alta
    // Penalizar si las completaciones están muy dispersas
    double confidence = concentration - dispersionPenalty;

    return confidence.clamp(0.0, 1.0);
  }

  /// Obtiene recomendaciones para múltiples actividades
  Future<Map<String, Map<String, dynamic>>> getRecommendationsForActivities(
      List<Activity> activities) async {
    final Map<String, Map<String, dynamic>> recommendations = {};

    for (var activity in activities) {
      final recommendation = await getOptimalTimeRecommendation(activity.id);
      if (recommendation != null) {
        recommendations[activity.id] = recommendation;
      }
    }

    return recommendations;
  }

  /// Obtiene estadísticas detalladas de patrones de completación
  Future<Map<String, dynamic>> getCompletionPatternStats(
      String activityId) async {
    final completions = await _db.getCompletionHistory(activityId);

    if (completions.isEmpty) {
      return {
        'totalCompletions': 0,
        'hasEnoughData': false,
      };
    }

    final distribution = _getHourlyCompletionDistribution(completions);
    final optimalHour = _findOptimalHour(distribution);
    final confidence = _calculateConfidenceScore(distribution, optimalHour);

    // Calcular hora más temprana y más tardía
    final hours = completions.map((c) => c.completedAt.hour).toList();
    final earliestHour = hours.reduce((a, b) => a < b ? a : b);
    final latestHour = hours.reduce((a, b) => a > b ? a : b);

    // Calcular días de la semana más comunes
    final Map<int, int> weekdayDistribution = {};
    for (var completion in completions) {
      final weekday = completion.completedAt.weekday;
      weekdayDistribution[weekday] = (weekdayDistribution[weekday] ?? 0) + 1;
    }

    return {
      'totalCompletions': completions.length,
      'hasEnoughData': hasEnoughDataForAnalysis(completions),
      'hourlyDistribution': distribution,
      'optimalHour': optimalHour,
      'confidence': confidence,
      'earliestHour': earliestHour,
      'latestHour': latestHour,
      'hourRange': latestHour - earliestHour,
      'weekdayDistribution': weekdayDistribution,
      'mostCommonWeekday': _findMostCommonWeekday(weekdayDistribution),
    };
  }

  int _findMostCommonWeekday(Map<int, int> weekdayDistribution) {
    if (weekdayDistribution.isEmpty) return 1; // Monday by default

    int maxWeekday = 1;
    int maxCount = 0;

    weekdayDistribution.forEach((weekday, count) {
      if (count > maxCount) {
        maxCount = count;
        maxWeekday = weekday;
      }
    });

    return maxWeekday;
  }
}
