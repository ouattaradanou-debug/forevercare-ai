import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/abonnement.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/abonnement_repository.dart';

final abonnementRepositoryProvider = Provider<AbonnementRepository>((ref) {
  return AbonnementRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// Abonnement de l'atelier courant, lu depuis le cache local (donc
/// disponible hors-ligne pour le bandeau de rappel et le mode consultation
/// seule).
final abonnementCourantProvider = StreamProvider<Abonnement?>((ref) async* {
  final utilisateur = await ref.watch(utilisateurCourantProvider.future);
  if (utilisateur == null) {
    yield null;
    return;
  }
  yield* ref.watch(abonnementRepositoryProvider).observerAbonnement(utilisateur.atelierId);
});
