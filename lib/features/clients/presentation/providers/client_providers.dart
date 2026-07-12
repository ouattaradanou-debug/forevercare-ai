import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/client_local_datasource.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/create_client_usecase.dart';
import '../../domain/usecases/get_all_clients_usecase.dart';
import '../../domain/usecases/update_client_usecase.dart';
import '../../domain/usecases/delete_client_usecase.dart';

/// DataSource locale
final clientLocalDataSourceProvider = Provider<ClientLocalDataSource>(
  (ref) => ClientLocalDataSource(),
);

/// Repository
final clientRepositoryProvider = Provider<ClientRepository>(
  (ref) => ClientRepositoryImpl(
    localDataSource: ref.read(clientLocalDataSourceProvider),
  ),
);

/// UseCase : création
final createClientUseCaseProvider = Provider<CreateClientUseCase>(
  (ref) => CreateClientUseCase(ref.read(clientRepositoryProvider)),
);

/// UseCase : modification
final updateClientUseCaseProvider = Provider<UpdateClientUseCase>(
  (ref) => UpdateClientUseCase(ref.read(clientRepositoryProvider)),
);

/// UseCase : suppression
final deleteClientUseCaseProvider = Provider<DeleteClientUseCase>(
  (ref) => DeleteClientUseCase(ref.read(clientRepositoryProvider)),
);

/// UseCase : lecture
final getAllClientsUseCaseProvider = Provider<GetAllClientsUseCase>(
  (ref) => GetAllClientsUseCase(ref.read(clientRepositoryProvider)),
);

/// Liste des clients
final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final useCase = ref.read(getAllClientsUseCaseProvider);

  return useCase();
});
