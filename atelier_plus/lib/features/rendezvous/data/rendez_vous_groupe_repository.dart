import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/notifications_service.dart';
import '../../../data/local/database.dart';
import '../../../data/models/rendez_vous_groupe.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../../data/sync/lecture_tolerante.dart';
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
        tenueRetiree: ligne.tenueRetiree,
        tenueRetireeLe: ligne.tenueRetireeLe,
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

  /// Variante pratique pour les écrans qui n'ont que l'id sous la main (ex.
  /// une liste) — même principe que RendezVousRepository.changerStatutParId.
  Future<RendezVousGroupe?> changerStatutParId(String rendezVousId, String nouveauStatut) async {
    final ligne = await _baseLocale.rendezVousGroupeParId(rendezVousId);
    if (ligne == null) return null;
    return changerStatut(_depuisLigne(ligne), nouveauStatut);
  }

  Future<RendezVousGroupe> changerStatut(RendezVousGroupe existant, String nouveauStatut) async {
    await verifierEcritureAutorisee(_baseLocale, existant.atelierId);
    final miseAJour = existant.copierAvec(statut: nouveauStatut);
    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'rendez_vous_groupe',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    if (nouveauStatut == AppConstants.rdvAnnule) {
      await NotificationsService.instance.annulerRappel(miseAJour.id);
    }
    return miseAJour;
  }

  /// Corrige un rendez-vous de groupe déjà enregistré (date, heure, type),
  /// permet de le marquer urgent et/ou "tenue retirée" — même principe que
  /// RendezVousRepository.modifierRendezVous.
  Future<RendezVousGroupe> modifierRendezVous({
    required RendezVousGroupe existant,
    required DateTime dateHeure,
    required String type,
    required bool urgent,
    required bool tenueRetiree,
    required String nomGroupePourRappel,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, existant.atelierId);
    await _baseLocale.retirerTachesPourEnregistrement('rendez_vous_groupe', existant.id);
    final tenueRetireeLe = tenueRetiree
        ? (existant.tenueRetiree ? existant.tenueRetireeLe : DateTime.now().toUtc())
        : null;
    final miseAJour = RendezVousGroupe(
      id: existant.id,
      atelierId: existant.atelierId,
      groupeId: existant.groupeId,
      dateHeure: dateHeure,
      type: type,
      statut: existant.statut,
      urgent: urgent,
      updatedAt: DateTime.now().toUtc(),
      tenueRetiree: tenueRetiree,
      tenueRetireeLe: tenueRetireeLe,
    );
    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'rendez_vous_groupe',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    if (miseAJour.statut != AppConstants.rdvAnnule) {
      await _planifierRappel(miseAJour, nomGroupePourRappel);
    }
    return miseAJour;
  }

  Future<void> chargerDepuisServeur(String groupeId) async {
    try {
      final lignes = await _client.from('rendez_vous_groupe').select().eq('groupe_id', groupeId);
      await pourChaqueLigne(lignes, (ligne) => _mettreEnCache(RendezVousGroupe.depuisJson(ligne)));
    } catch (_) {
      // Hors-ligne : le cache local existant reste utilisable.
    }
  }

  /// Rapatriement best-effort des rendez-vous de TOUS les groupes de
  /// l'atelier (et non d'un seul groupe) — même principe que
  /// RendezVousRepository.chargerDepuisServeur, utilisé par l'écran
  /// "Rendez-vous" et la carte "Aujourd'hui" de l'accueil pour fusionner
  /// les deux sources sans avoir à visiter chaque groupe individuellement.
  Future<void> chargerTousDepuisServeur(String atelierId) async {
    try {
      final lignes =
          await _client.from('rendez_vous_groupe').select().eq('atelier_id', atelierId);
      await pourChaqueLigne(lignes, (ligne) => _mettreEnCache(RendezVousGroupe.depuisJson(ligne)));
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
      tenueRetiree: rdv.tenueRetiree,
      tenueRetireeLe: rdv.tenueRetireeLe,
    );
  }
}
