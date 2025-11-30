import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/models/activity.dart';
import '../mocks/mock_services.dart';

void main() {
  setUp(() async {
    await initializeMocks();
  });

  group('List Performance Tests', () {
    test('should handle 100 activities efficiently', () {
      final stopwatch = Stopwatch()..start();
      
      final activities = _generateActivities(100);
      
      stopwatch.stop();
      
      expect(activities.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      
      print('Generated 100 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should handle 500 activities efficiently', () {
      final stopwatch = Stopwatch()..start();
      
      final activities = _generateActivities(500);
      
      stopwatch.stop();
      
      expect(activities.length, equals(500));
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      
      print('Generated 500 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should handle 1000 activities efficiently', () {
      final stopwatch = Stopwatch()..start();
      
      final activities = _generateActivities(1000);
      
      stopwatch.stop();
      
      expect(activities.length, equals(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      print('Generated 1000 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should filter 1000 activities efficiently', () {
      final activities = _generateActivities(1000);
      
      final stopwatch = Stopwatch()..start();
      
      final activeActivities = activities.where((a) => a.active).toList();
      
      stopwatch.stop();
      
      expect(activeActivities.length, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      
      print('Filtered 1000 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should sort 1000 activities efficiently', () {
      final activities = _generateActivities(1000);
      
      final stopwatch = Stopwatch()..start();
      
      activities.sort((a, b) => b.streak.compareTo(a.streak));
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      
      print('Sorted 1000 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should search in 1000 activities efficiently', () {
      final activities = _generateActivities(1000);
      
      final stopwatch = Stopwatch()..start();
      
      final results = activities.where(
        (a) => a.name.toLowerCase().contains('activity 500')
      ).toList();
      
      stopwatch.stop();
      
      expect(results.length, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      
      print('Searched 1000 activities in ${stopwatch.elapsedMilliseconds}ms');
    });
  });

  group('Serialization Performance Tests', () {
    test('should serialize 100 activities efficiently', () {
      final activities = _generateActivities(100);
      
      final stopwatch = Stopwatch()..start();
      
      for (var activity in activities) {
        activity.toJson();
      }
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
      
      print('Serialized 100 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should deserialize 100 activities efficiently', () {
      final activities = _generateActivities(100);
      final jsonList = activities.map((a) => a.toJson()).toList();
      
      final stopwatch = Stopwatch()..start();
      
      for (var json in jsonList) {
        Activity.fromJson(json);
      }
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
      
      print('Deserialized 100 activities in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should handle round-trip serialization for 500 activities', () {
      final activities = _generateActivities(500);
      
      final stopwatch = Stopwatch()..start();
      
      final jsonList = activities.map((a) => a.toJson()).toList();
      final deserialized = jsonList.map((j) => Activity.fromJson(j)).toList();
      
      stopwatch.stop();
      
      expect(deserialized.length, equals(500));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      print('Round-trip serialization for 500 activities in ${stopwatch.elapsedMilliseconds}ms');
    });
  });

  group('Memory Performance Tests', () {
    test('should not cause memory issues with 1000 activities', () {
      final activities = _generateActivities(1000);
      
      // Verify all activities are created
      expect(activities.length, equals(1000));
      
      // Perform operations that might cause memory issues
      for (int i = 0; i < 10; i++) {
        final filtered = activities.where((a) => a.streak > i).toList();
        expect(filtered, isNotEmpty);
      }
      
      print('Memory test completed successfully with 1000 activities');
    });

    test('should handle repeated list operations', () {
      final activities = _generateActivities(500);
      
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 100; i++) {
        final sorted = List<Activity>.from(activities);
        sorted.sort((a, b) => a.name.compareTo(b.name));
      }
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      
      print('100 sort operations on 500 activities in ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}

/// Generate test activities
List<Activity> _generateActivities(int count) {
  return List.generate(count, (index) {
    return Activity(
      id: 'test-$index',
      name: 'Activity $index',
      recurrenceType: index % 2 == 0 
          ? RecurrenceType.daily 
          : RecurrenceType.specificDays,
      streak: index % 100,
      active: index % 3 != 0,
      targetDays: (index % 50) + 10,
    );
  });
}
