import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:ecoleplus/core/sync/synced_tables.dart';

enum SyncPhase { idle, running, offline, sessionExpired, error }

class SyncState {
  const new({required this.phase, this.lastSuccess, this.error});
  final SyncPhase phase;
  final DateTime? lastSuccess;
  final Object? error;
}

/// Envoie la file d'attente puis télécharge les nouveautés. Ne bloque jamais
/// l'interface : en cas d'absence de réseau, tout reste sur le téléphone.
class SyncEngine {
  new({
    required this.store,
    required this.remote,
    this.batchSize = 100,
    this.pageSize = 500,
    this.overlap = const Duration(minutes: 2),
  });

  final LocalStore store;
  final SyncRemote remote;
  final int batchSize;
  final int pageSize;

  /// Fenêtre de recouvrement du curseur : rattrape les lignes d'une
  /// transaction serveur validée juste après un téléchargement.
  final Duration overlap;

  AppDatabase get db => store.db;

  final _state = StreamController<SyncState>.broadcast();
  SyncState _current = const SyncState(phase: SyncPhase.idle);
  Future<SyncState>? _running;

  Stream<SyncState> get states => _state.stream;
  SyncState get state => _current;

  void _emit(SyncState s) {
    _current = s;
    _state.add(s);
  }

  /// Lance une synchronisation (ou rejoint celle en cours).
  Future<SyncState> syncNow() => _running ??= _run().whenComplete(() {
    _running = null;
  });

  Future<SyncState> _run() async {
    _emit(
      SyncState(phase: SyncPhase.running, lastSuccess: _current.lastSuccess),
    );
    try {
      store.clock.calibrate(await remote.serverNow());
      await _push();
      await _pull();
      await _uploadFiles();
      final done = SyncState(
        phase: SyncPhase.idle,
        lastSuccess: DateTime.now(),
      );
      await db
          .update(db.localSession)
          .write(
            LocalSessionCompanion(
              lastSyncAt: Value(done.lastSuccess!.toUtc().toIso8601String()),
              clockOffsetMs: Value(store.clock.offset.inMilliseconds),
            ),
          );
      _emit(done);
    } on RemoteUnavailable catch (e) {
      _emit(
        SyncState(
          phase: SyncPhase.offline,
          lastSuccess: _current.lastSuccess,
          error: e,
        ),
      );
    } on SessionExpired catch (e) {
      _emit(
        SyncState(
          phase: SyncPhase.sessionExpired,
          lastSuccess: _current.lastSuccess,
          error: e,
        ),
      );
    } on Object catch (e) {
      _emit(
        SyncState(
          phase: SyncPhase.error,
          lastSuccess: _current.lastSuccess,
          error: e,
        ),
      );
    }
    return _current;
  }

  // ------------------------------- Envoi -------------------------------
  Future<void> _push() async {
    while (true) {
      final batch =
          await (db.select(db.outbox)
                ..where((o) => o.status.equals('en_attente'))
                ..orderBy([(o) => OrderingTerm.asc(o.id)])
                ..limit(batchSize))
              .get();
      if (batch.isEmpty) return;
      await db.customUpdate(
        'UPDATE outbox SET attempts = attempts + 1 WHERE id IN '
        '(${batch.map((e) => e.id).join(',')})',
        updates: {db.outbox},
      );
      final results = await remote.push([
        for (final e in batch)
          PushChange(
            changeId: e.id,
            table: e.targetTable,
            row: jsonDecode(e.payload) as Map<String, dynamic>,
          ),
      ]);
      final byId = {for (final r in results) r.changeId: r};
      for (final entry in batch) {
        final r = byId[entry.id];
        if (r == null) continue;
        await _applyResult(entry, r);
      }
      if (batch.length < batchSize) return;
    }
  }

