import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Format des dates en français (jours/mois écrits en toutes lettres, etc.)
  await initializeDateFormatting('fr_FR', null);

  if (SupabaseConfig.estConfigure) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } else {
    // En développement local sans Supabase configuré, l'application démarre
    // quand même : le mode hors-ligne (Drift) reste pleinement utilisable.
    debugPrint(
      'SUPABASE_URL / SUPABASE_ANON_KEY non configurés : '
      'la synchronisation distante est désactivée.',
    );
  }

  runApp(const ProviderScope(child: AtelierPlusApp()));
}

class AtelierPlusApp extends ConsumerWidget {
  const AtelierPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.nomApplication,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      routerConfig: router,
    );
  }
}
