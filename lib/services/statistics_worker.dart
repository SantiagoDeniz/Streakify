import '../models/activity.dart';
import '../models/completion_history.dart';

/// Worker class containing static methods for heavy statistical calculations
/// to be run in isolates.
class StatisticsWorker {
  static Map<String, double> calculateSuccessRate(
      Map<String, dynamic> args) {
    final activities = (args['activities'] as List)
        .map((e) => Activity.fromJson(e))
        .toList();
    final completionsMap = args['completions'] as Map<String, List<Map<String, dynamic>>>;
    
    final Map<String, double> successRates = {};

    for (var activity in activities) {
      if (activity.lastCompleted == null) {
        successRates[activity.id] = 0.0;
        continue;
      }

      final rawCompletions = completionsMap[activity.id];
      if (rawCompletions == null || rawCompletions.isEmpty) {
        successRates[activity.id] = 0.0;
        continue;
      }
      
      final completions = rawCompletions
          .map((e) => CompletionHistory.fromJson(e))
          .toList();

      // Calcular días desde la primera completación hasta hoy
      final firstCompletion = completions.last.completedAt;
      final daysSinceStart = DateTime.now().difference(firstCompletion).inDays + 1;
      
      // Tasa de éxito = (días completados / días totales) * 100
      final successRate = (completions.length / daysSinceStart) * 100;
      successRates[activity.id] = successRate.clamp(0.0, 100.0);
    }

    return successRates;
  }

  static Map<String, int> calculateBestStreaks(Map<String, dynamic> args) {
    final activities = (args['activities'] as List)
        .map((e) => Activity.fromJson(e))
        .toList();
    final completionsMap = args['completions'] as Map<String, List<Map<String, dynamic>>>;
    
    final Map<String, int> bestStreaks = {};

    for (var activity in activities) {
      final rawCompletions = completionsMap[activity.id];
      if (rawCompletions == null || rawCompletions.isEmpty) {
        bestStreaks[activity.id] = 0;
        continue;
      }
      
      final completions = rawCompletions
          .map((e) => CompletionHistory.fromJson(e))
          .toList();

      // Ordenar por fecha ascendente para calcular rachas
      completions.sort((a, b) => a.completedAt.compareTo(b.completedAt));

      int currentStreak = 1;
      int bestStreak = 1;

      for (int i = 1; i < completions.length; i++) {
        final prevDate = completions[i - 1].completedAt;
        final currentDate = completions[i].completedAt;
        
        // Normalizar a solo fecha (sin hora)
        final prevDay = DateTime(prevDate.year, prevDate.month, prevDate.day);
        final currentDay = DateTime(currentDate.year, currentDate.month, currentDate.day);
        
        final daysDiff = currentDay.difference(prevDay).inDays;

        if (daysDiff == 1) {
          currentStreak++;
          if (currentStreak > bestStreak) {
            bestStreak = currentStreak;
          }
        } else if (daysDiff > 1) {
          currentStreak = 1;
        }
      }

      bestStreaks[activity.id] = bestStreak;
    }

    return bestStreaks;
  }

  static Map<String, double> calculateAverageStreaks(Map<String, dynamic> args) {
    final activities = (args['activities'] as List)
        .map((e) => Activity.fromJson(e))
        .toList();
    final completionsMap = args['completions'] as Map<String, List<Map<String, dynamic>>>;
    
    final Map<String, double> averageStreaks = {};

    for (var activity in activities) {
      final rawCompletions = completionsMap[activity.id];
      if (rawCompletions == null || rawCompletions.isEmpty) {
        averageStreaks[activity.id] = 0.0;
        continue;
      }
      
      final completions = rawCompletions
          .map((e) => CompletionHistory.fromJson(e))
          .toList();

      // Calcular todas las rachas
      completions.sort((a, b) => a.completedAt.compareTo(b.completedAt));
      
      List<int> allStreaks = [];
      int currentStreak = 1;

      for (int i = 1; i < completions.length; i++) {
        final prevDate = completions[i - 1].completedAt;
        final currentDate = completions[i].completedAt;
        
        final prevDay = DateTime(prevDate.year, prevDate.month, prevDate.day);
        final currentDay = DateTime(currentDate.year, currentDate.month, currentDate.day);
        
        final daysDiff = currentDay.difference(prevDay).inDays;

        if (daysDiff == 1) {
          currentStreak++;
        } else if (daysDiff > 1) {
          allStreaks.add(currentStreak);
          currentStreak = 1;
        }
      }
      allStreaks.add(currentStreak); // Agregar la última racha

      // Calcular promedio
      final sum = allStreaks.reduce((a, b) => a + b);
      averageStreaks[activity.id] = sum / allStreaks.length;
    }

    return averageStreaks;
  }
  
  static int calculateTotalConsecutiveDays(List<Map<String, dynamic>> rawCompletions) {
    // Agrupar por fecha única (sin importar la hora)
    final Set<String> uniqueDays = {};
    for (var raw in rawCompletions) {
      final completion = CompletionHistory.fromJson(raw);
      final day = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      uniqueDays.add(day.toIso8601String());
    }

    return uniqueDays.length;
  }
}
