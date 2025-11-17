import 'package:flutter/material.dart';

/// Tipos de widgets disponibles para el dashboard
enum DashboardWidgetType {
  totalActivities,
  activeStreak,
  todayProgress,
  weekProgress,
  bestStreak,
  totalDays,
  perfectDays,
  recentAchievements,
  upcomingTasks,
  timeRemaining,
}

/// Modelo de widget del dashboard
class DashboardWidget {
  final String id;
  final DashboardWidgetType type;
  final String title;
  final IconData icon;
  int order;
  bool isVisible;

  DashboardWidget({
    required this.id,
    required this.type,
    required this.title,
    required this.icon,
    required this.order,
    this.isVisible = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'order': order,
        'isVisible': isVisible,
      };

  factory DashboardWidget.fromJson(Map<String, dynamic> json) {
    return DashboardWidget(
      id: json['id'],
      type: DashboardWidgetType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => DashboardWidgetType.totalActivities,
      ),
      title: json['title'],
      icon: Icons.widgets, // Default, se actualiza según tipo
      order: json['order'],
      isVisible: json['isVisible'] ?? true,
    );
  }

  DashboardWidget copyWith({
    String? id,
    DashboardWidgetType? type,
    String? title,
    IconData? icon,
    int? order,
    bool? isVisible,
  }) {
    return DashboardWidget(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// Widgets predefinidos del dashboard
class PredefinedDashboardWidgets {
  static List<DashboardWidget> get all => [
        DashboardWidget(
          id: 'total_activities',
          type: DashboardWidgetType.totalActivities,
          title: 'Total de Actividades',
          icon: Icons.list_alt,
          order: 0,
        ),
        DashboardWidget(
          id: 'active_streak',
          type: DashboardWidgetType.activeStreak,
          title: 'Rachas Activas',
          icon: Icons.local_fire_department,
          order: 1,
        ),
        DashboardWidget(
          id: 'today_progress',
          type: DashboardWidgetType.todayProgress,
          title: 'Progreso de Hoy',
          icon: Icons.today,
          order: 2,
        ),
        DashboardWidget(
          id: 'week_progress',
          type: DashboardWidgetType.weekProgress,
          title: 'Progreso Semanal',
          icon: Icons.calendar_view_week,
          order: 3,
        ),
        DashboardWidget(
          id: 'best_streak',
          type: DashboardWidgetType.bestStreak,
          title: 'Mejor Racha',
          icon: Icons.emoji_events,
          order: 4,
        ),
        DashboardWidget(
          id: 'total_days',
          type: DashboardWidgetType.totalDays,
          title: 'Días Totales',
          icon: Icons.calendar_month,
          order: 5,
        ),
        DashboardWidget(
          id: 'perfect_days',
          type: DashboardWidgetType.perfectDays,
          title: 'Días Perfectos',
          icon: Icons.star,
          order: 6,
        ),
        DashboardWidget(
          id: 'recent_achievements',
          type: DashboardWidgetType.recentAchievements,
          title: 'Logros Recientes',
          icon: Icons.workspace_premium,
          order: 7,
        ),
        DashboardWidget(
          id: 'upcoming_tasks',
          type: DashboardWidgetType.upcomingTasks,
          title: 'Próximas Tareas',
          icon: Icons.pending_actions,
          order: 8,
        ),
        DashboardWidget(
          id: 'time_remaining',
          type: DashboardWidgetType.timeRemaining,
          title: 'Tiempo Restante',
          icon: Icons.timer,
          order: 9,
        ),
      ];
}
