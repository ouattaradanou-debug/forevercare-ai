import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/ecran_provisoire.dart';

/// Chemins nommés des routes de l'application, centralisés pour éviter les
/// chaînes de caractères éparpillées dans le code.
class AppRoutes {
  const AppRoutes._();

  static const String connexion = '/connexion';
  static const String creationCompte = '/creation-compte';
  static const String accueil = '/';
}

/// Router déclaratif de l'application (go_router).
///
/// Squelette minimal pour la Phase 0 : une seule route provisoire. Les
/// routes d'authentification et de navigation par onglets sont ajoutées en
/// Phase 1, avec une redirection basée sur l'état de session Supabase.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.accueil,
    routes: [
      GoRoute(
        path: AppRoutes.accueil,
        builder: (context, state) => const EcranProvisoire(titre: 'Atelier+'),
      ),
    ],
  );
});
