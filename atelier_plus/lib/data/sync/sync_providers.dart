import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/database_provider.dart';
import '../remote/supabase_client_provider.dart';
import 'sync_engine.dart';
import 'sync_trigger.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// Démarre l'écoute de connectivité au premier accès et la maintient tant
/// que ce provider reste utilisé (voir `AtelierPlusApp`, qui le lit une
/// seule fois pour toute la durée de vie de l'application).
final syncTriggerProvider = Provider<SyncTrigger>((ref) {
  final trigger = SyncTrigger(syncEngine: ref.watch(syncEngineProvider));
  trigger.demarrer();
  ref.onDispose(trigger.arreter);
  return trigger;
});

/// Nombre de tâches en attente de synchronisation, pour un indicateur
/// discret dans l'interface (voir EcranAccueilProvisoire).
final tachesSyncEnAttenteProvider = StreamProvider<int>((ref) {
  return ref.watch(baseLocaleProvider).observerNombreTachesEnAttente();
});
