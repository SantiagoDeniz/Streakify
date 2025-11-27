/// Application-wide constants
class AppConstants {
  // App info
  static const String appName = 'Streakify';
  static const String appVersion = '0.0.1';

  // Database
  static const String databaseName = 'streakify.db';
  static const int databaseVersion = 1;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Streak settings
  static const int defaultStreakWarningHours = 2;
  static const int maxProtectorsPerMonth = 5;

  // Notification settings
  static const int defaultNotificationHour = 9;
  static const int defaultNotificationMinute = 0;

  // Analytics
  static const String analyticsEnabled = 'analytics_enabled';
  static const String crashlyticsEnabled = 'crashlytics_enabled';

  // Feature flags (default values)
  static const bool defaultEnableNewStatisticsUI = false;
  static const bool defaultEnableSocialFeatures = false;
  static const bool defaultEnableAdvancedGamification = true;
  static const bool defaultEnableExperimentalThemes = false;

  // Cache
  static const Duration cacheDuration = Duration(minutes: 5);
  static const int maxCacheSize = 100;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration databaseTimeout = Duration(seconds: 10);

  // Limits
  static const int maxActivitiesInFreeVersion = 5;
  static const int maxActivitiesInPremium = 999;
  static const int maxTagsPerActivity = 10;
  static const int maxNotesLength = 1000;

  // UI
  static const double minTouchTargetSize = 44.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Accessibility
  static const double minTextScaleFactor = 0.8;
  static const double maxTextScaleFactor = 2.0;
  static const double defaultTextScaleFactor = 1.0;
}
