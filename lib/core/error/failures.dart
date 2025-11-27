/// Base class for all failures in the application
abstract class Failure {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// Failure when database operations fail
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.stackTrace]);
}

/// Failure when cache operations fail
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.stackTrace]);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.stackTrace]);
}

/// Failure when network operations fail
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

/// Failure when a resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.stackTrace]);
}

/// Failure when an operation is not permitted
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.stackTrace]);
}

/// Generic server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.stackTrace]);
}

/// Failure when parsing data fails
class ParsingFailure extends Failure {
  const ParsingFailure(super.message, [super.stackTrace]);
}
