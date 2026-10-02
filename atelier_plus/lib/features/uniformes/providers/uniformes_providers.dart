import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/groupe_uniforme.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/groupes_uniformes_repository.dart';

final groupesUniformesRepositoryProvider = Provider<GroupesUniformesRepository>((ref) {
  return GroupesUniformesRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// Groupes d'uniformes de l'atelier — lecture locale (hors-ligne) ; le
/// rapatriement serveur est déclenché par l'écran, comme pour les
/// rendez-vous et les clients.
final groupesUniformesProvider = StreamProvider<List<GroupeUniforme>>((ref) async* {
  final utilisateur = await ref.watch(utilisateurCourantProvider.future);
  if (utilisateur == null) {
    yield const [];
    return;
  }
  yield* ref.watch(groupesUniformesRepositoryProvider).observerGroupes(utilisateur.atelierId);
});