  Future<void> _applyResult(OutboxEntry entry, PushResult r) async {
    final t = store.table(entry.targetTable);
    await db.transaction(() async {
      final current = await (db.select(
        db.outbox,
      )..where((o) => o.id.equals(entry.id))).getSingleOrNull();
      final changedMeanwhile =
          current != null && current.revision != entry.revision;
      if (r.status == 'rejete') {
        await (db.update(db.outbox)..where((o) => o.id.equals(entry.id))).write(
          OutboxCompanion(
            status: const Value('refuse'),
            message: Value(_friendlyRejection(r)),
          ),
        );
        await _restoreServerVersion(t, entry);
        return;
      }
      if (changedMeanwhile) return; // renvoyé au prochain passage, fusionné
      await (db.delete(db.outbox)..where((o) => o.id.equals(entry.id))).go();
      if (r.row != null) await store.writeLocal(t, r.row!);
    });
  }

  /// Après un refus, le téléphone reprend la version du serveur (ou retire
  /// une ligne que le serveur n'a pas acceptée).
  Future<void> _restoreServerVersion(SyncedTable t, OutboxEntry entry) async {
    final key = Map<String, Object?>.from(jsonDecode(entry.rowKey) as Map);
    Map<String, dynamic>? server;
    try {
      server = await remote.fetchRow(t.name, key);
    } on RemoteUnavailable {
      return;
    }
    if (server != null) {
      await store.writeLocal(t, server);
    } else {
      await store.deleteLocal(t, key);
    }
  }

  static String _friendlyRejection(PushResult r) => switch (r.code) {
    '42501' => "Modification refusée : vous n'avez pas le droit de la faire.",
    'P0002' =>
      "Modification refusée : la date et l'heure du téléphone sont fausses.",
    'P0001' => r.message ?? 'Modification refusée par une règle de l’école.',
    '23505' => 'Modification refusée : cet élément existe déjà.',
    _ => 'Modification refusée par le serveur.',
  };

  // --------------------------- Téléchargement --------------------------
  Future<void> _pull() async {
    for (final t in store.tables) {
      if (!t.incremental) {
        for (final row in await remote.fetchAll(t.name)) {
          await store.writeLocal(t, row);
        }
        continue;
      }
      final cursor = await (db.select(
        db.syncCursors,
      )..where((c) => c.targetTable.equals(t.name))).getSingleOrNull();
      var syncedAt = cursor == null
          ? '1970-01-01T00:00:00Z'
          : DateTime.parse(cursor.syncedAt)
                .toUtc()
                .subtract(overlap)
                .toIso8601String();
      var tie = '';
      while (true) {
        final rows = await remote.pull(
          t.name,
          syncedAt: syncedAt,
          tie: tie,
          tieColumn: t.tieColumn,
          limit: pageSize,
        );
        await db.transaction(() async {
          for (final row in rows) {
            // Une modification locale pas encore envoyée reste prioritaire.
            if (await store.hasPending(t.name, t.encodeKey(row))) continue;
            await store.writeLocal(t, row);
          }
        });
        if (rows.isEmpty) break;
        syncedAt = rows.last['synced_at'] as String;
        tie = '${rows.last[t.tieColumn]}';
        await db
            .into(db.syncCursors)
            .insertOnConflictUpdate(
              SyncCursorsCompanion.insert(
                targetTable: t.name,
                syncedAt: syncedAt,
                tie: Value(tie),
              ),
            );
        if (rows.length < pageSize) break;
      }
    }
  }

  // ------------------------------ Fichiers -----------------------------
  Future<void> _uploadFiles() async {
    final files = await db.select(db.fileUploads).get();
    for (final f in files) {
      final file = File(f.localPath);
      if (!file.existsSync()) {
        await (db.delete(db.fileUploads)..where((u) => u.id.equals(f.id))).go();
        continue;
      }
      await remote.upload(
        f.bucket,
        f.objectPath,
        await file.readAsBytes(),
        f.contentType,
      );
      await (db.delete(db.fileUploads)..where((u) => u.id.equals(f.id))).go();
    }
  }

  Future<void> dispose() => _state.close();
}
