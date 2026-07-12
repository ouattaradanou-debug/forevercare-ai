import '../entities/client.dart';
import '../repositories/client_repository.dart';

/// Cas d'utilisation : modifier un client.
///
/// Toute la logique métier liée à la modification
/// d'un client passera par cette classe.
class UpdateClientUseCase {
  const UpdateClientUseCase(this._repository);

  final ClientRepository _repository;

  /// Met à jour un client existant.
  Future<void> call(Client client) async {
    await _repository.update(client);
  }
}
