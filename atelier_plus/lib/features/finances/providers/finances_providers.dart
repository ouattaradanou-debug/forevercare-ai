import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/commande.dart';
import '../../../data/models/depense.dart';
import '../../../data/models/paiement.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../../ventes/providers/ventes_providers.dart';
import '../data/finances_repository.dart';
import '../data/recapitulatif_finances.dart';

final financesRepositoryProvider = Provider<FinancesRepository>((ref) {
  return FinancesRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
    ventesRepository: ref.watch(ventesRepositoryProvider),
  );
});

/// Récapitulatif global (jour/semaine/mois/année en cours), recalculé à
/// chaque consultation de l'écran "Suivi des finances" — `autoDispose` par
/// précaution supplémentaire, comme le reste des données financières.
final recapitulatifGlobalProvider = FutureProvider.autoDispose<RecapitulatifGlobal>((ref) async {
  final atelier = await ref.watch(atelierCourantProvider.future);
  if (atelier == null) {
    return calculerRecapitulatifGlobal(paiements: [], ventes: [], depenses: []);
  }

  final repo = ref.watch(financesRepositoryProvider);
  await repo.chargerRecapitulatifDepuisServeur(atelier.id);
  final brut = await repo.recapitulatifBrut(atelier.id);
  return calculerRecapitulatifGlobal(
    paiements: brut.paiements,
    ventes: brut.ventes,
    depenses: brut.depenses,
  );
});

/// Récapitulatif mois par mois d'une année donnée, pour le tableau
/// "Récapitulatif {année}" navigable de l'écran "Suivi des finances".
final recapitulatifMensuelProvider =
    FutureProvider.family.autoDispose<List<RecapitulatifPeriode>, int>((ref, annee) async {
  final atelier = await ref.watch(atelierCourantProvider.future);
  if (atelier == null) {
    return calculerRecapitulatifMensuel(paiements: [], ventes: [], depenses: [], annee: annee);
  }

  final repo = ref.watch(financesRepositoryProvider);
  final brut = await repo.recapitulatifBrut(atelier.id);
  return calculerRecapitulatifMensuel(
    paiements: brut.paiements,
    ventes: brut.ventes,
    depenses: brut.depenses,
    annee: annee,
  );
});

/// `autoDispose` : ces données financières ne doivent pas rester en mémoire
/// au-delà de la consultation de l'écran qui les affiche (déjà réservé au
/// propriétaire), par précaution supplémentaire.
///
/// Toutes les commandes du client (une par couture successive), de la plus
/// récente à la plus ancienne — la première est "la commande en cours".
final commandesDuClientProvider =
    FutureProvider.family.autoDispose<List<Commande>, String>((ref, clientId) {
  return ref.watch(financesRepositoryProvider).commandesDuClient(clientId);
});

/// Équivalent de [commandesDuClientProvider] pour un groupe d'uniformes —
/// un groupe a une seule commande globale (pas une par membre).
final commandesDuGroupeProvider =
    FutureProvider.family.autoDispose<List<Commande>, String>((ref, groupeId) {
  return ref.watch(financesRepositoryProvider).commandesDuGroupe(groupeId);
});

final paiementsDeLaCommandeProvider =
    StreamProvider.family<List<Paiement>, String>((ref, commandeId) {
  return ref.watch(financesRepositoryProvider).observerPaiements(commandeId);
});

/// Historique des dépenses de l'atelier, pour l'écran du même nom.
final depensesDeLAtelierProvider = StreamProvider.autoDispose<List<Depense>>((ref) async* {
  final atelier = await ref.watch(atelierCourantProvider.future);
  if (atelier == null) {
    yield const [];
    return;
  }
  yield* ref.watch(financesRepositoryProvider).observerDepenses(atelier.id);
});
