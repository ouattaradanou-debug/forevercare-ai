import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/mesure.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';

/// Prise de mesure : écriture locale d'abord (comme `ClientsRepository`),
/// chaque prise crée une nouvelle ligne historisée — jamais de mise à jour
/// d'une mesure existante.
class MesuresRepository {
  MesuresRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  Future<Mesure> enregistrerNouvellePrise({
    required String atelierId,
    required String clientId,
    required String typeTenueId,
    required Map<String, String> valeurs,
    required String prisePar,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final mesure = Mesure(
      id: _uuid.v4(),
      atelierId: atelierId,
      clientId: clientId,
      typeTenueId: typeTenueId,
      datePrise: DateTime.now().toUtc(),
      valeurs: valeurs,
      prisePar: prisePar,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCache(mesure);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'mesures',
      recordId: mesure.id,
      operation: 'insert',
      payload: mesure.versJson(),
    );
    return mesure;
  }

  /// Rapatrie depuis Supabase toutes les mesures déjà prises pour ce client,
  /// quel que soit l'appareil qui les a enregistrées à l'origine — sans
  /// ceci, la fiche client (et le pré-remplissage du formulaire de prise de
  /// mesure) ne montre jamais aucune mesure sur un appareil qui ne l'a pas
  /// prise lui-même (changement de téléphone, réinstallation, apprenti vs
  /// propriétaire), même si elle existe bien côté serveur.
  Future<void> chargerDepuisServeur(String clientId) async {
    try {
      final lignes = await _client.from('mesures').select().eq('client_id', clientId);
      for (final ligne in lignes) {
        await _mettreEnCache(Mesure.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : le cache existant reste utilisable.
    }
  }

  /// Dernières valeurs enregistrées pour ce client et ce type de tenue,
  /// utilisées pour pré-remplir le formulaire de prise de mesure.
  Future<Map<String, String>?> dernieresValeurs(String clientId, String typeTenueId) async {
    final ligne = await _baseLocale.derniereMesure(clientId, typeTenueId);
    if (ligne == null) return null;
    return _decoderValeurs(ligne.valeursJson);
  }

  /// Date de la dernière prise de mesure, affichée à titre indicatif quand
  /// le formulaire est pré-rempli.
  Future<DateTime?> dateDerniereMesure(String clientId, String typeTenueId) async {
    final ligne = await _baseLocale.derniereMesure(clientId, typeTenueId);
    return ligne?.datePrise;
  }

  Future<void> _mettreEnCache(Mesure mesure) {
    return _baseLocale.enregistrerMesure(
      id: mesure.id,
      atelierId: mesure.atelierId,
      clientId: mesure.clientId,
      typeTenueId: mesure.typeTenueId,
      datePrise: mesure.datePrise,
      valeursJson: jsonEncode(mesure.valeurs),
      prisePar: mesure.prisePar,
      updatedAt: mesure.updatedAt,
    );
  }

  Map<String, String> _decoderValeurs(String valeursJson) {
    final decode = jsonDecode(valeursJson) as Map<String, dynamic>;
    return decode.map((cle, valeur) => MapEntry(cle, valeur.toString()));
  }
}
