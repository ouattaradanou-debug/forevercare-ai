import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'core/services/notification_service.dart';
import 'core/services/sync_providers.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formats de date/heure en français (nécessaire pour l'affichage des
  // dates de rendez-vous, de mesures, etc. dans toute l'application).
  await initializeDateFormatting('fr_FR');

  // Connexion au projet Supabase (voir lib/core/config/supabase_config.dart
  // pour la marche à suivre de configuration).
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final ProviderContainer container = ProviderContainer();

  // Affiche l'application tout de suite avec le cache local déjà présent
  // (lecture hors-ligne d'abord, voir tous les repositories) au lieu
  // d'attendre la fin des appels réseau ci-dessous : sur une connexion
  // mobile lente, ceux-ci pouvaient à eux seuls retarder le tout premier
  // affichage de plusieurs secondes, écran figé, à chaque démarrage.
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AtelierPlusApp(),
    ),
  );

  // Rappels locaux de rendez-vous : best-effort, ne doit jamais retarder
  // l'affichage de l'application (permission refusée, plateforme sans
  // notifications, etc.).
  NotificationService.instance.initialiser().catchError((Object e) {
    debugPrint("Échec de l'initialisation des notifications : $e");
  });

  // Rapatriement des données locales dès le démarrage si une session est
  // déjà active (reconnexion automatique de Supabase, sans repasser par
  // l'écran de connexion). Sans cette étape, un appareil dont le cache
  // local Drift a été vidé (réinstallation, `flutter clean`...) resterait
  // connecté mais sans aucune donnée locale — voir le même mécanisme
  // déclenché explicitement après une connexion manuelle dans
  // ConnexionPage. Lancé maintenant, après le premier affichage, plutôt
  // qu'avant runApp : les écrans déjà à l'écran se mettent à jour tout
  // seuls dès que chaque donnée arrive (flux Drift observés partout).
  final Session? session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    container
        .read(recuperationCompteServiceProvider)
        .recupererDonneesCompte(session.user.id)
        .catchError((Object e) {
          // Best-effort : si hors-ligne au démarrage, l'application
          // continue avec le cache local existant, quel qu'il soit.
          debugPrint('Échec de la récupération des données au démarrage : $e');
        });
  }

  // Dès que la connexion revient (l'app peut être restée ouverte
  // longtemps hors-ligne, sans redémarrage ni reconnexion pour
  // redéclencher recupererDonneesCompte), retente l'envoi de tout ce qui
  // a été écrit localement en attendant — voir SyncEngine.
  Connectivity().onConnectivityChanged.listen((resultats) {
    if (!resultats.contains(ConnectivityResult.none)) {
      container.read(syncEngineProvider).pousserModificationsEnAttente();
    }
  });
}
