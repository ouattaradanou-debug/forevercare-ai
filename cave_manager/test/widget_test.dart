// Test de fumée (smoke test) : vérifie que l'app démarre réellement et
// affiche le bon écran selon l'état d'authentification, plutôt que de se
// fier uniquement à `flutter analyze` (qui ne détecte pas les erreurs à
// l'exécution : provider mal câblé, widget qui plante au premier build...).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cave_manager/app/app.dart';

void main() {
  setUpAll(() async {
    // supabase_flutter persiste sa session via shared_preferences ; en
    // environnement de test il n'y a pas de vraie plateforme derrière ce
    // plugin, donc on fournit un stockage en mémoire vide.
    SharedPreferences.setMockInitialValues({});

    // Initialise un client Supabase "à vide" (URL factice, aucune requête
    // réseau au démarrage) : suffisant pour que l'app boot et route vers
    // l'écran de connexion, sans dépendre d'un vrai projet Supabase.
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      publishableKey: 'test-anon-key',
    );
  });

  testWidgets('Sans session active, l\'app affiche l\'écran de connexion',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CaveManagerApp()));
    await tester.pumpAndSettle();

    expect(find.text('Ma Cave'), findsOneWidget);
    expect(find.text('Numéro de téléphone'), findsOneWidget);
    expect(find.text('Code PIN (6 chiffres)'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Code PIN oublié ?'), findsOneWidget);
  });

  testWidgets('Le lien "Code PIN oublié ?" mène à l\'écran de récupération',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CaveManagerApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Code PIN oublié ?'));
    await tester.pumpAndSettle();

    expect(find.text('Code PIN oublié'), findsOneWidget);
    expect(find.text('Entrez le numéro de téléphone de votre compte.'),
        findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets(
      'Le lien "Première utilisation" mène à l\'écran de configuration de la cave',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CaveManagerApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Première utilisation ? Configurer ma cave'));
    await tester.pumpAndSettle();

    expect(find.text('Configurer ma cave'), findsOneWidget);
    expect(find.text('Cave à vin'), findsOneWidget);
    expect(find.text('Question secrète'), findsOneWidget);
    expect(find.text('Créer ma cave'), findsOneWidget);

    await tester.tap(find.text('Cave à vin'));
    await tester.pumpAndSettle();

    expect(find.text('Type de cave et profil'), findsOneWidget);
    expect(find.text('Votre profil'), findsOneWidget);
  });
}
