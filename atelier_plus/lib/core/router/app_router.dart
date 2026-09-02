import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/remote/supabase_client_provider.dart';
import '../../features/auth/presentation/ecran_accueil_provisoire.dart';
import '../../features/auth/presentation/ecran_connexion.dart';
import '../../features/auth/presentation/ecran_creation_apprenti.dart';
import '../../features/auth/presentation/ecran_creation_compte_atelier.dart';
import '../../features/auth/presentation/ecran_gestion_apprentis.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/permissions/presentation/ecran_panneau_permissions.dart';

/// Chemins nommés des routes de l'application, centralisés pour éviter les
/// chaînes de caractères éparpillées dans le code.
class AppRoutes {
  const AppRoutes._();

  static const String connexion = '/connexion';
  static const String creationCompte = '/creation-compte';
  static const String accueil = '/';
  static const String apprentis = '/apprentis';
  static const String creationApprenti = '/apprentis/nouveau';
  static const String _permissionsApprentiTemplate = '/apprentis/:id/permissions';

  static String permissionsApprenti(String utilisateurId) =>
      '/apprentis/$utilisateurId/permissions';
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
