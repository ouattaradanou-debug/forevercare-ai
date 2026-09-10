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

/// Cache local de la table `types_tenue`. `atelierId` nul = gabarit par
/// défaut fourni par Atelier+ (voir supabase/schema.sql).
@DataClassName('TypeTenueLocal')
class TypesTenue extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text().nullable()();
  TextColumn get nom => text()();
  TextColumn get sexe => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de la table `champs_mesure`.
@DataClassName('ChampMesureLocal')
class ChampsMesure extends Table {
  TextColumn get id => text()();
  TextColumn get typeTenueId => text()();
  TextColumn get nom => text()();
  TextColumn get unite => text().nullable()();
  TextColumn get statut => text().withDefault(const Constant('actif'))();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de la table `clients`.
///
/// Décision d'architecture (correctif formulaire continu) : `nom`,
/// `prenom`, `telephone`, `sexe` et `datePriseMesures` sont nullable ici
/// (et sur la table Supabase correspondante, voir
/// supabase/migration_phase2_champs_optionnels.sql) car aucun champ
/// d'identité n'est individuellement obligatoire : seule l'existence d'au
/// moins une mesure conditionne la création officielle du client.
@DataClassName('ClientLocal')
class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get nom => text().nullable()();
  TextColumn get prenom => text().nullable()();
  TextColumn get telephone => text().nullable()();
  TextColumn get sexe => text().nullable()();
  DateTimeColumn get datePriseMesures => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de la table `mesures`. Historisée : jamais mise à jour après
/// écriture, une nouvelle prise crée toujours une nouvelle ligne.
/// `valeursJson` contient la carte {nom du champ: valeur saisie} encodée
/// en JSON (Drift/SQLite n'a pas de colonne JSON native).
@DataClassName('MesureLocal')
class Mesures extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get typeTenueId => text()();
  DateTimeColumn get datePrise => dateTime()();
  TextColumn get valeursJson => text().withDefault(const Constant('{}'))();
  TextColumn get prisePar => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de la table `photos`. `cheminLocal` pointe vers une copie
/// permanente du fichier dans le stockage de l'application (voir
/// `ImageUtils.compresserEtPersister`) : l'envoi vers Supabase Storage sera
/// ajouté avec le reste du moteur de synchronisation en Phase 3.
@DataClassName('PhotoLocal')
class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get type => text()();
  TextColumn get cheminLocal => text()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de la table `commandes`. Le « solde » financier d'un client
/// (voir supabase/schema.sql) : montant total convenu et avance déjà
/// versée. Réservé au propriétaire — un apprenti n'a jamais accès aux
/// finances, y compris localement (voir PermissionsApprenti).
@DataClassName('CommandeLocal')
class Commandes extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  RealColumn get montantTotal => real()();
  RealColumn get avance => real().withDefault(const Constant(0))();
  BoolColumn get tenueRetiree =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de la table `paiements`. Historisée : un paiement enregistré
/// est définitif, jamais modifié ni supprimé (une correction se fait par un
/// nouveau paiement).
@DataClassName('PaiementLocal')
class Paiements extends Table {
  TextColumn get id => text()();
  TextColumn get commandeId => text()();
  RealColumn get montant => real()();
  DateTimeColumn get datePaiement => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Brouillon de fiche client en cours de saisie.
///
/// Un seul brouillon actif par utilisateur : `utilisateurId` est la clé
/// primaire. Entièrement local, jamais envoyé à Supabase — un client n'est
/// créé "pour de vrai" (table `clients` + synchronisation) qu'au moment de
/// la finalisation, dès lors qu'il possède au moins une mesure.
///
/// `rendezVousJson` contient les rendez-vous planifiés pendant la saisie,
/// avant même que le client n'existe (donc avant qu'un `client_id` réel ne
/// soit disponible pour la table `rendez_vous`) : une liste JSON de
/// `{date_heure, type}`, transformée en vraies lignes `rendez_vous` au
/// moment de la finalisation (voir `ClientRepository.finaliserClient`).
@DataClassName('BrouillonClientLocal')
class BrouillonsClient extends Table {
  TextColumn get utilisateurId => text()();
  TextColumn get atelierId => text()();
  TextColumn get nom => text().nullable()();
  TextColumn get prenom => text().nullable()();
  TextColumn get telephone => text().nullable()();
  TextColumn get sexe => text().nullable()();
  DateTimeColumn get datePriseMesures => dateTime().nullable()();
  TextColumn get typeTenueId => text().nullable()();
  TextColumn get valeursMesuresJson => text().nullable()();
  TextColumn get photosTissuJson => text().nullable()();
  TextColumn get photosModeleJson => text().nullable()();
  TextColumn get rendezVousJson => text().nullable()();
  DateTimeColumn get misAJourLe => dateTime()();

  @override
  Set<Column> get primaryKey => {utilisateurId};
}

/// Cache local de la table `rendez_vous`. `type` vaut 'essayage' ou
/// 'livraison', `statut` 'planifie'/'confirme'/'termine'/'annule' (voir
/// supabase/schema.sql).
@DataClassName('RendezVousLocal')
class RendezVousTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  DateTimeColumn get dateHeure => dateTime()();
  TextColumn get type => text()();
  TextColumn get statut => text().withDefault(const Constant('planifie'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Base de données locale (SQLite via Drift), cache hors-ligne d'Atelier+.
@DriftDatabase(
  tables: [
    Ateliers,
    Utilisateurs,
    PermissionsApprenti,
    TypesTenue,
    ChampsMesure,
    Clients,
    Mesures,
    Photos,
    BrouillonsClient,
    RendezVousTable,
    Commandes,
    Paiements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_ouvrirConnexion());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int depuis, int vers) async {
      if (depuis < 2) {
        await m.createTable(typesTenue);
        await m.createTable(champsMesure);
        await m.createTable(clients);
        await m.createTable(mesures);
        await m.createTable(photos);
        await m.createTable(brouillonsClient);
      }
      if (depuis < 3) {
        await m.createTable(rendezVousTable);
        await m.addColumn(brouillonsClient, brouillonsClient.rendezVousJson);
      }
      if (depuis < 4) {
        await m.createTable(commandes);
        await m.createTable(paiements);
      }
      if (depuis < 5) {
        await m.addColumn(commandes, commandes.tenueRetiree);
      }
    },
  );

  static QueryExecutor _ouvrirConnexion() {
    return driftDatabase(name: 'atelier_plus');
  }
}
