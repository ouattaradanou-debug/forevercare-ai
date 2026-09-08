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
    // Uniquement pour le cas d'une session déjà active restaurée
    // automatiquement par Supabase au tout premier démarrage de l'app
    // (sans repasser par l'écran de connexion) : on rapatrie les données
    // locales une fois (voir RecuperationCompteService). On se limite
    // volontairement à la toute première évaluation du flux (`previous ==
    // null`) : une connexion ou une inscription faite pendant que l'app
    // tourne est déjà prise en charge, au bon moment, par ConnexionPage /
    // CreationComptePage elles-mêmes — les déclencher aussi ici les
    // ferait courir en même temps que ces écrans, avant même que la ligne
    // `utilisateurs` n'existe encore côté inscription.
    ref.listen<AsyncValue<AuthState>>(etatAuthProvider, (previous, next) {
      if (previous != null) return;
      final String? idUtilisateur = next.asData?.value.session?.user.id;
      if (idUtilisateur != null) {
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
