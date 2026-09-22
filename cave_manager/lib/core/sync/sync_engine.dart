import 'remote_writer.dart';
import 'sync_queue_entry.dart';

/// Orchestrateur pur de la file de synchronisation : ne connaît ni Drift
/// ni Supabase directement, seulement l'abstraction [RemoteWriter]. Cela
/// permet de le tester unitairement de façon fiable et rapide (voir
/// `test/unit/sync_engine_test.dart`), sans base de données ni réseau.
///
/// `SyncService` (Phase 1, câblé à Drift + Supabase dans l'app réelle)
/// délègue à cette classe pour le traitement effectif de chaque entrée.
class SyncEngine {
  SyncEngine(this._remoteWriter);

  final RemoteWriter _remoteWriter;

  /// Traite une seule entrée : tente l'envoi, met à jour son statut.
  /// Ne lève jamais d'exception : une entrée en échec reste en file avec
  /// `statut = erreur` pour être retentée plus tard (aucune donnée n'est
  /// jamais silencieusement abandonnée).
  Future<SyncQueueEntry> traiterEntree(SyncQueueEntry entree) async {
    entree.statut = StatutSync.enCours;
    try {
      await _remoteWriter.envoyer(
        table: entree.table,
        operation: entree.operation.name,
        payload: entree.payload,
      );
      entree.statut = StatutSync.synchronise;
      entree.messageErreur = null;
    } catch (e) {
      entree.tentatives += 1;
      entree.statut = StatutSync.erreur;
      entree.messageErreur = e.toString();
    }
    return entree;
  }

  /// Traite toute la file (entrées en attente ou en erreur, pour permettre
  /// un nouveau essai). L'ordre de création (`creeLe`) est respecté pour
  /// ne jamais rejouer les opérations dans le désordre.
  Future<List<SyncQueueEntry>> traiterFile(List<SyncQueueEntry> file) async {
    final aTraiter = file
        .where(
          (e) =>
              e.statut == StatutSync.enAttente || e.statut == StatutSync.erreur,
        )
        .toList()
      ..sort((a, b) => a.creeLe.compareTo(b.creeLe));

    final resultats = <SyncQueueEntry>[];
    for (final entree in aTraiter) {
      resultats.add(await traiterEntree(entree));
    }
    return resultats;
  }
}
