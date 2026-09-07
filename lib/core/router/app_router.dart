import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_page.dart';

/// Table de routes de l'application.
///
/// Phase 0 : une seule route statique vers l'écran d'accueil. Les écrans
/// d'authentification, de clients, de mesures, etc. seront ajoutés au fil
/// des phases suivantes.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'accueil',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
