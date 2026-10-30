import 'dart:io';
import 'dart:typed_data';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/sync/sync_engine.dart';
import 'package:ecoleplus/features/bibliotheque/data/bibliotheque_repository.dart';
import 'package:ecoleplus/features/bibliotheque/data/documents_en_ligne.dart';
import 'package:ecoleplus/features/bibliotheque/domain/document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'phase8_cartes_test.dart' show accueil, retour, tap, tapLong, voir;

/// Fichiers de test : contenu différent pour chacun (pas de doublon), assez
/// gros pour être envoyés en plusieurs morceaux (64 Ko dans les tests).
List<FichierChoisi> fichiersDeTest(
  Directory dossier,
  int n, {
  int taille = 150 * 1024,
  String extension = 'pdf',
}) {
  dossier.createSync(recursive: true);
  return [
    for (var i = 1; i <= n; i++)
      () {
        final nom = 'Fiche_${i.toString().padLeft(3, '0')}.$extension';
        final f = File('${dossier.path}/$nom');
        final octets = Uint8List(taille);
        for (var j = 0; j < taille; j++) {
          octets[j] = (i * 31 + j * 7) % 251;
        }
        f.writeAsBytesSync(octets);
        return FichierChoisi(nom, f.path);
      }(),
  ];
}

/// Attend la fin des traitements en cours (ajout, synchronisation) avant
/// de lire la base : sinon la lecture attend un verrou que seul le temps
/// simulé libère.
Future<void> calme(WidgetTester tester) async {
  for (var i = 0; i < 60; i++) {
    await AppHarness.settle(tester);
    final moteur = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(syncEngineProvider);
    if (moteur.state.phase != SyncPhase.running &&
        find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      break;
    }
  }
  await AppHarness.settle(tester);
}

Future<void> ouvrirBibliotheque(WidgetTester tester) async {
  await AppHarness.toucher(tester, 'Bibliothèque');
  await AppHarness.settle(tester);
}

/// Ajoute les fichiers choisis (« Commun à toute l'école »).
Future<void> ajouterCommun(WidgetTester tester) async {
  await tapLong(tester, find.text('Ajouter des documents'));
  await calme(tester);
  await tap(tester, find.byKey(const Key('commun')));
  await tapLong(tester, find.widgetWithText(FilledButton, 'Ajouter'));
  await calme(tester);
}

