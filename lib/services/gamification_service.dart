import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/gamification.dart';
import '../models/activity.dart';
import '../services/database_helper.dart';
import '../services/advanced_statistics_service.dart';

/// Servicio para gestionar la gamificación: medallas, niveles, desafíos
class GamificationService {
  static const String _medalsKey = 'gamification_medals';
  static const String _pointsKey = 'gamification_points';
  static const String _challengeKey = 'gamification_challenge';
  static const String _rewardsKey = 'gamification_rewards';

  final DatabaseHelper _db = DatabaseHelper();
  final AdvancedStatisticsService _stats = AdvancedStatisticsService();

  /// Obtener todas las medallas ganadas
  Future<List<Medal>> getMedals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_medalsKey);
      if (data == null) return [];

      final List<dynamic> list = jsonDecode(data);
      return list.map((e) => Medal.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Otorgar una medalla
  Future<void> awardMedal(String achievementId, MedalTier tier) async {
    final medals = await getMedals();

    // Verificar si ya tiene esta medalla
    if (medals.any((m) => m.achievementId == achievementId && m.tier == tier)) {
      return;
    }

    medals.add(Medal(
      achievementId: achievementId,
      tier: tier,
      earnedAt: DateTime.now(),
    ));

    await _saveMedals(medals);
    await _addPoints(tier.points);
  }

  Future<void> _saveMedals(List<Medal> medals) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(medals.map((e) => e.toJson()).toList());
    await prefs.setString(_medalsKey, data);
  }

  /// Obtener puntos totales
  Future<int> getTotalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  /// Agregar puntos
  Future<void> _addPoints(int points) async {
    final current = await getTotalPoints();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, current + points);
  }

  /// Obtener nivel actual del usuario
  Future<UserLevel> getUserLevel() async {
    final points = await getTotalPoints();
    return UserLevel.fromPoints(points);
  }

  /// Obtener desafío semanal actual
  Future<WeeklyChallenge> getWeeklyChallenge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_challengeKey);

      if (data != null) {
        final challenge = WeeklyChallenge.fromJson(jsonDecode(data));

        // Si el desafío está activo, devolverlo
        if (challenge.isActive) {
          return challenge;
        }
      }

      // Generar nuevo desafío
      final newChallenge = ChallengeGenerator.generateWeeklyChallenge();
      await _saveChallenge(newChallenge);
      return newChallenge;
    } catch (e) {
      final newChallenge = ChallengeGenerator.generateWeeklyChallenge();
      await _saveChallenge(newChallenge);
      return newChallenge;
    }
  }

  Future<void> _saveChallenge(WeeklyChallenge challenge) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_challengeKey, jsonEncode(challenge.toJson()));
  }

  /// Actualizar progreso del desafío semanal
  Future<void> updateChallengeProgress(List<Activity> activities) async {
    final challenge = await getWeeklyChallenge();

    if (challenge.isCompleted || !challenge.isActive) {
      return;
    }

    int progress = 0;

    switch (challenge.type) {
      case ChallengeType.completions:
        // Contar completaciones desde el inicio de la semana
        final completions = await _db.getCompletionsByDateRange(
          challenge.startDate,
          DateTime.now(),
        );
        progress = completions.length;
        break;

      case ChallengeType.perfectDays:
        // Contar días perfectos desde el inicio de la semana
        final perfectDays = await _stats.getPerfectDays();
        progress = perfectDays
            .where((day) =>
                day.isAfter(challenge.startDate) &&
                day.isBefore(challenge.endDate))
            .length;
        break;

      case ChallengeType.streak:
        // Encontrar la racha más larga actual
        int maxStreak = 0;
        for (var activity in activities) {
          if (activity.streak > maxStreak) {
            maxStreak = activity.streak;
          }
        }
        progress = maxStreak;
        break;

      case ChallengeType.variety:
        // Contar actividades únicas completadas esta semana
        final completions = await _db.getCompletionsByDateRange(
          challenge.startDate,
          DateTime.now(),
        );
        final uniqueActivities = completions.map((c) => c.activityId).toSet();
        progress = uniqueActivities.length;
        break;
    }

    challenge.currentProgress = progress;

    if (progress >= challenge.targetValue && !challenge.isCompleted) {
      challenge.isCompleted = true;
      // Otorgar puntos por completar el desafío
      await _addPoints(50);
    }

    await _saveChallenge(challenge);
  }

  /// Obtener recompensas por consistencia
  Future<List<ConsistencyReward>> getConsistencyRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_rewardsKey);

      final allRewards = ConsistencyReward.all;

      if (data == null) {
        return allRewards;
      }

      final Map<String, dynamic> savedData = jsonDecode(data);

      return allRewards.map((reward) {
        if (savedData.containsKey(reward.id)) {
          return ConsistencyReward.fromJson(savedData[reward.id], reward);
        }
        return reward;
      }).toList();
    } catch (e) {
      return ConsistencyReward.all;
    }
  }

  /// Verificar y otorgar recompensas por consistencia
  Future<List<ConsistencyReward>> checkConsistencyRewards(
    List<Activity> activities,
  ) async {
    final rewards = await getConsistencyRewards();
    final newlyEarned = <ConsistencyReward>[];

    // Verificar cada recompensa
    for (var reward in rewards) {
      if (reward.isEarned) continue;

      // Verificar si alguna actividad cumple el requisito
      for (var activity in activities) {
        if (activity.streak >= reward.daysRequired) {
          reward.isEarned = true;
          newlyEarned.add(reward);
          // Otorgar puntos según la dificultad
          await _addPoints(reward.daysRequired * 2);
          break;
        }
      }
    }

    if (newlyEarned.isNotEmpty) {
      await _saveRewards(rewards);
    }

    return newlyEarned;
  }

  Future<void> _saveRewards(List<ConsistencyReward> rewards) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {};

    for (var reward in rewards) {
      data[reward.id] = reward.toJson();
    }

    await prefs.setString(_rewardsKey, jsonEncode(data));
  }

  /// Determinar nivel de medalla según el valor del logro
  MedalTier getMedalTierForValue(int value, int requiredValue) {
    final ratio = value / requiredValue;

    if (ratio >= 10) return MedalTier.platinum;
    if (ratio >= 5) return MedalTier.gold;
    if (ratio >= 2) return MedalTier.silver;
    return MedalTier.bronze;
  }

  /// Otorgar medalla por logro de racha
  Future<Medal?> awardStreakMedal(int streakValue, String achievementId) async {
    MedalTier? tier;

    if (streakValue >= 100) {
      tier = MedalTier.platinum;
    } else if (streakValue >= 50) {
      tier = MedalTier.gold;
    } else if (streakValue >= 30) {
      tier = MedalTier.silver;
    } else if (streakValue >= 7) {
      tier = MedalTier.bronze;
    }

    if (tier != null) {
      await awardMedal(achievementId, tier);
      return Medal(
        achievementId: achievementId,
        tier: tier,
        earnedAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Obtener estadísticas de gamificación
  Future<Map<String, dynamic>> getGamificationStats() async {
    final medals = await getMedals();
    final level = await getUserLevel();
    final challenge = await getWeeklyChallenge();
    final rewards = await getConsistencyRewards();

    final bronzeMedals = medals.where((m) => m.tier == MedalTier.bronze).length;
    final silverMedals = medals.where((m) => m.tier == MedalTier.silver).length;
    final goldMedals = medals.where((m) => m.tier == MedalTier.gold).length;
    final platinumMedals =
        medals.where((m) => m.tier == MedalTier.platinum).length;
    final earnedRewards = rewards.where((r) => r.isEarned).length;

    return {
      'totalMedals': medals.length,
      'bronzeMedals': bronzeMedals,
      'silverMedals': silverMedals,
      'goldMedals': goldMedals,
      'platinumMedals': platinumMedals,
      'level': level.level,
      'levelTitle': level.title,
      'totalPoints': await getTotalPoints(),
      'currentChallenge': challenge.title,
      'challengeProgress': challenge.progress,
      'challengeCompleted': challenge.isCompleted,
      'consistencyRewards': earnedRewards,
      'totalRewards': rewards.length,
    };
  }

  /// Reset gamificación (para testing)
  Future<void> resetGamification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_medalsKey);
    await prefs.remove(_pointsKey);
    await prefs.remove(_challengeKey);
    await prefs.remove(_rewardsKey);
  }
}
