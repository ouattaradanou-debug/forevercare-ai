/// ============================================================================
/// ForeverCare AI
/// Configuration générale de la base de données
/// ============================================================================
///
/// Ce fichier ne contient QUE les constantes globales.
///
/// Les constantes propres à chaque module sont placées dans :
///
/// - client_constants.dart
/// - product_constants.dart
/// - order_constants.dart
/// - protocol_constants.dart
/// - appointment_constants.dart
///
abstract final class DatabaseConstants {
  DatabaseConstants._();

  /// Nom du fichier SQLite.
  static const String databaseName = 'forevercare.db';

  /// Version actuelle de la base.
  ///
  /// Version 1 :
  ///   - Clients
  ///
  /// Version 2 :
  ///   - Produits
  static const int databaseVersion = 2;
}