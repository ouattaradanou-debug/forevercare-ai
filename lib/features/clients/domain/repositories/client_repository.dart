import '../entities/client.dart';

/// Contrat du repository des clients.
///
/// Le Domain connaît uniquement cette interface.
/// Il ignore totalement SQLite, sqflite,
/// les modèles de données et toute autre technologie.
abstract interface class ClientRepository {
  /// Crée un nouveau client.
  Future<void> create(Client client);

  /// Met à jour un client.
  Future<void> update(Client client);

  /// Supprime un client.
  Future<void> delete(String id);

  /// Recherche un client par son identifiant.
  Future<Client?> findById(String id);

  /// Retourne tous les clients.
  Future<List<Client>> findAll();
}
