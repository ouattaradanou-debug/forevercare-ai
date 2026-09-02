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

/// Cache local des clients de l'atelier.
@DataClassName('ClientEntry')
class ClientEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get nom => text()();
  TextColumn get prenom => text().nullable()();
  TextColumn get telephone => text().nullable()();
  TextColumn get sexe => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des types de tenue (gabarits par défaut + personnalisés).
@DataClassName('TypeTenueEntry')
class TypeTenueEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text().nullable()();
  TextColumn get nom => text()();
  TextColumn get sexe => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des champs de mesure d'un type de tenue.
@DataClassName('ChampMesureEntry')
class ChampMesureEntries extends Table {
  TextColumn get id => text()();
  TextColumn get typeTenueId => text()();
  TextColumn get nom => text()();
  TextColumn get unite => text()();
  TextColumn get statut => text()();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des mesures prises (historique, jamais écrasé).
/// [valeursJson] est un objet JSON encodé en texte (SQLite n'a pas de type
/// JSON natif dans l'API typée de Drift) : `{champMesureId: "valeur"}`.
@DataClassName('MesureEntry')
class MesureEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get clientId => text()();
  TextColumn get typeTenueId => text()();
  DateTimeColumn get datePrise => dateTime()();
  TextColumn get valeursJson => text()();
  TextColumn get prisePar => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des photos (tissus/modèles) d'un client.
@DataClassName('PhotoEntry')
class PhotoEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get clientId => text()();
  TextColumn get type => text()();
  TextColumn get url => text()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  AtelierEntries,
  UtilisateurEntries,
  PermissionEntries,
  SessionLocale,
  ClientEntries,
  TypeTenueEntries,
  ChampMesureEntries,
  MesureEntries,
  PhotoEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_ouvrirConnexion());

  /// Incrémenté à chaque ajout/modification de table. Phase 3 y ajoutera la
  /// file d'attente de synchronisation.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(clientEntries);
            await m.createTable(typeTenueEntries);
            await m.createTable(champMesureEntries);
            await m.createTable(mesureEntries);
            await m.createTable(photoEntries);
          }
        },
      );

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

  // --- Clients ---

  Future<void> enregistrerClient({
    required String id,
    required String atelierId,
    required String nom,
    String? prenom,
    String? telephone,
    String? sexe,
    required DateTime updatedAt,
  }) async {
    await into(clientEntries).insertOnConflictUpdate(
      ClientEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        nom: nom,
        prenom: Value(prenom),
        telephone: Value(telephone),
        sexe: Value(sexe),
        updatedAt: updatedAt,
      ),
    );
  }

  Future<ClientEntry?> clientParId(String id) {
    return (select(clientEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Recherche instantanée locale par nom, prénom ou téléphone — c'est le
  /// chemin de lecture normal de l'écran liste des clients (hors-ligne au
  /// quotidien).
  Stream<List<ClientEntry>> rechercherClients(String atelierId, String requete) {
    final termeRecherche = requete.trim();
    final motif = '%$termeRecherche%';
    return (select(clientEntries)
          ..where((t) {
            final memeAtelier = t.atelierId.equals(atelierId);
            if (termeRecherche.isEmpty) return memeAtelier;
            final correspond = t.nom.like(motif) | t.prenom.like(motif) | t.telephone.like(motif);
            return memeAtelier & correspond;
          })
          ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
        .watch();
  }

  // --- Types de tenue ---

  Future<void> enregistrerTypeTenue({
    required String id,
    String? atelierId,
    required String nom,
    required String sexe,
    required DateTime updatedAt,
  }) async {
    await into(typeTenueEntries).insertOnConflictUpdate(
      TypeTenueEntriesCompanion.insert(
        id: id,
        atelierId: Value(atelierId),
        nom: nom,
        sexe: sexe,
        updatedAt: updatedAt,
      ),
    );
  }

  /// Gabarits par défaut (atelierId NULL) + gabarits propres à l'atelier —
  /// même règle de visibilité que la politique RLS `types_tenue_select`.
  Stream<List<TypeTenueEntry>> observerTypesTenueVisibles(String atelierId) {
    return (select(typeTenueEntries)
          ..where((t) => t.atelierId.isNull() | t.atelierId.equals(atelierId))
          ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
        .watch();
  }

  // --- Champs de mesure ---

  Future<void> enregistrerChampMesure({
    required String id,
    required String typeTenueId,
    required String nom,
    required String unite,
    required String statut,
    required int ordre,
    required DateTime updatedAt,
  }) async {
    await into(champMesureEntries).insertOnConflictUpdate(
      ChampMesureEntriesCompanion.insert(
        id: id,
        typeTenueId: typeTenueId,
        nom: nom,
        unite: unite,
        statut: statut,
        ordre: Value(ordre),
        updatedAt: updatedAt,
      ),
    );
  }

  /// Champs actifs uniquement, dans l'ordre d'affichage — utilisé pour
  /// construire le formulaire dynamique de prise de mesure.
  Stream<List<ChampMesureEntry>> observerChampsActifs(String typeTenueId) {
    return (select(champMesureEntries)
          ..where((t) => t.typeTenueId.equals(typeTenueId) & t.statut.equals('actif'))
          ..orderBy([(t) => OrderingTerm.asc(t.ordre)]))
        .watch();
  }

  /// Tous les champs (actifs + masqués), pour l'écran de gestion des
  /// gabarits.
  Stream<List<ChampMesureEntry>> observerTousLesChamps(String typeTenueId) {
    return (select(champMesureEntries)
          ..where((t) => t.typeTenueId.equals(typeTenueId))
          ..orderBy([(t) => OrderingTerm.asc(t.ordre)]))
        .watch();
  }

  // --- Mesures ---

  Future<void> enregistrerMesure({
    required String id,
    required String atelierId,
    required String clientId,
    required String typeTenueId,
    required DateTime datePrise,
    required String valeursJson,
    String? prisePar,
    required DateTime updatedAt,
  }) async {
    await into(mesureEntries).insertOnConflictUpdate(
      MesureEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        clientId: clientId,
        typeTenueId: typeTenueId,
        datePrise: datePrise,
        valeursJson: valeursJson,
        prisePar: Value(prisePar),
        updatedAt: updatedAt,
      ),
    );
  }

  /// Toutes les mesures prises pour ce type de tenue, tous clients
  /// confondus — utilisé pour détecter si un champ de mesure est déjà
  /// utilisé avant de proposer de le masquer.
  Future<List<MesureEntry>> mesuresParType(String typeTenueId) {
    return (select(mesureEntries)..where((t) => t.typeTenueId.equals(typeTenueId))).get();
  }

  /// Dernière mesure prise pour ce client et ce type de tenue — sert à
  /// pré-remplir le formulaire de prise de mesure par défaut.
  Future<MesureEntry?> derniereMesure(String clientId, String typeTenueId) {
    return (select(mesureEntries)
          ..where((t) => t.clientId.equals(clientId) & t.typeTenueId.equals(typeTenueId))
          ..orderBy([(t) => OrderingTerm.desc(t.datePrise)])
          ..limit(1))
        .getSingleOrNull();
  }

  // --- Photos ---

  Future<void> enregistrerPhoto({
    required String id,
    required String atelierId,
    required String clientId,
    required String type,
    required String url,
    required String source,
    required DateTime createdAt,
  }) async {
    await into(photoEntries).insertOnConflictUpdate(
      PhotoEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        clientId: clientId,
        type: type,
        url: url,
        source: source,
        createdAt: createdAt,
      ),
    );
  }

  Stream<List<PhotoEntry>> observerPhotosDuClient(String clientId) {
    return (select(photoEntries)
          ..where((t) => t.clientId.equals(clientId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}

QueryExecutor _ouvrirConnexion() {
  return LazyDatabase(() async {
    final dossier = await getApplicationDocumentsDirectory();
    final fichier = File(p.join(dossier.path, 'atelier_plus.sqlite'));
    return NativeDatabase.createInBackground(fichier);
  });
}
