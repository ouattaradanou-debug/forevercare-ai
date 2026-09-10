import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database_provider.dart';
import '../../../../data/models/commande.dart';
import '../../../../data/models/depense.dart';
import '../../../../data/models/paiement.dart';
import '../../../../data/repositories/finances_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final Provider<FinancesRepository> financesRepositoryProvider =
    Provider<FinancesRepository>(
      (ref) => FinancesRepository(
        ref.watch(supabaseClientProvider),
        ref.watch(appDatabaseProvider),
      ),
    );

/// Le solde financier d'un client (montant convenu, avance), s'il en a un.
final commandeClientProvider = StreamProvider.family<Commande?, String>((
  ref,
  clientId,
) {
  return ref.watch(financesRepositoryProvider).observerCommandeClient(clientId);
});

/// Historique des paiements reçus pour une commande, le plus récent en
/// premier.
final paiementsCommandeProvider = StreamProvider.family<List<Paiement>, String>(
  (ref, commandeId) {
    return ref
        .watch(financesRepositoryProvider)
        .observerPaiementsCommande(commandeId);
  },
);

/// Toutes les commandes de l'atelier — pour savoir, sur l'accueil, quels
/// clients ont une commande soldée (voir Commande.estSoldee) et ne plus
/// les afficher parmi les rendez-vous à suivre.
final StreamProvider<List<Commande>> commandesAtelierProvider =
    StreamProvider<List<Commande>>((ref) {
      final atelier = ref.watch(atelierCourantProvider).asData?.value;
      if (atelier == null) return Stream<List<Commande>>.value(const []);
      return ref
          .watch(financesRepositoryProvider)
          .observerCommandesAtelier(atelier.id);
    });

/// Tous les paiements reçus par l'atelier — pour l'écran "Suivi des
/// finances" (recettes journalières/hebdomadaires/mensuelles/annuelles).
final StreamProvider<List<Paiement>> paiementsAtelierProvider =
    StreamProvider<List<Paiement>>((ref) {
      final atelier = ref.watch(atelierCourantProvider).asData?.value;
      if (atelier == null) return Stream<List<Paiement>>.value(const []);
      return ref
          .watch(financesRepositoryProvider)
          .observerPaiementsAtelier(atelier.id);
    });

/// Toutes les dépenses de l'atelier — pour l'écran "Suivi des dépenses".
final StreamProvider<List<Depense>> depensesAtelierProvider =
    StreamProvider<List<Depense>>((ref) {
      final atelier = ref.watch(atelierCourantProvider).asData?.value;
      if (atelier == null) return Stream<List<Depense>>.value(const []);
      return ref
          .watch(financesRepositoryProvider)
          .observerDepensesAtelier(atelier.id);
    });
