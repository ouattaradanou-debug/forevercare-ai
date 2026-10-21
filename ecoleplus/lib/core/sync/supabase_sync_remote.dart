import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ecoleplus/core/sync/sync_remote.dart';
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
}
