import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/client.dart';
import '../../data/models/type_tenue.dart';
import '../../data/remote/supabase_client_provider.dart';
import '../../features/abonnement/presentation/ecran_abonnement.dart';
import '../../features/auth/presentation/ecran_accueil_provisoire.dart';
import '../../features/auth/presentation/ecran_connexion.dart';
import '../../features/auth/presentation/ecran_creation_apprenti.dart';
import '../../features/auth/presentation/ecran_creation_compte_atelier.dart';
import '../../features/auth/presentation/ecran_gestion_apprentis.dart';
import '../../features/auth/presentation/ecran_parametres.dart';
import '../../features/auth/presentation/ecran_signature_atelier.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/clients/presentation/ecran_fiche_client.dart';
import '../../features/clients/presentation/ecran_formulaire_client.dart';
import '../../features/clients/presentation/ecran_gestion_photos.dart';
import '../../features/clients/presentation/ecran_liste_clients.dart';
import '../../features/clients/presentation/ecran_nouveau_client.dart';
import '../../features/mesures/presentation/ecran_champs_de_mesure.dart';
import '../../features/mesures/presentation/ecran_creation_type_tenue.dart';
import '../../features/mesures/presentation/ecran_gestion_champs.dart';
import '../../features/mesures/presentation/ecran_gestion_types_tenue.dart';
import '../../features/mesures/presentation/ecran_prise_mesure.dart';
import '../../features/mesures/presentation/ecran_selection_type_tenue.dart';
import '../../features/finances/presentation/ecran_enregistrer_depense.dart';
import '../../features/finances/presentation/ecran_historique_depenses.dart';
import '../../features/finances/presentation/ecran_finances_client.dart';
import '../../features/finances/presentation/ecran_suivi_finances.dart';
import '../../features/permissions/presentation/ecran_panneau_permissions.dart';
import '../../features/rendezvous/presentation/ecran_formulaire_rendez_vous.dart';
import '../../features/rendezvous/presentation/ecran_liste_rendez_vous.dart';
import '../../features/uniformes/presentation/ecran_detail_groupe.dart';
import '../../features/uniformes/presentation/ecran_groupes_uniformes.dart';
import '../../features/uniformes/presentation/ecran_prise_mesure_membre.dart';
import '../../features/uniformes/presentation/ecran_selection_type_tenue_membre.dart';
import '../../data/models/categorie_vente.dart';
import '../../features/ventes/presentation/ecran_enregistrer_vente.dart';
import '../../features/ventes/presentation/ecran_gestion_stock.dart';
import '../../features/ventes/presentation/ecran_historique_ventes.dart';
import '../../features/ventes/presentation/ecran_stock_categorie.dart';
import '../../features/ventes/presentation/ecran_ventes.dart';

/// Chemins nommés des routes de l'application, centralisés pour éviter les
/// chaînes de caractères éparpillées dans le code.
class AppRoutes {
  const AppRoutes._();

  static const String connexion = '/connexion';
  static const String creationCompte = '/creation-compte';
  static const String accueil = '/';
  static const String parametres = '/parametres';
  static const String apprentis = '/apprentis';
  static const String creationApprenti = '/apprentis/nouveau';
  static const String _permissionsApprentiTemplate = '/apprentis/:id/permissions';

  static String permissionsApprenti(String utilisateurId) =>
      '/apprentis/$utilisateurId/permissions';

  static const String clients = '/clients';
  static const String creationClient = '/clients/nouveau';
  static const String _ficheClientTemplate = '/clients/:id';
  static const String _modificationClientTemplate = '/clients/:id/modifier';
  static const String _selectionTypeTenueTemplate = '/clients/:id/mesures';
  static const String _priseMesureTemplate = '/clients/:id/mesures/:typeTenueId';
  static const String _photosClientTemplate = '/clients/:id/photos';

  static String ficheClient(String id) => '/clients/$id';
  static String modificationClient(String id) => '/clients/$id/modifier';
  static String selectionTypeTenue(String clientId) => '/clients/$clientId/mesures';
  static String priseMesure(String clientId, String typeTenueId) =>
      '/clients/$clientId/mesures/$typeTenueId';
  static String photosClient(String clientId) => '/clients/$clientId/photos';

