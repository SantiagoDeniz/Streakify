/// Base class for all exceptions in the application
class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when database operations fail
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.stackTrace]);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException(super.message, [super.stackTrace]);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(super.message, [super.stackTrace]);

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(super.message, [super.stackTrace]);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.stackTrace]);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when an operation is not permitted
class PermissionException extends AppException {
  const PermissionException(super.message, [super.stackTrace]);

  @override
  String toString() => 'PermissionException: $message';
}

/// Exception thrown when server operations fail
class ServerException extends AppException {
  const ServerException(super.message, [super.stackTrace]);

  @override
  String toString() => 'ServerException: $message';
}

/// Exception thrown when parsing data fails
class ParsingException extends AppException {
  const ParsingException(super.message, [super.stackTrace]);

  @override
  String toString() => 'ParsingException: $message';
}
