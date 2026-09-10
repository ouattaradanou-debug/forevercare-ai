import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/sync_providers.dart';
import '../../../../data/local/database_provider.dart';
import '../../../../data/models/abonnement.dart';
import '../../../../data/models/atelier.dart';
import '../../../../data/models/utilisateur.dart';
import '../../../../data/repositories/atelier_repository.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/gabarit_repository.dart';
import '../../../../data/repositories/recuperation_compte_service.dart';
import '../../../../data/repositories/utilisateur_repository.dart';

final Provider<SupabaseClient> supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
    );

final Provider<AtelierRepository> atelierRepositoryProvider =
    Provider<AtelierRepository>(
      (ref) => AtelierRepository(
        ref.watch(supabaseClientProvider),
        ref.watch(appDatabaseProvider),
      ),
    );

final Provider<UtilisateurRepository> utilisateurRepositoryProvider =
    Provider<UtilisateurRepository>(
      (ref) => UtilisateurRepository(
        ref.watch(supabaseClientProvider),
        ref.watch(appDatabaseProvider),
      ),
    );

final Provider<GabaritRepository> gabaritRepositoryProvider =
    Provider<GabaritRepository>(
      (ref) => GabaritRepository(
        ref.watch(supabaseClientProvider),
        ref.watch(appDatabaseProvider),
      ),
    );

final Provider<RecuperationCompteService> recuperationCompteServiceProvider =
    Provider<RecuperationCompteService>(
      (ref) => RecuperationCompteService(
        ref.watch(atelierRepositoryProvider),
        ref.watch(utilisateurRepositoryProvider),
        ref.watch(gabaritRepositoryProvider),
        ref.watch(syncEngineProvider),
      ),
    );

/// Émet un événement à chaque connexion/déconnexion.
final StreamProvider<AuthState> etatAuthProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authRepositoryProvider).changementsEtat,
);

/// Identifiant de l'utilisateur connecté, recalculé à chaque changement
/// d'état d'authentification.
final Provider<String?> idUtilisateurConnecteProvider = Provider<String?>((
  ref,
) {
  ref.watch(etatAuthProvider);
  return Supabase.instance.client.auth.currentUser?.id;
});

/// Lecture hors-ligne d'abord : l'utilisateur courant vient du cache local,
/// alimenté par `RecuperationCompteService` après connexion.
final StreamProvider<Utilisateur?> utilisateurCourantProvider =
    StreamProvider<Utilisateur?>((ref) {
      final String? id = ref.watch(idUtilisateurConnecteProvider);
      if (id == null) return Stream<Utilisateur?>.value(null);
      return ref.watch(utilisateurRepositoryProvider).observerUtilisateurLocal(id);
    });

final StreamProvider<Atelier?> atelierCourantProvider =
    StreamProvider<Atelier?>((ref) {
      final Utilisateur? utilisateur = ref
          .watch(utilisateurCourantProvider)
          .asData?.value;
      if (utilisateur == null) return Stream<Atelier?>.value(null);
      return ref
          .watch(atelierRepositoryProvider)
          .observerAtelierLocal(utilisateur.atelierId);
    });

/// Abonnement (essai gratuit ou payant) de l'atelier courant — voir
/// HomePage, bandeau "Essai gratuit".
final StreamProvider<Abonnement?> abonnementCourantProvider =
    StreamProvider<Abonnement?>((ref) {
      final Utilisateur? utilisateur = ref
          .watch(utilisateurCourantProvider)
          .asData?.value;
      if (utilisateur == null) return Stream<Abonnement?>.value(null);
      return ref
          .watch(atelierRepositoryProvider)
          .observerAbonnementLocal(utilisateur.atelierId);
    });
