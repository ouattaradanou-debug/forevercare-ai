import 'atelier_repository.dart';
import 'utilisateur_repository.dart';

/// Récupération complète des données d'un compte sur un nouvel appareil
/// (scénario "perte de téléphone", exigé en Phase 1) : après une connexion
/// réussie, on retélécharge tout depuis Supabase et on repeuple le cache
/// local Drift avant d'afficher l'application, qui ne lit ensuite plus que
/// le cache local (lecture hors-ligne d'abord).
///
/// Ce service ne couvre pour l'instant que les données de compte (atelier,
/// équipe, permissions), seules concernées par la Phase 1. Il sera étendu
/// au fil des Phases 2 et 3 pour inclure clients, mesures, rendez-vous, etc.
class RecuperationCompteService {
  RecuperationCompteService(this._ateliers, this._utilisateurs);

  final AtelierRepository _ateliers;
  final UtilisateurRepository _utilisateurs;

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
  }
}
