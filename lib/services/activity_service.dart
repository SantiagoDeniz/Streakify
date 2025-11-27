import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import 'database_helper.dart';

class ActivityService {
  static const String _oldKey = 'streakify_activities_v1';
  final DatabaseHelper _db = DatabaseHelper();
  bool _migrated = false;

  Future<List<Activity>> loadActivities() async {
    if (!_migrated) {
      await _migrateFromSharedPreferences();
      _migrated = true;
    }
    return await _db.getAllActivities();
  }

  Future<List<Activity>> loadActivitiesWithPagination(int page, int pageSize) async {
    if (!_migrated) {
      await _migrateFromSharedPreferences();
      _migrated = true;
    }
    return await _db.getActivitiesWithPagination(pageSize, page * pageSize);
  }

  Future<void> saveActivities(List<Activity> activities) async {
    for (var activity in activities) {
      final existing = await _db.getActivity(activity.id);
      if (existing != null) {
        await _db.updateActivity(activity);
      } else {
        await _db.insertActivity(activity);
      }
    }
  }

  Future<void> addActivity(Activity activity) async {
    await _db.insertActivity(activity);
  }

  Future<void> updateActivity(Activity activity) async {
    await _db.updateActivity(activity);
  }

  Future<void> deleteActivity(String id) async {
    await _db.deleteActivity(id);
  }

  Future<Activity?> getActivity(String id) async {
    return await _db.getActivity(id);
  }

  Future<List<Activity>> getActiveActivities() async {
    return await _db.getActiveActivities();
  }

  Future<List<Activity>> searchActivities(String query) async {
    return await _db.searchActivities(query);
  }

  Future<Map<String, dynamic>> getStatistics() async {
    return await _db.getStatistics();
  }

  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_oldKey);

      if (data == null || data.isEmpty) {
        return;
      }

      final existingActivities = await _db.getAllActivities();
      if (existingActivities.isNotEmpty) {
        return;
      }

      final list = jsonDecode(data) as List;
      final activities = list.map((e) => Activity.fromJson(e)).toList();

      for (var activity in activities) {
        await _db.insertActivity(activity);
      }

      print('Migrados  actividades de SharedPreferences a SQLite');
    } catch (e) {
      print('Error al migrar datos: ');
    }
  }

  Future<String> exportToJson() async {
    final activities = await _db.getAllActivities();
    final data = activities.map((e) => e.toJson()).toList();
    return jsonEncode(data);
  }

  Future<void> importFromJson(String jsonData) async {
    try {
      final list = jsonDecode(jsonData) as List;
      final activities = list.map((e) => Activity.fromJson(e)).toList();

      for (var activity in activities) {
        await _db.insertActivity(activity);
      }

      print('Importadas  actividades desde JSON');
    } catch (e) {
      print('Error al importar datos: ');
      rethrow;
    }
  }

  Future<void> deleteAllActivities() async {
    await _db.deleteAllActivities();
  }

  // Métodos para categorías y tags

  /// Obtener actividades por categoría
  Future<List<Activity>> getActivitiesByCategory(String categoryId) async {
    return await _db.getActivitiesByCategory(categoryId);
  }

  /// Obtener actividades por tag
  Future<List<Activity>> getActivitiesByTag(String tag) async {
    return await _db.getActivitiesByTag(tag);
  }

  /// Obtener todos los tags únicos usados en actividades
  Future<List<String>> getAllTags() async {
    final activities = await loadActivities();
    final Set<String> allTags = {};

    for (final activity in activities) {
      allTags.addAll(activity.tags);
    }

    final tagList = allTags.toList()..sort();
    return tagList;
  }

  /// Obtener tags más usados (con conteo)
  Future<Map<String, int>> getTagFrequency() async {
    final activities = await loadActivities();
    final Map<String, int> tagCount = {};

    for (final activity in activities) {
      for (final tag in activity.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }

    return tagCount;
  }

  /// Actualiza el horario de notificación de una actividad
  /// Usado por el sistema de auto-ajuste de horarios óptimos
  Future<void> updateActivityNotificationTime(
    String activityId,
    int hour,
    int minute,
  ) async {
    final activity = await getActivity(activityId);
    if (activity == null) return;

    // Actualizar horario
    activity.notificationHour = hour;
    activity.notificationMinute = minute;

    // Guardar cambios
    await updateActivity(activity);
  }
}
