import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mock services for testing
/// This file provides centralized mocks for external dependencies

/// Initialize all mocks for testing
Future<void> initializeMocks() async {
  // Initialize SharedPreferences mock
  SharedPreferences.setMockInitialValues({});

  // Initialize sqflite_ffi for database testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Mock SharedPreferences with custom initial values
void setupMockSharedPreferences(Map<String, Object> initialValues) {
  SharedPreferences.setMockInitialValues(initialValues);
}

/// Mock notification plugin for testing
class MockFlutterLocalNotificationsPlugin {
  final List<PendingNotification> _scheduledNotifications = [];
  bool _initialized = false;

  Future<bool> initialize() async {
    _initialized = true;
    return true;
  }

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required dynamic notificationDetails,
    required dynamic uiLocalNotificationDateInterpretation,
    required bool androidAllowWhileIdle,
    dynamic payload,
  }) async {
    if (!_initialized) {
      throw Exception('Plugin not initialized');
    }

    _scheduledNotifications.add(PendingNotification(
      id: id,
      title: title,
      body: body,
      payload: payload?.toString(),
    ));
  }

  Future<void> cancel(int id) async {
    _scheduledNotifications.removeWhere((n) => n.id == id);
  }

  Future<void> cancelAll() async {
    _scheduledNotifications.clear();
  }

  Future<List<PendingNotification>> pendingNotificationRequests() async {
    return List.from(_scheduledNotifications);
  }

  bool get isInitialized => _initialized;
  List<PendingNotification> get scheduledNotifications =>
      List.from(_scheduledNotifications);
}

/// Pending notification model for testing
class PendingNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  PendingNotification({
    required this.id,
    this.title,
    this.body,
    this.payload,
  });
}

/// Mock file system for testing
class MockFileSystem {
  final Map<String, String> _files = {};
  final Set<String> _directories = {};

  void writeFile(String path, String content) {
    _files[path] = content;
  }

  String? readFile(String path) {
    return _files[path];
  }

  bool fileExists(String path) {
    return _files.containsKey(path);
  }

  void createDirectory(String path) {
    _directories.add(path);
  }

  bool directoryExists(String path) {
    return _directories.contains(path);
  }

  void deleteFile(String path) {
    _files.remove(path);
  }

  void deleteDirectory(String path) {
    _directories.remove(path);
  }

  void clear() {
    _files.clear();
    _directories.clear();
  }

  List<String> listFiles(String directory) {
    return _files.keys.where((path) => path.startsWith(directory)).toList();
  }
}
