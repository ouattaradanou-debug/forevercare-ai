import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';
import '../../../data/models/champ_mesure.dart';
import '../../../data/models/type_tenue.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/gabarits_repository.dart';

final gabaritsRepositoryProvider = Provider<GabaritsRepository>((ref) {
  return GabaritsRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// Types de tenue visibles (gabarits par défaut + ceux de l'atelier), lus
/// depuis le cache local.
final typesTenueVisiblesProvider = StreamProvider<List<TypeTenue>>((ref) async* {
  final utilisateur = await ref.watch(utilisateurCourantProvider.future);
  if (utilisateur == null) {
    yield const [];
    return;
  }
  final baseLocale = ref.watch(baseLocaleProvider);
  yield* baseLocale.observerTypesTenueVisibles(utilisateur.atelierId).map(
        (lignes) => lignes
            .map(
              (ligne) => TypeTenue(
                id: ligne.id,
                atelierId: ligne.atelierId,
                nom: ligne.nom,
                sexe: ligne.sexe,
                updatedAt: ligne.updatedAt,
              ),
            )
            .toList(),
      );
});

ChampMesure _champDepuisLigne(ChampMesureEntry ligne) => ChampMesure(
      id: ligne.id,
      typeTenueId: ligne.typeTenueId,
      nom: ligne.nom,
      unite: ligne.unite,
      statut: StatutChamp.depuisTexte(ligne.statut),
      ordre: ligne.ordre,
      updatedAt: ligne.updatedAt,
    );

/// Champs actifs d'un type de tenue, dans l'ordre — utilisé par le
/// formulaire de prise de mesure.
final champsActifsProvider = StreamProvider.family<List<ChampMesure>, String>((ref, typeTenueId) {
  final baseLocale = ref.watch(baseLocaleProvider);
  return baseLocale
      .observerChampsActifs(typeTenueId)
      .map((lignes) => lignes.map(_champDepuisLigne).toList());
});

/// Tous les champs (actifs + masqués) d'un type de tenue — utilisé par
/// l'écran de gestion des gabarits.
final tousLesChampsProvider = StreamProvider.family<List<ChampMesure>, String>((ref, typeTenueId) {
  final baseLocale = ref.watch(baseLocaleProvider);
  return baseLocale
      .observerTousLesChamps(typeTenueId)
      .map((lignes) => lignes.map(_champDepuisLigne).toList());
});
