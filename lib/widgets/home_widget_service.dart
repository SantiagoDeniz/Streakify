import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/activity.dart';

class HomeWidgetService {
  static const String widgetDataKey = 'widget_activities';

  static Future<void> updateWidget(List<Activity> activities) async {
    final active = activities.where((a) => a.active).toList();
    final data = jsonEncode(active.map((e) => e.toJson()).toList());
    await HomeWidget.saveWidgetData<String>(widgetDataKey, data);
    await HomeWidget.updateWidget(
      name: 'StreakifyWidgetProvider',
      iOSName: 'StreakifyWidget',
    );
  }
}