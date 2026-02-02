/// Custom exception classes for the application
///
/// Provides a hierarchy of exceptions for different error scenarios.
/// These exceptions are used throughout the app for consistent error handling.

/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  const AppException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// ============================================================================
// NETWORK EXCEPTIONS
// ============================================================================

/// Exception thrown when there is no internet connection
class NetworkException extends AppException {
  const NetworkException([
    String message = 'No internet connection',
    int? code,
  ]) : super(message, code: code);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when the request times out
class TimeoutException extends AppException {
  const TimeoutException([
    String message = 'Request timeout',
    int? code,
  ]) : super(message, code: code);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Exception thrown when the server returns an error
class ServerException extends AppException {
  const ServerException([
    String message = 'Server error occurred',
    int? code,
    dynamic details,
  ]) : super(message, code: code, details: details);

  @override
  String toString() =>
      'ServerException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when the API request is cancelled
class RequestCancelledException extends AppException {
  const RequestCancelledException([
    String message = 'Request was cancelled',
  ]) : super(message);

  @override
  String toString() => 'RequestCancelledException: $message';
}

// ============================================================================
// AUTHENTICATION EXCEPTIONS
// ============================================================================

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  const AuthenticationException([
    String message = 'Authentication failed',
    int? code,
  ]) : super(message, code: code);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exception thrown when user credentials are invalid
class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([
    String message = 'Invalid email or password',
  ]) : super(message, code: 401);

  @override
  String toString() => 'InvalidCredentialsException: $message';
}

/// Exception thrown when the user is not authorized
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    String message = 'Unauthorized access',
  ]) : super(message, code: 401);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception thrown when the user doesn't have permission
class ForbiddenException extends AppException {
  const ForbiddenException([
    String message = 'Access forbidden',
  ]) : super(message, code: 403);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Exception thrown when the session expires
class SessionExpiredException extends AppException {
  const SessionExpiredException([
    String message = 'Session expired. Please login again.',
  ]) : super(message, code: 401);

  @override
  String toString() => 'SessionExpiredException: $message';
}

// ============================================================================
// DATA EXCEPTIONS
// ============================================================================

/// Exception thrown when cached data is not found
class CacheException extends AppException {
  const CacheException([
    String message = 'Cache error occurred',
  ]) : super(message);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when data parsing fails
class DataParsingException extends AppException {
  const DataParsingException([
    String message = 'Failed to parse data',
    dynamic details,
  ]) : super(message, details: details);

  @override
  String toString() => 'DataParsingException: $message';
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException([
    String message = 'Resource not found',
  ]) : super(message, code: 404);

  @override
  String toString() => 'NotFoundException: $message';
}

// ============================================================================
// VALIDATION EXCEPTIONS
// ============================================================================

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException([
    String message = 'Validation error',
    this.errors,
  ]) : super(message, code: 422);

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final errorList = errors!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return 'ValidationException: $message ($errorList)';
    }
    return 'ValidationException: $message';
  }
}

/// Exception thrown when required field is empty
class RequiredFieldException extends ValidationException {
  const RequiredFieldException(String fieldName)
      : super('$fieldName is required');

  @override
  String toString() => message;
}

/// Exception thrown when email format is invalid
class InvalidEmailException extends ValidationException {
  const InvalidEmailException() : super('Invalid email format');

  @override
  String toString() => message;
}

/// Exception thrown when password is too short
class WeakPasswordException extends ValidationException {
  const WeakPasswordException()
      : super('Password must be at least 6 characters');

  @override
  String toString() => message;
}

// ============================================================================
// STORAGE EXCEPTIONS
// ============================================================================

/// Exception thrown when storage operation fails
class StorageException extends AppException {
  const StorageException([
    String message = 'Storage operation failed',
    dynamic details,
  ]) : super(message, details: details);

  @override
  String toString() => 'StorageException: $message';
}

/// Exception thrown when reading from storage fails
class StorageReadException extends StorageException {
  const StorageReadException([
    String message = 'Failed to read from storage',
  ]) : super(message);

  @override
  String toString() => 'StorageReadException: $message';
}

/// Exception thrown when writing to storage fails
class StorageWriteException extends StorageException {
  const StorageWriteException([
    String message = 'Failed to write to storage',
  ]) : super(message);

  @override
  String toString() => 'StorageWriteException: $message';
}

// ============================================================================
// BUSINESS LOGIC EXCEPTIONS
// ============================================================================

/// Exception thrown when a business rule is violated
class BusinessRuleException extends AppException {
  const BusinessRuleException(
    String message, {
    int? code,
  }) : super(message, code: code);

  @override
  String toString() => 'BusinessRuleException: $message';
}

/// Exception thrown when an operation conflicts with existing data
class ConflictException extends AppException {
  const ConflictException([
    String message = 'Conflict with existing data',
  ]) : super(message, code: 409);

  @override
  String toString() => 'ConflictException: $message';
}

// ============================================================================
// UNKNOWN EXCEPTION
// ============================================================================

/// Exception thrown when an unknown error occurs
class UnknownException extends AppException {
  const UnknownException([
    String message = 'An unknown error occurred',
    dynamic details,
  ]) : super(message, details: details);

  @override
  String toString() => 'UnknownException: $message${details != null ? ' - Details: $details' : ''}';
}
