import 'package:flutter/material.dart';

/// Modelo de logro
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredValue;
  final AchievementType type;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredValue,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'requiredValue': requiredValue,
        'type': type.toString(),
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: Icons.emoji_events,
      color: Colors.amber,
      requiredValue: json['requiredValue'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AchievementType.streak,
      ),
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }
}

enum AchievementType {
  streak, // Racha consecutiva
  totalDays, // Total de días completados
  activities, // Número de actividades creadas
  perfect, // Días perfectos (todas completadas)
}

/// Logros predefinidos del juego
class PredefinedAchievements {
  static List<Achievement> get all => [
        // Logros de racha
        Achievement(
          id: 'streak_3',
          title: 'Primer Paso',
          description: 'Alcanza una racha de 3 días',
          icon: Icons.directions_walk,
          color: Colors.green,
          requiredValue: 3,
          type: AchievementType.streak,
        ),
        Achievement(
          id: 'streak_7',
          title: 'Una Semana Fuerte',
          description: 'Alcanza una racha de 7 días',
          icon: Icons.calendar_view_week,
          color: Colors.blue,
          requiredValue: 7,
          type: AchievementType.streak,
        ),
        Achievement(
          id: 'streak_14',
          title: 'Dos Semanas',
          description: 'Alcanza una racha de 14 días',
          icon: Icons.trending_up,
          color: Colors.purple,
          requiredValue: 14,
          type: AchievementType.streak,
        ),
        Achievement(
          id: 'streak_30',
          title: 'Mes Completo',
          description: 'Alcanza una racha de 30 días',
          icon: Icons.stars,
          color: Colors.orange,
          requiredValue: 30,
          type: AchievementType.streak,
        ),
        Achievement(
          id: 'streak_50',
          title: 'Medio Centenar',
          description: 'Alcanza una racha de 50 días',
          icon: Icons.military_tech,
          color: Colors.deepOrange,
          requiredValue: 50,
          type: AchievementType.streak,
        ),
        Achievement(
          id: 'streak_100',
          title: 'Centurión',
          description: 'Alcanza una racha de 100 días',
          icon: Icons.emoji_events,
          color: Colors.amber,
          requiredValue: 100,
          type: AchievementType.streak,
        ),

        // Logros de total de días
        Achievement(
          id: 'total_10',
          title: 'Comenzando',
          description: 'Completa 10 días en total',
          icon: Icons.check_circle_outline,
          color: Colors.lightGreen,
          requiredValue: 10,
          type: AchievementType.totalDays,
        ),
        Achievement(
          id: 'total_50',
          title: 'Persistente',
          description: 'Completa 50 días en total',
          icon: Icons.psychology,
          color: Colors.teal,
          requiredValue: 50,
          type: AchievementType.totalDays,
        ),
        Achievement(
          id: 'total_100',
          title: 'Dedicado',
          description: 'Completa 100 días en total',
          icon: Icons.diamond,
          color: Colors.cyan,
          requiredValue: 100,
          type: AchievementType.totalDays,
        ),
        Achievement(
          id: 'total_250',
          title: 'Maestro del Hábito',
          description: 'Completa 250 días en total',
          icon: Icons.workspace_premium,
          color: Colors.indigo,
          requiredValue: 250,
          type: AchievementType.totalDays,
        ),
        Achievement(
          id: 'total_500',
          title: 'Leyenda',
          description: 'Completa 500 días en total',
          icon: Icons.auto_awesome,
          color: Colors.pink,
          requiredValue: 500,
          type: AchievementType.totalDays,
        ),

        // Logros de actividades
        Achievement(
          id: 'activities_3',
          title: 'Multitarea',
          description: 'Crea 3 actividades',
          icon: Icons.list_alt,
          color: Colors.blueGrey,
          requiredValue: 3,
          type: AchievementType.activities,
        ),
        Achievement(
          id: 'activities_5',
          title: 'Organizador',
          description: 'Crea 5 actividades',
          icon: Icons.folder_special,
          color: Colors.brown,
          requiredValue: 5,
          type: AchievementType.activities,
        ),
        Achievement(
          id: 'activities_10',
          title: 'Planificador Experto',
          description: 'Crea 10 actividades',
          icon: Icons.dashboard_customize,
          color: Colors.deepPurple,
          requiredValue: 10,
          type: AchievementType.activities,
        ),

        // Logros de días perfectos
        Achievement(
          id: 'perfect_1',
          title: 'Día Perfecto',
          description: 'Completa todas tus actividades en un día',
          icon: Icons.star,
          color: Colors.yellow,
          requiredValue: 1,
          type: AchievementType.perfect,
        ),
        Achievement(
          id: 'perfect_7',
          title: 'Semana Perfecta',
          description: 'Completa 7 días perfectos',
          icon: Icons.star_rate,
          color: Colors.amber,
          requiredValue: 7,
          type: AchievementType.perfect,
        ),
        Achievement(
          id: 'perfect_30',
          title: 'Mes Perfecto',
          description: 'Completa 30 días perfectos',
          icon: Icons.stars,
          color: Colors.deepOrange,
          requiredValue: 30,
          type: AchievementType.perfect,
        ),
      ];
}
