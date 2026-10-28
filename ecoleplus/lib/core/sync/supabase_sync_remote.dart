import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implémentation Supabase : RPC sync_push pour l'envoi, API REST (donc RLS)
/// pour le téléchargement.
class SupabaseSyncRemote implements SyncRemote {
  new(this.client);

  final SupabaseClient client;

  static const _timeout = Duration(seconds: 30);

  Future<T> _call<T>(Future<T> Function() f) async {
    try {
      return await f().timeout(_timeout);
    } on SocketException catch (e) {
      throw RemoteUnavailable(e);
    } on TimeoutException catch (e) {
      throw RemoteUnavailable(e);
    } on HttpException catch (e) {
      throw RemoteUnavailable(e);
    } on AuthException catch (e) {
      if (e.statusCode == '400' || e.statusCode == '401') {
        throw const SessionExpired();
      }
      throw RemoteUnavailable(e);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST301' || e.code == '401') throw const SessionExpired();
      rethrow;
    } on Exception catch (e) {
      // ClientException (paquet http) et erreurs réseau équivalentes.
      if (e.toString().contains('ClientException')) throw RemoteUnavailable(e);
      rethrow;
    }
  }

  @override
  Future<DateTime> serverNow() => _call(() async {
    final v = await client.rpc<dynamic>('server_now');
    return DateTime.parse(v as String).toUtc();
  });

  @override
  Future<List<PushResult>> push(List<PushChange> changes) => _call(() async {
    final res = await client.rpc<dynamic>(
      'sync_push',
      params: {
        'p_changes': [for (final c in changes) c.toJson()],
      },
    );
    return [
      for (final r in res as List)
        PushResult.fromJson(Map<String, dynamic>.from(r as Map)),
    ];
  });

  @override
  Future<List<Map<String, dynamic>>> pull(
    String table, {
    required String syncedAt,
    required String tie,
    required String tieColumn,
    required int limit,
  }) => _call(() async {
    // Sans départage (premier passage, fenêtre de recouvrement) : >= suffit,
    // l'application des lignes étant idempotente.
    final filtered = tie.isEmpty
        ? client.from(table).select().gte('synced_at', syncedAt)
        : client
              .from(table)
              .select()
              .or(
                'synced_at.gt."$syncedAt",'
                'and(synced_at.eq."$syncedAt",$tieColumn.gt."$tie")',
              );
    final rows = await filtered
        .order('synced_at', ascending: true)
        .order(tieColumn, ascending: true)
        .limit(limit);
    return [for (final r in rows) Map<String, dynamic>.from(r)];
  });

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) => _call(() async {
    final rows = await client.from(table).select();
    return [for (final r in rows) Map<String, dynamic>.from(r)];
  });

  @override
  Future<Map<String, dynamic>?> fetchRow(
    String table,
    Map<String, Object?> key,
  ) => _call(() async {
    var q = client.from(table).select();
    for (final e in key.entries) {
      q = q.eq(e.key, e.value!);
    }
    final r = await q.maybeSingle();
    return r == null ? null : Map<String, dynamic>.from(r);
  });

  @override
  Future<void> upload(
    String bucket,
    String path,
    Uint8List bytes,
    String contentType,
  ) => _call(
    () => client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        ),
  );

  @override
  Future<Uint8List> download(String bucket, String path) =>
      _call(() => client.storage.from(bucket).download(path));

  @override
  Future<bool> heartbeat(String deviceId, int pending, String appVersion) =>
      _call(() async {
        final r = await client.rpc<dynamic>(
          'device_heartbeat',
          params: {
            'p_device_id': deviceId,
            'p_pending': pending,
            'p_app_version': appVersion,
          },
        );
        return (r as Map)['revoked'] == true;
      });

  // ------------------------- Envoi reprenable (TUS) -------------------------

  /// En-têtes des envois reprenables : le jeton de la session connectée
  /// (la clé de l'application seule n'est pas un jeton d'utilisateur).
  Map<String, String> get _entetesTus {
    final jeton = client.auth.currentSession?.accessToken;
    if (jeton == null) throw const SessionExpired();
    return {
      ...client.storage.headers,
      'Authorization': 'Bearer $jeton',
      'Tus-Resumable': '1.0.0',
    };
  }

  static String _b64(String v) => base64.encode(utf8.encode(v));

  void _verifierTus(http.Response r, List<int> attendus) {
    if (attendus.contains(r.statusCode)) return;
    if (r.statusCode == 401) throw const SessionExpired();
    throw HttpStatusException(r.statusCode, r.body);
  }

  @override
  int get tailleMorceau => 6 * 1024 * 1024;

  @override
  Future<String> debutEnvoi(
    String bucket,
    String path,
    int taille,
    String contentType,
  ) => _call(() async {
    final r = await http.post(
      Uri.parse('${client.storage.url}/upload/resumable'),
      headers: {
        ..._entetesTus,
        'Upload-Length': '$taille',
        'x-upsert': 'true',
        'Upload-Metadata': [
          'bucketName ${_b64(bucket)}',
          'objectName ${_b64(path)}',
          'contentType ${_b64(contentType)}',
          'cacheControl ${_b64('3600')}',
        ].join(','),
      },
    );
    _verifierTus(r, [201]);
    final adresse = r.headers['location']!;
    return adresse.startsWith('http')
        ? adresse
        : Uri.parse(client.storage.url).resolve(adresse).toString();
  });

  @override
  Future<int> positionEnvoi(String adresse) => _call(() async {
    final r = await http.head(Uri.parse(adresse), headers: _entetesTus);
    _verifierTus(r, [200, 204]);
    return int.parse(r.headers['upload-offset'] ?? '0');
  });

  @override
  Future<int> envoyerMorceau(String adresse, int position, Uint8List octets) =>
      _call(() async {
        final r = await http.patch(
          Uri.parse(adresse),
          headers: {
            ..._entetesTus,
            'Upload-Offset': '$position',
            'Content-Type': 'application/offset+octet-stream',
          },
          body: octets,
        );
        _verifierTus(r, [204]);
        return int.parse(r.headers['upload-offset']!);
      });
}

/// Réponse inattendue du serveur de fichiers (adresse d'envoi expirée,
/// droits…).
class HttpStatusException implements Exception {
  const new(this.code, this.corps);
  final int code;
  final String corps;
  @override
  String toString() => 'HTTP $code : $corps';
}
