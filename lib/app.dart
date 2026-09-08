import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

/// Racine de l'application Atelier+.
class AtelierPlusApp extends ConsumerWidget {
  const AtelierPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dès qu'une session devient active — connexion manuelle ou
    // restauration automatique de la session par Supabase au démarrage,
    // sans repasser par l'écran de connexion — on rapatrie les données
    // locales (voir RecuperationCompteService). S'appuyer sur ce flux
    // plutôt que sur une simple vérification juste après
    // Supabase.initialize() évite toute hypothèse sur le moment exact où
    // la session persistée est restaurée (potentiellement asynchrone).
    ref.listen<AsyncValue<AuthState>>(etatAuthProvider, (previous, next) {
      final bool avaitDejaUneSession = previous?.asData?.value.session != null;
      final String? idUtilisateur = next.asData?.value.session?.user.id;
      if (!avaitDejaUneSession && idUtilisateur != null) {
        ref
            .read(recuperationCompteServiceProvider)
            .recupererDonneesCompte(idUtilisateur)
            .catchError((Object e) {
              debugPrint('Échec de la récupération des données de compte : $e');
            });
      }
    });

    return MaterialApp.router(
      title: 'Atelier+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair,
      darkTheme: AppTheme.sombre,
      themeMode: ThemeMode.system,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
