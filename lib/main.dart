import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
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

  // Rapatriement des données locales dès le démarrage si une session est
  // déjà active (reconnexion automatique de Supabase, sans repasser par
  // l'écran de connexion). Sans cette étape, un appareil dont le cache
  // local Drift a été vidé (réinstallation, `flutter clean`...) resterait
  // connecté mais sans aucune donnée locale — voir le même mécanisme
  // déclenché explicitement après une connexion manuelle dans
  // ConnexionPage. Tentative silencieuse : si hors-ligne au démarrage,
  // l'application continue avec le cache local existant, quel qu'il soit.
  final ProviderContainer container = ProviderContainer();
  final Session? session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    try {
      await container
          .read(recuperationCompteServiceProvider)
          .recupererDonneesCompte(session.user.id);
    } catch (_) {
      // Best-effort : voir commentaire ci-dessus.
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AtelierPlusApp(),
    ),
  );
}
