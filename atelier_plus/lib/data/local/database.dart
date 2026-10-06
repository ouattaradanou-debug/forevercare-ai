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
  // Nullable uniquement pour permettre l'ajout de ces colonnes sans casser
  // un éventuel cache existant (migration) — en pratique toujours
  // renseignées, `clients.prenom/telephone/sexe/date_prise_mesures` étant
  // NOT NULL côté serveur.
  TextColumn get prenom => text().nullable()();
  TextColumn get telephone => text().nullable()();
  TextColumn get sexe => text().nullable()();
  DateTimeColumn get datePriseMesures => dateTime().nullable()();
  // Nullable pour la même raison que les colonnes ci-dessus (migration sans
  // casser un cache existant) : un client déjà en cache avant cet ajout
  // n'aura ce champ renseigné qu'après le prochain rapatriement serveur —
  // en attendant, il trie simplement après les clients qui l'ont déjà
  // (NULL est trié en dernier par ORDER BY ... DESC en SQLite).
  DateTimeColumn get createdAt => dateTime().nullable()();
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
  TextColumn get audioUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des rendez-vous.
@DataClassName('RendezVousEntry')
class RendezVousEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get clientId => text()();
  DateTimeColumn get dateHeure => dateTime()();
  TextColumn get type => text()();
  TextColumn get statut => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des commandes — données financières, jamais alimenté ni lu
/// pour un utilisateur apprenti (l'écran finances vérifie le rôle avant
/// même de solliciter ce cache, voir EcranFinancesClient).
@DataClassName('CommandeEntry')
class CommandeEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get clientId => text()();
  RealColumn get montantTotal => real()();
  RealColumn get avance => real()();
  BoolColumn get tenueRetiree => boolean().withDefault(const Constant(false))();
  // Nullable pour la même raison que Client.createdAt (migration sans
  // casser le cache existant) : déjà présent côté serveur de longue date,
  // seulement pas encore mirroré localement avant cet ajout.
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des paiements — même remarque que CommandeEntries.
@DataClassName('PaiementEntry')
class PaiementEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get commandeId => text()();
  RealColumn get montant => real()();
  DateTimeColumn get datePaiement => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des dépenses — même remarque que CommandeEntries/PaiementEntries
/// : donnée financière, jamais alimentée ni lue pour un apprenti.
@DataClassName('DepenseEntry')
class DepenseEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  RealColumn get montant => real()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des groupes de mesures d'uniformes.
@DataClassName('GroupeUniformeEntry')
class GroupeUniformeEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get nom => text()();
  TextColumn get repondantNom => text().nullable()();
  TextColumn get repondantTelephone => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des membres d'un groupe d'uniformes.
@DataClassName('MembreGroupeUniformeEntry')
class MembreGroupeUniformeEntries extends Table {
  TextColumn get id => text()();
  TextColumn get groupeId => text()();
  TextColumn get nom => text().nullable()();
  TextColumn get prenom => text().nullable()();
  TextColumn get sexe => text().nullable()();
  BoolColumn get tenueTerminee => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local des mesures prises pour un membre de groupe.
@DataClassName('MesureUniformeEntry')
class MesureUniformeEntries extends Table {
  TextColumn get id => text()();
  TextColumn get membreId => text()();
  TextColumn get typeTenueId => text()();
  DateTimeColumn get datePrise => dateTime()();
  TextColumn get valeursJson => text()();
  TextColumn get prisePar => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// File d'attente de synchronisation (Phase 3) : toute écriture "locale
/// d'abord" dont l'envoi immédiat vers Supabase a échoué (hors-ligne,
/// coupure réseau) y est déposée, puis rejouée par `SyncEngine` dès qu'une
/// connexion est détectée (`connectivity_plus`).
@DataClassName('TacheSyncEntry')
class SyncQueueEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nomTable => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // 'insert' | 'update'
  TextColumn get payloadJson => text()();
  DateTimeColumn get creeLe => dateTime()();
  IntColumn get tentatives => integer().withDefault(const Constant(0))();
  TextColumn get derniereErreur => text().nullable()();
}

/// Cache local de l'abonnement de l'atelier — jamais écrit depuis
/// l'application (voir modèle `Abonnement`), seulement lu, y compris
/// hors-ligne, pour calculer le bandeau de rappel d'essai et activer le
/// mode consultation seule le cas échéant.
@DataClassName('AbonnementEntry')
class AbonnementEntries extends Table {
  TextColumn get id => text()();
  TextColumn get atelierId => text()();
  TextColumn get statut => text()();
  DateTimeColumn get dateFinEssai => dateTime()();
  DateTimeColumn get dateRenouvellement => dateTime().nullable()();

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
  RendezVousEntries,
  CommandeEntries,
  PaiementEntries,
  SyncQueueEntries,
  AbonnementEntries,
  DepenseEntries,
  GroupeUniformeEntries,
  MembreGroupeUniformeEntries,
  MesureUniformeEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_ouvrirConnexion());

