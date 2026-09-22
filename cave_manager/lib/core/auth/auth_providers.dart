import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../sync/sync_service.dart';
import 'auth_service.dart';
import 'profil.dart';

final supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    dao: ref.watch(appDatabaseProvider).syncQueueDao,
    client: ref.watch(supabaseClientProvider),
  );
});

/// Ré-émet le profil courant à chaque changement d'état d'authentification
/// (connexion, déconnexion, rafraîchissement de session).
final profilActuelProvider = StreamProvider<Profil?>((ref) async* {
  final authService = ref.watch(authServiceProvider);

  yield await authService.profilActuel();

  await for (final _ in authService.changementsAuth) {
    yield await authService.profilActuel();
  }
});
