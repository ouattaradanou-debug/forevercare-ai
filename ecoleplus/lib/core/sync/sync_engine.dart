import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/app_info.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:ecoleplus/core/sync/synced_tables.dart';
import 'package:path/path.dart' as p;

enum SyncPhase { idle, running, offline, sessionExpired, revoked, error }

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
    this.mediaDir,
    this.onRevoked,
    this.autresEnvois,
  });

  /// Dossier local des images (téléchargées sur un nouveau téléphone).
  final Directory? mediaDir;

  /// Envois de fichiers supplémentaires (documents de la bibliothèque,
  /// reprenables), après les lignes et les petites images.
  final Future<void> Function()? autresEnvois;

  /// Appelé quand le directeur a déconnecté ce téléphone.
  final Future<void> Function()? onRevoked;

  /// Fichiers rattachés à des lignes : (table, colonne, compartiment).
  static const fileColumns = [
    ('admin_headers', 'emblem_path', 'ecole-medias'),
    ('schools', 'logo_path', 'ecole-medias'),
    ('students', 'photo_path', 'ecole-medias'),
  ];

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
      await _heartbeat(); // un téléphone déconnecté n'envoie rien
      await _push();
      await _pull();
      await _uploadFiles();
      if (autresEnvois != null) {
        await autresEnvois!();
        // Fin d'envoi notée sur la fiche : signalée tout de suite.
        await _push();
      }
      await _downloadFiles();
      await _heartbeat();
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
    } on DeviceRevoked catch (e) {
      _emit(SyncState(phase: SyncPhase.revoked, error: e));
      await onRevoked?.call();
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

  Future<void> _heartbeat() async {
    final session = await db.select(db.localSession).getSingleOrNull();
    if (session == null) return;
    final revoked = await remote.heartbeat(
      session.deviceId,
      await store.pendingCount(),
      appVersion,
    );
    if (revoked) throw const DeviceRevoked();
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
        final fiche = await _quelleFiche(t, entry);
        await (db.update(db.outbox)..where((o) => o.id.equals(entry.id))).write(
          OutboxCompanion(
            status: const Value('refuse'),
            message: Value(
              fiche == null
                  ? _friendlyRejection(r)
                  : '$fiche — ${_friendlyRejection(r)}',
            ),
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
    '23505' => _doublon(r.message),
    _ => 'Modification refusée par le serveur.',
  };

  /// « Élève TEST Aïcha », « Enseignant … » : pour savoir quelle fiche
  /// corriger (lu sur le téléphone avant de reprendre la version du serveur).
  Future<String?> _quelleFiche(SyncedTable t, OutboxEntry entry) async {
    final key = Map<String, Object?>.from(jsonDecode(entry.rowKey) as Map);
    final ligne = await store.read(t.name, key);
    final nom = ligne == null
        ? null
        : '${ligne['last_name'] ?? ''} ${ligne['first_names'] ?? ''}'.trim();
    return switch (t.name) {
      'students' when nom != null && nom.isNotEmpty => 'Élève $nom',
      'teachers' when nom != null && nom.isNotEmpty => 'Enseignant $nom',
      'classes' when ligne?['name'] != null => 'Classe ${ligne!['name']}',
      'documents' when ligne?['title'] != null =>
        'Document « ${ligne!['title']} »',
      _ => null,
    };
  }

  /// Valeur déjà utilisée ailleurs : dire laquelle, en français simple.
  static String _doublon(String? message) {
    final m = message ?? '';
    if (m.contains('students_code_uq')) {
      return 'Modification refusée : cet identifiant d’élève est déjà utilisé '
          'par un autre élève. Choisissez-en un autre sur la fiche.';
    }
    if (m.contains('teachers_matricule_uq')) {
      return 'Modification refusée : ce matricule est déjà celui d’un autre '
          'enseignant.';
    }
    if (m.contains('registry_number')) {
      return 'Modification refusée : ce numéro d’ordre du registre est déjà '
          'attribué à un autre élève.';
    }
    if (m.contains('classes_school_year_id_name')) {
      return 'Modification refusée : une classe porte déjà ce nom cette année.';
    }
    return 'Modification refusée : cet élément existe déjà.';
  }

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

  /// Images présentes sur le serveur mais pas sur ce téléphone (nouveau
  /// téléphone, autre appareil) : téléchargées automatiquement.
  Future<void> _downloadFiles() async {
    final dir = mediaDir;
    if (dir == null) return;
    final pendingUploads = {
      for (final u in await db.select(db.fileUploads).get()) u.objectPath,
    };
    for (final (table, column, bucket) in fileColumns) {
      final rows = await db
          .customSelect(
            'SELECT DISTINCT "$column" AS path FROM "$table" '
            'WHERE "$column" IS NOT NULL',
          )
          .get();
      for (final r in rows) {
        final path = r.read<String>('path');
        final file = File(p.join(dir.path, path));
        if (file.existsSync() || pendingUploads.contains(path)) continue;
        try {
          final bytes = await remote.download(bucket, path);
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes, flush: true);
        } on RemoteUnavailable {
          rethrow;
        } on Object {
          // Pas encore envoyé par l'autre téléphone : réessayé plus tard.
        }
      }
    }
  }

  Future<void> dispose() => _state.close();
}
