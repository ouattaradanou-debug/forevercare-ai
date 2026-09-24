import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../database/daos/ventes_dao.dart';
import 'client.dart';
import 'commande.dart';
import 'ventes_service.dart';

final ventesServiceProvider = Provider<VentesService>((ref) {
  return VentesService(ref.watch(supabaseClientProvider));
});

final ventesDaoProvider = Provider<VentesDao>((ref) {
  return ref.watch(appDatabaseProvider).ventesDao;
});

/// Clients de la cave courante (nécessite le réseau — voir commentaire de
/// `VentesService`).
final clientsProvider = FutureProvider.autoDispose<List<Client>>((ref) async {
  final profil = await ref.watch(profilActuelProvider.future);
  if (profil == null) return const [];
  return ref.watch(ventesServiceProvider).listerClients(profil.caveId);
});

/// Commandes de la cave courante, déjà filtrées par rôle côté RLS
/// (`commandes_select` : un Agent ne reçoit que les siennes).
final commandesProvider =
    FutureProvider.autoDispose<List<Commande>>((ref) async {
  final profil = await ref.watch(profilActuelProvider.future);
  if (profil == null) return const [];
  return ref.watch(ventesServiceProvider).listerCommandes(profil.caveId);
});
