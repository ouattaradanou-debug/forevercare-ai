import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Cache local de l'atelier courant (au plus une ligne par appareil : un
/// appareil est utilisé par un seul atelier à la fois).
///
/// `@DataClassName` fixe explicitement le nom de la classe générée : la
/// règle de singularisation par défaut de Drift (retrait naïf d'un simple
/// "s" final, pas une vraie inflexion anglaise) est trop incertaine à
/// deviner sans pouvoir exécuter `build_runner` dans cet environnement.
@DataClassName('AtelierEntry')
class AtelierEntries extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  TextColumn get logoUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des utilisateurs de l'atelier courant (propriétaire +
/// apprentis), nécessaire pour que l'écran "Gérer mes apprentis" reste
/// consultable hors-ligne.
@DataClassName('UtilisateurEntry')
class UtilisateurEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get nom => text()();
  TextColumn get telephone => text()();
  TextColumn get role => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des permissions de chaque apprenti.
@DataClassName('PermissionEntry')
class PermissionEntries extends Table {
  TextColumn get utilisateurId => text()();
  BoolColumn get creerClient => boolean().withDefault(const Constant(false))();
  BoolColumn get modifierClient => boolean().withDefault(const Constant(false))();
  BoolColumn get prendreMesures => boolean().withDefault(const Constant(false))();
  BoolColumn get ajouterPhotos => boolean().withDefault(const Constant(false))();
  BoolColumn get modifierGabarits => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {utilisateurId};
}

/// Pointeur "qui est connecté sur cet appareil ?", indépendant du jeton de
/// session Supabase : permet à l'application de démarrer et de savoir qui
/// l'utilise (rôle, permissions) sans aucun accès réseau.
///
/// Une seule ligne (id fixé à 1).
@DataClassName('SessionLocaleEntry')
class SessionLocale extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get utilisateurId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [AtelierEntries, UtilisateurEntries, PermissionEntries, SessionLocale])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_ouvrirConnexion());

  /// Incrémenté à chaque ajout/modification de table. Phase 2 y ajoutera
  /// les tables clients/gabarits/mesures, Phase 3 la file de synchronisation.
  @override
  int get schemaVersion => 1;

  // --- Session locale ---

  Future<String?> utilisateurConnecteId() async {
    final ligne = await (select(sessionLocale)..where((t) => t.id.equals(1))).getSingleOrNull();
    return ligne?.utilisateurId;
  }

  Future<void> definirUtilisateurConnecte(String? utilisateurId) async {
    await into(sessionLocale).insertOnConflictUpdate(
      SessionLocaleCompanion.insert(id: const Value(1), utilisateurId: Value(utilisateurId)),
    );
  }

  // --- Atelier ---

  Future<void> enregistrerAtelier({
    required String id,
    required String nom,
    String? logoUrl,
    required DateTime updatedAt,
  }) async {
    await into(atelierEntries).insertOnConflictUpdate(
      AtelierEntriesCompanion.insert(
        id: id,
        nom: nom,
        logoUrl: Value(logoUrl),
        updatedAt: updatedAt,
      ),
    );
  }

  Future<AtelierEntry?> atelierParId(String id) {
    return (select(atelierEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // --- Utilisateurs ---

  Future<void> enregistrerUtilisateur({
    required String id,
    required String atelierId,
    required String nom,
    required String telephone,
    required String role,
    required DateTime updatedAt,
  }) async {
    await into(utilisateurEntries).insertOnConflictUpdate(
      UtilisateurEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        nom: nom,
        telephone: telephone,
        role: role,
        updatedAt: updatedAt,
      ),
    );
  }

  Future<UtilisateurEntry?> utilisateurParId(String id) {
    return (select(utilisateurEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<UtilisateurEntry>> observerUtilisateursDeLAtelier(String atelierId) {
    return (select(utilisateurEntries)..where((t) => t.atelierId.equals(atelierId))).watch();
  }

  // --- Permissions ---

  Future<void> enregistrerPermissions({
    required String utilisateurId,
    required bool creerClient,
    required bool modifierClient,
    required bool prendreMesures,
    required bool ajouterPhotos,
    required bool modifierGabarits,
  }) async {
    await into(permissionEntries).insertOnConflictUpdate(
      PermissionEntriesCompanion.insert(
        utilisateurId: utilisateurId,
        creerClient: Value(creerClient),
        modifierClient: Value(modifierClient),
        prendreMesures: Value(prendreMesures),
        ajouterPhotos: Value(ajouterPhotos),
        modifierGabarits: Value(modifierGabarits),
      ),
    );
  }

  Future<PermissionEntry?> permissionsDe(String utilisateurId) {
    return (select(permissionEntries)..where((t) => t.utilisateurId.equals(utilisateurId)))
        .getSingleOrNull();
  }
}

QueryExecutor _ouvrirConnexion() {
  return LazyDatabase(() async {
    final dossier = await getApplicationDocumentsDirectory();
    final fichier = File(p.join(dossier.path, 'atelier_plus.sqlite'));
    return NativeDatabase.createInBackground(fichier);
  });
}
