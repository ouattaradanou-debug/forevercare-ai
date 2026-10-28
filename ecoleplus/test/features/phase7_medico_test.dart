import 'dart:io';

import 'package:ecoleplus/features/medical/domain/fiche_medicale.dart';
import 'package:ecoleplus/features/medical/pdf/pdf_b5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'documents_directeur_test.dart' show entete, polices, texteDuPdf;

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

Future<void> retour(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Retour').first);
  await AppHarness.settle(tester);
}

Future<void> accueil(WidgetTester tester) async {
  while (find.byTooltip('Retour').evaluate().isNotEmpty) {
    await retour(tester);
  }
}

Future<void> ouvrirAicha(
  WidgetTester tester, {
  String bouton = 'Élèves',
}) async {
  await AppHarness.toucher(tester, bouton);
  await AppHarness.settle(tester);
  await tap(tester, find.text('TEST Aïcha'));
}

Future<void> ecrire(WidgetTester tester, String cle, String texte) async {
  final f = find.byKey(Key(cle));
  if (f.evaluate().isEmpty) await voir(tester, f);
  await tester.ensureVisible(f);
  await tester.enterText(f, texte);
  await tester.pump();
}

/// Marqueur pour vérifier qu'aucune donnée de santé ne reste sur le
/// téléphone.
const marqueur = 'MARQUEUR-SANTE-42';

