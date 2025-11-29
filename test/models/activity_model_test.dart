import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/models/activity.dart';

void main() {
  group('Activity Model Tests', () {
    test('should create Activity from JSON', () {
      final json = {
        'id': '1',
        'name': 'Test Activity',
        'streak': 5,
        'active': true,
        'recurrenceType': 'daily',
      };

      final activity = Activity.fromJson(json);

      expect(activity.id, '1');
      expect(activity.name, 'Test Activity');
      expect(activity.streak, 5);
      expect(activity.active, true);
      expect(activity.recurrenceType, RecurrenceType.daily);
    });

    test('should serialize Activity to JSON', () {
      final activity = Activity(
        id: '1',
        name: 'Test Activity',
        streak: 5,
        recurrenceType: RecurrenceType.daily,
      );

      final json = activity.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test Activity');
      expect(json['streak'], 5);
      expect(json['recurrenceType'], 'daily');
    });

    test('shouldCompleteToday returns true for daily recurrence', () {
      final activity = Activity(
        id: '1',
        name: 'Daily Activity',
        recurrenceType: RecurrenceType.daily,
      );

      expect(activity.shouldCompleteToday(), true);
    });

    test('shouldCompleteToday respects specific days', () {
      // Assuming today is not -1 day. We need to be careful with DateTime.now() in tests.
      // Ideally we should mock the date, but for this simple logic we can check if it works for the current day.
      final now = DateTime.now();
      final todayWeekday = now.weekday;

      final activity = Activity(
        id: '1',
        name: 'Specific Day Activity',
        recurrenceType: RecurrenceType.specificDays,
        recurrenceDays: [todayWeekday],
      );

      expect(activity.shouldCompleteToday(), true);

      final otherDayActivity = Activity(
        id: '2',
        name: 'Other Day Activity',
        recurrenceType: RecurrenceType.specificDays,
        recurrenceDays: [todayWeekday == 1 ? 2 : 1], // Pick a different day
      );

      expect(otherDayActivity.shouldCompleteToday(), false);
    });

    test('getGoalProgress calculates correctly', () {
      final activity = Activity(
        id: '1',
        name: 'Goal Activity',
        streak: 5,
        targetDays: 10,
      );

      expect(activity.getGoalProgress(), 0.5);
    });

    test('hasReachedGoal returns true when streak meets target', () {
      final activity = Activity(
        id: '1',
        name: 'Goal Activity',
        streak: 10,
        targetDays: 10,
      );

      expect(activity.hasReachedGoal(), true);
    });
  });
}
