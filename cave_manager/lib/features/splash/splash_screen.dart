import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';

/// Écran de démarrage : détermine où router l'utilisateur (connexion,
/// configuration initiale, ou accueil) selon l'état d'authentification.
/// Une seule action : attendre et rediriger — aucune interaction.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(profilActuelProvider);
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
