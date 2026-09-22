/// Abstraction de l'écriture distante, pour permettre de tester
/// `SyncEngine` sans dépendre de `supabase_flutter` ni du réseau.
///
/// L'implémentation réelle (Phase 1) fait un upsert/delete Supabase selon
/// `operation`. Voir `SupabaseRemoteWriter` dans `sync_service.dart`.
abstract class RemoteWriter {
  Future<void> envoyer({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  });
}
