import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWidgetService {
  static const String widgetDataKey = 'widget_activities';
  static const String widgetStatsKey = 'widget_stats';
  static const String widgetThemeKey = 'widget_theme';
  static const String widgetSelectedActivitiesKey = 'widget_selected_activities';

  /// Actualiza todos los widgets con los datos más recientes
  static Future<void> updateWidget(List<Activity> activities) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedIds = prefs.getStringList(widgetSelectedActivitiesKey) ?? [];
      final isDark = prefs.getBool(widgetThemeKey) ?? false;

      // 1. Preparar datos de actividades
      List<Activity> targetActivities;
      
      if (selectedIds.isNotEmpty) {
        // Si hay selección manual, usar esas actividades
        targetActivities = activities
            .where((a) => selectedIds.contains(a.id))
            .toList();
            
        // Rellenar con las mejores rachas si faltan para llegar a 3
        if (targetActivities.length < 3) {
          final remaining = activities
              .where((a) => !selectedIds.contains(a.id) && a.active)
              .toList()
            ..sort((a, b) => b.streak.compareTo(a.streak));
          
          targetActivities.addAll(remaining.take(3 - targetActivities.length));
        }
      } else {
        // Si no, usar las top 3 por racha
        targetActivities = activities.where((a) => a.active).toList()
          ..sort((a, b) => b.streak.compareTo(a.streak));
        targetActivities = targetActivities.take(3).toList();
      }

      // Guardar datos de actividades
      final activitiesData = jsonEncode({
        'activities': targetActivities.map((e) => e.toJson()).toList(),
        'isDark': isDark,
      });
      await HomeWidget.saveWidgetData<String>(widgetDataKey, activitiesData);

      // 2. Preparar datos de estadísticas
      final totalStreak = activities.fold(0, (sum, a) => sum + a.streak);
      final activeCount = activities.where((a) => a.active).toList().length;
      final bestStreak = activities.isEmpty 
          ? 0 
          : activities.map((a) => a.streak).reduce((curr, next) => curr > next ? curr : next);
      
      final statsData = jsonEncode({
        'totalStreak': totalStreak,
        'activeCount': activeCount,
        'bestStreak': bestStreak,
        'isDark': isDark,
      });
      await HomeWidget.saveWidgetData<String>(widgetStatsKey, statsData);

      // 3. Actualizar Widgets
      // Widget Principal (Grande, Mediano, Pequeño usan el mismo provider base en este plugin, 
      // pero definiremos nombres específicos si usamos providers separados)
      await HomeWidget.updateWidget(
        name: 'StreakifyWidgetProvider',
        androidName: 'StreakifyWidgetProvider',
        iOSName: 'StreakifyWidget',
      );

      // Widget de Estadísticas
      await HomeWidget.updateWidget(
        name: 'StreakifyStatsWidgetProvider',
        androidName: 'StreakifyStatsWidgetProvider',
        iOSName: 'StreakifyStatsWidget',
      );

      print('✓ Widgets actualizados: ${targetActivities.length} actividades, Stats: $totalStreak dias');
    } catch (e) {
      print('⚠ Error al actualizar widget: $e');
    }
  }

  /// Guarda la configuración de tema del widget
  static Future<void> setWidgetTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(widgetThemeKey, isDark);
    // No actualizamos inmediatamente, se actualizará con el próximo cambio de datos
    // o se puede forzar una actualización si se tiene acceso a las actividades
  }

  /// Guarda la selección manual de actividades
  static Future<void> setSelectedActivities(List<String> activityIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(widgetSelectedActivitiesKey, activityIds);
  }

  /// Inicializa el widget con datos vacíos
  static Future<void> initializeWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>(widgetDataKey, '{"activities":[], "isDark":false}');
      await HomeWidget.saveWidgetData<String>(widgetStatsKey, '{"totalStreak":0, "activeCount":0, "bestStreak":0, "isDark":false}');
      
      await HomeWidget.updateWidget(
        name: 'StreakifyWidgetProvider',
        androidName: 'StreakifyWidgetProvider',
        iOSName: 'StreakifyWidget',
      );
      
      await HomeWidget.updateWidget(
        name: 'StreakifyStatsWidgetProvider',
        androidName: 'StreakifyStatsWidgetProvider',
        iOSName: 'StreakifyStatsWidget',
      );
      print('✓ Widgets inicializados');
    } catch (e) {
      print('⚠ Error al inicializar widget: $e');
    }
  }
}
