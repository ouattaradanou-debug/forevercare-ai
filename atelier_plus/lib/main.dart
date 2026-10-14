import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'core/notifications/notifications_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/preference_theme.dart';
import 'data/sync/sync_providers.dart';

/// Bande du haut (heure, réseau, batterie) toujours bleue avec des icônes
/// blanches, quel que soit l'écran affiché en dessous — y compris un écran
/// sans bandeau de couleur (ex. écran de chargement, fond blanc), où ces
/// informations étaient auparavant difficiles à distinguer.
const _styleBarreSysteme = SystemUiOverlayStyle(
  statusBarColor: AppColors.primaire,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(_styleBarreSysteme);

  // Format des dates en français (jours/mois écrits en toutes lettres, etc.)
  // et initialisation de Supabase en parallèle plutôt que l'un après
  // l'autre : les deux sont indépendants, donc attendre leur somme au lieu
  // du plus lent des deux ne faisait que rallonger l'ouverture pour rien.
  //
  // Toujours initialisé, même sans configuration réelle (voir
  // SupabaseConfig.urlEffective) : Supabase.instance.client est sollicité
  // dès le premier écran (redirection du router), y compris en mode
  // hors-ligne pur. Sans configuration réelle, les appels réseau échouent
  // simplement et sont déjà traités comme "hors-ligne" partout ailleurs
  // dans l'application.
  await Future.wait([
    initializeDateFormatting('fr_FR', null),
    Supabase.initialize(
      url: SupabaseConfig.urlEffective,
      anonKey: SupabaseConfig.anonKeyEffective,
    ),
  ]);
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

    // AnnotatedRegion plutôt que le seul appel dans main() : certains
    // widgets (ex. AppBar) recalculent leur propre style de barre système à
    // chaque écran, ce qui écraserait un réglage fait une seule fois au
    // démarrage. L'envelopper ainsi autour de toute l'application le
    // réapplique systématiquement, écran après écran.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _styleBarreSysteme,
      child: MaterialApp.router(
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
      ),
    );
  }
}
