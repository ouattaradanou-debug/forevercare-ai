import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/permissions_apprenti.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/permissions_repository.dart';

final permissionsRepositoryProvider = Provider<PermissionsRepository>((ref) {
  return PermissionsRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// Permissions de l'utilisateur connecté, lues depuis le cache local.
/// `null` si l'utilisateur est propriétaire (aucune restriction ne
/// s'applique à lui) ou si personne n'est connecté.
final mesPermissionsProvider = FutureProvider<PermissionsApprenti?>((ref) async {
  final utilisateur = await ref.watch(utilisateurCourantProvider.future);
  if (utilisateur == null || utilisateur.estProprietaire) return null;

  final repo = ref.watch(permissionsRepositoryProvider);
  return repo.lireDepuisCache(utilisateur.id);
});
