/// Opération représentée par une entrée de la file de synchronisation.
enum OperationSync { insertion, modification, suppression }

/// État d'avancement d'une entrée dans la file de synchronisation.
enum StatutSync { enAttente, enCours, synchronise, erreur }

/// Une entrée de la file d'attente de synchronisation (sync queue).
///
/// Toute écriture faite hors ligne (configuration cave, profil — et, dès
/// la Phase 2/3/4/5, produits/stock/commandes/encaissements/clôtures) passe
/// par une entrée de ce type avant d'être rejouée vers Supabase au retour
/// de connexion. C'est le mécanisme central qui garantit qu'aucune donnée
/// n'est perdue en cas de coupure réseau ou de fermeture brutale de l'app.
///
/// Cette classe est un modèle Dart pur (aucune dépendance Drift), pour
/// pouvoir tester la logique de synchronisation (`SyncEngine`) sans avoir
/// besoin de la base générée par build_runner. La persistance réelle est
/// assurée par `SyncQueueDao`, qui convertit vers/depuis la table Drift
/// `SyncQueue` (voir `lib/core/database/tables/sync_queue_table.dart`).
class SyncQueueEntry {
  SyncQueueEntry({
    required this.id,
    required this.table,
    required this.entiteId,
    required this.operation,
    required this.payload,
    required this.creeLe,
    this.statut = StatutSync.enAttente,
    this.tentatives = 0,
    this.messageErreur,
  });

  final String id;
  final String table;
  final String entiteId;
  final OperationSync operation;
  final Map<String, dynamic> payload;
  final DateTime creeLe;

  StatutSync statut;
  int tentatives;
  String? messageErreur;

  @override
  String toString() =>
      'SyncQueueEntry(table: $table, entiteId: $entiteId, operation: $operation, statut: $statut, tentatives: $tentatives)';
}
