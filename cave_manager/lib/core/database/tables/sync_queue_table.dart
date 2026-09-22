import 'package:drift/drift.dart';

/// Table Drift générique de la file de synchronisation.
///
/// Réutilisée telle quelle par toutes les phases suivantes (produits,
/// stock, commandes, encaissements, clôtures) : seul le contenu de
/// `payload` (JSON sérialisé) change selon l'entité concernée. Voir
/// `lib/core/sync/sync_queue_entry.dart` pour le modèle Dart pur associé
/// et `lib/core/sync/sync_engine.dart` pour la logique de traitement.
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get nomTable => text().named('table_cible')();
  TextColumn get entiteId => text()();

  /// 'insertion' | 'modification' | 'suppression'
  TextColumn get operation => text()();

  /// Payload JSON de la ligne à synchroniser.
  TextColumn get payload => text()();

  DateTimeColumn get creeLe => dateTime()();

  /// 'enAttente' | 'enCours' | 'synchronise' | 'erreur'
  TextColumn get statut => text().withDefault(const Constant('enAttente'))();

  IntColumn get tentatives => integer().withDefault(const Constant(0))();
  TextColumn get messageErreur => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
