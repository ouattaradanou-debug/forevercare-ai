import 'dart:typed_data';

import 'package:ecoleplus/core/sync/sync_remote.dart';

/// Serveur simulé en mémoire qui applique les mêmes règles que sync_push :
/// dernière modification gagne (avec trace), rejet possible, colonnes non
/// envoyées conservées.
class FakeServer {
  final Map<String, Map<String, Map<String, dynamic>>> tables = {};
  final List<Map<String, dynamic>> conflicts = [];
  final Map<String, Uint8List> files = {};
  final Set<String> revokedDevices = {};
  final Map<String, int> reportedPending = {};
  DateTime now = DateTime.utc(2026, 10, 21, 8);
  int _tick = 0;
  int pushCalls = 0;
  final _depuis = Stopwatch()..start();
  int registryCounter = 0;

  /// Renvoie un code d'erreur SQL pour refuser un changement, sinon null.
  String? Function(String table, Map<String, dynamic> row)? rejectWith;

  /// Message joint au refus (exception levée par une règle du serveur).
  String? rejectMessage;

  static List<String> keyColumns(String table) => switch (table) {
    'school_modules' => const ['school_id', 'module_key'],
    'modules_catalog' => const ['key'],
    'levels' => const ['code'],
    _ => const ['id'],
  };

  static String keyOf(String table, Map<String, dynamic> row) =>
      keyColumns(table).map((k) => '${row[k]}').join('|');

  String _stamp() => now.add(Duration(milliseconds: _tick++)).toIso8601String();

  Map<String, Map<String, dynamic>> table(String name) =>
      tables.putIfAbsent(name, () => {});

  /// Insère directement une ligne côté serveur (autre appareil, directeur…).
  void seed(String name, Map<String, dynamic> row) {
    table(name)[keyOf(name, row)] = {...row, 'synced_at': _stamp()};
  }

  List<PushResult> push(List<PushChange> changes) {
    pushCalls++;
    final out = <PushResult>[];
    for (final c in changes) {
      final code = rejectWith?.call(c.table, c.row);
      if (code != null) {
        out.add(
          PushResult(
            changeId: c.changeId,
            status: 'rejete',
            code: code,
            message: rejectMessage,
          ),
        );
        continue;
      }
      final t = table(c.table);
      final k = keyOf(c.table, c.row);
      final old = t[k];
      if (old == null) {
        t[k] = {...c.row, 'synced_at': _stamp()};
        // Numéro d'ordre du registre matricule attribué par le serveur.
        if (c.table == 'students' && t[k]!['registry_number'] == null) {
          t[k]!['registry_number'] = ++registryCounter;
        }
        out.add(PushResult(changeId: c.changeId, status: 'ok', row: t[k]));
      } else if (DateTime.parse(old['updated_at'] as String)
          .isAfter(DateTime.parse(c.row['updated_at'] as String))) {
        conflicts.add({'winner': old, 'loser': c.row});
        out.add(
          PushResult(
            changeId: c.changeId,
            status: 'ignore_plus_ancien',
            row: old,
          ),
        );
      } else {
        t[k] = {
          ...old,
          ...c.row,
          'registry_number':
              ?(c.row['registry_number'] ?? old['registry_number']),
          'synced_at': _stamp(),
        };
        conflicts.add({'winner': t[k], 'loser': old});
        out.add(PushResult(changeId: c.changeId, status: 'ok', row: t[k]));
      }
    }
    return out;
  }
}

class FakeRemote implements SyncRemote {
  new(this.server);

  final FakeServer server;
  bool online = true;

  /// Simule une réponse perdue : le serveur ne renvoie aucun résultat.
  bool dropPushResults = false;

  void _check() {
    if (!online) throw const RemoteUnavailable('mode avion');
  }

  @override
  Future<DateTime> serverNow() async {
    _check();
    // Comme un vrai serveur : l'heure avance avec le temps réel.
    return server.now.add(server._depuis.elapsed);
  }

  @override
  Future<List<PushResult>> push(List<PushChange> changes) async {
    _check();
    if (dropPushResults) return const [];
    return server.push(changes);
  }

  @override
  Future<List<Map<String, dynamic>>> pull(
    String table, {
    required String syncedAt,
    required String tie,
    required String tieColumn,
    required int limit,
  }) async {
    _check();
    final since = DateTime.parse(syncedAt);
    final rows =
        server.table(table).values.where((r) {
          final s = DateTime.parse(r['synced_at'] as String);
          return s.isAfter(since) ||
              (s.isAtSameMomentAs(since) &&
                  '${r[tieColumn]}'.compareTo(tie) > 0);
        }).toList()..sort((a, b) {
          final c = DateTime.parse(a['synced_at'] as String)
              .compareTo(DateTime.parse(b['synced_at'] as String));
          return c != 0 ? c : '${a[tieColumn]}'.compareTo('${b[tieColumn]}');
        });
    return [for (final r in rows.take(limit)) Map.of(r)];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    _check();
    return [for (final r in server.table(table).values) Map.of(r)];
  }

  @override
  Future<Map<String, dynamic>?> fetchRow(
    String table,
    Map<String, Object?> key,
  ) async {
    _check();
    final r = server.table(table)[key.values.map((v) => '$v').join('|')];
    return r == null ? null : Map.of(r);
  }

  @override
  Future<void> upload(
    String bucket,
    String path,
    Uint8List bytes,
    String contentType,
  ) async {
    _check();
    server.files['$bucket/$path'] = bytes;
  }

  /// Envois reprenables en cours : adresse → (fichier, octets reçus).
  final Map<String, (String, BytesBuilder)> envois = {};

  /// Coupure de connexion simulée après ce nombre de morceaux (null : jamais).
  int? couperApresMorceaux;
  int morceauxRecus = 0;

  @override
  int tailleMorceau = 64 * 1024;

  @override
  Future<String> debutEnvoi(
    String bucket,
    String path,
    int taille,
    String contentType,
  ) async {
    _check();
    final adresse = 'tus://$bucket/$path/${envois.length}';
    envois[adresse] = ('$bucket/$path', BytesBuilder());
    return adresse;
  }

  @override
  Future<int> positionEnvoi(String adresse) async {
    _check();
    return envois[adresse]!.$2.length;
  }

  @override
  Future<int> envoyerMorceau(
    String adresse,
    int position,
    Uint8List octets,
  ) async {
    _check();
    if (couperApresMorceaux != null && morceauxRecus >= couperApresMorceaux!) {
      online = false;
      throw const RemoteUnavailable('coupure');
    }
    final (fichier, recu) = envois[adresse]!;
    if (position != recu.length) throw StateError('position $position');
    recu.add(octets);
    morceauxRecus++;
    server.files[fichier] = recu.toBytes();
    return recu.length;
  }

  @override
  Future<Uint8List> download(String bucket, String path) async {
    _check();
    final f = server.files['$bucket/$path'];
    if (f == null) throw StateError('absent');
    return f;
  }

  @override
  Future<bool> heartbeat(
    String deviceId,
    int pending,
    String appVersion,
  ) async {
    _check();
    server.reportedPending[deviceId] = pending;
    return server.revokedDevices.contains(deviceId);
  }
}
