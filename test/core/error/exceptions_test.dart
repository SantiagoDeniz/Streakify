import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/core/error/exceptions.dart';

void main() {
  group('Exception Tests', () {
    test('DatabaseException should have correct message and toString', () {
      const exception = DatabaseException('Database error');
      expect(exception.message, 'Database error');
      expect(exception.toString(), 'DatabaseException: Database error');
    });

    test('CacheException should have correct message and toString', () {
      const exception = CacheException('Cache error');
      expect(exception.message, 'Cache error');
      expect(exception.toString(), 'CacheException: Cache error');
    });

    test('ValidationException should have correct message and toString', () {
      const exception = ValidationException('Validation error');
      expect(exception.message, 'Validation error');
      expect(exception.toString(), 'ValidationException: Validation error');
    });

    test('NetworkException should have correct message and toString', () {
      const exception = NetworkException('Network error');
      expect(exception.message, 'Network error');
      expect(exception.toString(), 'NetworkException: Network error');
    });

    test('NotFoundException should have correct message and toString', () {
      const exception = NotFoundException('Not found error');
      expect(exception.message, 'Not found error');
      expect(exception.toString(), 'NotFoundException: Not found error');
    });

    test('PermissionException should have correct message and toString', () {
      const exception = PermissionException('Permission error');
      expect(exception.message, 'Permission error');
      expect(exception.toString(), 'PermissionException: Permission error');
    });

    test('ServerException should have correct message and toString', () {
      const exception = ServerException('Server error');
      expect(exception.message, 'Server error');
      expect(exception.toString(), 'ServerException: Server error');
    });

    test('ParsingException should have correct message and toString', () {
      const exception = ParsingException('Parsing error');
      expect(exception.message, 'Parsing error');
      expect(exception.toString(), 'ParsingException: Parsing error');
    });

    test('Exception should store stackTrace', () {
      final stackTrace = StackTrace.current;
      final exception = DatabaseException('Error', stackTrace);
      expect(exception.stackTrace, stackTrace);
    });

    test('AppException should have correct toString', () {
      const exception = AppException('Generic error');
      expect(exception.toString(), 'AppException: Generic error');
    });
  });
}
