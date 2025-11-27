import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/core/utils/logger.dart';

void main() {
  group('Logger Tests', () {
    test('Should log debug messages without errors', () {
      expect(() => Logger.debug('Test debug message'), returnsNormally);
    });

    test('Should log info messages without errors', () {
      expect(() => Logger.info('Test info message'), returnsNormally);
    });

    test('Should log warning messages without errors', () {
      expect(() => Logger.warning('Test warning message'), returnsNormally);
    });

    test('Should log error messages without errors', () {
      expect(
        () => Logger.error(
          'Test error message',
          error: Exception('Test exception'),
        ),
        returnsNormally,
      );
    });

    test('Should log analytics events without errors', () {
      expect(
        () => Logger.analytics('test_event', parameters: {'key': 'value'}),
        returnsNormally,
      );
    });

    test('Should log performance metrics without errors', () {
      expect(
        () => Logger.performance('test_metric', data: {'duration': 100}),
        returnsNormally,
      );
    });

    test('Should accept custom tags', () {
      expect(
        () => Logger.debug('Test message', tag: 'CustomTag'),
        returnsNormally,
      );
    });

    test('Should handle null error and stackTrace', () {
      expect(
        () => Logger.error('Error without exception'),
        returnsNormally,
      );
    });
  });
}
