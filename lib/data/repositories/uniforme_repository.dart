import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../models/groupe_uniforme.dart';
import '../models/membre_groupe_uniforme.dart';
import '../models/mesure_uniforme.dart';
import '../models/photo_groupe_uniforme.dart';

/// Module "Mesures des uniformes" : groupes de commande (promotion,
/// établissement, équipe...), leurs membres et les mesures de chacun.
///
/// Entièrement indépendant de ClientRepository — voir
/// supabase/migration_phase8_uniformes.sql : ces données ne doivent jamais
/// se mélanger aux fiches clients classiques. La logique de synchronisation
/// (local d'abord, `synced: false` tant que non confirmé, retenté par
/// SyncEngine) reproduit exactement celle de ClientRepository.
class UniformeRepository {
  UniformeRepository(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;
  static final Uuid _uuid = Uuid();
  static const String _bucketPhotos = 'photos-uniformes';

  Future<bool> _estEnLigne() async {
    final List<ConnectivityResult> resultats = await Connectivity()
        .checkConnectivity();
    return !resultats.contains(ConnectivityResult.none);
  }

  // ---------------------------------------------------------------------
  // Groupes
  // ---------------------------------------------------------------------

  /// Crée un groupe avec ses informations générales et ses photos de
  /// modèles/tissus. `cheminsPhotosParType` est indexé par
  /// 'modele_homme'/'modele_femme'/'tissu_homme'/'tissu_femme'.
  Future<GroupeUniforme> creerGroupe({
    required String atelierId,
    required String nom,
    String? repondantNom,
    String? repondantTelephone,
    Map<String, List<String>> cheminsPhotosParType = const {},
    Map<String, String> commentairesPhotos = const {},
  }) async {
    final DateTime maintenant = DateTime.now();

    final GroupeUniforme groupe = GroupeUniforme(
      id: _uuid.v4(),
      atelierId: atelierId,
      nom: nom,
      repondantNom: repondantNom,
      repondantTelephone: repondantTelephone,
      createdAt: maintenant,
      updatedAt: maintenant,
      synced: false,
    );
    await _db
        .into(_db.groupesUniformes)
        .insertOnConflictUpdate(groupe.versCompagnonLocal());

    final List<PhotoGroupeUniforme> photos = [
      for (final MapEntry<String, List<String>> entree
          in cheminsPhotosParType.entries)
        for (final String chemin in entree.value)
          PhotoGroupeUniforme(
            id: _uuid.v4(),
            groupeId: groupe.id,
            type: entree.key,
            cheminLocal: chemin,
            source: 'galerie',
            createdAt: maintenant,
            commentaire: commentairesPhotos[chemin],
          ),
    ];
    for (final PhotoGroupeUniforme photo in photos) {
      await _db
          .into(_db.photosGroupeUniforme)
          .insertOnConflictUpdate(photo.versCompagnonLocal());
    }

    if (await _estEnLigne()) {
      try {
        await pousserGroupe(groupe);
        for (final PhotoGroupeUniforme photo in photos) {
          await pousserPhoto(photo);
        }
      } catch (_) {
        // Best-effort : les données restent valides localement (synced
        // reste à false) et seront retentées par SyncEngine.
      }
    }

    return groupe;
  }

  Future<void> pousserGroupe(GroupeUniforme groupe) async {
    await _client.from('groupes_uniformes').upsert({
      'id': groupe.id,
      'atelier_id': groupe.atelierId,
      'nom': groupe.nom,
      'repondant_nom': groupe.repondantNom,
      'repondant_telephone': groupe.repondantTelephone,
    });
    await (_db.update(
      _db.groupesUniformes,
    )..where((t) => t.id.equals(groupe.id))).write(
      const GroupesUniformesCompanion(synced: Value(true)),
    );
  }

  /// Envoie une photo de groupe vers Supabase : le fichier dans Supabase
  /// Storage (bucket `photos-uniformes`), puis sa ligne dans
  /// `photos_groupe_uniforme`. Voir ClientRepository.pousserPhoto (même
  /// logique, adaptée au groupe plutôt qu'au client).
  Future<void> pousserPhoto(PhotoGroupeUniforme photo) async {
    String? url = photo.url;

    if (url == null) {
      final File fichier = File(photo.cheminLocal);
      if (!await fichier.exists()) {
        return;
      }

      final GroupeUniformeLocal groupe = await (_db.select(
        _db.groupesUniformes,
      )..where((t) => t.id.equals(photo.groupeId))).getSingle();
      final String cheminStockage =
          '${groupe.atelierId}/${photo.groupeId}/${photo.id}.jpg';

      await _client.storage
          .from(_bucketPhotos)
          .upload(
            cheminStockage,
            fichier,
            fileOptions: const FileOptions(upsert: true),
          );
      url = _client.storage.from(_bucketPhotos).getPublicUrl(cheminStockage);
    }

    await _client.from('photos_groupe_uniforme').upsert({
      'id': photo.id,
      'groupe_id': photo.groupeId,
      'type': photo.type,
      'url': url,
      'source': photo.source,
      'commentaire': photo.commentaire,
    });

    await (_db.update(
      _db.photosGroupeUniforme,
    )..where((t) => t.id.equals(photo.id))).write(
      PhotosGroupeUniformeCompanion(synced: const Value(true), url: Value(url)),
    );
  }

  Stream<List<GroupeUniforme>> observerGroupes(String atelierId) {
    final query = _db.select(_db.groupesUniformes)
      ..where((t) => t.atelierId.equals(atelierId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map(
      (lignes) => lignes.map(GroupeUniforme.depuisLigneLocale).toList(),
    );
  }

  Stream<GroupeUniforme?> observerGroupe(String id) {
    final query = _db.select(_db.groupesUniformes)
      ..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map(
      (ligne) => ligne == null ? null : GroupeUniforme.depuisLigneLocale(ligne),
    );
  }

  Stream<List<PhotoGroupeUniforme>> observerPhotosGroupe(String groupeId) {
    final query = _db.select(_db.photosGroupeUniforme)
      ..where((t) => t.groupeId.equals(groupeId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map(
      (lignes) => lignes.map(PhotoGroupeUniforme.depuisLigneLocale).toList(),
    );
  }

  // ---------------------------------------------------------------------
  // Membres
  // ---------------------------------------------------------------------

  /// Ajoute un membre au groupe (identité seule — voir
  /// [enregistrerMesuresMembre] pour ses mesures, saisies dans un second
  /// temps depuis la fiche du groupe).
  Future<MembreGroupeUniforme> ajouterMembre({
    required String groupeId,
    String? nom,
    String? prenom,
    String? sexe,
  }) async {
    final DateTime maintenant = DateTime.now();
    final MembreGroupeUniforme membre = MembreGroupeUniforme(
      id: _uuid.v4(),
      groupeId: groupeId,
      nom: nom,
      prenom: prenom,
      sexe: sexe,
      createdAt: maintenant,
      updatedAt: maintenant,
      synced: false,
    );
    await _db
        .into(_db.membresGroupeUniforme)
        .insertOnConflictUpdate(membre.versCompagnonLocal());

    if (await _estEnLigne()) {
      try {
        await pousserMembre(membre);
      } catch (_) {
        // Best-effort, voir creerGroupe.
      }
    }

    return membre;
  }

  Future<void> pousserMembre(MembreGroupeUniforme membre) async {
    await _client.from('membres_groupe_uniforme').upsert({
      'id': membre.id,
      'groupe_id': membre.groupeId,
      'nom': membre.nom,
      'prenom': membre.prenom,
      'sexe': membre.sexe,
    });
    await (_db.update(
      _db.membresGroupeUniforme,
    )..where((t) => t.id.equals(membre.id))).write(
      const MembresGroupeUniformeCompanion(synced: Value(true)),
    );
  }

  /// Renseigne (ou change) le sexe d'un membre déjà créé — utile quand il
  /// n'a pas été précisé lors de [ajouterMembre], puisqu'il conditionne le
  /// gabarit de mesures à afficher (voir GabaritRepository.resoudreTypeTenue
  /// et MesuresMembrePage).
  Future<MembreGroupeUniforme> definirSexeMembre({
    required MembreGroupeUniforme membre,
    required String sexe,
  }) async {
    final MembreGroupeUniforme misAJour = MembreGroupeUniforme(
      id: membre.id,
      groupeId: membre.groupeId,
      nom: membre.nom,
      prenom: membre.prenom,
      sexe: sexe,
      createdAt: membre.createdAt,
      updatedAt: DateTime.now(),
      synced: false,
    );
    await _db
        .into(_db.membresGroupeUniforme)
        .insertOnConflictUpdate(misAJour.versCompagnonLocal());

    if (await _estEnLigne()) {
      try {
        await pousserMembre(misAJour);
      } catch (_) {
        // Best-effort, voir creerGroupe.
      }
    }

    return misAJour;
  }

  Stream<List<MembreGroupeUniforme>> observerMembresGroupe(String groupeId) {
    final query = _db.select(_db.membresGroupeUniforme)
      ..where((t) => t.groupeId.equals(groupeId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map(
      (lignes) => lignes.map(MembreGroupeUniforme.depuisLigneLocale).toList(),
    );
  }

  // ---------------------------------------------------------------------
  // Mesures
  // ---------------------------------------------------------------------

  /// Enregistre une nouvelle prise de mesures pour un membre. Historisée
  /// comme Mesure : n'écrase jamais une prise existante.
  Future<MesureUniforme> enregistrerMesuresMembre({
    required String membreId,
    required String typeTenueId,
    required Map<String, String> valeursMesures,
    required String prisePar,
  }) async {
    final DateTime maintenant = DateTime.now();
    final MesureUniforme mesure = MesureUniforme(
      id: _uuid.v4(),
      membreId: membreId,
      typeTenueId: typeTenueId,
      datePrise: maintenant,
      valeurs: valeursMesures,
      prisePar: prisePar,
      createdAt: maintenant,
      synced: false,
    );
    await _db
        .into(_db.mesuresUniforme)
        .insertOnConflictUpdate(mesure.versCompagnonLocal());

    if (await _estEnLigne()) {
      try {
        await pousserMesure(mesure);
      } catch (_) {
        // Best-effort, voir creerGroupe.
      }
    }

    return mesure;
  }

  Future<void> pousserMesure(MesureUniforme mesure) async {
    await _client.from('mesures_uniforme').upsert({
      'id': mesure.id,
      'membre_id': mesure.membreId,
      'type_tenue_id': mesure.typeTenueId,
      'valeurs': mesure.valeurs,
      'prise_par': mesure.prisePar,
    });
    await (_db.update(
      _db.mesuresUniforme,
    )..where((t) => t.id.equals(mesure.id))).write(
      const MesuresUniformeCompanion(synced: Value(true)),
    );
  }

  /// Historique des mesures d'un membre (la plus récente en premier).
  Stream<List<MesureUniforme>> observerMesuresMembre(String membreId) {
    final query = _db.select(_db.mesuresUniforme)
      ..where((t) => t.membreId.equals(membreId))
      ..orderBy([(t) => OrderingTerm.desc(t.datePrise)]);
    return query.watch().map(
      (lignes) => lignes.map(MesureUniforme.depuisLigneLocale).toList(),
    );
  }
}
