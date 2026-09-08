import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database_provider.dart';
import '../../../../data/models/brouillon_client.dart';
import '../../../../data/models/client.dart';
import '../../../../data/repositories/brouillon_repository.dart';
import '../../../../data/repositories/client_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final Provider<ClientRepository> clientRepositoryProvider =
    Provider<ClientRepository>(
      (ref) => ClientRepository(
        ref.watch(supabaseClientProvider),
        ref.watch(appDatabaseProvider),
      ),
    );

final Provider<BrouillonRepository> brouillonRepositoryProvider =
    Provider<BrouillonRepository>(
      (ref) => BrouillonRepository(ref.watch(appDatabaseProvider)),
    );

/// Brouillon en cours de l'utilisateur connecté (un seul à la fois).
final StreamProvider<BrouillonClient?> brouillonActuelProvider =
    StreamProvider<BrouillonClient?>((ref) {
      final String? id = ref.watch(idUtilisateurConnecteProvider);
      if (id == null) return Stream<BrouillonClient?>.value(null);
      return ref.watch(brouillonRepositoryProvider).observer(id);
    });

/// Clients officiellement créés (avec au moins une mesure, par
/// construction — voir ClientRepository).
final StreamProvider<List<Client>> clientsProvider = StreamProvider<List<Client>>((
  ref,
) {
  final atelier = ref.watch(atelierCourantProvider).asData?.value;
  if (atelier == null) return Stream<List<Client>>.value(const []);
  return ref.watch(clientRepositoryProvider).observerClients(atelier.id);
});
