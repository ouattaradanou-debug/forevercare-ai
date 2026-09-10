import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/client.dart';
import '../../data/models/utilisateur.dart';
import '../../features/auth/presentation/pages/connexion_page.dart';
import '../../features/auth/presentation/pages/creation_compte_page.dart';
import '../../features/clients/presentation/pages/client_detail_page.dart';
import '../../features/clients/presentation/pages/clients_list_page.dart';
import '../../features/clients/presentation/pages/formulaire_client_page.dart';
import '../../features/clients/presentation/pages/gestion_champs_mesure_page.dart';
import '../../features/clients/presentation/pages/modifier_client_page.dart';
import '../../features/clients/presentation/pages/rendez_vous_list_page.dart';
import '../../features/clients/presentation/pages/suivi_depenses_page.dart';
import '../../features/clients/presentation/pages/suivi_finances_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/permissions/presentation/pages/apprentis_page.dart';
import '../../features/permissions/presentation/pages/nouvel_apprenti_page.dart';
import '../../features/permissions/presentation/pages/permissions_apprenti_page.dart';

/// Relie les changements d'état d'authentification Supabase à go_router,
/// pour que la redirection se réévalue automatiquement à chaque connexion
/// ou déconnexion (et pas seulement lors d'une navigation explicite).
class _FluxAuthGoRouter extends ChangeNotifier {
  _FluxAuthGoRouter(Stream<AuthState> flux) {
    notifyListeners();
    _abonnement = flux.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _abonnement;

  @override
  void dispose() {
    _abonnement.cancel();
    super.dispose();
  }
}

const List<String> _ecransSansConnexion = ['/connexion', '/creation-compte'];

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _FluxAuthGoRouter(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    final bool connecte = Supabase.instance.client.auth.currentSession != null;
    final bool versEcranAuth = _ecransSansConnexion.contains(
      state.matchedLocation,
    );

    if (!connecte && !versEcranAuth) return '/connexion';
    if (connecte && versEcranAuth) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'accueil',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/connexion',
      name: 'connexion',
      builder: (context, state) => const ConnexionPage(),
    ),
    GoRoute(
      path: '/creation-compte',
      name: 'creation-compte',
      builder: (context, state) => const CreationComptePage(),
    ),
    GoRoute(
      path: '/clients',
      name: 'clients',
      builder: (context, state) => const ClientsListPage(),
      routes: [
        GoRoute(
          path: 'nouveau',
          name: 'nouveau-client',
          builder: (context, state) => const FormulaireClientPage(),
        ),
        GoRoute(
          path: ':id',
          name: 'client-detail',
          builder: (context, state) =>
              ClientDetailPage(client: state.extra as Client),
          routes: [
            GoRoute(
              path: 'modifier',
              name: 'modifier-client',
              builder: (context, state) =>
                  ModifierClientPage(client: state.extra as Client),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/rendez-vous',
      name: 'rendez-vous',
      builder: (context, state) => const RendezVousListPage(),
    ),
    GoRoute(
      path: '/finances',
      name: 'finances',
      builder: (context, state) => const SuiviFinancesPage(),
    ),
    GoRoute(
      path: '/depenses',
      name: 'depenses',
      builder: (context, state) => const SuiviDepensesPage(),
    ),
    GoRoute(
      path: '/champs-mesure',
      name: 'champs-mesure',
      builder: (context, state) => const GestionChampsMesurePage(),
    ),
    GoRoute(
      path: '/apprentis',
      name: 'apprentis',
      builder: (context, state) => const ApprentisPage(),
      routes: [
        GoRoute(
          path: 'nouveau',
          name: 'nouvel-apprenti',
          builder: (context, state) => const NouvelApprentiPage(),
        ),
        GoRoute(
          path: ':id/permissions',
          name: 'permissions-apprenti',
          builder: (context, state) => PermissionsApprentiPage(
            apprenti: state.extra as Utilisateur,
          ),
        ),
      ],
    ),
  ],
);
