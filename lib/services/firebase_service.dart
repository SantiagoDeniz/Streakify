import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../core/utils/logger.dart';
import '../core/analytics/analytics_events.dart';

/// Service for managing Firebase integrations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;

  bool _initialized = false;

  /// Initialize Firebase services
  Future<void> initialize() async {
    if (_initialized) {
      Logger.warning('Firebase already initialized');
      return;
    }

    try {
      await Firebase.initializeApp();
      
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable Crashlytics collection
      await _crashlytics?.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = (errorDetails) {
        _crashlytics?.recordFlutterFatalError(errorDetails);
        Logger.error(
          'Flutter Error',
          error: errorDetails.exception,
          stackTrace: errorDetails.stack,
        );
      };

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics?.recordError(error, stack, fatal: true);
        Logger.error(
          'Async Error',
          error: error,
          stackTrace: stack,
        );
        return true;
      };

      _initialized = true;
      Logger.info('Firebase initialized successfully');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to initialize Firebase',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - app should work without Firebase
    }
  }

  /// Log an analytics event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_initialized || _analytics == null) {
      Logger.debug('Analytics not initialized, skipping event: $name');
      return;
    }

    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters,
      );
      Logger.analytics(name, parameters: parameters);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to log analytics event: $name',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log a screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      Logger.analytics('screen_view', parameters: {
        'screen_name': screenName,
        'screen_class': screenClass,
      });
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to log screen view: $screenName',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: userId);
      await _crashlytics?.setUserIdentifier(userId ?? '');
      Logger.info('User ID set: $userId');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to set user ID',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set user property for analytics
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.setUserProperty(name: name, value: value);
      Logger.info('User property set: $name = $value');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to set user property: $name',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Record a non-fatal error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_initialized || _crashlytics == null) {
      Logger.error(
        reason ?? 'Error occurred',
        error: exception,
        stackTrace: stackTrace,
      );
      return;
    }

    try {
      await _crashlytics!.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      // Also log to analytics
      await logEvent(
        name: AnalyticsEvents.errorOccurred,
        parameters: {
          AnalyticsEvents.paramErrorType: exception.runtimeType.toString(),
          AnalyticsEvents.paramErrorMessage: exception.toString(),
          if (reason != null) 'reason': reason,
        },
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to record error to Crashlytics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set custom key for crash reports
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_initialized || _crashlytics == null) return;

    try {
      await _crashlytics!.setCustomKey(key, value);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to set custom key: $key',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log a message to Crashlytics
  Future<void> log(String message) async {
    if (!_initialized || _crashlytics == null) return;

    try {
      await _crashlytics!.log(message);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to log message to Crashlytics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if Firebase is initialized
  bool get isInitialized => _initialized;

  /// Get analytics instance
  FirebaseAnalytics? get analytics => _analytics;

  /// Get crashlytics instance
  FirebaseCrashlytics? get crashlytics => _crashlytics;
}
