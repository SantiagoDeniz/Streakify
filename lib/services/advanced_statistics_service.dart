import '../models/activity.dart';
import '../models/completion_history.dart';
import 'database_helper.dart';
import '../utils/compute_helper.dart';
import 'statistics_worker.dart';

/// Servicio para calcular métricas y estadísticas avanzadas
class AdvancedStatisticsService {
  final DatabaseHelper _db = DatabaseHelper();

  /// Tasa de éxito histórica (% de días completados vs total de días desde creación)
  Future<Map<String, double>> getSuccessRate() async {
    final activities = await _db.getAllActivities();
    final Map<String, List<Map<String, dynamic>>> completionsMap = {};
    
    // Pre-fetch all completions to pass to isolate
    for (var activity in activities) {
      final completions = await _db.getCompletionHistory(activity.id);
      completionsMap[activity.id] = completions.map((c) => c.toJson()).toList();
    }
    
    final args = {
      'activities': activities.map((a) => a.toJson()).toList(),
      'completions': completionsMap,
    };

    return await ComputeHelper.run(StatisticsWorker.calculateSuccessRate, args);
  }

  /// Mejor racha histórica de cada actividad (récord personal)
  Future<Map<String, int>> getBestStreaks() async {
    final activities = await _db.getAllActivities();
    final Map<String, List<Map<String, dynamic>>> completionsMap = {};
    
    for (var activity in activities) {
      final completions = await _db.getCompletionHistory(activity.id);
      completionsMap[activity.id] = completions.map((c) => c.toJson()).toList();
    }
    
    final args = {
      'activities': activities.map((a) => a.toJson()).toList(),
      'completions': completionsMap,
    };

    return await ComputeHelper.run(StatisticsWorker.calculateBestStreaks, args);
  }

  /// Promedio de racha por actividad (racha promedio histórica)
  Future<Map<String, double>> getAverageStreaks() async {
    final activities = await _db.getAllActivities();
    final Map<String, List<Map<String, dynamic>>> completionsMap = {};
    
    for (var activity in activities) {
      final completions = await _db.getCompletionHistory(activity.id);
      completionsMap[activity.id] = completions.map((c) => c.toJson()).toList();
    }
    
    final args = {
      'activities': activities.map((a) => a.toJson()).toList(),
      'completions': completionsMap,
    };

    return await ComputeHelper.run(StatisticsWorker.calculateAverageStreaks, args);
  }

  /// Días consecutivos totales (suma de todos los días completados)
  Future<int> getTotalConsecutiveDays() async {
    final completions = await _db.getAllCompletions();
    final rawCompletions = completions.map((c) => c.toJson()).toList();
    
    return await ComputeHelper.run(StatisticsWorker.calculateTotalConsecutiveDays, rawCompletions);
  }

  /// Heatmap de actividad (datos para calendario anual estilo GitHub)
  /// Retorna un mapa de fecha -> cantidad de completaciones ese día
  Future<Map<DateTime, int>> getActivityHeatmap({DateTime? year}) async {
    final targetYear = year ?? DateTime.now();
    final startOfYear = DateTime(targetYear.year, 1, 1);
    final endOfYear = DateTime(targetYear.year, 12, 31, 23, 59, 59);

    final completions = await _db.getCompletionsByDateRange(startOfYear, endOfYear);
    
    // This calculation is relatively light, but could be moved to isolate if needed
    // For now keeping it here as it involves DateTime keys which might need serialization
    final Map<DateTime, int> heatmap = {};

    for (var completion in completions) {
      final day = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      heatmap[day] = (heatmap[day] ?? 0) + 1;
    }

    return heatmap;
  }

  /// Tendencias semanales (últimas 12 semanas)
  Future<List<WeeklyTrend>> getWeeklyTrends() async {
    final now = DateTime.now();
    final trends = <WeeklyTrend>[];

    for (int i = 11; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: 7 * i + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final completions = await _db.getCompletionsByDateRange(
        weekStart,
        weekEnd,
      );

      // Contar días únicos con completaciones
      final Set<String> uniqueDays = {};
      for (var completion in completions) {
        final day = DateTime(
          completion.completedAt.year,
          completion.completedAt.month,
          completion.completedAt.day,
        );
        uniqueDays.add(day.toIso8601String());
      }

      trends.add(WeeklyTrend(
        weekStart: weekStart,
        weekEnd: weekEnd,
        completions: completions.length,
        activeDays: uniqueDays.length,
      ));
    }

    return trends;
  }

