import 'dart:convert';

import 'package:flutter/foundation.dart';
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
      // Délai limite explicite : la fiche client ATTEND ce rapatriement
      // (contrairement aux autres `chargerDepuisServeur` de l'application,
      // tous en arrière-plan) — sans cette limite, un réseau qui ne répond
      // ni n'échoue (certains portails captifs, coupures silencieuses)
      // bloquerait l'ouverture de la fiche indéfiniment.
      final lignes = await _client
          .from('mesures')
          .select()
          .eq('client_id', clientId)
          .timeout(const Duration(seconds: 6));
      debugPrint('MesuresRepository.chargerDepuisServeur: '
          '${lignes.length} ligne(s) reçue(s) pour client $clientId');
      for (final ligne in lignes) {
        await _mettreEnCache(Mesure.depuisJson(ligne));
      }
    } catch (e, pile) {
      debugPrint('MesuresRepository.chargerDepuisServeur: échec : $e');
      debugPrint('$pile');
      // Hors-ligne (ou délai dépassé) : le cache existant reste utilisable.
    }
  }

  /// Rapatrie TOUTES les mesures de l'atelier en une seule requête
  /// (contrairement à [chargerDepuisServeur], limité à un client) — appelé
  /// une fois après chaque connexion (voir synchronisation_initiale.dart),
  /// pour que les mesures déjà prises par le passé réapparaissent d'un
  /// coup pour tous les clients, notamment après une réinstallation de
  /// l'application (qui vide entièrement le cache local).
  Future<void> chargerToutesDepuisServeur(String atelierId) async {
    try {
      final lignes = await _client
          .from('mesures')
          .select()
          .eq('atelier_id', atelierId)
          .timeout(const Duration(seconds: 20));
      // Diagnostic temporaire (voir le terminal `flutter run`) : permet de
      // distinguer "aucune mesure sur le serveur pour cet atelier" d'un
      // échec de la requête, invisible autrement derrière le catch ci-dessous.
      debugPrint('MesuresRepository.chargerToutesDepuisServeur: '
          '${lignes.length} ligne(s) reçue(s) pour atelier $atelierId');
      for (final ligne in lignes) {
        await _mettreEnCache(Mesure.depuisJson(ligne));
      }
    } catch (e, pile) {
      debugPrint('MesuresRepository.chargerToutesDepuisServeur: échec : $e');
      debugPrint('$pile');
      // Hors-ligne (ou délai dépassé) : le cache existant reste utilisable.
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