  static const String typesTenue = '/types-tenue';
  static const String creationTypeTenue = '/types-tenue/nouveau';
  static const String _gestionChampsTemplate = '/types-tenue/:id/champs';
  static const String champsDeMesure = '/champs-de-mesure';
  static const String signatureAtelier = '/signature-atelier';

  static String gestionChampsTypeTenue(String id) => '/types-tenue/$id/champs';

  static const String rendezVous = '/rendez-vous';
  static const String creationRendezVous = '/rendez-vous/nouveau';

  static const String _financesClientTemplate = '/clients/:id/finances';

  static String financesClient(String clientId) => '/clients/$clientId/finances';

  static const String abonnement = '/abonnement';

  static const String nouvelleDepense = '/depenses/nouvelle';
  static const String historiqueDepenses = '/depenses/historique';
  static const String suiviFinances = '/finances';
  static const String groupesUniformes = '/uniformes';
  static const String _detailGroupeUniformeTemplate = '/uniformes/:id';
  static const String _selectionTypeTenueMembreTemplate = '/uniformes/membres/:membreId/mesures';
  static const String _priseMesureMembreTemplate =
      '/uniformes/membres/:membreId/mesures/:typeTenueId';

  static String detailGroupeUniforme(String id) => '/uniformes/$id';
  static String selectionTypeTenueMembre(String membreId) => '/uniformes/membres/$membreId/mesures';
  static String priseMesureMembre(String membreId, String typeTenueId) =>
      '/uniformes/membres/$membreId/mesures/$typeTenueId';

  static const String ventes = '/ventes';
  static const String _nouvelleVenteTemplate = '/ventes/nouvelle/:categorie';
  static const String historiqueVentes = '/ventes/historique';
  static const String gestionStock = '/ventes/stock';
  static const String _stockCategorieTemplate = '/ventes/stock/categorie/:categorie';

  // La catégorie est encodée dans l'URL (plutôt que passée via `extra`) :
  // `extra` ne survit pas à un recalcul de route par go_router (ex. retour
  // système, redirection réévaluée), ce qui provoquait un plantage
  // "type 'Null' is not a subtype of type 'CategorieVente'" en rouvrant
  // l'écran après une telle réévaluation.
  static String nouvelleVente(CategorieVente categorie) =>
      '/ventes/nouvelle/${categorie.valeurJson}';
  static String stockCategorie(CategorieVente categorie) =>
      '/ventes/stock/categorie/${categorie.valeurJson}';
}

