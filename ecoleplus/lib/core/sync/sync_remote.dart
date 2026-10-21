import 'dart:typed_data';

/// Le serveur est injoignable (pas de réseau, serveur arrêté…).
class RemoteUnavailable implements Exception {
  const new([this.cause]);
  final Object? cause;
  @override
  String toString() => 'RemoteUnavailable($cause)';
}

/// La session a expiré : il faut se reconnecter (en ligne).
class SessionExpired implements Exception {
  const new();
}

/// Ce téléphone a été déconnecté par le directeur (perte, vol).
class DeviceRevoked implements Exception {
  const new();
}

class PushChange {
  const new({required this.changeId, required this.table, required this.row});
  final int changeId;
  final String table;
  final Map<String, dynamic> row;

  Map<String, dynamic> toJson() => {
    'change_id': changeId,
    'table': table,
    'row': row,
  };
}

class PushResult {
  const new({
    required this.changeId,
    required this.status,
    this.code,
    this.message,
    this.row,
  });

  factory fromJson(Map<String, dynamic> json) => PushResult(
    changeId: (json['change_id'] as num).toInt(),
    status: json['status'] as String,
    code: json['code'] as String?,
    message: json['message'] as String?,
    row: json['row'] as Map<String, dynamic>?,
  );

  final int changeId;

  /// ok | deja_recu | ignore_plus_ancien | rejete
  final String status;
  final String? code;
  final String? message;

  /// Version serveur de la ligne après traitement (si visible).
  final Map<String, dynamic>? row;
}

/// Accès au serveur utilisé par le moteur de synchronisation.
abstract interface class SyncRemote {
  Future<DateTime> serverNow();

  Future<List<PushResult>> push(List<PushChange> changes);

  /// Lignes modifiées après (syncedAt, tie), triées, au plus [limit].
  Future<List<Map<String, dynamic>>> pull(
    String table, {
    required String syncedAt,
    required String tie,
    required String tieColumn,
    required int limit,
  });

  Future<List<Map<String, dynamic>>> fetchAll(String table);

  Future<Map<String, dynamic>?> fetchRow(
    String table,
    Map<String, Object?> key,
  );

  Future<void> upload(
    String bucket,
    String path,
    Uint8List bytes,
    String contentType,
  );

  Future<Uint8List> download(String bucket, String path);

  /// Signale l'état du téléphone ; renvoie vrai s'il a été déconnecté.
  Future<bool> heartbeat(String deviceId, int pending, String appVersion);
}
