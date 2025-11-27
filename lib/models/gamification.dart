import 'dart:math';
import 'package:flutter/material.dart';

/// Niveles de medallas para logros
enum MedalTier {
  bronze,
  silver,
  gold,
  platinum,
}

extension MedalTierExtension on MedalTier {
  String get name {
    switch (this) {
      case MedalTier.bronze:
        return 'Bronce';
      case MedalTier.silver:
        return 'Plata';
      case MedalTier.gold:
        return 'Oro';
      case MedalTier.platinum:
        return 'Platino';
    }
  }

  Color get color {
    switch (this) {
      case MedalTier.bronze:
        return const Color(0xFFCD7F32);
      case MedalTier.silver:
        return const Color(0xFFC0C0C0);
      case MedalTier.gold:
        return const Color(0xFFFFD700);
      case MedalTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  IconData get icon {
    return Icons.workspace_premium;
  }

  int get points {
    switch (this) {
      case MedalTier.bronze:
        return 10;
      case MedalTier.silver:
        return 25;
      case MedalTier.gold:
        return 50;
      case MedalTier.platinum:
        return 100;
    }
  }
}

/// Medalla obtenida por un logro
class Medal {
  final String achievementId;
  final MedalTier tier;
  final DateTime earnedAt;

  Medal({
    required this.achievementId,
    required this.tier,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
        'achievementId': achievementId,
        'tier': tier.toString(),
        'earnedAt': earnedAt.toIso8601String(),
      };

  factory Medal.fromJson(Map<String, dynamic> json) {
    return Medal(
      achievementId: json['achievementId'],
      tier: MedalTier.values.firstWhere(
        (e) => e.toString() == json['tier'],
        orElse: () => MedalTier.bronze,
      ),
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }
}

/// Nivel del usuario basado en puntos
class UserLevel {
  final int level;
  final int currentPoints;
  final int pointsForNextLevel;
  final String title;

  UserLevel({
    required this.level,
    required this.currentPoints,
    required this.pointsForNextLevel,
    required this.title,
  });

  double get progress => currentPoints / pointsForNextLevel;

  static UserLevel fromPoints(int totalPoints) {
    final level = _calculateLevel(totalPoints);
    final title = _getLevelTitle(level);
    final pointsForNextLevel = _getPointsForLevel(level + 1);
    final currentLevelPoints = _getPointsForLevel(level);
    final pointsInCurrentLevel = totalPoints - currentLevelPoints;
    final pointsNeeded = pointsForNextLevel - currentLevelPoints;

    return UserLevel(
      level: level,
      currentPoints: pointsInCurrentLevel,
      pointsForNextLevel: pointsNeeded,
      title: title,
    );
  }

  static int _calculateLevel(int points) {
    // Fórmula: nivel = sqrt(puntos / 50)
    return (sqrt(points / 50)).floor() + 1;
  }

  static int _getPointsForLevel(int level) {
    // Puntos necesarios para alcanzar un nivel
    return ((level - 1) * (level - 1) * 50).toInt();
  }

  static String _getLevelTitle(int level) {
    if (level >= 50) return '🌟 Leyenda Suprema';
    if (level >= 40) return '👑 Maestro Absoluto';
    if (level >= 30) return '💎 Diamante';
    if (level >= 25) return '🏆 Campeón';
    if (level >= 20) return '⚡ Experto';
    if (level >= 15) return '🔥 Avanzado';
    if (level >= 10) return '⭐ Intermedio';
    if (level >= 5) return '🌱 Aprendiz';
    return '🥚 Novato';
  }

  static Color getColorForLevel(int level) {
    if (level >= 40) return Colors.purple;
    if (level >= 30) return Colors.cyan;
    if (level >= 20) return Colors.orange;
    if (level >= 10) return Colors.blue;
    if (level >= 5) return Colors.green;
    return Colors.grey;
  }
}

/// Desafío semanal
class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int targetValue;
  final ChallengeType type;
  final DateTime startDate;
  final DateTime endDate;
  int currentProgress;
  bool isCompleted;

  WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.currentProgress = 0,
    this.isCompleted = false,
  });

  double get progress => (currentProgress / targetValue).clamp(0.0, 1.0);

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetValue': targetValue,
        'type': type.toString(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'currentProgress': currentProgress,
        'isCompleted': isCompleted,
      };

  factory WeeklyChallenge.fromJson(Map<String, dynamic> json) {
    return WeeklyChallenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: Icons.flag,
      targetValue: json['targetValue'],
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ChallengeType.completions,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      currentProgress: json['currentProgress'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

enum ChallengeType {
  completions, // Completar N actividades
  perfectDays, // Lograr N días perfectos
  streak, // Mantener racha de N días
  variety, // Completar N actividades diferentes
}

/// Generador de desafíos semanales
class ChallengeGenerator {
  static WeeklyChallenge generateWeeklyChallenge() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final challenges = [
      WeeklyChallenge(
        id: 'weekly_completions',
        title: 'Semana Productiva',
        description: 'Completa 20 actividades esta semana',
        icon: Icons.check_circle,
        targetValue: 20,
        type: ChallengeType.completions,
        startDate: startOfWeek,
        endDate: endOfWeek,
      ),
      WeeklyChallenge(
        id: 'weekly_perfect',
        title: 'Días Perfectos',
        description: 'Logra 3 días perfectos esta semana',
        icon: Icons.star,
        targetValue: 3,
        type: ChallengeType.perfectDays,
        startDate: startOfWeek,
        endDate: endOfWeek,
      ),
      WeeklyChallenge(
        id: 'weekly_streak',
        title: 'Racha Semanal',
        description: 'Mantén una racha de 7 días',
        icon: Icons.local_fire_department,
        targetValue: 7,
        type: ChallengeType.streak,
        startDate: startOfWeek,
        endDate: endOfWeek,
      ),
      WeeklyChallenge(
        id: 'weekly_variety',
        title: 'Variedad',
        description: 'Completa al menos 5 actividades diferentes',
        icon: Icons.dashboard,
        targetValue: 5,
        type: ChallengeType.variety,
        startDate: startOfWeek,
        endDate: endOfWeek,
      ),
    ];

    // Rotar desafíos según la semana del año
    final weekOfYear = _getWeekOfYear(now);
    return challenges[weekOfYear % challenges.length];
  }

  static int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).floor();
  }
}

/// Recompensa por consistencia
class ConsistencyReward {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int daysRequired;
  bool isEarned;

  ConsistencyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.daysRequired,
    this.isEarned = false,
  });

  static List<ConsistencyReward> get all => [
        ConsistencyReward(
          id: 'consistency_7',
          title: 'Semana Perfecta',
          description: '7 días consecutivos sin fallar',
          icon: Icons.celebration,
          color: Colors.green,
          daysRequired: 7,
        ),
        ConsistencyReward(
          id: 'consistency_14',
          title: 'Quincena Impecable',
          description: '14 días consecutivos sin fallar',
          icon: Icons.auto_awesome,
          color: Colors.blue,
          daysRequired: 14,
        ),
        ConsistencyReward(
          id: 'consistency_30',
          title: 'Mes Legendario',
          description: '30 días consecutivos sin fallar',
          icon: Icons.military_tech,
          color: Colors.purple,
          daysRequired: 30,
        ),
        ConsistencyReward(
          id: 'consistency_60',
          title: 'Bimestre Épico',
          description: '60 días consecutivos sin fallar',
          icon: Icons.diamond,
          color: Colors.cyan,
          daysRequired: 60,
        ),
        ConsistencyReward(
          id: 'consistency_100',
          title: 'Centenario',
          description: '100 días consecutivos sin fallar',
          icon: Icons.emoji_events,
          color: Colors.amber,
          daysRequired: 100,
        ),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'isEarned': isEarned,
      };

  factory ConsistencyReward.fromJson(
      Map<String, dynamic> json, ConsistencyReward template) {
    return ConsistencyReward(
      id: template.id,
      title: template.title,
      description: template.description,
      icon: template.icon,
      color: template.color,
      daysRequired: template.daysRequired,
      isEarned: json['isEarned'] ?? false,
    );
  }
}
