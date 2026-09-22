import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_providers.dart';
import '../features/auth/login_screen.dart';
import '../features/cave_setup/cave_setup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';

/// Routage centralisé sur l'état d'authentification (`profilActuelProvider`).
/// Pas de routage par rôle vers des écrans différents en Phase 1 : les 4
/// rôles partagent le même `HomeScreen` minimal, qui adapte seulement son
/// contenu (voir `HomeScreen`). Le routage par rôle vers des parcours
/// distincts (Agent -> Vendre, Responsable -> Dashboard) arrive en Phase 3.
GoRouter construireRouteur(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _RiverpodRefreshListenable(ref, profilActuelProvider),
    redirect: (context, state) {
      final profilAsync = ref.read(profilActuelProvider);

      if (profilAsync.isLoading) return null;

      final profil = profilAsync.valueOrNull;
      final surConfiguration = state.matchedLocation == '/configuration-cave';
      final surConnexion = state.matchedLocation == '/connexion';

      if (profil == null) {
        return (surConnexion || surConfiguration) ? null : '/connexion';
      }

      if (surConnexion || surConfiguration) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) {
        final profil = ref.read(profilActuelProvider).valueOrNull;
        if (profil == null) return const SplashScreen();
        return HomeScreen(profil: profil);
      }),
      GoRoute(path: '/connexion', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/configuration-cave', builder: (context, state) => const CaveSetupScreen()),
    ],
  );
}

/// Petit pont Riverpod -> Listenable attendu par GoRouter, pour éviter une
/// dépendance supplémentaire (ex. package `riverpod_go_router`) pour un
/// besoin aussi simple.
class _RiverpodRefreshListenable extends ChangeNotifier {
  _RiverpodRefreshListenable(Ref ref, ProviderListenable listenable) {
    ref.listen(listenable, (_, __) => notifyListeners());
  }
}
