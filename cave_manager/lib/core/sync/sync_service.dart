import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/daos/sync_queue_dao.dart';
import 'remote_writer.dart';
import 'sync_engine.dart';
import 'sync_queue_entry.dart';

/// Implémentation réelle de [RemoteWriter] : envoie chaque entrée de la
/// file vers Supabase (upsert pour insertion/modification, delete pour
/// suppression). Les policies RLS s'appliquent normalement : si
/// l'utilisateur courant n'a pas le droit d'écrire (ex. Agent de vente sur
/// `stock`), Supabase renvoie une erreur, l'entrée repasse en `erreur` et
/// n'est PAS perdue — elle reste visible pour diagnostic plutôt que d'être
/// synchronisée silencieusement en échec.
class SupabaseRemoteWriter implements RemoteWriter {
  SupabaseRemoteWriter(this._client);

  final SupabaseClient _client;

  @override
  Future<void> envoyer({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    switch (operation) {
      case 'insertion':
      case 'modification':
        await _client.from(table).upsert(payload);
        return;
      case 'suppression':
        await _client.from(table).delete().eq('id', payload['id']);
        return;
      default:
        throw ArgumentError('Opération de synchronisation inconnue : $operation');
    }
  }
}

/// Point d'entrée applicatif de la synchronisation : relie la file
/// persistée (Drift, via [SyncQueueDao]) au moteur pur [SyncEngine].
///
/// Déclenché : (1) au retour de connectivité (voir `connectivity_provider.dart`),
/// (2) manuellement (bouton "Synchroniser" éventuel), (3) après chaque
/// écriture locale si une connexion est déjà disponible.
class SyncService {
  SyncService({required SyncQueueDao dao, required SupabaseClient client})
      : _dao = dao,
        _engine = SyncEngine(SupabaseRemoteWriter(client));

  final SyncQueueDao _dao;
  final SyncEngine _engine;

  bool _synchronisationEnCours = false;

  Future<void> synchroniser() async {
    if (_synchronisationEnCours) return;
    _synchronisationEnCours = true;
    try {
      final entrees = await _dao.entreesATraiter();
      if (entrees.isEmpty) return;

      final resultats = await _engine.traiterFile(entrees);
      for (final resultat in resultats) {
        await _dao.enregistrerResultat(resultat);
      }
      await _dao.purgerSynchronisees();
    } finally {
      _synchronisationEnCours = false;
    }
  }
}
