import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/commande_groupe.dart';
import '../../../data/models/paiement.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../data/finances_groupe_repository.dart';

final financesGroupeRepositoryProvider = Provider<FinancesGroupeRepository>((ref) {
  return FinancesGroupeRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// Équivalent de `commandesDuClientProvider` pour un groupe d'uniformes —
/// un groupe a une seule commande globale (pas une par membre).
final commandesDuGroupeProvider =
    FutureProvider.family.autoDispose<List<CommandeGroupe>, String>((ref, groupeId) {
  return ref.watch(financesGroupeRepositoryProvider).commandesDuGroupe(groupeId);
});

final paiementsDeLaCommandeGroupeProvider =
    StreamProvider.family<List<Paiement>, String>((ref, commandeId) {
  return ref.watch(financesGroupeRepositoryProvider).observerPaiements(commandeId);
});
