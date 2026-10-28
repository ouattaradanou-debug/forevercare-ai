import 'dart:io';
import 'dart:typed_data';

import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/documents/pdf/pdf_documents.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:flutter_test/flutter_test.dart';

PolicesPdf polices() {
  ByteData lire(String n) => ByteData.sublistView(
    File('assets/fonts/Roboto-$n.ttf').readAsBytesSync(),
  );
  return PolicesPdf(
    normale: lire('Regular'),
    grasse: lire('Bold'),
    italique: lire('Italic'),
  );
}

String? texteDuPdf(Uint8List octets) {
  if (!File('/usr/bin/pdftotext').existsSync()) return null;
  final dir = Directory.systemTemp.createTempSync('pdf');
  final f = File('${dir.path}/f.pdf')..writeAsBytesSync(octets);
  final r = Process.runSync('pdftotext', [f.path, '-']);
  dir.deleteSync(recursive: true);
  // pdftotext ajoute une espace entre texte normal et texte gras.
  return (r.stdout as String)
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(' (?=[,.])'), '');
}

const entete = EnteteDocument(
  ecole: 'École Primaire Publique de Barkouitenga',
  ministere:
      'Ministère de l’Enseignement de Base, de l’Alphabétisation et de la '
      'Promotion des Langues Nationales',
  directionRegionale: 'Direction régionale de Oubri',
  directionProvinciale: 'Direction provinciale de Bassitenga',
  ceb: 'Ziniaré II',
  devise: 'La Patrie ou la Mort, nous Vaincrons',
  anneeScolaire: '2025-2026',
);
const directrice = Signataire(
  civilite: 'madame',
  nom: 'TEST Directrice',
  grade: 'Professeur Certifié des Écoles',
);
const fatou = EleveDocument(
  nom: 'TEST Fatou',
  sexe: 'F',
  neLe: '11/02/2014',
  lieuNaissance: 'Ville Test',
  pere: 'TEST Père',
  professionPere: 'Cultivateur',
  mere: 'TEST Mère',
  professionMere: 'Ménagère',
  matricule: '5',
  classe: 'CM2 A',
  niveau: 'CM2',
  entreLe: '01/10/2019',
);

