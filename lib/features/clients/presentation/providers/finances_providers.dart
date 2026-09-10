import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database_provider.dart';
import '../../../../data/models/commande.dart';
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
