import '../entities/client.dart';
import '../repositories/client_repository.dart';

/// Cas d'utilisation : créer un client.
///
/// Toute la logique métier liée à la création
/// d'un client passera par cette classe.
class CreateClientUseCase {
  const CreateClientUseCase(this._repository);

  final ClientRepository _repository;

  /// Exécute la création du client.
  Future<void> call(Client client) async {
    await _repository.create(client);
  }
}
