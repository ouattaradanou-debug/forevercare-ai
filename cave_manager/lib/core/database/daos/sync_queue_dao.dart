import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/sync_queue_table.dart';
import '../../sync/sync_queue_entry.dart';

part 'sync_queue_dao.g.dart';

const _uuid = Uuid();

/// DAO pour la table Drift `SyncQueue`, convertit vers/depuis le modèle
/// Dart pur `SyncQueueEntry` utilisé par `SyncEngine` (voir
/// `lib/core/sync/sync_engine.dart`).
@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Enregistre localement une écriture à synchroniser plus tard. Appelée
  /// à chaque création/modification faite hors ligne — c'est ce qui
  /// garantit qu'aucune donnée n'est perdue en cas de coupure réseau ou
  /// de fermeture brutale de l'application.
  Future<void> enfiler({
    required String table,
    required String entiteId,
    required OperationSync operation,
    required Map<String, dynamic> payload,
  }) {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        id: _uuid.v4(),
        nomTable: table,
        entiteId: entiteId,
        operation: operation.name,
        payload: jsonEncode(payload),
        creeLe: DateTime.now(),
      ),
    );
  }

  Future<List<SyncQueueEntry>> entreesATraiter() async {
    final lignes = await (select(syncQueue)
          ..where((t) => t.statut.isIn(['enAttente', 'erreur']))
          ..orderBy([(t) => OrderingTerm.asc(t.creeLe)]))
        .get();
    return lignes.map(_versModele).toList();
  }

  Future<void> enregistrerResultat(SyncQueueEntry entree) {
    return (update(syncQueue)..where((t) => t.id.equals(entree.id))).write(
      SyncQueueCompanion(
        statut: Value(entree.statut.name),
        tentatives: Value(entree.tentatives),
        messageErreur: Value(entree.messageErreur),
      ),
    );
  }

  /// Purge les entrées synchronisées avec succès (nettoyage périodique,
  /// jamais avant confirmation d'écriture côté serveur).
  Future<void> purgerSynchronisees() {
    return (delete(syncQueue)..where((t) => t.statut.equals('synchronise')))
        .go();
  }

  SyncQueueEntry _versModele(SyncQueueData ligne) {
    return SyncQueueEntry(
      id: ligne.id,
      table: ligne.nomTable,
      entiteId: ligne.entiteId,
      operation:
          OperationSync.values.firstWhere((o) => o.name == ligne.operation),
      payload: jsonDecode(ligne.payload) as Map<String, dynamic>,
      creeLe: ligne.creeLe,
      statut: StatutSync.values.firstWhere((s) => s.name == ligne.statut),
      tentatives: ligne.tentatives,
      messageErreur: ligne.messageErreur,
    );
  }
}
