import '../../core/services/sync_engine.dart';
import 'atelier_repository.dart';
import 'gabarit_repository.dart';
import 'utilisateur_repository.dart';

/// Récupération complète des données d'un compte sur un nouvel appareil
/// (scénario "perte de téléphone", exigé en Phase 1) : après une connexion
/// réussie, on retélécharge tout depuis Supabase et on repeuple le cache
/// local Drift avant d'afficher l'application, qui ne lit ensuite plus que
/// le cache local (lecture hors-ligne d'abord).
///
/// Depuis la Phase 2, la synchronisation initiale inclut aussi les
/// gabarits (types de tenue + champs de mesure), pour qu'ils restent
/// disponibles hors-ligne dès la prochaine ouverture de l'application, y
/// compris pour la toute première prise de mesure d'un client.
///
/// Depuis SyncEngine (Phase 3), inclut aussi les clients et tout ce qui
/// leur est rattaché (mesures, rendez-vous, finances) : sans ça, le
/// téléphone d'un apprenti ou une réinstallation ne voyait jamais les
/// clients déjà créés sur un autre appareil de l'atelier.
class RecuperationCompteService {
  RecuperationCompteService(
    this._ateliers,
    this._utilisateurs,
    this._gabarits,
    this._sync,
  );

  final AtelierRepository _ateliers;
  final UtilisateurRepository _utilisateurs;
  final GabaritRepository _gabarits;
  final SyncEngine _sync;

  Future<void> recupererDonneesCompte(String utilisateurId) async {
    final utilisateur = await _utilisateurs.recupererDepuisSupabase(
      utilisateurId,
    );
    await _utilisateurs.enregistrerLocalement(utilisateur);

    final atelier = await _ateliers.recupererDepuisSupabase(
      utilisateur.atelierId,
    );
    await _ateliers.enregistrerLocalement(atelier);

    // Visible par tous les membres de l'atelier (voir RLS utilisateurs).
    final equipe = await _utilisateurs.recupererEquipeAtelier(
      utilisateur.atelierId,
    );

    if (utilisateur.estProprietaire) {
      // Un propriétaire peut lire les permissions de tous ses apprentis.
      for (final membre in equipe) {
        if (!membre.estProprietaire) {
          await _utilisateurs.recupererPermissions(membre.id);
        }
      }
    } else {
      // Un apprenti ne peut lire que ses propres permissions (RLS).
      await _utilisateurs.recupererPermissions(utilisateur.id);
    }

    await _gabarits.synchroniserGabarits(utilisateur.atelierId);

    // Pousser d'abord ce qui a été écrit hors-ligne depuis la dernière
    // session (évite d'écraser une modification locale pas encore
    // envoyée lors du tirage qui suit), puis tirer l'état de l'atelier.
    await _sync.pousserModificationsEnAttente();
    await _sync.tirerDonneesAtelier(utilisateur.atelierId);
  }
}
