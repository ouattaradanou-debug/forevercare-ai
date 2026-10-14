import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/mesure_uniforme.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';

/// Prise de mesure pour un membre de groupe — même principe que
/// `MesuresRepository` (toujours une nouvelle ligne historisée).
class MesuresUniformeRepository {
  MesuresUniformeRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  Future<MesureUniforme> enregistrerNouvellePrise({
    required String atelierId,
    required String membreId,
    required String typeTenueId,
    required Map<String, String> valeurs,
    required String prisePar,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final mesure = MesureUniforme(
      id: _uuid.v4(),
      membreId: membreId,
      typeTenueId: typeTenueId,
      datePrise: DateTime.now().toUtc(),
      valeurs: valeurs,
      prisePar: prisePar,
    );

    await _mettreEnCache(mesure);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'mesures_uniforme',
      recordId: mesure.id,
      operation: 'insert',
      payload: mesure.versJson(),
    );
    return mesure;
  }

  /// Rapatrie depuis Supabase toutes les mesures déjà prises pour ce membre
  /// — même raison que MesuresRepository.chargerDepuisServeur (sinon
  /// jamais visible sur un appareil qui ne l'a pas prise lui-même).
  Future<void> chargerDepuisServeur(String membreId) async {
    try {
      final lignes = await _client.from('mesures_uniforme').select().eq('membre_id', membreId);
      for (final ligne in lignes) {
        await _mettreEnCache(MesureUniforme.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : le cache existant reste utilisable.
    }
  }

  Future<Map<String, String>?> dernieresValeurs(String membreId, String typeTenueId) async {
    final ligne = await _baseLocale.derniereMesureUniforme(membreId, typeTenueId);
    if (ligne == null) return null;
    return _decoderValeurs(ligne.valeursJson);
  }

  Future<DateTime?> dateDerniereMesure(String membreId, String typeTenueId) async {
    final ligne = await _baseLocale.derniereMesureUniforme(membreId, typeTenueId);
    return ligne?.datePrise;
  }

  Future<void> _mettreEnCache(MesureUniforme mesure) {
    return _baseLocale.enregistrerMesureUniforme(
      id: mesure.id,
      membreId: mesure.membreId,
      typeTenueId: mesure.typeTenueId,
      datePrise: mesure.datePrise,
      valeursJson: jsonEncode(mesure.valeurs),
      prisePar: mesure.prisePar,
    );
  }

  Map<String, String> _decoderValeurs(String valeursJson) {
    final decode = jsonDecode(valeursJson) as Map<String, dynamic>;
    return decode.map((cle, valeur) => MapEntry(cle, valeur.toString()));
  }
}
