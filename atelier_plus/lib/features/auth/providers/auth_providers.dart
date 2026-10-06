import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/atelier.dart';
import '../../../data/models/role_utilisateur.dart';
import '../../../data/models/utilisateur.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../data/apprenti_repository.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

final apprentiRepositoryProvider = Provider<ApprentiRepository>((ref) {
  return ApprentiRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(baseLocaleProvider),
  );
});

/// Utilisateur actuellement connecté, lu depuis le cache local (donc
/// disponible hors-ligne) et recalculé à chaque changement d'état
/// d'authentification Supabase (connexion/déconnexion).
final utilisateurCourantProvider = FutureProvider<Utilisateur?>((ref) async {
  ref.watch(etatAuthProvider);
  final repo = ref.watch(authRepositoryProvider);
  return repo.sessionHorsLigne();
});

final estProprietaireProvider = Provider<bool>((ref) {
  final utilisateur = ref.watch(utilisateurCourantProvider).valueOrNull;
  return utilisateur?.estProprietaire ?? false;
});

/// Atelier de l'utilisateur connecté, lu depuis le cache local.
final atelierCourantProvider = FutureProvider<Atelier?>((ref) async {
  final utilisateur = await ref.watch(utilisateurCourantProvider.future);
  if (utilisateur == null) return null;

  final baseLocale = ref.watch(baseLocaleProvider);
  final ligne = await baseLocale.atelierParId(utilisateur.atelierId);
  if (ligne == null) return null;

  return Atelier(
    id: ligne.id,
    nom: ligne.nom,
    logoUrl: ligne.logoUrl,
    signatureUrl: ligne.signatureUrl,
    updatedAt: ligne.updatedAt,
  );
});

/// Utilisateurs (propriétaire + apprentis) de l'atelier courant, lus depuis
/// le cache local — consultable hors-ligne, y compris l'écran "Gérer mes
/// apprentis".
final utilisateursDeLAtelierProvider = StreamProvider<List<Utilisateur>>((ref) async* {
  final utilisateur = await ref.watch(utilisateurCourantProvider.future);
  if (utilisateur == null) {
    yield const [];
    return;
  }
  final baseLocale = ref.watch(baseLocaleProvider);
  yield* baseLocale.observerUtilisateursDeLAtelier(utilisateur.atelierId).map(
        (lignes) => lignes
            .map(
              (ligne) => Utilisateur(
                id: ligne.id,
                atelierId: ligne.atelierId,
                nom: ligne.nom,
                telephone: ligne.telephone,
                role: RoleUtilisateur.depuisTexte(ligne.role),
                updatedAt: ligne.updatedAt,
              ),
            )
            .toList(),
      );
});