  @override
  int get schemaVersion => 11;

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
          if (from < 3) {
            await m.createTable(rendezVousEntries);
            await m.createTable(commandeEntries);
            await m.createTable(paiementEntries);
            await m.createTable(syncQueueEntries);
          }
          if (from < 4) {
            await m.createTable(abonnementEntries);
          }
          if (from < 5) {
            await m.createTable(depenseEntries);
            await m.createTable(groupeUniformeEntries);
          }
          if (from < 6) {
            // `createTable` ci-dessus construit toujours la table avec la
            // définition Dart actuelle (donc déjà avec repondant_nom/
            // repondant_telephone) : ces colonnes n'existent pas encore
            // seulement pour un appareil qui était déjà exactement en
            // version 5 (table créée avant leur ajout au modèle).
            if (from >= 5) {
              await m.addColumn(groupeUniformeEntries, groupeUniformeEntries.repondantNom);
              await m.addColumn(groupeUniformeEntries, groupeUniformeEntries.repondantTelephone);
            }
            await m.createTable(membreGroupeUniformeEntries);
            await m.createTable(mesureUniformeEntries);
          }
          if (from < 7) {
            // Même précaution que pour groupeUniformeEntries ci-dessus :
            // `createTable(clientEntries)` dans le bloc `from < 2` construit
            // déjà la table avec datePriseMesures si c'est la première
            // création de cette table sur l'appareil.
            if (from >= 2) {
              await m.addColumn(clientEntries, clientEntries.datePriseMesures);
            }
          }
          if (from < 8) {
            // photoEntries est créée (avec audioUrl déjà présent dans sa
            // définition Dart actuelle) dans le bloc `from < 2` : même
            // précaution que ci-dessus pour un appareil déjà en version >= 2.
            if (from >= 2) {
              await m.addColumn(photoEntries, photoEntries.audioUrl);
            }
          }
          if (from < 9) {
            // commandeEntries est créée (avec tenueRetiree déjà présent
            // dans sa définition Dart actuelle) dans le bloc `from < 3` :
            // même précaution que ci-dessus pour un appareil déjà en
            // version >= 3.
            if (from >= 3) {
              await m.addColumn(commandeEntries, commandeEntries.tenueRetiree);
            }
          }
          if (from < 10) {
            // clientEntries est créée (avec createdAt déjà présent dans sa
            // définition Dart actuelle) dans le bloc `from < 2` : même
            // précaution que ci-dessus pour un appareil déjà en version >= 2.
            if (from >= 2) {
              await m.addColumn(clientEntries, clientEntries.createdAt);
            }
          }
          if (from < 11) {
            // commandeEntries est créée (avec createdAt déjà présent dans
            // sa définition Dart actuelle) dans le bloc `from < 3` : même
            // précaution que ci-dessus pour un appareil déjà en version >= 3.
            if (from >= 3) {
              await m.addColumn(commandeEntries, commandeEntries.createdAt);
            }
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
    DateTime? datePriseMesures,
    DateTime? createdAt,
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
        datePriseMesures: Value(datePriseMesures),
        createdAt: Value(createdAt),
        updatedAt: updatedAt,
      ),
    );
  }

  Future<ClientEntry?> clientParId(String id) {
    return (select(clientEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Recherche instantanée locale par nom, prénom ou téléphone — c'est le
  /// chemin de lecture normal de l'écran liste des clients (hors-ligne au
  /// quotidien). Du plus récent au plus ancien, comme dans l'ancienne
  /// application.
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
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Supprime un client du cache local, avec tout ce qui lui est associé
  /// (mesures, photos, rendez-vous, commande et ses paiements) — miroir
  /// local du `on delete cascade` déjà en place côté serveur, appelé après
  /// une suppression réussie sur Supabase (voir ClientsRepository.
  /// supprimerClient).
  Future<void> supprimerClientEtDependances(String clientId) async {
    await transaction(() async {
      // Retire d'abord toute tâche encore en file d'attente pour le client
      // et chacune de ses dépendances (ajout fait hors-ligne, jamais encore
      // envoyé au serveur) : sans ça, la suppression ci-dessous serait
      // "ressuscitée" dès que la file d'attente serait rejouée — voir
      // ClientsRepository.supprimerClient.
      final commandes =
          await (select(commandeEntries)..where((t) => t.clientId.equals(clientId))).get();
      for (final commande in commandes) {
        final paiements =
            await (select(paiementEntries)..where((t) => t.commandeId.equals(commande.id))).get();
        for (final paiement in paiements) {
          await retirerTachesPourEnregistrement('paiements', paiement.id);
        }
        await retirerTachesPourEnregistrement('commandes', commande.id);
        await (delete(paiementEntries)..where((t) => t.commandeId.equals(commande.id))).go();
      }

      final mesures = await (select(mesureEntries)..where((t) => t.clientId.equals(clientId))).get();
      for (final mesure in mesures) {
        await retirerTachesPourEnregistrement('mesures', mesure.id);
      }
      final photos = await (select(photoEntries)..where((t) => t.clientId.equals(clientId))).get();
      for (final photo in photos) {
        await retirerTachesPourEnregistrement('photos', photo.id);
      }
      final rendezVous =
          await (select(rendezVousEntries)..where((t) => t.clientId.equals(clientId))).get();
      for (final rdv in rendezVous) {
        await retirerTachesPourEnregistrement('rendez_vous', rdv.id);
      }
      await retirerTachesPourEnregistrement('clients', clientId);

      await (delete(commandeEntries)..where((t) => t.clientId.equals(clientId))).go();
      await (delete(mesureEntries)..where((t) => t.clientId.equals(clientId))).go();
      await (delete(photoEntries)..where((t) => t.clientId.equals(clientId))).go();
      await (delete(rendezVousEntries)..where((t) => t.clientId.equals(clientId))).go();
      await (delete(clientEntries)..where((t) => t.id.equals(clientId))).go();
    });
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

  /// Utilisé par l'export PDF (Phase 4) pour retrouver le nom du type de
  /// tenue associé à un groupe de mesures.
  Future<TypeTenueEntry?> typeTenueParId(String id) {
    return (select(typeTenueEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Utilisé par l'export PDF (Phase 4) pour retrouver le nom/l'unité d'un
  /// champ à partir de son id (clé stockée dans `mesures.valeurs`).
  Future<ChampMesureEntry?> champMesureParId(String id) {
    return (select(champMesureEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
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

  /// Toutes les mesures d'un client (tous types de tenue confondus),
  /// utilisé par l'export PDF (Phase 4) pour composer la fiche complète.
  Future<List<MesureEntry>> toutesMesuresDuClient(String clientId) {
    return (select(mesureEntries)..where((t) => t.clientId.equals(clientId))).get();
  }

  // --- Photos ---

  Future<void> enregistrerPhoto({
    required String id,
    required String atelierId,
    required String clientId,
    required String type,
    required String url,
    required String source,
    String? audioUrl,
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
        audioUrl: Value(audioUrl),
        createdAt: createdAt,
      ),
    );
  }

  /// Rattache (ou remplace) la note vocale de description d'une photo déjà
  /// envoyée — ne touche à aucune autre colonne de la ligne.
  Future<void> mettreAJourAudioPhoto(String id, String? audioUrl) async {
    await (update(photoEntries)..where((t) => t.id.equals(id)))
        .write(PhotoEntriesCompanion(audioUrl: Value(audioUrl)));
  }

  Stream<List<PhotoEntry>> observerPhotosDuClient(String clientId) {
    return (select(photoEntries)
          ..where((t) => t.clientId.equals(clientId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<void> supprimerPhoto(String id) {
    return (delete(photoEntries)..where((t) => t.id.equals(id))).go();
  }

  // --- Rendez-vous ---

  Future<void> enregistrerRendezVous({
    required String id,
    required String atelierId,
    required String clientId,
    required DateTime dateHeure,
    required String type,
    required String statut,
    required DateTime updatedAt,
  }) async {
    await into(rendezVousEntries).insertOnConflictUpdate(
      RendezVousEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        clientId: clientId,
        dateHeure: dateHeure,
        type: type,
        statut: statut,
        updatedAt: updatedAt,
      ),
    );
  }

  Future<RendezVousEntry?> rendezVousParId(String id) {
    return (select(rendezVousEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Rendez-vous à venir, triés par date — lecture locale, hors-ligne.
  Stream<List<RendezVousEntry>> observerRendezVousTries(String atelierId) {
    return (select(rendezVousEntries)
          ..where((t) => t.atelierId.equals(atelierId))
          ..orderBy([(t) => OrderingTerm.asc(t.dateHeure)]))
        .watch();
  }

  // --- Commandes (financier — jamais consulté pour un apprenti) ---

  Future<void> enregistrerCommande({
    required String id,
    required String atelierId,
    required String clientId,
    required double montantTotal,
    required double avance,
    bool tenueRetiree = false,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    await into(commandeEntries).insertOnConflictUpdate(
      CommandeEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        clientId: clientId,
        montantTotal: montantTotal,
        avance: avance,
        tenueRetiree: Value(tenueRetiree),
        createdAt: Value(createdAt),
        updatedAt: updatedAt,
      ),
    );
  }

  /// Toutes les commandes du client, de la plus récente à la plus ancienne
  /// — un client peut revenir pour plusieurs coutures successives, chacune
  /// avec son propre montant/avance/paiements (voir FinancesRepository).
  Future<List<CommandeEntry>> commandesDuClient(String clientId) {
    return (select(commandeEntries)
          ..where((t) => t.clientId.equals(clientId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  // --- Paiements (financier — jamais consulté pour un apprenti) ---

  Future<void> enregistrerPaiement({
    required String id,
    required String atelierId,
    required String commandeId,
    required double montant,
    required DateTime datePaiement,
  }) async {
    await into(paiementEntries).insertOnConflictUpdate(
      PaiementEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        commandeId: commandeId,
        montant: montant,
        datePaiement: datePaiement,
      ),
    );
  }

  Stream<List<PaiementEntry>> observerPaiementsDeLaCommande(String commandeId) {
    return (select(paiementEntries)
          ..where((t) => t.commandeId.equals(commandeId))
          ..orderBy([(t) => OrderingTerm.desc(t.datePaiement)]))
        .watch();
  }

  /// Supprime tous les paiements d'une commande du cache local — utilisé
  /// quand le propriétaire corrige directement le total "Paiement reçu"
  /// (voir FinancesRepository.definirPaiementTotal), qui remplace
  /// l'historique détaillé par une seule ligne correspondant au nouveau
  /// total.
  Future<void> supprimerPaiementsDeLaCommande(String commandeId) {
    return (delete(paiementEntries)..where((t) => t.commandeId.equals(commandeId))).go();
  }

  /// Tous les paiements de l'atelier (tous clients confondus), utilisé par
  /// l'écran "Suivi des finances" pour le récapitulatif global.
  Future<List<PaiementEntry>> tousPaiementsDeLAtelier(String atelierId) {
    return (select(paiementEntries)..where((t) => t.atelierId.equals(atelierId))).get();
  }

  // --- Dépenses (financier — jamais consulté pour un apprenti) ---

  Future<void> enregistrerDepense({
    required String id,
    required String atelierId,
    required double montant,
    String? description,
    required DateTime date,
    required DateTime createdAt,
  }) async {
    await into(depenseEntries).insertOnConflictUpdate(
      DepenseEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        montant: montant,
        description: Value(description),
        date: date,
        createdAt: createdAt,
      ),
    );
  }

  Future<List<DepenseEntry>> toutesDepensesDeLAtelier(String atelierId) {
    return (select(depenseEntries)..where((t) => t.atelierId.equals(atelierId))).get();
  }

  /// Historique des dépenses, les plus récentes en premier — utilisé par
  /// l'écran "Historique des dépenses".
  Stream<List<DepenseEntry>> observerDepensesDeLAtelier(String atelierId) {
    return (select(depenseEntries)
          ..where((t) => t.atelierId.equals(atelierId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Vide le cache local des commandes/paiements/dépenses à la déconnexion : un
  /// appareil peut être partagé entre le propriétaire et un apprenti, et
  /// les données financières ne doivent jamais rester lisibles sur disque
  /// après le départ du propriétaire (défense en profondeur, en plus du
  /// filtrage déjà fait par l'écran et par la RLS). Ne fait rien s'il reste
  /// des écritures financières non encore synchronisées, pour ne jamais
  /// perdre de données en attente d'envoi.
  Future<void> effacerCacheFinancierSiSynchronise() async {
    final tachesFinancieres = await (select(syncQueueEntries)
          ..where((t) => t.nomTable.isIn(const ['commandes', 'paiements', 'depenses'])))
        .get();
    if (tachesFinancieres.isNotEmpty) return;

    await delete(commandeEntries).go();
    await delete(paiementEntries).go();
    await delete(depenseEntries).go();
  }

  // --- Groupes d'uniformes ---

  Future<void> enregistrerGroupeUniforme({
    required String id,
    required String atelierId,
    required String nom,
    String? repondantNom,
    String? repondantTelephone,
    required DateTime updatedAt,
  }) async {
    await into(groupeUniformeEntries).insertOnConflictUpdate(
      GroupeUniformeEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        nom: nom,
        repondantNom: Value(repondantNom),
        repondantTelephone: Value(repondantTelephone),
        updatedAt: updatedAt,
      ),
    );
  }

  Stream<List<GroupeUniformeEntry>> observerGroupesUniformes(String atelierId) {
    return (select(groupeUniformeEntries)
          ..where((t) => t.atelierId.equals(atelierId))
          ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
        .watch();
  }

  Future<GroupeUniformeEntry?> groupeUniformeParId(String id) {
    return (select(groupeUniformeEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // --- Membres d'un groupe d'uniformes ---

  Future<void> enregistrerMembreGroupeUniforme({
    required String id,
    required String groupeId,
    String? nom,
    String? prenom,
    String? sexe,
    required bool tenueTerminee,
    required DateTime updatedAt,
  }) async {
    await into(membreGroupeUniformeEntries).insertOnConflictUpdate(
      MembreGroupeUniformeEntriesCompanion.insert(
        id: id,
        groupeId: groupeId,
        nom: Value(nom),
        prenom: Value(prenom),
        sexe: Value(sexe),
        tenueTerminee: Value(tenueTerminee),
        updatedAt: updatedAt,
      ),
    );
  }

  Stream<List<MembreGroupeUniformeEntry>> observerMembresDuGroupe(String groupeId) {
    return (select(membreGroupeUniformeEntries)
          ..where((t) => t.groupeId.equals(groupeId))
          ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
        .watch();
  }

  // --- Mesures des membres de groupe ---

  Future<void> enregistrerMesureUniforme({
    required String id,
    required String membreId,
    required String typeTenueId,
    required DateTime datePrise,
    required String valeursJson,
    String? prisePar,
  }) async {
    await into(mesureUniformeEntries).insertOnConflictUpdate(
      MesureUniformeEntriesCompanion.insert(
        id: id,
        membreId: membreId,
        typeTenueId: typeTenueId,
        datePrise: datePrise,
        valeursJson: valeursJson,
        prisePar: Value(prisePar),
      ),
    );
  }

  /// Dernière mesure prise pour ce membre et ce type de tenue — pré-remplit
  /// le formulaire, comme `derniereMesure` pour un client.
  Future<MesureUniformeEntry?> derniereMesureUniforme(String membreId, String typeTenueId) {
    return (select(mesureUniformeEntries)
          ..where((t) => t.membreId.equals(membreId) & t.typeTenueId.equals(typeTenueId))
          ..orderBy([(t) => OrderingTerm.desc(t.datePrise)])
          ..limit(1))
        .getSingleOrNull();
  }

  // --- File d'attente de synchronisation ---

  Future<void> enfilerSync({
    required String nomTable,
    required String recordId,
    required String operation,
    required String payloadJson,
  }) async {
    await into(syncQueueEntries).insert(
      SyncQueueEntriesCompanion.insert(
        nomTable: nomTable,
        recordId: recordId,
        operation: operation,
        payloadJson: payloadJson,
        creeLe: DateTime.now().toUtc(),
      ),
    );
  }

  Future<List<TacheSyncEntry>> tachesEnAttente() {
    return (select(syncQueueEntries)..orderBy([(t) => OrderingTerm.asc(t.creeLe)])).get();
  }

  Future<void> retirerTacheSync(int id) {
    return (delete(syncQueueEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Retire toute tâche en attente concernant un enregistrement précis.
  ///
  /// Indispensable avant de supprimer localement une ligne dont l'envoi au
  /// serveur a pu échouer et être mis en file d'attente (hors-ligne,
  /// coupure réseau) : sans ce nettoyage, la tâche en attente finirait par
  /// être rejouée par `SyncEngine` et "ressusciterait" côté serveur une
  /// ligne pourtant supprimée (et de nouveau dans le cache local via
  /// `_appliquerLocalement`) — voir ClientsRepository.supprimerClient et
  /// FinancesRepository.definirPaiementTotal.
  Future<void> retirerTachesPourEnregistrement(String nomTable, String recordId) {
    return (delete(syncQueueEntries)
          ..where((t) => t.nomTable.equals(nomTable) & t.recordId.equals(recordId)))
        .go();
  }

  Future<void> enregistrerEchecSync(int id, String erreur) async {
    final tache =
        await (select(syncQueueEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (tache == null) return;
    await (update(syncQueueEntries)..where((t) => t.id.equals(id))).write(
      SyncQueueEntriesCompanion(
        tentatives: Value(tache.tentatives + 1),
        derniereErreur: Value(erreur),
      ),
    );
  }

  /// Nombre de tâches en attente, affiché comme indicateur discret dans
  /// l'application (ex. "3 en attente de synchronisation").
  Stream<int> observerNombreTachesEnAttente() {
    final compte = syncQueueEntries.id.count();
    final requete = selectOnly(syncQueueEntries)..addColumns([compte]);
    return requete.watchSingle().map((ligne) => ligne.read(compte) ?? 0);
  }

  // --- Abonnement ---

  Future<void> enregistrerAbonnement({
    required String id,
    required String atelierId,
    required String statut,
    required DateTime dateFinEssai,
    DateTime? dateRenouvellement,
  }) async {
    await into(abonnementEntries).insertOnConflictUpdate(
      AbonnementEntriesCompanion.insert(
        id: id,
        atelierId: atelierId,
        statut: statut,
        dateFinEssai: dateFinEssai,
        dateRenouvellement: Value(dateRenouvellement),
      ),
    );
  }

  Stream<AbonnementEntry?> observerAbonnement(String atelierId) {
    return (select(abonnementEntries)..where((t) => t.atelierId.equals(atelierId)))
        .watchSingleOrNull();
  }
}

QueryExecutor _ouvrirConnexion() {
  return LazyDatabase(() async {
    final dossier = await getApplicationDocumentsDirectory();
    final fichier = File(p.join(dossier.path, 'atelier_plus.sqlite'));
    return NativeDatabase.createInBackground(fichier);
  });
}
