import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';

class ActivityService {
  static const String _key = 'streakify_activities_v1';

  Future<List<Activity>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Activity.fromJson(e)).toList();
  }

  Future<void> saveActivities(List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(activities.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }
}