  /// Tendencias mensuales (últimos 12 meses)
  Future<List<MonthlyTrend>> getMonthlyTrends() async {
    final now = DateTime.now();
    final trends = <MonthlyTrend>[];

    for (int i = 11; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthStart = DateTime(targetDate.year, targetDate.month, 1);
      final monthEnd = DateTime(targetDate.year, targetDate.month + 1, 0);

      final completions = await _db.getCompletionsByDateRange(
        monthStart,
        monthEnd,
      );

      // Contar días únicos con completaciones
      final Set<String> uniqueDays = {};
      for (var completion in completions) {
        final day = DateTime(
          completion.completedAt.year,
          completion.completedAt.month,
          completion.completedAt.day,
        );
        uniqueDays.add(day.toIso8601String());
      }

      trends.add(MonthlyTrend(
        month: monthStart,
        completions: completions.length,
        activeDays: uniqueDays.length,
      ));
    }

    return trends;
  }

  /// Comparativa mes a mes (mejora/declive)
  Future<MonthComparison> compareMonths(DateTime month1, DateTime month2) async {
    final m1Start = DateTime(month1.year, month1.month, 1);
    final m1End = DateTime(month1.year, month1.month + 1, 0);
    
    final m2Start = DateTime(month2.year, month2.month, 1);
    final m2End = DateTime(month2.year, month2.month + 1, 0);

    final c1 = await _db.getCompletionsByDateRange(m1Start, m1End);
    final c2 = await _db.getCompletionsByDateRange(m2Start, m2End);

    final improvement = c2.length - c1.length;
    final percentage = c1.isEmpty ? 0.0 : (improvement / c1.length) * 100;

    return MonthComparison(
      month1: month1,
      month2: month2,
      month1Completions: c1.length,
      month2Completions: c2.length,
      improvement: improvement,
      improvementPercentage: percentage,
    );
  }

  /// Predicción simple de rachas (basado en promedio histórico)
  Future<Map<String, int>> predictStreaks() async {
    final activities = await _db.getAllActivities();
    final Map<String, int> predictions = {};

    for (var activity in activities) {
      final completions = await _db.getCompletionHistory(activity.id);
      if (completions.length < 7) {
        // No hay suficientes datos para predecir
        predictions[activity.id] = activity.streak;
        continue;
      }

      // Calcular tasa de éxito de los últimos 30 días
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentCompletions = completions.where(
        (c) => c.completedAt.isAfter(thirtyDaysAgo)
      ).toList();

      final successRate = recentCompletions.length / 30;
      
      // Predecir racha en 7 días: racha actual + (tasa de éxito * 7)
      final predictedIncrease = (successRate * 7).round();
      predictions[activity.id] = activity.streak + predictedIncrease;
    }

    return predictions;
  }

  /// Obtener días perfectos (todos los hábitos completados)
  Future<List<DateTime>> getPerfectDays() async {
    final activities = await _db.getActiveActivities();
    if (activities.isEmpty) return [];

    final completions = await _db.getAllCompletions();
    
    // Agrupar completaciones por día
    final Map<String, Set<String>> dayToActivities = {};
    for (var completion in completions) {
      final day = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      final dayStr = day.toIso8601String();
      
      if (!dayToActivities.containsKey(dayStr)) {
        dayToActivities[dayStr] = {};
      }
      dayToActivities[dayStr]!.add(completion.activityId);
    }

    // Encontrar días donde todas las actividades fueron completadas
    final perfectDays = <DateTime>[];
    final activeActivityIds = activities.map((a) => a.id).toSet();

    for (var entry in dayToActivities.entries) {
      if (entry.value.length >= activeActivityIds.length) {
        perfectDays.add(DateTime.parse(entry.key));
      }
    }

    perfectDays.sort();
    return perfectDays;
  }
}

/// Modelo para tendencias semanales
class WeeklyTrend {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int completions;
  final int activeDays;

  WeeklyTrend({
    required this.weekStart,
    required this.weekEnd,
    required this.completions,
    required this.activeDays,
  });
}

/// Modelo para tendencias mensuales
class MonthlyTrend {
  final DateTime month;
  final int completions;
  final int activeDays;

  MonthlyTrend({
    required this.month,
    required this.completions,
    required this.activeDays,
  });
}

/// Modelo para comparación de meses
class MonthComparison {
  final DateTime month1;
  final DateTime month2;
  final int month1Completions;
  final int month2Completions;
  final int improvement;
  final double improvementPercentage;

  MonthComparison({
    required this.month1,
    required this.month2,
    required this.month1Completions,
    required this.month2Completions,
    required this.improvement,
    required this.improvementPercentage,
  });

  bool get isImprovement => improvement > 0;
  bool get isDecline => improvement < 0;
  bool get isStable => improvement == 0;
}