void main() {
  group('accords', () {
    test('directeur ou directrice, élève fille ou garçon', () {
      expect(directrice.fonction, 'Directrice');
      expect(directrice.soussigne, 'soussignée');
      expect(
        const Signataire(civilite: 'monsieur').titreSignature,
        'Le Directeur',
      );
      expect(const Signataire().fonction, 'Directeur/Directrice');
      expect(const Accords('M').filsFille, 'Fils');
      expect(const Accords('F').inscrit, 'inscrite');
      expect(const Accords(null).ne, 'né(e)');
      expect(
        deLEcole('École Primaire Publique de X'),
        'de l’École Primaire Publique de X',
      );
      expect(deLEcole('Wend-Panga'), 'de l’école Wend-Panga');
    });

    test('ce qui manque avant l’impression', () {
      expect(
        manquesDocument(
          CodeDocument.priseService,
          signataire: const Signataire(nom: 'X'),
          enseignant: const EnseignantDocument(nom: 'Y', matricule: '1'),
        ),
        [
          'directeur ou directrice (Mon école)',
          'emploi',
          'n° de la décision d’affectation',
          'date de prise de service',
        ],
      );
    });
  });

  test('les 5 documents en PDF : textes des modèles du porteur', () async {
    final sortie = Directory('build/pdf_a17')..createSync(recursive: true);
    Future<String?> pdf(String nom, DocumentDirecteur d) async {
      final o = await pdfDocumentDirecteur(polices(), d);
      expect(String.fromCharCodes(o.take(5)), '%PDF-');
      File('${sortie.path}/$nom.pdf').writeAsBytesSync(o);
      return texteDuPdf(o);
    }

    final prise = await pdf(
      'prise_service',
      const DocumentDirecteur(
        code: CodeDocument.priseService,
        entete: entete,
        signataire: directrice,
        lieu: 'Barkouitenga',
        date: '27/10/2026',
        enseignant: EnseignantDocument(
          nom: 'ENSEIGNANT Un',
          sexe: 'F',
          matricule: '123456A',
          emploi: 'Institutrice Certifiée',
          decisionNumero: '2025-045/MENAPLN',
          decisionDate: '15/09/2025',
          priseDeService: '01/10/2025',
        ),
      ),
    );
    final long = await pdf(
      'certificat_scolarite',
      const DocumentDirecteur(
        code: CodeDocument.certificatScolarite,
        entete: entete,
        signataire: directrice,
        eleve: fatou,
        lieu: 'Barkouitenga',
        date: '27/10/2026',
      ),
    );
    final court = await pdf(
      'certificat_scolarite_court',
      const DocumentDirecteur(
        code: CodeDocument.certificatScolarite,
        entete: entete,
        signataire: directrice,
        eleve: fatou,
        lieu: 'Barkouitenga',
        date: '27/10/2026',
        court: true,
      ),
    );
    final niveau = await pdf(
      'attestation_niveau',
      const DocumentDirecteur(
        code: CodeDocument.attestationNiveau,
        entete: entete,
        signataire: directrice,
        eleve: fatou,
        lieu: 'Barkouitenga',
        date: '27/10/2026',
      ),
    );
    final redevance = await pdf(
      'non_redevance',
      const DocumentDirecteur(
        code: CodeDocument.nonRedevance,
        entete: entete,
        signataire: directrice,
        eleve: fatou,
        lieu: 'Ziniaré',
        date: '27/10/2026',
      ),
    );
    if (prise == null) return; // pdftotext absent
    for (final (t, attendus) in [
      (
        prise,
        [
          'ATTESTATION DE PRISE DE SERVICE',
          'Je soussignée, Camarade TEST Directrice, Directrice',
          'de l’École Primaire Publique de Barkouitenga',
          'Atteste que Camarade ENSEIGNANT Un, matricule 123456A',
          'Institutrice Certifiée, affectée à l’École Primaire',
          'suivant décision N° 2025-045/MENAPLN du 15/09/2025',
          'a effectivement pris service le 01/10/2025.',
          'CIRCONSCRIPTION D’ÉDUCATION DE BASE DE ZINIARÉ II',
          'La Patrie ou la Mort, nous Vaincrons',
          'Fait à Barkouitenga, le 27/10/2026',
          'La Directrice',
          'Professeur Certifié des Écoles',
        ],
      ),
      (
        long!,
        [
          'CERTIFICAT DE SCOLARITÉ',
          'Certifie que l’élève TEST Fatou',
          'Fille de : TEST Père',
          'Profession : Cultivateur',
          'Est inscrite au registre matricule sous le numéro 5',
          'fréquente régulièrement depuis le 01/10/2019',
          'où elle est élève de la classe du CM2 A.',
        ],
      ),
      (
        court!,
        [
          'Année scolaire : 2025-2026',
          'La Directrice de l’École Primaire Publique de Barkouitenga',
          'soussignée certifie que l’élève TEST Fatou de la classe de CM2 A',
          'Circonscription d’Éducation de Base de Ziniaré II',
        ],
      ),
      (
        niveau!,
        [
          'ATTESTATION DE NIVEAU',
          'atteste que TEST Fatou née le 11/02/2014',
          'Fille de TEST Père et de TEST Mère',
          'a le niveau de la classe de CM2.',
        ],
      ),
      (
        redevance!,
        [
          'CERTIFICAT DE NON REDEVANCE',
          'ne doit rien à l’établissement.',
          'Par conséquent elle nous quitte libre de tout engagement.',
          'Fait à Ziniaré, le 27/10/2026',
        ],
      ),
    ]) {
      for (final x in attendus) {
        expect(t, contains(x));
      }
    }
  });
}
