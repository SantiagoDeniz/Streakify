import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
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
    await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('Database Performance - Batch Inserts', () {
    test('should insert 100 activities efficiently', () async {
      final activities = _generateActivities(100);

      final stopwatch = Stopwatch()..start();

      for (var activity in activities) {
        await dbHelper.insertActivity(activity);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      print('Inserted 100 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should insert 500 activities efficiently', () async {
      final activities = _generateActivities(500);

      final stopwatch = Stopwatch()..start();

      for (var activity in activities) {
        await dbHelper.insertActivity(activity);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(25000));

      print('Inserted 500 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should insert 100 completions efficiently', () async {
      final activity = Activity(
        id: 'perf-test',
        name: 'Performance Test',
        recurrenceType: RecurrenceType.daily,
      );
      await dbHelper.insertActivity(activity);

      final completions = _generateCompletions('perf-test', 100);

      final stopwatch = Stopwatch()..start();

      for (var completion in completions) {
        await dbHelper.insertCompletion(completion);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      print('Inserted 100 completions in ${stopwatch.elapsedMilliseconds}ms');
    });
  });

  group('Database Performance - Queries', () {
    test('should query all activities efficiently with 500 records', () async {
      final activities = _generateActivities(500);
      for (var activity in activities) {
        await dbHelper.insertActivity(activity);
      }

      final stopwatch = Stopwatch()..start();

      final retrieved = await dbHelper.getAllActivities();

      stopwatch.stop();

      expect(retrieved.length, greaterThanOrEqualTo(500));
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      print('Queried 500+ activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should filter activities efficiently', () async {
      final activities = _generateActivities(200);
      for (var activity in activities) {
        await dbHelper.insertActivity(activity);
      }

      final stopwatch = Stopwatch()..start();

      final active = await dbHelper.getActiveActivities();

      stopwatch.stop();

      expect(active, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      print('Filtered active activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should query by category efficiently', () async {
      final category = Category(
        id: 'perf-cat',
        name: 'Performance Category',
        icon: Icons.flag,
        color: Colors.blue,
      );
      await dbHelper.insertCategory(category);

      final activities = _generateActivitiesWithCategory('perf-cat', 100);
      for (var activity in activities) {
        await dbHelper.insertActivity(activity);
      }

      final stopwatch = Stopwatch()..start();

      final retrieved = await dbHelper.getActivitiesByCategory('perf-cat');

      stopwatch.stop();

      expect(retrieved.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      print('Queried by category in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should query completion history efficiently', () async {
      final activity = Activity(
        id: 'history-test',
        name: 'History Test',
        recurrenceType: RecurrenceType.daily,
      );
      await dbHelper.insertActivity(activity);

      final completions = _generateCompletions('history-test', 200);
      for (var completion in completions) {
        await dbHelper.insertCompletion(completion);
      }

      final stopwatch = Stopwatch()..start();

      final history = await dbHelper.getCompletionHistory('history-test');

      stopwatch.stop();

      expect(history.length, equals(200));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      print('Queried 200 completions in ${stopwatch.elapsedMilliseconds}ms');
    });
  });

  group('Database Performance - Updates', () {
    test('should update 100 activities efficiently', () async {
      final activities = _generateActivities(100);
      for (var activity in activities) {
        await dbHelper.insertActivity(activity);
      }

      final stopwatch = Stopwatch()..start();

      for (var activity in activities) {
        final updated = activity.copyWith(streak: activity.streak + 1);
        await dbHelper.updateActivity(updated);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      print('Updated 100 activities in ${stopwatch.elapsedMilliseconds}ms');
    });
  });

  group('Database Performance - Deletes', () {
    test('should delete 100 activities efficiently', () async {
      final activities = _generateActivities(100);
      for (var activity in activities) {
        await dbHelper.insertActivity(activity);
      }

      final stopwatch = Stopwatch()..start();

      for (var activity in activities) {
        await dbHelper.deleteActivity(activity.id);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      print('Deleted 100 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should delete completions by activity efficiently', () async {
      final activity = Activity(
        id: 'delete-test',
        name: 'Delete Test',
        recurrenceType: RecurrenceType.daily,
      );
      await dbHelper.insertActivity(activity);

      final completions = _generateCompletions('delete-test', 100);
      for (var completion in completions) {
        await dbHelper.insertCompletion(completion);
      }

      final stopwatch = Stopwatch()..start();

      await dbHelper.deleteCompletionsByActivity('delete-test');

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      print('Deleted 100 completions in ${stopwatch.elapsedMilliseconds}ms');
    });
  });

  group('Database Performance - Complex Operations', () {
    test('should handle mixed operations efficiently', () async {
      final stopwatch = Stopwatch()..start();

      // Insert
      final activities = _generateActivities(50);
      for (var activity in activities) {
        await dbHelper.insertActivity(activity);
      }

      // Query
      await dbHelper.getAllActivities();

      // Update
      for (var activity in activities.take(25)) {
        final updated = activity.copyWith(streak: activity.streak + 1);
        await dbHelper.updateActivity(updated);
      }

      // Delete
      for (var activity in activities.skip(25)) {
        await dbHelper.deleteActivity(activity.id);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(10000));

      print('Mixed operations completed in ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}

/// Generate test activities
List<Activity> _generateActivities(int count) {
  return List.generate(count, (index) {
    return Activity(
      id: 'perf-test-$index',
      name: 'Performance Test Activity $index',
      recurrenceType:
          index % 2 == 0 ? RecurrenceType.daily : RecurrenceType.specificDays,
      streak: index % 100,
      active: index % 3 != 0,
    );
  });
}

/// Generate activities with specific category
List<Activity> _generateActivitiesWithCategory(String categoryId, int count) {
  return List.generate(count, (index) {
    return Activity(
      id: 'cat-test-$index',
      name: 'Category Test $index',
      recurrenceType: RecurrenceType.daily,
      categoryId: categoryId,
    );
  });
}

/// Generate completion history
List<CompletionHistory> _generateCompletions(String activityId, int count) {
  final now = DateTime.now();
  return List.generate(count, (index) {
    return CompletionHistory(
      id: 'completion-$activityId-$index',
      activityId: activityId,
      completedAt: now.subtract(Duration(days: index)),
    );
  });
}
