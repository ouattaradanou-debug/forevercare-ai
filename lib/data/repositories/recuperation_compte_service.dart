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

    final String atelierId = utilisateur.atelierId;

    // Aucun de ces appels ne dépend du résultat d'un autre (tous ne
    // dépendent que de `atelierId`, déjà connu) : les lancer en parallèle
    // plutôt qu'un par un réduit d'autant le temps total avant que
    // l'application ait fini de se mettre à jour — c'était l'un des
    // principaux points de lenteur au démarrage/à la connexion, chaque
    // aller-retour réseau s'ajoutant en plus des précédents sur une
    // connexion mobile.
    final Future<void> futureAtelier = _ateliers
        .recupererDepuisSupabase(atelierId)
        .then(_ateliers.enregistrerLocalement);
    final Future<void> futureAbonnement = _ateliers
        .synchroniserAbonnement(atelierId)
        .catchError((Object _) {
          // Best-effort : voir AtelierRepository.synchroniserAbonnement.
        });
    final Future<void> futureGabarits = _gabarits.synchroniserGabarits(
      atelierId,
    );
    // Ne dépend pas non plus de l'atelier : porte uniquement sur ce qui
    // est déjà en attente localement.
    final Future<void> futurePush = _sync.pousserModificationsEnAttente();

    // Visible par tous les membres de l'atelier (voir RLS utilisateurs).
    final equipe = await _utilisateurs.recupererEquipeAtelier(atelierId);

    if (utilisateur.estProprietaire) {
      // Un propriétaire peut lire les permissions de tous ses apprentis —
      // là aussi en parallèle plutôt qu'un par un.
      await Future.wait([
        for (final membre in equipe)
          if (!membre.estProprietaire)
            _utilisateurs.recupererPermissions(membre.id),
      ]);
    } else {
      // Un apprenti ne peut lire que ses propres permissions (RLS).
      await _utilisateurs.recupererPermissions(utilisateur.id);
    }

    await Future.wait([futureAtelier, futureAbonnement, futureGabarits]);

    // Pousser d'abord ce qui a été écrit hors-ligne depuis la dernière
    // session (évite d'écraser une modification locale pas encore
    // envoyée lors du tirage qui suit), puis tirer l'état de l'atelier —
    // ce dernier appel doit rester après `futurePush`, contrairement aux
    // autres ci-dessus.
    await futurePush;
    await _sync.tirerDonneesAtelier(atelierId);
  }
}
