import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/activity.dart';

class AchievementService {
  static const String _achievementsKey = 'achievements_data';
  static const String _perfectDaysKey = 'perfect_days_count';

  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  List<Achievement> _achievements = [];
  int _perfectDaysCount = 0;

  /// Cargar logros desde almacenamiento
  Future<void> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_achievementsKey);
    _perfectDaysCount = prefs.getInt(_perfectDaysKey) ?? 0;

    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      final savedAchievements =
          jsonList.map((json) => Achievement.fromJson(json)).toList();

      // Merge con los logros predefinidos
      _achievements = PredefinedAchievements.all.map((predefined) {
        final saved = savedAchievements.firstWhere(
          (a) => a.id == predefined.id,
          orElse: () => predefined,
        );
        return Achievement(
          id: predefined.id,
          title: predefined.title,
          description: predefined.description,
          icon: predefined.icon,
          color: predefined.color,
          requiredValue: predefined.requiredValue,
          type: predefined.type,
          isUnlocked: saved.isUnlocked,
          unlockedAt: saved.unlockedAt,
        );
      }).toList();
    } else {
      _achievements = List.from(PredefinedAchievements.all);
    }
  }

  /// Guardar logros
  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final String data =
        jsonEncode(_achievements.map((a) => a.toJson()).toList());
    await prefs.setString(_achievementsKey, data);
    await prefs.setInt(_perfectDaysKey, _perfectDaysCount);
  }

  /// Obtener todos los logros
  List<Achievement> getAllAchievements() => List.from(_achievements);

  /// Obtener logros desbloqueados
  List<Achievement> getUnlockedAchievements() =>
      _achievements.where((a) => a.isUnlocked).toList();

  /// Obtener logros bloqueados
  List<Achievement> getLockedAchievements() =>
      _achievements.where((a) => !a.isUnlocked).toList();

  /// Porcentaje de logros completados
  double getCompletionPercentage() {
    if (_achievements.isEmpty) return 0;
    final unlocked = _achievements.where((a) => a.isUnlocked).length;
    return (unlocked / _achievements.length) * 100;
  }

  /// Verificar y desbloquear logros basados en las actividades actuales
  Future<List<Achievement>> checkAndUnlockAchievements(
      List<Activity> activities) async {
    final newlyUnlocked = <Achievement>[];

    // Calcular estadísticas
    final maxStreak = activities.isEmpty
        ? 0
        : activities.map((a) => a.streak).reduce((a, b) => a > b ? a : b);
    final totalDays =
        activities.fold<int>(0, (sum, activity) => sum + activity.streak);
    final totalActivities = activities.length;

    // Verificar si hoy es un día perfecto
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final activeActivities = activities.where((a) => a.active).toList();

    if (activeActivities.isNotEmpty) {
      final allCompletedToday = activeActivities.every((a) {
        if (a.lastCompleted == null) return false;
        final lastDay = DateTime(
          a.lastCompleted!.year,
          a.lastCompleted!.month,
          a.lastCompleted!.day,
        );
        return lastDay == todayDay;
      });

      if (allCompletedToday && activeActivities.isNotEmpty) {
        // Es un día perfecto, incrementar contador si no se había contado hoy
        final prefs = await SharedPreferences.getInstance();
        final lastPerfectDay = prefs.getString('last_perfect_day');
        final todayString = todayDay.toIso8601String();

        if (lastPerfectDay != todayString) {
          _perfectDaysCount++;
          await prefs.setString('last_perfect_day', todayString);
        }
      }
    }

    // Verificar logros de racha
    for (var achievement in _achievements) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.streak:
          shouldUnlock = maxStreak >= achievement.requiredValue;
          break;
        case AchievementType.totalDays:
          shouldUnlock = totalDays >= achievement.requiredValue;
          break;
        case AchievementType.activities:
          shouldUnlock = totalActivities >= achievement.requiredValue;
          break;
        case AchievementType.perfect:
          shouldUnlock = _perfectDaysCount >= achievement.requiredValue;
          break;
      }

      if (shouldUnlock) {
        achievement.isUnlocked = true;
        achievement.unlockedAt = DateTime.now();
        newlyUnlocked.add(achievement);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await _saveAchievements();
    }

    return newlyUnlocked;
  }

  /// Obtener nivel del usuario basado en logros desbloqueados
  int getUserLevel() {
    final unlocked = getUnlockedAchievements().length;
    return (unlocked / 3).floor() + 1; // 1 nivel por cada 3 logros
  }

  /// Obtener puntos del usuario
  int getUserPoints() {
    return getUnlockedAchievements().length * 100; // 100 puntos por logro
  }

  /// Obtener progreso hacia el siguiente nivel
  double getProgressToNextLevel() {
    final unlocked = getUnlockedAchievements().length;
    final currentLevelAchievements = (getUserLevel() - 1) * 3;
    final achievementsInCurrentLevel = unlocked - currentLevelAchievements;
    return achievementsInCurrentLevel / 3;
  }

  /// Resetear todos los logros (para testing)
  Future<void> resetAchievements() async {
    _achievements = List.from(PredefinedAchievements.all);
    _perfectDaysCount = 0;
    await _saveAchievements();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_perfect_day');
  }
}
