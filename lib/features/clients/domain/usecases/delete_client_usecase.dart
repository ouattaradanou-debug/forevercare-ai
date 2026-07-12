import '../repositories/client_repository.dart';

/// Cas d'utilisation : supprimer un client.
///
/// Toute la logique métier liée à la suppression
/// d'un client passera par cette classe.
class DeleteClientUseCase {
  const DeleteClientUseCase(this._repository);

  final ClientRepository _repository;

  /// Supprime un client à partir de son identifiant.
  Future<void> call(String id) async {
    await _repository.delete(id);
  }
}
