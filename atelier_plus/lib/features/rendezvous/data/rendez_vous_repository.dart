import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/notifications_service.dart';
import '../../../data/local/database.dart';
import '../../../data/models/rendez_vous.dart';
import '../../../data/sync/ecriture_synchronisee.dart';

/// Gestion des rendez-vous : écriture locale d'abord, comme les clients et
/// les mesures — un rendez-vous fait partie de l'usage quotidien hors-ligne
/// ("noter RDV"). Accessible à tout membre de l'atelier, sans permission
/// dédiée (voir supabase/README.md, aucune colonne de permission pour les
/// rendez-vous : action non financière, non sensible).
class RendezVousRepository {
  RendezVousRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  Future<RendezVous> creerRendezVous({
    required String atelierId,
    required String clientId,
    required DateTime dateHeure,
    required String type,
    required String nomClientPourRappel,
  }) async {
    final rdv = RendezVous(
      id: _uuid.v4(),
      atelierId: atelierId,
      clientId: clientId,
      dateHeure: dateHeure,
      type: type,
      statut: AppConstants.rdvPlanifie,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCache(rdv);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'rendez_vous',
      recordId: rdv.id,
      operation: 'insert',
      payload: rdv.versJson(),
    );
    await _planifierRappel(rdv, nomClientPourRappel);
    return rdv;
  }

  /// Variante pratique pour les écrans qui n'ont que l'id sous la main
  /// (ex. une liste) : relit la ligne depuis le cache local avant de
  /// déléguer à [changerStatut]. Retourne `null` si le rendez-vous n'est
  /// plus en cache (cas très improbable, défensif).
  Future<RendezVous?> changerStatutParId(String rendezVousId, String nouveauStatut) async {
    final ligne = await _baseLocale.rendezVousParId(rendezVousId);
    if (ligne == null) return null;
    final existant = RendezVous(
      id: ligne.id,
      atelierId: ligne.atelierId,
      clientId: ligne.clientId,
      dateHeure: ligne.dateHeure,
      type: ligne.type,
      statut: ligne.statut,
      updatedAt: ligne.updatedAt,
    );
    return changerStatut(existant, nouveauStatut);
  }

  Future<RendezVous> changerStatut(RendezVous existant, String nouveauStatut) async {
    final miseAJour = existant.copierAvec(statut: nouveauStatut);
    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'rendez_vous',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    if (nouveauStatut == AppConstants.rdvAnnule) {
      await NotificationsService.instance.annulerRappel(miseAJour.id);
    }
    return miseAJour;
  }

  Future<void> chargerDepuisServeur(String atelierId) async {
    try {
      final lignes = await _client.from('rendez_vous').select().eq('atelier_id', atelierId);
      for (final ligne in lignes) {
        await _mettreEnCache(RendezVous.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : le cache local existant reste utilisable.
    }
  }

  Future<void> _planifierRappel(RendezVous rdv, String nomClient) async {
    final libelleType =
        rdv.type == AppConstants.rdvEssayage ? 'essayage' : 'livraison';
    await NotificationsService.instance.planifierRappelRendezVous(
      rendezVousId: rdv.id,
      dateHeureRendezVous: rdv.dateHeure,
      titre: 'Rendez-vous dans 1 heure',
      corps: '$libelleType avec $nomClient',
    );
  }

  Future<void> _mettreEnCache(RendezVous rdv) {
    return _baseLocale.enregistrerRendezVous(
      id: rdv.id,
      atelierId: rdv.atelierId,
      clientId: rdv.clientId,
      dateHeure: rdv.dateHeure,
      type: rdv.type,
      statut: rdv.statut,
      updatedAt: rdv.updatedAt,
    );
  }
}
