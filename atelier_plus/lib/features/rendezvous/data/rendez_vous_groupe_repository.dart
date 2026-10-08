import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/notifications_service.dart';
import '../../../data/local/database.dart';
import '../../../data/models/rendez_vous_groupe.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';

/// Gestion des rendez-vous rattachés à un groupe d'uniformes — même
/// principe que `RendezVousRepository` (clients), sur la table dédiée
/// `rendez_vous_groupe` (voir la remarque de `RendezVousGroupeEntries`).
/// Accessible à tout membre de l'atelier, comme pour les clients (aucune
/// permission dédiée : action non financière, non sensible).
class RendezVousGroupeRepository {
  RendezVousGroupeRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  RendezVousGroupe _depuisLigne(RendezVousGroupeEntry ligne) => RendezVousGroupe(
        id: ligne.id,
        atelierId: ligne.atelierId,
        groupeId: ligne.groupeId,
        dateHeure: ligne.dateHeure,
        type: ligne.type,
        statut: ligne.statut,
        urgent: ligne.urgent,
        updatedAt: ligne.updatedAt,
      );

  Future<RendezVousGroupe> creerRendezVous({
    required String atelierId,
    required String groupeId,
    required DateTime dateHeure,
    required String type,
    required String nomGroupePourRappel,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final rdv = RendezVousGroupe(
      id: _uuid.v4(),
      atelierId: atelierId,
      groupeId: groupeId,
      dateHeure: dateHeure,
      type: type,
      statut: AppConstants.rdvPlanifie,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCache(rdv);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'rendez_vous_groupe',
      recordId: rdv.id,
      operation: 'insert',
      payload: rdv.versJson(),
    );
    await _planifierRappel(rdv, nomGroupePourRappel);
    return rdv;
  }

  Future<RendezVousGroupe?> rendezVousParId(String id) async {
    final ligne = await _baseLocale.rendezVousGroupeParId(id);
    return ligne == null ? null : _depuisLigne(ligne);
  }

  Future<void> chargerDepuisServeur(String groupeId) async {
    try {
      final lignes = await _client.from('rendez_vous_groupe').select().eq('groupe_id', groupeId);
      for (final ligne in lignes) {
        await _mettreEnCache(RendezVousGroupe.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : le cache local existant reste utilisable.
    }
  }

  Future<void> _planifierRappel(RendezVousGroupe rdv, String nomGroupe) async {
    final libelleType = rdv.type == AppConstants.rdvEssayage ? 'essayage' : 'livraison';
    await NotificationsService.instance.planifierRappelRendezVous(
      rendezVousId: rdv.id,
      dateHeureRendezVous: rdv.dateHeure,
      titre: 'Rendez-vous à venir',
      corps: '$libelleType avec $nomGroupe',
    );
  }

  Future<void> _mettreEnCache(RendezVousGroupe rdv) {
    return _baseLocale.enregistrerRendezVousGroupe(
      id: rdv.id,
      atelierId: rdv.atelierId,
      groupeId: rdv.groupeId,
      dateHeure: rdv.dateHeure,
      type: rdv.type,
      statut: rdv.statut,
      urgent: rdv.urgent,
      updatedAt: rdv.updatedAt,
    );
  }
}
