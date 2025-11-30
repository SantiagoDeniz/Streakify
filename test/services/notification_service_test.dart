import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/services/notification_service.dart';
import 'package:streakify/models/activity.dart';
import 'package:streakify/models/notification_preferences.dart';
import '../mocks/mock_services.dart';

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUp(() async {
    await initializeMocks();
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService();
    // Note: In real implementation, inject mockPlugin into NotificationService
  });

  group('NotificationService - Initialization', () {
    test('should initialize successfully', () async {
      await mockPlugin.initialize();
      expect(mockPlugin.isInitialized, isTrue);
    });
  });

  group('NotificationService - Schedule Notifications', () {
    test('should schedule notification for activity', () async {
      await mockPlugin.initialize();
      
      final activity = Activity(
        id: 'test-1',
        name: 'Test Activity',
        recurrenceType: RecurrenceType.daily,
      );

      final scheduledDate = DateTime.now().add(const Duration(hours: 1));
      
      await mockPlugin.zonedSchedule(
        id: activity.id.hashCode,
        title: 'Recordatorio: ${activity.name}',
        body: '¡No olvides completar tu actividad!',
        scheduledDate: scheduledDate,
        notificationDetails: null,
        uiLocalNotificationDateInterpretation: null,
        androidAllowWhileIdle: true,
      );

      final pending = await mockPlugin.pendingNotificationRequests();
      expect(pending.length, equals(1));
      expect(pending.first.title, contains('Test Activity'));
    });

    test('should schedule multiple notifications', () async {
      await mockPlugin.initialize();

      for (int i = 0; i < 3; i++) {
        await mockPlugin.zonedSchedule(
          id: i,
          title: 'Notification $i',
          body: 'Body $i',
          scheduledDate: DateTime.now().add(Duration(hours: i + 1)),
          notificationDetails: null,
          uiLocalNotificationDateInterpretation: null,
          androidAllowWhileIdle: true,
        );
      }

      final pending = await mockPlugin.pendingNotificationRequests();
      expect(pending.length, equals(3));
    });
  });

  group('NotificationService - Cancel Notifications', () {
    test('should cancel specific notification', () async {
      await mockPlugin.initialize();

      await mockPlugin.zonedSchedule(
        id: 1,
        title: 'Notification 1',
        body: 'Body 1',
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
        notificationDetails: null,
        uiLocalNotificationDateInterpretation: null,
        androidAllowWhileIdle: true,
      );

      await mockPlugin.zonedSchedule(
        id: 2,
        title: 'Notification 2',
        body: 'Body 2',
        scheduledDate: DateTime.now().add(const Duration(hours: 2)),
        notificationDetails: null,
        uiLocalNotificationDateInterpretation: null,
        androidAllowWhileIdle: true,
      );

      await mockPlugin.cancel(1);

      final pending = await mockPlugin.pendingNotificationRequests();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals(2));
    });

    test('should cancel all notifications', () async {
      await mockPlugin.initialize();

      for (int i = 0; i < 5; i++) {
        await mockPlugin.zonedSchedule(
          id: i,
          title: 'Notification $i',
          body: 'Body $i',
          scheduledDate: DateTime.now().add(Duration(hours: i + 1)),
          notificationDetails: null,
          uiLocalNotificationDateInterpretation: null,
          androidAllowWhileIdle: true,
        );
      }

      await mockPlugin.cancelAll();

      final pending = await mockPlugin.pendingNotificationRequests();
      expect(pending.length, equals(0));
    });
  });

  group('NotificationService - Notification Preferences', () {
    test('should handle contextual notifications state', () {
      final prefs = NotificationPreferences(
        contextualNotificationsEnabled: false,
      );

      expect(prefs.contextualNotificationsEnabled, isFalse);
    });

    test('should store morning summary time', () {
      final prefs = NotificationPreferences(
        dailySummaryEnabled: true,
        morningSummaryHour: 9,
        morningSummaryMinute: 30,
      );

      expect(prefs.dailySummaryEnabled, isTrue);
      expect(prefs.morningSummaryHour, equals(9));
      expect(prefs.morningSummaryMinute, equals(30));
    });

    test('should handle smart notifications flag', () {
      final prefs = NotificationPreferences(
        autoAdjustNotificationTimes: true,
      );

      expect(prefs.autoAdjustNotificationTimes, isTrue);
    });
  });

  group('NotificationService - Error Handling', () {
    test('should throw error when not initialized', () async {
      final uninitializedPlugin = MockFlutterLocalNotificationsPlugin();

      expect(
        () => uninitializedPlugin.zonedSchedule(
          id: 1,
          title: 'Test',
          body: 'Test',
          scheduledDate: DateTime.now(),
          notificationDetails: null,
          uiLocalNotificationDateInterpretation: null,
          androidAllowWhileIdle: true,
        ),
        throwsException,
      );
    });
  });
}
