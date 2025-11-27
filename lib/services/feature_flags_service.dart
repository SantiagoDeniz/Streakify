import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import '../core/config/feature_flags.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';

/// Service for managing feature flags via Firebase Remote Config
class FeatureFlagsService {
  static final FeatureFlagsService _instance = FeatureFlagsService._internal();
  factory FeatureFlagsService() => _instance;
  FeatureFlagsService._internal();

  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;

  /// Initialize Remote Config
  Future<void> initialize() async {
    if (_initialized) {
      Logger.warning('FeatureFlagsService already initialized');
      return;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set config settings
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 1) // Short interval for testing
              : const Duration(hours: 1), // Production interval
        ),
      );

      // Set default values
      await _remoteConfig!.setDefaults(_getDefaultValues());

      // Fetch and activate
      await _remoteConfig!.fetchAndActivate();

      _initialized = true;
      Logger.info('FeatureFlagsService initialized successfully');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to initialize FeatureFlagsService',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - app should work with default values
    }
  }

  /// Get default feature flag values
  Map<String, dynamic> _getDefaultValues() {
    return {
      // UI Features
      FeatureFlags.enableNewStatisticsUI:
          AppConstants.defaultEnableNewStatisticsUI,
      FeatureFlags.enableSocialFeatures:
          AppConstants.defaultEnableSocialFeatures,
      FeatureFlags.enableAdvancedGamification:
          AppConstants.defaultEnableAdvancedGamification,
      FeatureFlags.enableExperimentalThemes:
          AppConstants.defaultEnableExperimentalThemes,

      // Functionality Features
      FeatureFlags.enableTeamStreaks: false,
      FeatureFlags.enablePomodoroMode: false,
      FeatureFlags.enableHealthIntegration: false,
      FeatureFlags.enableVirtualCoach: false,

      // Performance Features
      FeatureFlags.enableLazyLoading: true,
      FeatureFlags.enableImageCache: true,
      FeatureFlags.enableOptimizedRenders: true,

      // Experimental Features
      FeatureFlags.enableTimeMachine: false,
      FeatureFlags.enableResilienceMode: false,
      FeatureFlags.enableMonthlyThemes: false,

      // Premium Features
      FeatureFlags.enableUnlimitedActivities: true, // Free for now
      FeatureFlags.enableCloudBackup: false,
      FeatureFlags.enableAdvancedStats: true,
      FeatureFlags.enablePremiumThemes: false,

      // A/B Testing
      FeatureFlags.onboardingVariant: 'default',
      FeatureFlags.notificationStrategy: 'standard',
      FeatureFlags.gamificationLevel: 'medium',
    };
  }

  /// Get boolean feature flag
  bool getBool(String key) {
    if (!_initialized || _remoteConfig == null) {
      final defaultValue = _getDefaultValues()[key] as bool? ?? false;
      Logger.debug('Feature flag $key not initialized, using default: $defaultValue');
      return defaultValue;
    }

    try {
      final value = _remoteConfig!.getBool(key);
      Logger.debug('Feature flag $key: $value');
      return value;
    } catch (e) {
      Logger.warning('Failed to get feature flag $key, using default');
      return _getDefaultValues()[key] as bool? ?? false;
    }
  }

  /// Get string feature flag
  String getString(String key) {
    if (!_initialized || _remoteConfig == null) {
      final defaultValue = _getDefaultValues()[key] as String? ?? '';
      Logger.debug('Feature flag $key not initialized, using default: $defaultValue');
      return defaultValue;
    }

    try {
      final value = _remoteConfig!.getString(key);
      Logger.debug('Feature flag $key: $value');
      return value;
    } catch (e) {
      Logger.warning('Failed to get feature flag $key, using default');
      return _getDefaultValues()[key] as String? ?? '';
    }
  }

  /// Get integer feature flag
  int getInt(String key) {
    if (!_initialized || _remoteConfig == null) {
      final defaultValue = _getDefaultValues()[key] as int? ?? 0;
      Logger.debug('Feature flag $key not initialized, using default: $defaultValue');
      return defaultValue;
    }

    try {
      final value = _remoteConfig!.getInt(key);
      Logger.debug('Feature flag $key: $value');
      return value;
    } catch (e) {
      Logger.warning('Failed to get feature flag $key, using default');
      return _getDefaultValues()[key] as int? ?? 0;
    }
  }

  /// Get double feature flag
  double getDouble(String key) {
    if (!_initialized || _remoteConfig == null) {
      final defaultValue = _getDefaultValues()[key] as double? ?? 0.0;
      Logger.debug('Feature flag $key not initialized, using default: $defaultValue');
      return defaultValue;
    }

    try {
      final value = _remoteConfig!.getDouble(key);
      Logger.debug('Feature flag $key: $value');
      return value;
    } catch (e) {
      Logger.warning('Failed to get feature flag $key, using default');
      return _getDefaultValues()[key] as double? ?? 0.0;
    }
  }

  /// Fetch latest config from server
  Future<void> fetch() async {
    if (!_initialized || _remoteConfig == null) {
      Logger.warning('Cannot fetch - FeatureFlagsService not initialized');
      return;
    }

    try {
      await _remoteConfig!.fetchAndActivate();
      Logger.info('Feature flags fetched and activated');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to fetch feature flags',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _initialized;

  // Convenience getters for common feature flags

  bool get enableNewStatisticsUI =>
      getBool(FeatureFlags.enableNewStatisticsUI);

  bool get enableSocialFeatures =>
      getBool(FeatureFlags.enableSocialFeatures);

  bool get enableAdvancedGamification =>
      getBool(FeatureFlags.enableAdvancedGamification);

  bool get enableExperimentalThemes =>
      getBool(FeatureFlags.enableExperimentalThemes);

  bool get enableTeamStreaks =>
      getBool(FeatureFlags.enableTeamStreaks);

  bool get enablePomodoroMode =>
      getBool(FeatureFlags.enablePomodoroMode);

  bool get enableHealthIntegration =>
      getBool(FeatureFlags.enableHealthIntegration);

  bool get enableVirtualCoach =>
      getBool(FeatureFlags.enableVirtualCoach);

  String get onboardingVariant =>
      getString(FeatureFlags.onboardingVariant);

  String get notificationStrategy =>
      getString(FeatureFlags.notificationStrategy);

  String get gamificationLevel =>
      getString(FeatureFlags.gamificationLevel);
}
