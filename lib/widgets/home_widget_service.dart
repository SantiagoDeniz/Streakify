import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/activity.dart';

class HomeWidgetService {
  static const String widgetDataKey = 'widget_activities';

  static Future<void> updateWidget(List<Activity> activities) async {
    try {
      final active = activities.where((a) => a.active).toList();
      final data = jsonEncode(active.map((e) => e.toJson()).toList());
      await HomeWidget.saveWidgetData<String>(widgetDataKey, data);
      await HomeWidget.updateWidget(
        name: 'com.streakify.streakify.StreakifyWidgetProvider',
        androidName: 'StreakifyWidgetProvider',
        iOSName: 'StreakifyWidget',
      );
    } catch (e) {
      // Widget no configurado todavía, se puede ignorar
      print('Widget not configured yet: $e');
    }
  }
}
