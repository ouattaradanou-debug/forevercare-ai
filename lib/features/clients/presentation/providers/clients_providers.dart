import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database_provider.dart';
import '../../../../data/models/brouillon_client.dart';
import '../../../../data/models/client.dart';
import '../../../../data/models/mesure.dart';
import '../../../../data/models/photo.dart';
import '../../../../data/models/rendez_vous.dart';
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

/// Historique des mesures d'un client (la plus récente en premier).
final mesuresClientProvider = StreamProvider.family<List<Mesure>, String>((
  ref,
  clientId,
) {
  return ref.watch(clientRepositoryProvider).observerMesuresClient(clientId);
});

/// Photos (tissu + modèle) d'un client.
final photosClientProvider = StreamProvider.family<List<Photo>, String>((
  ref,
  clientId,
) {
  return ref.watch(clientRepositoryProvider).observerPhotosClient(clientId);
});

/// Rendez-vous planifiés pour un client.
final rendezVousClientProvider = StreamProvider.family<List<RendezVous>, String>(
  (ref, clientId) {
    return ref
        .watch(clientRepositoryProvider)
        .observerRendezVousClient(clientId);
  },
);

/// Tous les rendez-vous de l'atelier, du plus proche au plus lointain —
/// pour l'écran "Rendez-vous" et le compteur du jour sur l'accueil.
final rendezVousAtelierProvider =
    StreamProvider<List<RendezVousAvecClient>>((ref) {
      final atelier = ref.watch(atelierCourantProvider).asData?.value;
      if (atelier == null) return Stream<List<RendezVousAvecClient>>.value(const []);
      return ref
          .watch(clientRepositoryProvider)
          .observerRendezVousAtelier(atelier.id);
    });

/// Nombre de rendez-vous prévus aujourd'hui, tous clients confondus.
final rendezVousAujourdhuiCompteProvider = Provider<int>((ref) {
  final List<RendezVousAvecClient> tous =
      ref.watch(rendezVousAtelierProvider).asData?.value ?? const [];
  final DateTime maintenant = DateTime.now();
  return tous.where((r) {
    final DateTime d = r.rendezVous.dateHeure;
    return d.year == maintenant.year &&
        d.month == maintenant.month &&
        d.day == maintenant.day;
  }).length;
});
