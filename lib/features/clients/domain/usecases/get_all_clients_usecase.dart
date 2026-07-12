import '../entities/client.dart';
import '../repositories/client_repository.dart';

/// Cas d'utilisation : récupérer tous les clients.
///
/// Toute la logique métier liée à la consultation
/// des clients passera par cette classe.
class GetAllClientsUseCase {
  const GetAllClientsUseCase(this._repository);

  final ClientRepository _repository;

  /// Retourne tous les clients enregistrés.
  Future<List<Client>> call() async {
    return _repository.findAll();
  }
}
