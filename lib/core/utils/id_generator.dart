import 'dart:math';

/// ============================================================================
/// ForeverCare Framework
/// ID Generator
/// ============================================================================
///
/// Générateur officiel des identifiants de l'application.
///
/// Tous les modules doivent utiliser cette classe
/// au lieu de créer eux-mêmes des identifiants.
///
/// Exemples :
///
/// final id = IdGenerator.next();
///
/// final orderId = IdGenerator.next(prefix: 'CMD');
///
/// final productId = IdGenerator.next(prefix: 'PRD');
///
abstract final class IdGenerator {
  IdGenerator._();

  static final Random _random = Random();

  /// Génère un identifiant unique.
  static String next({
    String? prefix,
  }) {
    final timestamp =
        DateTime.now().microsecondsSinceEpoch;

    final random =
        _random.nextInt(999999).toString().padLeft(
              6,
              '0',
            );

    if (prefix == null || prefix.isEmpty) {
      return '${timestamp}_$random';
    }

    return '${prefix.toUpperCase()}_${timestamp}_$random';
  }
}