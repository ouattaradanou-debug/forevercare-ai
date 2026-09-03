import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/commande.dart';
import '../../../data/models/paiement.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../data/finances_repository.dart';

final financesRepositoryProvider = Provider<FinancesRepository>((ref) {
  return FinancesRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// `autoDispose` : ces données financières ne doivent pas rester en mémoire
/// au-delà de la consultation de l'écran qui les affiche (déjà réservé au
/// propriétaire), par précaution supplémentaire.
final commandeDuClientProvider =
    FutureProvider.family.autoDispose<Commande?, String>((ref, clientId) {
  return ref.watch(financesRepositoryProvider).commandeDuClient(clientId);
});

final paiementsDeLaCommandeProvider =
    StreamProvider.family<List<Paiement>, String>((ref, commandeId) {
  return ref.watch(financesRepositoryProvider).observerPaiements(commandeId);
});
