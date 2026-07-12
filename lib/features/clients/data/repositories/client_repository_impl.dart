import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_local_datasource.dart';
import '../models/client_model.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl({required ClientLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final ClientLocalDataSource _localDataSource;

  @override
  Future<void> create(Client client) async {
    final model = ClientModel.fromEntity(client);

    await _localDataSource.insert(model);
  }

  @override
  Future<void> update(Client client) async {
    final model = ClientModel.fromEntity(client);

    await _localDataSource.update(model);
  }

  @override
  Future<void> delete(String id) async {
    await _localDataSource.delete(id);
  }

  @override
  Future<Client?> findById(String id) async {
    final model = await _localDataSource.findById(id);

    return model?.toEntity();
  }

  @override
  Future<List<Client>> findAll() async {
    final models = await _localDataSource.findAll();

    return models.map((model) => model.toEntity()).toList();
  }
}
