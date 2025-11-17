import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/activity.dart';

class HomeWidgetService {
  static const String widgetDataKey = 'widget_activities';

  static Future<void> updateWidget(List<Activity> activities) async {
    try {
      // Filtrar solo actividades activas y ordenar por racha (mayor a menor)
      final active = activities.where((a) => a.active).toList();
      active.sort((a, b) => b.streak.compareTo(a.streak));

      // Tomar solo las top 3
      final top3 = active.take(3).toList();

      // Convertir a JSON
      final data = jsonEncode(top3.map((e) => e.toJson()).toList());

      // Guardar en SharedPreferences del widget
      await HomeWidget.saveWidgetData<String>(widgetDataKey, data);

      // Actualizar el widget
      await HomeWidget.updateWidget(
        name: 'StreakifyWidget',
        androidName: 'StreakifyWidgetProvider',
        iOSName: 'StreakifyWidget',
      );

      print('✓ Widget actualizado con ${top3.length} actividades');
    } catch (e) {
      // Error al actualizar el widget
      print('⚠ Error al actualizar widget: $e');
    }
  }

  /// Inicializa el widget con datos vacíos
  static Future<void> initializeWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>(widgetDataKey, '[]');
      await HomeWidget.updateWidget(
        name: 'StreakifyWidget',
        androidName: 'StreakifyWidgetProvider',
        iOSName: 'StreakifyWidget',
      );
      print('✓ Widget inicializado');
    } catch (e) {
      print('⚠ Error al inicializar widget: $e');
    }
  }
}
