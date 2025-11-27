import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/core/error/failures.dart';

void main() {
  group('Failure Tests', () {
    test('DatabaseFailure should have correct message', () {
      const failure = DatabaseFailure('Database error');
      expect(failure.message, 'Database error');
      expect(failure.toString(), 'Database error');
    });

    test('CacheFailure should have correct message', () {
      const failure = CacheFailure('Cache error');
      expect(failure.message, 'Cache error');
    });

    test('ValidationFailure should have correct message', () {
      const failure = ValidationFailure('Validation error');
      expect(failure.message, 'Validation error');
    });

    test('NetworkFailure should have correct message', () {
      const failure = NetworkFailure('Network error');
      expect(failure.message, 'Network error');
    });

    test('NotFoundFailure should have correct message', () {
      const failure = NotFoundFailure('Not found error');
      expect(failure.message, 'Not found error');
    });

    test('PermissionFailure should have correct message', () {
      const failure = PermissionFailure('Permission error');
      expect(failure.message, 'Permission error');
    });

    test('ServerFailure should have correct message', () {
      const failure = ServerFailure('Server error');
      expect(failure.message, 'Server error');
    });

    test('ParsingFailure should have correct message', () {
      const failure = ParsingFailure('Parsing error');
      expect(failure.message, 'Parsing error');
    });

    test('Failure should store stackTrace', () {
      final stackTrace = StackTrace.current;
      final failure = DatabaseFailure('Error', stackTrace);
      expect(failure.stackTrace, stackTrace);
    });
  });
}
