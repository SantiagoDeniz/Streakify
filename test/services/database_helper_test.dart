import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/services/database_helper.dart';
import 'package:streakify/models/activity.dart';
import 'package:streakify/models/category.dart';
import 'package:streakify/models/completion_history.dart';
import '../mocks/mock_services.dart';

void main() {
  late DatabaseHelper dbHelper;

  setUp(() async {
    await initializeMocks();
    dbHelper = DatabaseHelper();
    await dbHelper.database; // Initialize database
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('DatabaseHelper - Activity CRUD', () {
    test('should insert and retrieve activity', () async {
      final activity = Activity(
        id: 'test-1',
        name: 'Test Activity',
        recurrenceType: RecurrenceType.daily,
      );

      await dbHelper.insertActivity(activity);
      final retrieved = await dbHelper.getActivity('test-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-1'));
      expect(retrieved.name, equals('Test Activity'));
      expect(retrieved.recurrenceType, equals(RecurrenceType.daily));
    });

    test('should update activity', () async {
      final activity = Activity(
        id: 'test-2',
        name: 'Original Name',
        recurrenceType: RecurrenceType.daily,
      );

      await dbHelper.insertActivity(activity);
      
      final updated = activity.copyWith(name: 'Updated Name');
      await dbHelper.updateActivity(updated);
      
      final retrieved = await dbHelper.getActivity('test-2');
      expect(retrieved!.name, equals('Updated Name'));
    });

    test('should delete activity', () async {
      final activity = Activity(
        id: 'test-3',
        name: 'To Delete',
        recurrenceType: RecurrenceType.daily,
      );

      await dbHelper.insertActivity(activity);
      await dbHelper.deleteActivity('test-3');
      
      final retrieved = await dbHelper.getActivity('test-3');
      expect(retrieved, isNull);
    });

    test('should get all activities', () async {
      final activities = [
        Activity(id: 'test-4', name: 'Activity 1', recurrenceType: RecurrenceType.daily),
        Activity(id: 'test-5', name: 'Activity 2', recurrenceType: RecurrenceType.daily),
        Activity(id: 'test-6', name: 'Activity 3', recurrenceType: RecurrenceType.daily),
      ];

      for (var activity in activities) {
        await dbHelper.insertActivity(activity);
      }

      final retrieved = await dbHelper.getAllActivities();
      expect(retrieved.length, greaterThanOrEqualTo(3));
    });

    test('should filter active activities', () async {
      final activeActivity = Activity(
        id: 'test-7',
        name: 'Active',
        recurrenceType: RecurrenceType.daily,
        active: true,
      );
      
      final inactiveActivity = Activity(
        id: 'test-8',
        name: 'Inactive',
        recurrenceType: RecurrenceType.daily,
        active: false,
      );

      await dbHelper.insertActivity(activeActivity);
      await dbHelper.insertActivity(inactiveActivity);

      final active = await dbHelper.getActiveActivities();
      final inactive = await dbHelper.getInactiveActivities();

      expect(active.any((a) => a.id == 'test-7'), isTrue);
      expect(inactive.any((a) => a.id == 'test-8'), isTrue);
    });
  });

  group('DatabaseHelper - Category CRUD', () {
    test('should insert and retrieve category', () async {
      final category = Category(
        id: 'cat-1',
        name: 'Test Category',
        icon: 'work',
        color: 'blue',
      );

      await dbHelper.insertCategory(category);
      final retrieved = await dbHelper.getCategory('cat-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Test Category'));
    });

    test('should get all categories', () async {
      final categories = [
        Category(id: 'cat-2', name: 'Work', icon: 'work', color: 'blue'),
        Category(id: 'cat-3', name: 'Personal', icon: 'person', color: 'green'),
      ];

      for (var category in categories) {
        await dbHelper.insertCategory(category);
      }

      final retrieved = await dbHelper.getAllCategories();
      expect(retrieved.length, greaterThanOrEqualTo(2));
    });

    test('should delete category', () async {
      final category = Category(
        id: 'cat-4',
        name: 'To Delete',
        icon: 'delete',
        color: 'red',
      );

      await dbHelper.insertCategory(category);
      await dbHelper.deleteCategory('cat-4');
      
      final retrieved = await dbHelper.getCategory('cat-4');
      expect(retrieved, isNull);
    });
  });

  group('DatabaseHelper - Completion History', () {
    test('should insert completion', () async {
      final activity = Activity(
        id: 'test-9',
        name: 'Activity for Completion',
        recurrenceType: RecurrenceType.daily,
      );
      await dbHelper.insertActivity(activity);

      final completion = CompletionHistory(
        id: 'comp-1',
        activityId: 'test-9',
        completedAt: DateTime.now(),
      );

      await dbHelper.insertCompletion(completion);
      final history = await dbHelper.getCompletionHistory('test-9');

      expect(history.length, equals(1));
      expect(history.first.activityId, equals('test-9'));
    });

    test('should get all completions', () async {
      final activity1 = Activity(
        id: 'test-10',
        name: 'Activity 1',
        recurrenceType: RecurrenceType.daily,
      );
      final activity2 = Activity(
        id: 'test-11',
        name: 'Activity 2',
        recurrenceType: RecurrenceType.daily,
      );

      await dbHelper.insertActivity(activity1);
      await dbHelper.insertActivity(activity2);

      await dbHelper.insertCompletion(CompletionHistory(
        id: 'comp-2',
        activityId: 'test-10',
        completedAt: DateTime.now(),
      ));
      
      await dbHelper.insertCompletion(CompletionHistory(
        id: 'comp-3',
        activityId: 'test-11',
        completedAt: DateTime.now(),
      ));

      final allCompletions = await dbHelper.getAllCompletions();
      expect(allCompletions.length, greaterThanOrEqualTo(2));
    });

    test('should delete completions by activity', () async {
      final activity = Activity(
        id: 'test-12',
        name: 'Activity',
        recurrenceType: RecurrenceType.daily,
      );
      await dbHelper.insertActivity(activity);

      await dbHelper.insertCompletion(CompletionHistory(
        id: 'comp-4',
        activityId: 'test-12',
        completedAt: DateTime.now(),
      ));

      await dbHelper.deleteCompletionsByActivity('test-12');
      final history = await dbHelper.getCompletionHistory('test-12');

      expect(history.length, equals(0));
    });
  });

  group('DatabaseHelper - Complex Queries', () {
    test('should get activities by category', () async {
      final category = Category(
        id: 'cat-5',
        name: 'Fitness',
        icon: 'fitness',
        color: 'orange',
      );
      await dbHelper.insertCategory(category);

      final activity = Activity(
        id: 'test-13',
        name: 'Gym',
        recurrenceType: RecurrenceType.daily,
        categoryId: 'cat-5',
      );
      await dbHelper.insertActivity(activity);

      final activities = await dbHelper.getActivitiesByCategory('cat-5');
      expect(activities.any((a) => a.id == 'test-13'), isTrue);
    });

    test('should get activities by tag', () async {
      final activity = Activity(
        id: 'test-14',
        name: 'Tagged Activity',
        recurrenceType: RecurrenceType.daily,
        tags: ['health', 'fitness'],
      );
      await dbHelper.insertActivity(activity);

      final activities = await dbHelper.getActivitiesByTag('health');
      expect(activities.any((a) => a.id == 'test-14'), isTrue);
    });

    test('should get completions in date range', () async {
      final activity = Activity(
        id: 'test-15',
        name: 'Activity',
        recurrenceType: RecurrenceType.daily,
      );
      await dbHelper.insertActivity(activity);

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      await dbHelper.insertCompletion(CompletionHistory(
        id: 'comp-5',
        activityId: 'test-15',
        completedAt: now,
      ));

      final completions = await dbHelper.getCompletionsInRange(
        yesterday,
        tomorrow,
      );

      expect(completions.length, greaterThanOrEqualTo(1));
    });
  });

  group('DatabaseHelper - Error Handling', () {
    test('should return null for non-existent activity', () async {
      final retrieved = await dbHelper.getActivity('non-existent');
      expect(retrieved, isNull);
    });

    test('should handle duplicate activity ID', () async {
      final activity = Activity(
        id: 'duplicate',
        name: 'Original',
        recurrenceType: RecurrenceType.daily,
      );

      await dbHelper.insertActivity(activity);
      
      // Second insert with same ID should replace
      final duplicate = Activity(
        id: 'duplicate',
        name: 'Replaced',
        recurrenceType: RecurrenceType.daily,
      );
      await dbHelper.insertActivity(duplicate);

      final retrieved = await dbHelper.getActivity('duplicate');
      expect(retrieved!.name, equals('Replaced'));
    });
  });
}