void main() {
  testsEffacement();
  testWidgets('50 fichiers ajoutés hors ligne : catalogue tout de suite '
      'utilisable ; envoi coupé en cours de route puis repris, sans doublon '
      'ni fichier abîmé ; le même lot ajouté une 2e fois est reconnu', (
    tester,
  ) async {
    final h = AppHarness()..seedEcoleTest();
    final source = Directory('${h.mediaDir.parent.path}/lot_${h.hashCode}');
    h.fichiersChoisis = fichiersDeTest(source, 50);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    h.online = false;

    await ouvrirBibliotheque(tester);
    await ajouterCommun(tester);
    expect(find.text('50 documents'), findsOneWidget);
    expect(find.byKey(const Key('envois-en-cours')), findsOneWidget);
    expect(await h.db.select(h.db.documents).get(), hasLength(50));
    expect(await h.db.select(h.db.documentUploads).get(), hasLength(50));

    // Recherche par titre sans Internet.
    await tester.enterText(
      find.byKey(const Key('recherche-documents')),
      'fiche 017',
    );
    await AppHarness.settle(tester);
    expect(find.text('1 document'), findsOneWidget);
    expect(find.text('Fiche 017'), findsOneWidget);
    // Recherche dans le texte : Internet nécessaire, message clair.
    await tap(tester, find.byKey(const Key('chercher-texte')));
    expect(find.textContaining('connexion à Internet nécessaire'), findsOne);
    await AppHarness.settle(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await AppHarness.settle(tester);
    await tester.enterText(find.byKey(const Key('recherche-documents')), '');
    await AppHarness.settle(tester);

    // Réseau qui revient… puis coupe après 40 morceaux.
    h.online = true;
    h.remote.couperApresMorceaux = 40;
    await accueil(tester);
    await h.synchroniser(tester);
    await calme(tester);
    expect(h.server.tables['documents'], hasLength(50));
    final envoyes = h.remote.morceauxRecus;
    expect(envoyes, 40);
    final restants = await h.db.select(h.db.documentUploads).get();
    expect(restants.length, inInclusiveRange(1, 49));
    final commences = restants.where((e) => e.sentBytes > 0).toList();
    expect(commences, hasLength(1), reason: 'un fichier coupé en cours');

    // Le réseau revient : l'envoi reprend où il s'était arrêté.
    h
      ..online = true
      ..remote.couperApresMorceaux = null;
    await h.synchroniser(tester);
    await calme(tester);
    expect(await h.db.select(h.db.documentUploads).get(), isEmpty);
    final fichiers = h.server.files.keys
        .where((k) => k.startsWith('documents/'))
        .toList();
    expect(fichiers, hasLength(50));
    // 150 Ko = 3 morceaux de 64 Ko : 150 morceaux en tout, aucun renvoyé.
    expect(h.remote.morceauxRecus, 150);
    for (final d in await h.db.select(h.db.documents).get()) {
      final recu = h.server.files['documents/${d.storagePath}']!;
      final original = File('${source.path}/${d.originalName}')
          .readAsBytesSync();
      expect(recu, original, reason: d.title);
      expect(h.server.tables['documents']![d.id]!['uploaded_at'], isNotNull);
    }

    // Même lot une 2e fois : rien de nouveau.
    final repo = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(bibliothequeRepositoryProvider);
    final r = (await tester.runAsync(
      () => repo.ajouter(
        schoolId: ecoleId,
        espace: Espace.bibliotheque,
        fichiers: h.fichiersChoisis,
        fiche: const FicheDocument(commun: true),
        gestionnaire: true,
      ),
    ))!;
    expect((r.ajoutes, r.doublons.length), (0, 50));
    await calme(tester);
    expect(await h.db.select(h.db.documents).get(), hasLength(50));
    expect(await h.db.select(h.db.documentUploads).get(), isEmpty);
    await h.dispose(tester);
  });

  testWidgets('garder sur le téléphone : en mode avion, un document épinglé '
      's’ouvre (moins de 3 s), un document libéré donne un message clair ; '
      'recherche dans le texte en ligne', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    final source = Directory('${h.mediaDir.parent.path}/av_${h.hashCode}');
    h.fichiersChoisis = fichiersDeTest(
      source,
      2,
      taille: 2000,
      extension: 'txt',
    );
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await ouvrirBibliotheque(tester);
    await ajouterCommun(tester);
    await accueil(tester);
    await h.synchroniser(tester);
    await calme(tester);
    expect(await h.db.select(h.db.documentUploads).get(), isEmpty);

    final docs = await h.db.select(h.db.documents).get();
    final un = docs.firstWhere((d) => d.title == 'Fiche 001');
    final deux = docs.firstWhere((d) => d.title == 'Fiche 002');
    h.enLigne.textes[deux.id] = [(3, 'Les fractions au CM1 : exercices')];

    await ouvrirBibliotheque(tester);
    await tester.enterText(
      find.byKey(const Key('recherche-documents')),
      'fractions',
    );
    await AppHarness.settle(tester);
    expect(
      find.text('0 document'),
      findsOneWidget,
      reason: 'pas dans le titre',
    );
    await tap(tester, find.byKey(const Key('chercher-texte')));
    expect(find.byKey(Key('trouve-${deux.id}-3')), findsOneWidget);
    expect(find.text('Page 3 : « fractions »'), findsOneWidget);
    await AppHarness.settle(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await AppHarness.settle(tester);
    await tester.enterText(find.byKey(const Key('recherche-documents')), '');
    await AppHarness.settle(tester);

    // Épingler le 1er, libérer l'espace : seul le 1er reste.
    await tap(tester, find.byKey(Key('document-${un.id}')));
    await tapLong(tester, find.byKey(const Key('epingler')));
    await calme(tester);
    await retour(tester);
    await voir(tester, find.byKey(const Key('liberer')));
    await tapLong(tester, find.byKey(const Key('liberer')));
    await calme(tester);
    final locaux = await h.db.select(h.db.documentFiles).get();
    expect(locaux.map((f) => f.documentId), [un.id]);
    expect(locaux.single.pinned, isTrue);

    // Mode avion.
    h.online = false;
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await AppHarness.settle(tester);
    await tap(tester, find.byKey(Key('document-${un.id}')));
    // Ouverture chronométrée (temps réel) : document épinglé, sans réseau.
    await voir(tester, find.text('Ouvrir'));
    final chrono = Stopwatch()..start();
    await tester.tap(find.text('Ouvrir'));
    while (h.fichiersOuverts.isEmpty && chrono.elapsed.inSeconds < 10) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    chrono.stop();
    // Ouvert dans l'application de lecture du téléphone (pas « Partager »).
    expect(h.fichiersOuverts.single, endsWith('/fiche_001.txt'));
    expect(h.fichiersSortis, isEmpty);
    expect(chrono.elapsedMilliseconds, lessThan(3000));
    // ignore: avoid_print, mesure affichée dans le rapport de la phase.
    print('Ouverture du document épinglé : ${chrono.elapsedMilliseconds} ms');
    await AppHarness.settle(tester);
    await retour(tester);

    await tap(tester, find.byKey(Key('document-${deux.id}')));
    await voir(tester, find.text('Ouvrir'));
    await tester.tap(find.text('Ouvrir'));
    final message = find.textContaining('n’est pas sur le téléphone');
    for (var i = 0; i < 100 && message.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(message, findsOne);
    await AppHarness.settle(tester);
    await retour(tester);

    // Aucune application de lecture : message clair, « Partager » proposé.
    h.lecteurInstalle = false;
    await tap(tester, find.byKey(Key('document-${un.id}')));
    await tapLong(tester, find.text('Ouvrir'));
    expect(find.text('Aucune application pour l’ouvrir'), findsOneWidget);
    await tapLong(tester, find.widgetWithText(FilledButton, 'Partager'));
    expect(h.fichiersSortis.keys, ['Fiche_001.txt']);
    await h.dispose(tester);
  });

  testWidgets('enseignant : ajout en attente de validation, le directeur '
      'valide ; espace plein : refus expliqué, rien n’est envoyé', (
    tester,
  ) async {
    final h = AppHarness()..seedEcoleTest();
    final source = Directory('${h.mediaDir.parent.path}/ens_${h.hashCode}');
    h.fichiersChoisis = fichiersDeTest(source, 1, taille: 3000);
    await h.pump(tester);
    await h.login(tester, '70 11 22 33');
    expect(find.text('Archives'), findsNothing, reason: 'enseignant');
    await ouvrirBibliotheque(tester);
    await tapLong(tester, find.text('Ajouter des documents'));
    await calme(tester);
    expect(find.textContaining('après validation du directeur'), findsOne);
    expect(find.byKey(const Key('commun')), findsNothing);
    await tap(tester, find.widgetWithText(FilterChip, 'CM1 A'));
    await tapLong(tester, find.widgetWithText(FilledButton, 'Ajouter'));
    await calme(tester);
    expect(find.textContaining('En attente de validation'), findsOne);
    final d = (await h.db.select(h.db.documents).get()).single;
    expect(d.approved, isFalse);
    expect(d.classes, ['c-cm1']);
    await h.dispose(tester);

    // Espace plein (règle du serveur).
    final h2 = AppHarness()
      ..seedEcoleTest()
      ..fichiersChoisis = h.fichiersChoisis;
    h2.server
      ..rejectWith = ((t, _) => t == 'documents' ? 'P0001' : null)
      ..rejectMessage =
          'Espace plein : 300 Mo utilisés sur 300 Mo. Videz la corbeille ou '
          'demandez plus d’espace.';
    await h2.pump(tester);
    await h2.login(tester, 'directeur@ecole-test.local');
    await ouvrirBibliotheque(tester);
    await ajouterCommun(tester);
    await accueil(tester);
    await h2.synchroniser(tester);
    await calme(tester);
    expect(
      h2.server.files.keys.where((k) => k.startsWith('documents/')),
      isEmpty,
    );
    expect(await h2.db.select(h2.db.documents).get(), isEmpty);
    expect(await h2.db.select(h2.db.documentUploads).get(), isEmpty);
    expect(await h2.db.select(h2.db.documentFiles).get(), isEmpty);
    final refus = await h2.db.select(h2.db.outbox).get();
    expect(
      refus.single.message,
      'Document « Fiche 001 » — Espace plein : 300 Mo utilisés sur 300 Mo. '
      'Videz la corbeille ou demandez plus d’espace.',
    );
    await h2.dispose(tester);
  });

  testWidgets('copie signée du B1 archivée : rangée dans les archives, '
      'formulaire « Signé et archivé »', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    final source = Directory('${h.mediaDir.parent.path}/b1_${h.hashCode}');
    h.fichiersChoisis = fichiersDeTest(source, 1, taille: 5000);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await AppHarness.toucher(tester, 'Documents');
    await AppHarness.settle(tester);
    await tap(tester, find.byKey(const Key('doc-/registres/B1')));
    await tapLong(tester, find.byKey(const Key('archiver-copie-signee')));
    await calme(tester);
    expect(find.byKey(const Key('copie-signee')), findsOneWidget);
    final d = (await h.db.select(h.db.documents).get()).single;
    expect(d.space, 'archives');
    expect(d.aiAllowed, isFalse);
    expect(d.title, 'B1 2025-2026 — copie signée');
    final f = (await h.db.select(h.db.officialForms).get()).single;
    expect(f.status, 'signe_archive');
    expect(f.signedScanDocumentId, d.id);
    await accueil(tester);
    // Commande à part sur l'accueil (A20), plus dans « Documents ».
    await AppHarness.toucher(tester, 'Archives');
    await AppHarness.settle(tester);
    expect(find.text('B1 2025-2026 — copie signée'), findsOneWidget);
    expect(
      find.textContaining('jamais utilisées par l’assistant IA'),
      findsOne,
    );
    await h.dispose(tester);
  });
}

void testsEffacement() {
  testWidgets('A21 : effacer définitivement depuis la corbeille : Internet '
      'nécessaire, puis effacé du serveur et du téléphone', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    final source = Directory('${h.mediaDir.parent.path}/eff_${h.hashCode}');
    h.fichiersChoisis = fichiersDeTest(source, 1, taille: 3000);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await ouvrirBibliotheque(tester);
    await ajouterCommun(tester);
    await accueil(tester);
    await h.synchroniser(tester);
    await calme(tester);
    final d = (await h.db.select(h.db.documents).get()).single;
    expect(h.server.files.keys, contains('documents/${d.storagePath}'));

    // À la corbeille, puis « Effacer définitivement » (pas avant).
    await ouvrirBibliotheque(tester);
    await tap(tester, find.byKey(Key('document-${d.id}')));
    expect(find.byKey(const Key('effacer-document')), findsNothing);
    await tap(tester, find.byKey(const Key('corbeille-document')));
    await tap(
      tester,
      find.widgetWithText(FilledButton, 'Mettre à la corbeille'),
    );
    await calme(tester);
    await tap(tester, find.text('Corbeille'));
    await tap(tester, find.byKey(Key('document-${d.id}')));

    // Sans Internet : message, rien n'est effacé.
    h.online = false;
    await tap(tester, find.byKey(const Key('effacer-document')));
    await tap(tester, find.widgetWithText(FilledButton, 'Effacer'));
    expect(find.text(messageEffacementHorsLigne), findsOneWidget);
    expect(await h.db.select(h.db.documents).get(), hasLength(1));
    await AppHarness.settle(tester);

    h.online = true;
    await tap(tester, find.byKey(const Key('effacer-document')));
    await tap(tester, find.widgetWithText(FilledButton, 'Effacer'));
    await calme(tester);
    expect(await h.db.select(h.db.documents).get(), isEmpty);
    expect(await h.db.select(h.db.documentFiles).get(), isEmpty);
    expect(
      h.server.files.keys.where((k) => k.startsWith('documents/')),
      isEmpty,
    );
    expect(h.server.tables['documents']![d.id]!['deleted_at'], isNotNull);
    expect(find.text('Aucun document.'), findsOneWidget);
    await h.dispose(tester);
  });
}
