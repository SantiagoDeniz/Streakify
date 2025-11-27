import 'dart:developer' as developer;

/// Logging utility for the application
class Logger {
  static const String _tag = 'Streakify';

  /// Log debug messages
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 500, // Debug level
    );
  }

  /// Log info messages
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
    );
  }

  /// Log warning messages
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
    );
  }

  /// Log error messages
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log analytics events
  static void analytics(String event, {Map<String, dynamic>? parameters}) {
    developer.log(
      'Analytics Event: $event${parameters != null ? ' - $parameters' : ''}',
      name: '$_tag:Analytics',
      level: 800,
    );
  }

  /// Log performance metrics
  static void performance(String metric, {Map<String, dynamic>? data}) {
    developer.log(
      'Performance: $metric${data != null ? ' - $data' : ''}',
      name: '$_tag:Performance',
      level: 800,
    );
  }
}
