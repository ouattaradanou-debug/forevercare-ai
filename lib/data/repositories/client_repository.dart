import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../models/brouillon_client.dart' show RendezVousBrouillon;
import '../models/client.dart';
import '../models/mesure.dart';
import '../models/photo.dart';
import '../models/rendez_vous.dart';

/// Fiches clients définitives.
///
/// Décision d'architecture centrale : la table `clients` (locale et
/// distante) n'est écrite QUE par [finaliserClient], qui exige toujours un
/// type de tenue et des valeurs de mesure. Il n'existe donc, par
/// construction, aucun chemin de code créant un client sans mesure — la
/// règle "un client sans mesure n'apparaît jamais dans la liste ni n'est
/// synchronisé" est ainsi garantie structurellement, sans filtre à
/// appliquer à la lecture. Tant qu'une fiche n'a pas de mesure, elle ne
/// vit que dans `brouillons_client` (voir BrouillonRepository).
///
/// Chaque écriture est enregistrée localement d'abord (`synced: false`),
/// puis poussée vers Supabase immédiatement si une connexion est
/// disponible (`synced: true` en cas de succès). En cas d'échec ou
/// d'absence de connexion, la ligne reste marquée `synced: false` : c'est
/// SyncEngine qui se charge de retenter l'envoi plus tard, dès que la
/// connexion revient — voir lib/core/services/sync_engine.dart.
class ClientRepository {
  ClientRepository(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;
  static final Uuid _uuid = Uuid();
  static const String _bucketPhotos = 'photos-clients';

  Future<bool> _estEnLigne() async {
    final List<ConnectivityResult> resultats = await Connectivity()
        .checkConnectivity();
    return !resultats.contains(ConnectivityResult.none);
  }

  Future<Client> finaliserClient({
    required String atelierId,
    required String utilisateurId,
    String? nom,
    String? prenom,
    String? telephone,
    String? sexe,
    DateTime? datePriseMesures,
    required String typeTenueId,
    required Map<String, String> valeursMesures,
    required List<String> cheminsPhotosTissu,
    required List<String> cheminsPhotosModele,
    Map<String, String> commentairesPhotos = const {},
    List<RendezVousBrouillon> rendezVous = const [],
  }) async {
    final DateTime maintenant = DateTime.now();

    final Client client = Client(
      id: _uuid.v4(),
      atelierId: atelierId,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      sexe: sexe,
      datePriseMesures: datePriseMesures,
      createdAt: maintenant,
      updatedAt: maintenant,
      synced: false,
    );
    await _db
        .into(_db.clients)
        .insertOnConflictUpdate(client.versCompagnonLocal());

    final Mesure mesure = Mesure(
      id: _uuid.v4(),
      clientId: client.id,
      typeTenueId: typeTenueId,
      datePrise: maintenant,
      valeurs: valeursMesures,
      prisePar: utilisateurId,
      createdAt: maintenant,
      synced: false,
    );
    await _db
        .into(_db.mesures)
        .insertOnConflictUpdate(mesure.versCompagnonLocal());

    final List<Photo> photos = [
      for (final String chemin in cheminsPhotosTissu)
        Photo(
          id: _uuid.v4(),
          clientId: client.id,
          type: 'tissu',
          cheminLocal: chemin,
          source: 'galerie',
          createdAt: maintenant,
          commentaire: commentairesPhotos[chemin],
        ),
      for (final String chemin in cheminsPhotosModele)
        Photo(
          id: _uuid.v4(),
          clientId: client.id,
          type: 'modele',
          cheminLocal: chemin,
          source: 'galerie',
          createdAt: maintenant,
          commentaire: commentairesPhotos[chemin],
        ),
    ];
    for (final Photo photo in photos) {
      await _db
          .into(_db.photos)
          .insertOnConflictUpdate(photo.versCompagnonLocal());
    }

    final List<RendezVous> rendezVousCrees = [
      for (final RendezVousBrouillon r in rendezVous)
        RendezVous(
          id: _uuid.v4(),
          clientId: client.id,
          dateHeure: r.dateHeure,
          type: TypeRendezVous.depuisTexte(r.type),
          createdAt: maintenant,
          updatedAt: maintenant,
          synced: false,
        ),
    ];
    for (final RendezVous rdv in rendezVousCrees) {
      await _db
          .into(_db.rendezVousTable)
          .insertOnConflictUpdate(rdv.versCompagnonLocal());
    }

    if (await _estEnLigne()) {
      try {
        await pousserClient(client);
        await pousserMesure(mesure);
        for (final Photo photo in photos) {
          await pousserPhoto(photo);
        }
        if (rendezVousCrees.isNotEmpty) {
          await pousserRendezVous(rendezVousCrees);
        }
      } catch (_) {
        // Best-effort : les données restent valides localement (synced
        // reste à false) et seront retentées par SyncEngine.
      }
    }

    return client;
  }

  /// Met à jour la fiche d'un client déjà finalisé : identité (nom,
  /// prénom, téléphone, sexe, date de prise des mesures — remplacée sur
  /// place, contrairement aux mesures) et, si renseignées, une nouvelle
  /// prise de mesures, de nouvelles photos et/ou de nouveaux rendez-vous.
  ///
  /// Les mesures restent historisées (voir `Mesures` dans
  /// app_database.dart) : `actualiserMesures` ajoute toujours une NOUVELLE
  /// ligne plutôt que de modifier une prise existante, pour conserver
  /// l'historique des mesures du client dans le temps.
  Future<void> actualiserClient({
    required Client client,
    String? nom,
    String? prenom,
    String? telephone,
    String? sexe,
    DateTime? datePriseMesures,
    String? typeTenueId,
    required Map<String, String> valeursMesures,
    required String utilisateurId,
    required List<String> cheminsPhotosTissu,
    required List<String> cheminsPhotosModele,
    Map<String, String> commentairesPhotos = const {},
    List<RendezVousBrouillon> rendezVous = const [],
  }) async {
    final DateTime maintenant = DateTime.now();

    final Client clientMisAJour = Client(
      id: client.id,
      atelierId: client.atelierId,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      sexe: sexe,
      datePriseMesures: datePriseMesures,
      createdAt: client.createdAt,
      updatedAt: maintenant,
      synced: false,
    );
    await _db
        .into(_db.clients)
        .insertOnConflictUpdate(clientMisAJour.versCompagnonLocal());

    final bool nouvelleMesure =
        typeTenueId != null &&
        valeursMesures.values.any((v) => v.trim().isNotEmpty);
    final Mesure? mesure = !nouvelleMesure
        ? null
        : Mesure(
            id: _uuid.v4(),
            clientId: client.id,
            typeTenueId: typeTenueId,
            datePrise: maintenant,
            valeurs: valeursMesures,
            prisePar: utilisateurId,
            createdAt: maintenant,
            synced: false,
          );
    if (mesure != null) {
      await _db
          .into(_db.mesures)
          .insertOnConflictUpdate(mesure.versCompagnonLocal());
    }

    final List<Photo> photos = [
      for (final String chemin in cheminsPhotosTissu)
        Photo(
          id: _uuid.v4(),
          clientId: client.id,
          type: 'tissu',
          cheminLocal: chemin,
          source: 'galerie',
          createdAt: maintenant,
          commentaire: commentairesPhotos[chemin],
        ),
      for (final String chemin in cheminsPhotosModele)
        Photo(
          id: _uuid.v4(),
          clientId: client.id,
          type: 'modele',
          cheminLocal: chemin,
          source: 'galerie',
          createdAt: maintenant,
          commentaire: commentairesPhotos[chemin],
        ),
    ];
    for (final Photo photo in photos) {
      await _db
          .into(_db.photos)
          .insertOnConflictUpdate(photo.versCompagnonLocal());
    }

    final List<RendezVous> rendezVousCrees = [
      for (final RendezVousBrouillon r in rendezVous)
        RendezVous(
          id: _uuid.v4(),
          clientId: client.id,
          dateHeure: r.dateHeure,
          type: TypeRendezVous.depuisTexte(r.type),
          createdAt: maintenant,
          updatedAt: maintenant,
          synced: false,
        ),
    ];
    for (final RendezVous rdv in rendezVousCrees) {
      await _db
          .into(_db.rendezVousTable)
          .insertOnConflictUpdate(rdv.versCompagnonLocal());
    }

    if (await _estEnLigne()) {
      try {
        await pousserClient(clientMisAJour);
        if (mesure != null) await pousserMesure(mesure);
        for (final Photo photo in photos) {
          await pousserPhoto(photo);
        }
        if (rendezVousCrees.isNotEmpty) {
          await pousserRendezVous(rendezVousCrees);
        }
      } catch (_) {
        // Best-effort : les données restent valides localement (synced
        // reste à false) et seront retentées par SyncEngine.
      }
    }
  }

  /// Envoie (ou met à jour) une fiche client sur Supabase, puis marque la
  /// ligne locale correspondante comme synchronisée. `upsert` gère aussi
  /// bien la création que la modification en un seul appel : plus besoin
  /// de savoir si la ligne distante existe déjà.
  Future<void> pousserClient(Client client) async {
    await _client.from('clients').upsert({
      'id': client.id,
      'atelier_id': client.atelierId,
      'nom': client.nom,
      'prenom': client.prenom,
      'telephone': client.telephone,
      'sexe': client.sexe,
      'date_prise_mesures': client.datePriseMesures?.toIso8601String(),
    });
    await (_db.update(_db.clients)..where((t) => t.id.equals(client.id)))
        .write(const ClientsCompanion(synced: Value(true)));
  }

  Future<void> pousserMesure(Mesure mesure) async {
    await _client.from('mesures').upsert({
      'id': mesure.id,
      'client_id': mesure.clientId,
      'type_tenue_id': mesure.typeTenueId,
      'valeurs': mesure.valeurs,
      'prise_par': mesure.prisePar,
    });
    await (_db.update(_db.mesures)..where((t) => t.id.equals(mesure.id)))
        .write(const MesuresCompanion(synced: Value(true)));
  }

  Future<void> pousserRendezVous(List<RendezVous> rendezVous) async {
    await _client.from('rendez_vous').upsert([
      for (final RendezVous rdv in rendezVous)
        {
          'id': rdv.id,
          'client_id': rdv.clientId,
          'date_heure': rdv.dateHeure.toIso8601String(),
          'type': rdv.type.name,
        },
    ]);
    for (final RendezVous rdv in rendezVous) {
      await (_db.update(
        _db.rendezVousTable,
      )..where((t) => t.id.equals(rdv.id))).write(
        const RendezVousTableCompanion(synced: Value(true)),
      );
    }
  }

  /// Envoie une photo vers Supabase : le fichier lui-même dans Supabase
  /// Storage (bucket `photos-clients`), puis sa ligne dans `photos`. Si
  /// `photo.url` est déjà renseignée (photo déjà envoyée une première
  /// fois, seul un champ comme `commentaire` a changé depuis), le fichier
  /// n'est pas réenvoyé — seule la ligne `photos` est mise à jour.
  ///
  /// `photos` ne porte pas `atelier_id` : on le retrouve via le client
  /// déjà en cache local, pour construire le chemin de stockage
  /// "<atelier_id>/<client_id>/<photo_id>.jpg" attendu par les policies du
  /// bucket (voir supabase/storage_policies_photos.sql).
  Future<void> pousserPhoto(Photo photo) async {
    String? url = photo.url;

    if (url == null) {
      final File fichier = File(photo.cheminLocal);
      if (!await fichier.exists()) {
        // Rien à envoyer (fichier disparu localement) : laisse `synced` à
        // false, SyncEngine retentera plus tard sans jamais réussir tant
        // que ce sera le cas — best-effort, voir la classe.
        return;
      }

      final ClientLocal client = await (_db.select(
        _db.clients,
      )..where((t) => t.id.equals(photo.clientId))).getSingle();
      final String cheminStockage =
          '${client.atelierId}/${photo.clientId}/${photo.id}.jpg';

      await _client.storage
          .from(_bucketPhotos)
          .upload(
            cheminStockage,
            fichier,
            fileOptions: const FileOptions(upsert: true),
          );
      url = _client.storage.from(_bucketPhotos).getPublicUrl(cheminStockage);
    }

    await _client.from('photos').upsert({
      'id': photo.id,
      'client_id': photo.clientId,
      'type': photo.type,
      'url': url,
      'source': photo.source,
      'commentaire': photo.commentaire,
    });

    await (_db.update(_db.photos)..where((t) => t.id.equals(photo.id))).write(
      PhotosCompanion(synced: const Value(true), url: Value(url)),
    );
  }

  Stream<Client?> observerClient(String id) {
    final query = _db.select(_db.clients)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map(
      (ligne) => ligne == null ? null : Client.depuisLigneLocale(ligne),
    );
  }

  Stream<List<Client>> observerClients(String atelierId) {
    final query = _db.select(_db.clients)
      ..where((t) => t.atelierId.equals(atelierId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map(
      (lignes) => lignes.map(Client.depuisLigneLocale).toList(),
    );
  }

  Stream<List<Mesure>> observerMesuresClient(String clientId) {
    final query = _db.select(_db.mesures)
      ..where((t) => t.clientId.equals(clientId))
      ..orderBy([(t) => OrderingTerm.desc(t.datePrise)]);
    return query.watch().map(
      (lignes) => lignes.map(Mesure.depuisLigneLocale).toList(),
    );
  }

  Stream<List<Photo>> observerPhotosClient(String clientId) {
    final query = _db.select(_db.photos)
      ..where((t) => t.clientId.equals(clientId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map(
      (lignes) => lignes.map(Photo.depuisLigneLocale).toList(),
    );
  }

  Stream<List<RendezVous>> observerRendezVousClient(String clientId) {
    final query = _db.select(_db.rendezVousTable)
      ..where((t) => t.clientId.equals(clientId))
      ..orderBy([(t) => OrderingTerm.asc(t.dateHeure)]);
    return query.watch().map(
      (lignes) => lignes.map(RendezVous.depuisLigneLocale).toList(),
    );
  }

  /// Tous les rendez-vous de l'atelier (tous clients confondus), du plus
  /// proche au plus lointain — pour l'écran "Rendez-vous" de l'accueil.
  /// `rendez_vous` ne porte pas directement `atelier_id` : on passe par une
  /// jointure avec `clients`.
  Stream<List<RendezVousAvecClient>> observerRendezVousAtelier(
    String atelierId,
  ) {
    final query =
        _db.select(_db.rendezVousTable).join([
            innerJoin(
              _db.clients,
              _db.clients.id.equalsExp(_db.rendezVousTable.clientId),
            ),
          ])
          ..where(_db.clients.atelierId.equals(atelierId))
          ..orderBy([OrderingTerm.asc(_db.rendezVousTable.dateHeure)]);
    return query.watch().map(
      (lignes) => lignes
          .map(
            (ligne) => RendezVousAvecClient(
              rendezVous: RendezVous.depuisLigneLocale(
                ligne.readTable(_db.rendezVousTable),
              ),
              client: Client.depuisLigneLocale(ligne.readTable(_db.clients)),
            ),
          )
          .toList(),
    );
  }
}
