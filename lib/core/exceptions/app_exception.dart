/// ============================================================================
/// ForeverCare Framework
/// Exceptions
/// ============================================================================
///
/// Classe de base de toutes les exceptions métier.
///
/// Toutes les exceptions de l'application doivent hériter
/// de AppException.
///
/// Exemple :
///
/// throw ValidationException(...)
///
/// throw DatabaseException(...)
///
abstract class AppException implements Exception {
  const AppException({
    required this.message,
  });

  /// Message destiné à l'utilisateur ou aux logs.
  final String message;

  @override
  String toString() => message;
}

/// Exception de validation.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
  });
}

/// Exception liée à SQLite.
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
  });
}

/// Exception liée à une ressource inexistante.
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
  });
}

/// Exception de conflit métier.
class ConflictException extends AppException {
  const ConflictException({
    required super.message,
  });
}

/// Exception inattendue.
class UnknownAppException extends AppException {
  const UnknownAppException({
    required super.message,
  });
}