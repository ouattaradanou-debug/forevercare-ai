import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'core/notifications/notifications_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/preference_theme.dart';
import 'data/sync/sync_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Format des dates en français (jours/mois écrits en toutes lettres, etc.)
  await initializeDateFormatting('fr_FR', null);

  // Toujours initialisé, même sans configuration réelle (voir
  // SupabaseConfig.urlEffective) : Supabase.instance.client est sollicité
  // dès le premier écran (redirection du router), y compris en mode
  // hors-ligne pur. Sans configuration réelle, les appels réseau échouent
  // simplement et sont déjà traités comme "hors-ligne" partout ailleurs
  // dans l'application.
  await Supabase.initialize(
    url: SupabaseConfig.urlEffective,
    anonKey: SupabaseConfig.anonKeyEffective,
  );
  if (!SupabaseConfig.estConfigure) {
    debugPrint(
      'SUPABASE_URL / SUPABASE_ANON_KEY non configurés : '
      'la synchronisation distante est désactivée.',
    );
  }

  runApp(const ProviderScope(child: AtelierPlusApp()));

  // Volontairement non attendu avant runApp : initialise le plugin de
  // notifications (fuseau horaire, permission système) une fois le premier
  // écran déjà affiché plutôt que de bloquer l'ouverture de l'application
  // dessus — NotificationsService.initialiser() est réappelée (sans effet,
  // déjà protégée par _initialise) avant toute programmation de rappel, au
  // cas improbable où un rendez-vous serait créé avant que ceci ait fini.
  unawaited(NotificationsService.instance.initialiser());
}

class AtelierPlusApp extends ConsumerWidget {
  const AtelierPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Instancié une seule fois pour toute la durée de vie de l'app : démarre
    // l'écoute connectivity_plus qui déclenche la synchronisation (Phase 3).
    ref.watch(syncTriggerProvider);

    return MaterialApp.router(
      title: AppConfig.nomApplication,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair,
      darkTheme: AppTheme.sombre,
      themeMode: themeMode,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