void main() {
  testWidgets('dossier médico-scolaire : désactivé = invisible ; activation '
      'avec avertissement ; fiche saisie en ligne et jamais gardée sur le '
      'téléphone ; PDF B5 ; journal ; refus', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');

    // Désactivé : aucun bouton.
    await ouvrirAicha(tester);
    expect(find.byKey(const Key('ouvrir-b5')), findsNothing);
    await accueil(tester);

    // Activation explicite, avec l'avertissement.
    await AppHarness.ouvrirDansMonEcole(tester, 'Options de l’école');
    await tester.scrollUntilVisible(
      find.byKey(const Key('module-medico_scolaire')),
      100,
    );
    await tester.tap(find.byKey(const Key('module-medico_scolaire')));
    await AppHarness.settle(tester);
    expect(find.text('Données de santé'), findsOneWidget);
    await tester.tap(find.text('J’ai compris, activer'));
    await AppHarness.settle(tester);
    await tap(tester, find.text('Information des parents'));
    expect(find.textContaining('Seul le directeur'), findsOneWidget);
    await accueil(tester);

    // Fiche B5.
    await ouvrirAicha(tester);
    await tap(tester, find.byKey(const Key('ouvrir-b5')));
    expect(find.textContaining('Pas de micro'), findsOneWidget);
    await ecrire(tester, 'medical-groupe_sanguin_rhesus', marqueur);
    await ecrire(tester, 'medical-vacc_bcg', '2017');
    await tap(tester, find.byKey(const Key('ajouter-examen')));
    await ecrire(tester, 'examen-2025-2026-poids', '24 kg');
    await tap(tester, find.byKey(const Key('aptitude-a_surveiller')));
    await tap(tester, find.byKey(const Key('exposer-aptitude')));
    await tap(tester, find.text('Enregistrer'));
    expect(find.text('Fiche médico-scolaire enregistrée.'), findsOneWidget);
    final envoye = h.medical.enregistrements.last;
    expect((envoye['fiche']! as Map)['groupe_sanguin_rhesus'], marqueur);
    expect((envoye['aptitude']! as Map)['aptitude'], 'a_surveiller');
    expect((envoye['aptitude']! as Map)['expose_to_teacher'], true);

    // Rien sur le téléphone : ni dans les tables, ni dans la file d'envoi.
    final tables = await h.db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    for (final t in tables) {
      final nom = t.read<String>('name');
      final lignes = await h.db.customSelect('SELECT * FROM "$nom"').get();
      for (final l in lignes) {
        expect(
          l.data.values.any((v) => '$v'.contains(marqueur)),
          isFalse,
          reason: 'donnée de santé trouvée dans la table $nom',
        );
      }
    }

    // PDF B5.
    // Le message « enregistrée » disparaît d'abord.
    await tester.pump(const Duration(seconds: 5));
    await AppHarness.settle(tester);
    await voir(tester, find.text('Fiche médico-scolaire (PDF)'));
    await tester.ensureVisible(find.text('Fiche médico-scolaire (PDF)'));
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.text('Fiche médico-scolaire (PDF)'));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await AppHarness.settle(tester);
    final t = texteDuPdf(h.pdfSortis['Fiche_medico-scolaire_TEST.pdf']!);
    if (t != null) {
      for (final x in [
        'FICHE MÉDICO-SCOLAIRE',
        'TEST Aïcha',
        'A) ANTÉCÉDENTS',
        'Groupe sanguin rhésus',
        marqueur,
        'B.C.G.',
        'B) EXAMEN CLINIQUE',
        '24 kg',
        'OBSERVATIONS',
        'À surveiller',
        'Document confidentiel',
      ]) {
        expect(t, contains(x));
      }
    }
    expect(
      [for (final l in h.medical.journalEcrit) l.action],
      ['consultation', 'modification', 'impression'],
    );
    await accueil(tester);

    // Journal d'accès.
    await AppHarness.ouvrirDansMonEcole(tester, 'Options de l’école');
    await tap(tester, find.text('Journal d’accès'));
    expect(find.textContaining('Directeur Test — impression'), findsOneWidget);
    await accueil(tester);

    // Refus (ex. module désactivé au serveur) et hors ligne : message clair.
    h.medical.autorise = false;
    await ouvrirAicha(tester);
    await tap(tester, find.byKey(const Key('ouvrir-b5')));
    expect(find.textContaining('Accès refusé'), findsOneWidget);
    await retour(tester);
    h.medical
      ..autorise = true
      ..enLigne = false;
    await tap(tester, find.byKey(const Key('ouvrir-b5')));
    expect(find.text(messageHorsLigneMedicalAttendu), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('enseignant(e) : pas de fiche, seulement la mention d’aptitude '
      'si le directeur l’a exposée', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    h.server.tables['school_modules']!['$ecoleId|medico_scolaire']!['enabled'] =
        true;
    h.medical.aptitudes['e-0'] = {
      'school_year_id': anneeId,
      'aptitude': 'a_surveiller',
      'expose_to_teacher': true,
    };
    await h.pump(tester);
    await h.login(tester, '70 11 22 33');
    await ouvrirAicha(tester, bouton: 'Mes élèves');
    expect(find.byKey(const Key('ouvrir-b5')), findsNothing);
    await voir(tester, find.byKey(const Key('aptitude-exposee')));
    expect(find.text('Aptitude : À surveiller'), findsOneWidget);
    expect(h.medical.journalEcrit, isEmpty, reason: 'aucune fiche ouverte');
    await h.dispose(tester);
  });

  test('libellés de la fiche : tous les champs du modèle B5', () {
    expect(champsFiche, hasLength(20));
    expect(constantes, hasLength(8));
    expect(anneesSurLeModele, 8);
    expect(aptitudes.values, [
      'Apte',
      'À surveiller',
      'Inapte temporaire',
      'Inapte définitif',
    ]);
  });

  test('PDF B5 : sections du modèle, huit années, cases d’aptitude', () async {
    final pdf = await pdfB5(
      polices(),
      entete: entete,
      eleve: const IdentiteB5(
        nom: 'TEST Aïcha',
        sexe: 'F',
        neLe: '10/01/2017',
        classe: 'CM1 A',
      ),
      dossier: DossierMedical(
        fiche: {'groupe_sanguin_rhesus': 'O+', 'vacc_bcg': '2017'},
        examens: [
          ExamenAnnuel('2024-2025', {'poids': '22 kg', 'taille': '1,18 m'}),
          ExamenAnnuel('2025-2026', {
            'poids': '24 kg',
            'examen_physique': 'RAS',
          }),
        ],
      ),
      aptitudeDeLAnnee: 'apte',
    );
    if (Platform.environment['PDF_SORTIE'] case final dossier?) {
      File('$dossier/b5.pdf').writeAsBytesSync(pdf);
    }
    final t = texteDuPdf(pdf);
    if (t == null) return;
    for (final x in [
      'I — Familiaux',
      'HTA',
      'Hémoglobine',
      'Anti-méningococcique',
      'b) chirurgicaux',
      'I — Constantes',
      'AV : OD',
      '2024-2025',
      '20…',
      'II — Examen physique',
      'Inapte définitif',
    ]) {
      expect(t, contains(x));
    }
  });
}

const messageHorsLigneMedicalAttendu =
    'Connexion à Internet nécessaire : la fiche médico-scolaire n’est jamais '
    'gardée sur le téléphone.';
