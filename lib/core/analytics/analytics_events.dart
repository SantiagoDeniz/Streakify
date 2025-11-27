/// Analytics event names and parameters
class AnalyticsEvents {
  // Activity events
  static const String activityCreated = 'activity_created';
  static const String activityCompleted = 'activity_completed';
  static const String activityDeleted = 'activity_deleted';
  static const String activityArchived = 'activity_archived';
  static const String activityRestored = 'activity_restored';
  static const String activityEdited = 'activity_edited';

  // Streak events
  static const String streakMilestone = 'streak_milestone';
  static const String streakLost = 'streak_lost';
  static const String streakRecovered = 'streak_recovered';
  static const String streakFrozen = 'streak_frozen';
  static const String protectorUsed = 'protector_used';

  // Achievement events
  static const String achievementUnlocked = 'achievement_unlocked';
  static const String levelUp = 'level_up';
  static const String challengeCompleted = 'challenge_completed';

  // Theme events
  static const String themeChanged = 'theme_changed';
  static const String customThemeCreated = 'custom_theme_created';
  static const String autoThemeEnabled = 'auto_theme_enabled';

  // Notification events
  static const String notificationScheduled = 'notification_scheduled';
  static const String notificationReceived = 'notification_received';
  static const String notificationTapped = 'notification_tapped';
  static const String optimalTimeAdjusted = 'optimal_time_adjusted';

  // Social events
  static const String achievementShared = 'achievement_shared';
  static const String groupJoined = 'group_joined';
  static const String buddyAdded = 'buddy_added';
  static const String leaderboardViewed = 'leaderboard_viewed';

  // Data events
  static const String dataExported = 'data_exported';
  static const String dataImported = 'data_imported';
  static const String backupCreated = 'backup_created';
  static const String backupRestored = 'backup_restored';

  // Personalization events
  static const String languageChanged = 'language_changed';
  static const String fontChanged = 'font_changed';
  static const String textSizeChanged = 'text_size_changed';
  static const String densityChanged = 'density_changed';

  // Accessibility events
  static const String highContrastEnabled = 'high_contrast_enabled';
  static const String reduceMotionEnabled = 'reduce_motion_enabled';
  static const String screenReaderUsed = 'screen_reader_used';

  // Feature usage events
  static const String widgetAdded = 'widget_added';
  static const String statisticsViewed = 'statistics_viewed';
  static const String calendarViewed = 'calendar_viewed';
  static const String dashboardCustomized = 'dashboard_customized';

  // Error events
  static const String errorOccurred = 'error_occurred';
  static const String crashReported = 'crash_reported';

  // Parameter keys
  static const String paramActivityId = 'activity_id';
  static const String paramActivityName = 'activity_name';
  static const String paramActivityCategory = 'activity_category';
  static const String paramStreakCount = 'streak_count';
  static const String paramAchievementId = 'achievement_id';
  static const String paramAchievementName = 'achievement_name';
  static const String paramThemeName = 'theme_name';
  static const String paramNotificationType = 'notification_type';
  static const String paramExportFormat = 'export_format';
  static const String paramLanguage = 'language';
  static const String paramFontFamily = 'font_family';
  static const String paramErrorType = 'error_type';
  static const String paramErrorMessage = 'error_message';
  static const String paramFeatureName = 'feature_name';
  static const String paramScreenName = 'screen_name';
  static const String paramValue = 'value';
  static const String paramSuccess = 'success';
}
