import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:ecoleplus/features/staff/domain/anciennete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/xlsx.dart';

/// Fait défiler l'écran jusqu'à [f] (les listes ne construisent que la
/// partie visible).
Future<void> voir(WidgetTester tester, Finder f) => tester.scrollUntilVisible(
  f,
  250,
  scrollable: find.byType(Scrollable).first,
);

Future<void> tap(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) await voir(tester, f);
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await AppHarness.settle(tester);
}

void main() {
  testWidgets('classes : effectifs filles/garçons, enseignant, nouvelle '
      'classe', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await tap(tester, find.text('Classes'));
    expect(find.text('2 classes · 4 élèves'), findsOneWidget);
    expect(find.text('Filles : 2 · Garçons : 2'), findsOneWidget);
    expect(
      find.text('3 élèves (2 F, 1 G)\nEnseignant : ENSEIGNANT Un'),
      findsOneWidget,
    );

    await tap(tester, find.text('Ajouter une classe'));
    // Maternelle désactivée : seuls les niveaux du primaire sont proposés.
    await tester.tap(find.byKey(const Key('niveau-classe')));
    await tester.pumpAndSettle();
    expect(find.text('Petite section'), findsNothing);
    await tester.tap(find.text('CM2').last);
    await tester.pumpAndSettle();
    await tap(tester, find.text('Créer la classe'));
    expect(find.text('CM2 A'), findsOneWidget);
    expect(find.text('3 classes · 4 élèves'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('élève créé en mode avion : numéro provisoire, puis numéro '
      'd’ordre définitif à la synchronisation', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    h.online = false;
    await tap(tester, find.text('Élèves'));
    await tap(tester, find.text('Ajouter un élève'));
    await tester.enterText(find.byKey(const Key('eleve-nom')), 'nouveau');
    await tester.enterText(find.byKey(const Key('eleve-prenoms')), 'Élise');
    await tester.tap(find.text('Fille'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('eleve-classe')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CE1 A').last);
    await tester.pumpAndSettle();
    await tap(tester, find.text('Créer la fiche'));
    expect(find.text('NOUVEAU Élise'), findsOneWidget);
    expect(find.textContaining('N° provisoire P-A-0001'), findsOneWidget);
    expect(find.textContaining('CE1 A'), findsWidgets);

    h.online = true;
    await h.synchroniser(tester);
    expect(find.textContaining('N° 5 · CE1 A'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('recherche, changement de classe et sortie définitive '
      '(rien n’est supprimé)', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await tap(tester, find.text('Élèves'));
    await tester.enterText(find.byKey(const Key('recherche')), 'boukary');
    await tester.pump();
    expect(find.text('1 élève'), findsOneWidget);
    await tap(tester, find.text('TEST Boukary'));

    // Changement de classe : CM1 A → CE1 A, l'historique est gardé.
    await tester.tap(find.byKey(const Key('changer-classe-c-cm1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CE1 A').last);
    await tester.pumpAndSettle();
    await tap(tester, find.text('Changer'));
    await voir(tester, find.textContaining('CM1 A : du 01/10/2025 au'));
    expect(find.textContaining('CM1 A : du 01/10/2025 au'), findsOneWidget);
    expect(find.textContaining('changement de classe'), findsOneWidget);

    await tap(tester, find.text('Sortie définitive de l’école'));
    await tester.enterText(find.widgetWithText(TextField, 'Allant à'), 'Ouaga');
    await tap(tester, find.text('Confirmer la sortie'));
    await tester.scrollUntilVisible(
      find.textContaining('Sorti de l’école'),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Sorti de l’école'), findsOneWidget);
    final eleve = await tester.runAsync(
      () => (h.db.select(
        h.db.students,
      )..where((s) => s.id.equals('e-1'))).getSingle(),
    );
    expect(eleve!.archivedAt, isNotNull);
    expect(eleve.deletedAt, isNull, reason: 'jamais de suppression');
    final registre = await tester.runAsync(
      () => h.db.select(h.db.studentRegistry).getSingle(),
    );
    expect(registre!.destination, 'Ouaga');
    await h.dispose(tester);
  });

  testWidgets('enseignant : voit ses élèves sans pouvoir modifier ni voir le '
      'registre', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, '70 11 22 33');
    expect(find.text('Mes élèves'), findsOneWidget);
    expect(find.text('Enseignants'), findsNothing);
    expect(find.text('Registres et formulaires'), findsNothing);
    await tap(tester, find.text('Mes élèves'));
    expect(find.text('Ajouter un élève'), findsNothing);
    await tap(tester, find.text('TEST Aïcha'));
    expect(find.text('Observations du registre matricule'), findsNothing);
    expect(find.text('Sortie définitive de l’école'), findsNothing);
    expect(find.byType(TextField), findsNothing, reason: 'lecture seule');
    await h.dispose(tester);
  });

  testWidgets('fiche enseignant : ancienneté calculée, historique B3, départ '
      'de l’école', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await tap(tester, find.text('Enseignants'));
    await tap(tester, find.text('ENSEIGNANT Un'));
    final a = Anciennete.entre(
      DateTime(2008, 10),
      referenceParDefaut(DateTime.now()),
    )!;
    await voir(tester, find.textContaining(': ${a.texte}'));
    expect(find.textContaining(': ${a.texte}'), findsOneWidget);

    // Titre de capacité (B3 col. 11) : plusieurs lignes possibles.
    await tap(tester, find.byKey(const Key('ajouter-diplomes')));
    await tester.enterText(find.byKey(const Key('historique-texte')), 'CAP');
    await tap(tester, find.text('Enregistrer'));
    expect(find.text('CAP'), findsOneWidget);
    final diplomes = await tester.runAsync(
      () => h.db.select(h.db.teacherDiplomas).get(),
    );
    expect(diplomes!.single.nature, 'CAP');

    await tap(tester, find.text('Cet enseignant a quitté l’école'));
    await tap(tester, find.text('Confirmer le départ'));
    await tester.tap(find.byTooltip('Retour').first);
    await AppHarness.settle(tester);
    expect(find.text('ENSEIGNANT Un'), findsNothing);
    expect(
      find.text('Afficher aussi les enseignants partis (1)'),
      findsOneWidget,
    );
    await h.dispose(tester);
  });

  testWidgets('import Excel : une classe de 40 élèves en moins d’une minute, '
      'effectifs exacts, rapport lisible', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    final lignes = <List<Object?>>[
      ['Nom', 'Prénoms', 'Sexe', 'Date de naissance', 'Classe', 'Parent'],
    ];
    for (var i = 1; i <= 40; i++) {
      final sexe = i.isEven ? 'F' : 'G';
      lignes.add([
        'IMPORT',
        'Élève $i',
        sexe,
        '${(i % 28) + 1}/03/2016',
        'CE1 A',
        'Parent $i',
      ]);
      if (i == 20) lignes.add([null, null]); // ligne vide
    }
    lignes
      ..add(['IMPORT', 'Élève 7', 'G', '8/03/2016', 'CE1 A']) // doublon
      ..add(['IMPORT', 'Sans classe', 'F', null, 'CM3']); // erreur
    h.fichierAImporter = fabriquerXlsx(lignes);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await tap(tester, find.text('Élèves'));
    await tap(tester, find.text('Importer un fichier Excel'));

    final chrono = Stopwatch()..start();
    await tap(tester, find.text('Choisir le fichier'));
    expect(find.text('40 élèves prêts à importer.'), findsOneWidget);
    await voir(tester, find.textContaining('Ligne 44 : la classe « CM3 »'));
    expect(find.textContaining('Ligne 44 : la classe « CM3 »'), findsOneWidget);
    expect(
      find.text('• Ligne 43 : même personne qu’à la ligne 8'),
      findsOneWidget,
    );
    await voir(tester, find.text('1 ligne vide ignorée.'));
    expect(find.text('1 ligne vide ignorée.'), findsOneWidget);
    await tap(tester, find.text('Importer 40 élèves'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await AppHarness.settle(tester);
    chrono.stop();
    expect(find.textContaining('40 fiches créées'), findsOneWidget);
    expect(chrono.elapsed, lessThan(const Duration(minutes: 1)));

    final ce1 = await tester.runAsync(
      () => (h.db.select(
        h.db.enrollments,
      )..where((e) => e.classId.equals('c-ce1') & e.endsOn.isNull())).get(),
    );
    expect(ce1!.length, 41, reason: '1 élève déjà en CE1 + 40 importés');
    final filles = await tester.runAsync(
      () => (h.db.select(
        h.db.students,
      )..where((s) => s.lastName.equals('IMPORT') & s.sex.equals('F'))).get(),
    );
    expect(filles!.length, 20);
    final parents = await tester.runAsync(
      () => h.db.select(h.db.guardians).get(),
    );
    expect(parents!.length, 40);

    // Deuxième import du même fichier : tout est reconnu comme doublon.
    await tap(tester, find.text('Choisir le fichier'));
    await tester.scrollUntilVisible(
      find.textContaining('Rien à importer'),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Rien à importer'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('registres : ce qui manque, réglages, impression du registre '
      'matricule (B2) et état « Imprimé »', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await tap(tester, find.text('Registres et formulaires'));
    expect(find.text('Registre matricule des élèves'), findsOneWidget);
    await tap(tester, find.text('Registre matricule des élèves'));
    expect(find.text('• 4 élève(s) sans date de naissance'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Fait à'),
      'Ville Test',
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await AppHarness.settle(tester);
    await tester.runAsync(() async {
      await tester.tap(find.text('Aperçu et impression'));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await AppHarness.settle(tester);
    final pdf = h.pdfSortis['B2_2025-2026.pdf'];
    expect(pdf, isNotNull);
    expect(String.fromCharCodes(pdf!.take(5)), '%PDF-');
    final f = await tester.runAsync(
      () => h.db.select(h.db.officialForms).getSingle(),
    );
    expect(
      (f!.formCode, f.status, f.signedPlace),
      ('B2', 'imprime', 'Ville Test'),
    );
    await h.dispose(tester);
  });

  testWidgets('dictée : texte reconnu modifiable puis ajouté aux '
      'observations ; micro absent → message et clavier', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    h.dictee.texte = 'tres bon eleve';
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await tap(tester, find.text('Élèves'));
    await tap(tester, find.text('TEST Aïcha'));
    await tap(tester, find.byTooltip('Dicter'));
    expect(find.textContaining('rien n’est enregistré'), findsOneWidget);
    await tap(tester, find.text('Continuer'));
    expect(find.text('tres bon eleve'), findsOneWidget);
    // Le texte reconnu reste modifiable avant d'être gardé (13.3).
    await tester.enterText(
      find.byKey(const Key('texte-dicte')),
      'Très bonne élève, attentive.',
    );
    await tap(tester, find.text('Ajouter au texte'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await AppHarness.settle(tester);
    final eleve = await tester.runAsync(
      () => (h.db.select(
        h.db.students,
      )..where((s) => s.id.equals('e-0'))).getSingle(),
    );
    expect(eleve!.observations, 'Très bonne élève, attentive.');

    // Téléphone sans reconnaissance vocale : message clair.
    h.dictee.micro = false;
    await tap(tester, find.byTooltip('Dicter'));
    expect(find.textContaining('Utilisez le clavier'), findsOneWidget);
    expect(h.dictee.ecoutes, 1);
    await h.dispose(tester);
  });

  testWidgets('fiche déjà enregistrée : on la rouvre, on complète, on '
      'modifie un parent et une ligne d’historique', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await tap(tester, find.text('Élèves'));
    await tap(tester, find.text('TEST Aïcha'));
    expect(find.textContaining('Pour modifier ou compléter'), findsOneWidget);
    await voir(tester, find.widgetWithText(TextField, 'À (lieu de naissance)'));
    await tester.enterText(
      find.widgetWithText(TextField, 'À (lieu de naissance)'),
      'Ville Test',
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await AppHarness.settle(tester);

    // Parent ajouté puis corrigé avec le crayon.
    await tap(tester, find.text('Ajouter un parent ou tuteur'));
    await tester.enterText(find.byKey(const Key('parent-nom')), 'Parent Un');
    await tap(tester, find.text('Enregistrer'));
    await tap(tester, find.byTooltip('Modifier').first);
    await tester.enterText(
      find.byKey(const Key('parent-nom')),
      'Parent Corrigé',
    );
    await tap(tester, find.text('Enregistrer'));

    final eleve = await tester.runAsync(
      () => (h.db.select(
        h.db.students,
      )..where((s) => s.id.equals('e-0'))).getSingle(),
    );
    expect(eleve!.birthPlace, 'Ville Test');
    final parents = await tester.runAsync(
      () => h.db.select(h.db.guardians).get(),
    );
    expect(parents!.single.fullName, 'Parent Corrigé');

    // Fiche enseignant : une ligne d'historique modifiée.
    await tester.tap(find.byTooltip('Retour').first);
    await AppHarness.settle(tester);
    await tester.tap(find.byTooltip('Retour').first);
    await AppHarness.settle(tester);
    await tap(tester, find.text('Enseignants'));
    await tap(tester, find.text('ENSEIGNANT Un'));
    await tap(tester, find.byKey(const Key('ajouter-diplomes')));
    await tester.enterText(find.byKey(const Key('historique-texte')), 'CAP');
    await tap(tester, find.text('Enregistrer'));
    await tap(tester, find.byTooltip('Modifier').last);
    await tester.enterText(find.byKey(const Key('historique-texte')), 'CEAP');
    await tap(tester, find.text('Enregistrer'));
    final d = await tester.runAsync(
      () => h.db.select(h.db.teacherDiplomas).get(),
    );
    expect(d!.single.nature, 'CEAP');
    await h.dispose(tester);
  });

  testWidgets('identifiant déjà utilisé par un autre élève : refusé dès la '
      'saisie, avec le nom de l’élève concerné', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await tap(tester, find.text('Élèves'));
    await tap(tester, find.text('TEST Aïcha'));
    await voir(tester, find.byKey(const Key('identifiant-eleve')));
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('identifiant-eleve')),
        matching: find.byType(TextField),
      ),
      'EL-2',
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await AppHarness.settle(tester);
    expect(
      find.textContaining('Identifiant déjà utilisé par TEST Boukary'),
      findsOneWidget,
    );
    final eleve = await tester.runAsync(
      () => (h.db.select(
        h.db.students,
      )..where((s) => s.id.equals('e-0'))).getSingle(),
    );
    expect(eleve!.studentCode, 'EL-1', reason: 'rien n’est enregistré');
    expect(await tester.runAsync(h.db.select(h.db.outbox).get), isEmpty);
    await h.dispose(tester);
  });
}
