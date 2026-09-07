import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Cache local de la table `ateliers` (voir supabase/schema.sql).
///
/// Nommage `@DataClassName` : évite toute collision avec les modèles de
/// domaine `Atelier` / `Utilisateur` définis dans `lib/data/models/`, qui
/// portent le même nom au singulier que le nom par défaut que Drift
/// aurait généré pour la ligne de table.
@DataClassName('AtelierLocal')
class Ateliers extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  TextColumn get logoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de la table `utilisateurs`.
@DataClassName('UtilisateurLocal')
class Utilisateurs extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get nom => text()();
  TextColumn get telephone => text()();
  TextColumn get role => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de la table `permissions_apprenti`.
/// Volontairement dépourvue de toute colonne financière, à l'identique du
/// schéma distant.
@DataClassName('PermissionsApprentiLocal')
class PermissionsApprenti extends Table {
  TextColumn get id => text()();
  TextColumn get utilisateurId => text()();
  BoolColumn get creerClient =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get modifierClient =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get prendreMesures =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get ajouterPhotos =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get modifierGabarits =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Base de données locale (SQLite via Drift), cache hors-ligne d'Atelier+.
///
/// Phase 1 : seules les tables nécessaires au compte, à l'atelier et aux
/// permissions d'apprenti sont présentes. Les tables clients, mesures,
/// rendez-vous, etc. seront ajoutées dans ce même fichier au fil des
/// Phases 2 et 3, suivant le même schéma que leur équivalent Supabase.
@DriftDatabase(tables: [Ateliers, Utilisateurs, PermissionsApprenti])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_ouvrirConnexion());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _ouvrirConnexion() {
    return driftDatabase(name: 'atelier_plus');
  }
}
