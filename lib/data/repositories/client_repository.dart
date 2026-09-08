import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../models/client.dart';
import '../models/mesure.dart';
import '../models/photo.dart';

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
class ClientRepository {
  ClientRepository(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;
  static final Uuid _uuid = Uuid();

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
        ),
      for (final String chemin in cheminsPhotosModele)
        Photo(
          id: _uuid.v4(),
          clientId: client.id,
          type: 'modele',
          cheminLocal: chemin,
          source: 'galerie',
          createdAt: maintenant,
        ),
    ];
    for (final Photo photo in photos) {
      await _db
          .into(_db.photos)
          .insertOnConflictUpdate(photo.versCompagnonLocal());
    }

    if (await _estEnLigne()) {
      try {
        await _synchroniserVersSupabase(client, mesure);
      } catch (_) {
        // Best-effort : les données restent valides localement et seront
        // resynchronisées par le moteur de synchronisation de la Phase 3.
      }
    }

    return client;
  }

  Future<void> _synchroniserVersSupabase(Client client, Mesure mesure) async {
    await _client.from('clients').insert({
      'id': client.id,
      'atelier_id': client.atelierId,
      'nom': client.nom,
      'prenom': client.prenom,
      'telephone': client.telephone,
      'sexe': client.sexe,
      'date_prise_mesures': client.datePriseMesures?.toIso8601String(),
    });
    await _client.from('mesures').insert({
      'id': mesure.id,
      'client_id': mesure.clientId,
      'type_tenue_id': mesure.typeTenueId,
      'valeurs': mesure.valeurs,
      'prise_par': mesure.prisePar,
    });
  }

  Stream<List<Client>> observerClients(String atelierId) {
    final query = _db.select(_db.clients)
      ..where((t) => t.atelierId.equals(atelierId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map(
      (lignes) => lignes.map(Client.depuisLigneLocale).toList(),
    );
  }
}