/// Router déclaratif de l'application (go_router), avec redirection
/// automatique selon l'état de connexion : un utilisateur non connecté ne
/// peut atteindre aucun écran protégé, et un utilisateur déjà connecté ne
/// revoit plus les écrans de connexion/création de compte.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.accueil,
    refreshListenable: _EcouteurEtatAuth(ref),
    redirect: (context, state) {
      final connecte = ref.read(supabaseClientProvider).auth.currentSession != null;
      final versEcranAuth = state.matchedLocation == AppRoutes.connexion ||
          state.matchedLocation == AppRoutes.creationCompte;

      if (!connecte && !versEcranAuth) return AppRoutes.connexion;
      if (connecte && versEcranAuth) return AppRoutes.accueil;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.connexion,
        builder: (context, state) => const EcranConnexion(),
      ),
      GoRoute(
        path: AppRoutes.creationCompte,
        builder: (context, state) => const EcranCreationCompteAtelier(),
      ),
      GoRoute(
        path: AppRoutes.accueil,
        builder: (context, state) => const EcranAccueilProvisoire(),
      ),
      GoRoute(
        path: AppRoutes.parametres,
        builder: (context, state) => const EcranParametres(),
      ),
      GoRoute(
        path: AppRoutes.apprentis,
        builder: (context, state) => const EcranGestionApprentis(),
      ),
      GoRoute(
        path: AppRoutes.creationApprenti,
        builder: (context, state) => const EcranCreationApprenti(),
      ),
      GoRoute(
        path: AppRoutes._permissionsApprentiTemplate,
        builder: (context, state) => EcranPanneauPermissions(
          utilisateurId: state.pathParameters['id']!,
          nomApprenti: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.clients,
        builder: (context, state) => const EcranListeClients(),
      ),
      GoRoute(
        path: AppRoutes.creationClient,
        builder: (context, state) => const EcranNouveauClient(),
      ),
      GoRoute(
        path: AppRoutes._ficheClientTemplate,
        builder: (context, state) => EcranFicheClient(clientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes._modificationClientTemplate,
        builder: (context, state) =>
            EcranFormulaireClient(clientExistant: state.extra as Client),
      ),
      GoRoute(
        path: AppRoutes._selectionTypeTenueTemplate,
        builder: (context, state) =>
            EcranSelectionTypeTenue(clientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes._priseMesureTemplate,
        builder: (context, state) => EcranPriseMesure(
          clientId: state.pathParameters['id']!,
          typeTenueId: state.pathParameters['typeTenueId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes._photosClientTemplate,
        builder: (context, state) => EcranGestionPhotos(clientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.typesTenue,
        builder: (context, state) => const EcranGestionTypesTenue(),
      ),
      GoRoute(
        path: AppRoutes.creationTypeTenue,
        builder: (context, state) => const EcranCreationTypeTenue(),
      ),
      GoRoute(
        path: AppRoutes._gestionChampsTemplate,
        builder: (context, state) => EcranGestionChamps(type: state.extra as TypeTenue),
      ),
      GoRoute(
        path: AppRoutes.champsDeMesure,
        builder: (context, state) => const EcranChampsDeMesure(),
      ),
      GoRoute(
        path: AppRoutes.signatureAtelier,
        builder: (context, state) => const EcranSignatureAtelier(),
      ),
      GoRoute(
        path: AppRoutes.rendezVous,
        builder: (context, state) => const EcranListeRendezVous(),
      ),
      GoRoute(
        path: AppRoutes.creationRendezVous,
        builder: (context, state) =>
            EcranFormulaireRendezVous(clientPreselectionne: state.extra as Client?),
      ),
      GoRoute(
        path: AppRoutes._financesClientTemplate,
        builder: (context, state) => EcranFinancesClient(clientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.abonnement,
        builder: (context, state) => const EcranAbonnement(),
      ),
      GoRoute(
        path: AppRoutes.nouvelleDepense,
        builder: (context, state) => const EcranEnregistrerDepense(),
      ),
      GoRoute(
        path: AppRoutes.historiqueDepenses,
        builder: (context, state) => const EcranHistoriqueDepenses(),
      ),
      GoRoute(
        path: AppRoutes.suiviFinances,
        builder: (context, state) => const EcranSuiviFinances(),
      ),
      GoRoute(
        path: AppRoutes.groupesUniformes,
        builder: (context, state) => const EcranGroupesUniformes(),
      ),
      GoRoute(
        path: AppRoutes._detailGroupeUniformeTemplate,
        builder: (context, state) => EcranDetailGroupe(groupeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes._selectionTypeTenueMembreTemplate,
        builder: (context, state) => EcranSelectionTypeTenueMembre(
          membreId: state.pathParameters['membreId']!,
          nomMembre: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes._priseMesureMembreTemplate,
        builder: (context, state) => EcranPriseMesureMembre(
          membreId: state.pathParameters['membreId']!,
          typeTenueId: state.pathParameters['typeTenueId']!,
          nomMembre: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.ventes,
        builder: (context, state) => const EcranVentes(),
      ),
      GoRoute(
        path: AppRoutes._nouvelleVenteTemplate,
        builder: (context, state) => EcranEnregistrerVente(
          categorie: CategorieVente.depuisJson(state.pathParameters['categorie']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.historiqueVentes,
        builder: (context, state) => const EcranHistoriqueVentes(),
      ),
      GoRoute(
        path: AppRoutes.gestionStock,
        builder: (context, state) => const EcranGestionStock(),
      ),
      GoRoute(
        path: AppRoutes._stockCategorieTemplate,
        builder: (context, state) => EcranStockCategorie(
          categorie: CategorieVente.depuisJson(state.pathParameters['categorie']!),
        ),
      ),
    ],
  );
});

/// Traduit le flux d'état d'authentification Supabase en `Listenable`, seul
/// format que `go_router` sait écouter pour redéclencher `redirect`.
class _EcouteurEtatAuth extends ChangeNotifier {
  _EcouteurEtatAuth(Ref ref) {
    _abonnement = ref.listen(etatAuthProvider, (_, __) => notifyListeners());
  }

  late final ProviderSubscription<AsyncValue<AuthState>> _abonnement;

  @override
  void dispose() {
    _abonnement.close();
    super.dispose();
  }
}
