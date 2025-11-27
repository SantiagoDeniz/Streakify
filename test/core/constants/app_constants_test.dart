import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/core/constants/app_constants.dart';

void main() {
  group('AppConstants Tests', () {
    test('App info constants should have correct values', () {
      expect(AppConstants.appName, 'Streakify');
      expect(AppConstants.appVersion, '0.0.1');
    });

    test('Database constants should have correct values', () {
      expect(AppConstants.databaseName, 'streakify.db');
      expect(AppConstants.databaseVersion, 1);
    });

    test('Pagination constants should have correct values', () {
      expect(AppConstants.defaultPageSize, 20);
      expect(AppConstants.maxPageSize, 100);
    });

    test('Streak settings should have correct values', () {
      expect(AppConstants.defaultStreakWarningHours, 2);
      expect(AppConstants.maxProtectorsPerMonth, 5);
    });

    test('Notification settings should have correct values', () {
      expect(AppConstants.defaultNotificationHour, 9);
      expect(AppConstants.defaultNotificationMinute, 0);
    });

    test('Feature flags defaults should have correct values', () {
      expect(AppConstants.defaultEnableNewStatisticsUI, false);
      expect(AppConstants.defaultEnableSocialFeatures, false);
      expect(AppConstants.defaultEnableAdvancedGamification, true);
      expect(AppConstants.defaultEnableExperimentalThemes, false);
    });

    test('Cache constants should have correct values', () {
      expect(AppConstants.cacheDuration, const Duration(minutes: 5));
      expect(AppConstants.maxCacheSize, 100);
    });

    test('Timeout constants should have correct values', () {
      expect(AppConstants.networkTimeout, const Duration(seconds: 30));
      expect(AppConstants.databaseTimeout, const Duration(seconds: 10));
    });

    test('Limits should have correct values', () {
      expect(AppConstants.maxActivitiesInFreeVersion, 5);
      expect(AppConstants.maxActivitiesInPremium, 999);
      expect(AppConstants.maxTagsPerActivity, 10);
      expect(AppConstants.maxNotesLength, 1000);
    });

    test('UI constants should have correct values', () {
      expect(AppConstants.minTouchTargetSize, 44.0);
      expect(AppConstants.defaultAnimationDuration, const Duration(milliseconds: 300));
      expect(AppConstants.longAnimationDuration, const Duration(milliseconds: 500));
    });

    test('Accessibility constants should have correct values', () {
      expect(AppConstants.minTextScaleFactor, 0.8);
      expect(AppConstants.maxTextScaleFactor, 2.0);
      expect(AppConstants.defaultTextScaleFactor, 1.0);
    });
  });
}
