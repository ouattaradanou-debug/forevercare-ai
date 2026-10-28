import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ecoleplus/features/cartes/domain/carte_scolaire.dart';
import 'package:ecoleplus/features/cartes/pdf/pdf_cartes.dart';
import 'package:ecoleplus/features/photos/domain/traitement_photo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'documents_directeur_test.dart' show polices, texteDuPdf;

/// Photo de test : dégradé de couleurs (assez riche pour mesurer le poids).
Uint8List photoDeTest(int graine) {
  final r = Random(graine);
  final im = img.Image(width: 1200, height: 1600);
  for (final p in im) {
    p
      ..r = (p.x * 255 ~/ 1200 + r.nextInt(30)).clamp(0, 255)
      ..g = (p.y * 255 ~/ 1600 + r.nextInt(30)).clamp(0, 255)
      ..b = ((p.x + p.y) % 255 + r.nextInt(30)).clamp(0, 255);
  }
  return img.encodeJpg(im, quality: 92);
}

void main() {
  test('planche : 10 cartes au format carte bancaire, dans la page A4 ; '
      'verso en miroir', () {
    for (var i = 0; i < cartesParPlanche; i++) {
      final r = positionCarte(i, verso: false);
      expect(r.x, greaterThanOrEqualTo(5));
      expect(r.y, greaterThanOrEqualTo(5));
      expect(r.x + largeurCarteMm, lessThanOrEqualTo(205));
      expect(r.y + hauteurCarteMm, lessThanOrEqualTo(292));
      final v = positionCarte(i, verso: true);
      expect(v.y, r.y);
      // Retournée sur le grand côté : la carte de gauche passe à droite.
      expect(
        v.x + largeurCarteMm / 2,
        closeTo(210 - (r.x + largeurCarteMm / 2), 0.001),
      );
    }
    expect(cartesParPlanche, 10);
  });

  test('identifiant opaque : 32 caractères hexadécimaux, jamais le même', () {
    final a = nouveauJeton();
    expect(a, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(nouveauJeton(), isNot(a));
    const c = CarteScolaire(
      nom: 'TEST',
      prenoms: 'Aïcha',
      classe: 'CM1 A',
      annee: '2025-2026',
      identifiant: 'EL-0001',
      ecole: 'École Test',
      jeton: '0123456789abcdef0123456789abcdef',
    );
    expect(c.contenuQr, 'EP1-0123456789abcdef0123456789abcdef');
    expect(c.contenuQr, isNot(contains('TEST')));
  });

  test('photo : recadrée en 3:4, 300 × 400, poids très réduit', () async {
    final poids = <int>[];
    for (var i = 0; i < 5; i++) {
      final jpeg = await preparerPhoto(
        photoDeTest(i),
        const Recadrage(0.1, 0.1, 0.6, 0.8),
      );
      final im = img.decodeJpg(jpeg)!;
      expect((im.width, im.height), (300, 400));
      poids.add(jpeg.length);
    }
    final moyen = poids.reduce((a, b) => a + b) / poids.length;
    // Mesure affichée dans le rapport de la phase 8.
    // ignore: avoid_print
    print('Poids moyen d’une photo : ${(moyen / 1024).toStringAsFixed(1)} Ko');
    expect(moyen, lessThanOrEqualTo(poidsMaxPhoto));
  });

  test(
    'lot de 12 cartes dont une sans photo : 2 planches recto-verso',
    () async {
      final photo = await preparerPhoto(photoDeTest(9), Recadrage.tout);
      final cartes = [
        for (var i = 0; i < 12; i++)
          CarteScolaire(
            nom: 'TEST',
            prenoms: 'Élève ${i + 1}',
            classe: 'CM1 A',
            annee: '2025-2026',
            identifiant: 'EL-${(i + 1).toString().padLeft(4, '0')}',
            ecole: 'École Primaire Publique de Barkouitenga',
            commune: 'Ziniaré',
            photo: i == 3 ? null : photo,
            jeton: nouveauJeton(Random(i)),
          ),
      ];
      final pdf = await pdfCartes(
        polices(),
        const EcoleCarte(
          nom: 'École Primaire Publique de Barkouitenga',
          commune: 'Ziniaré',
          telephone: '70 00 00 00',
        ),
        cartes,
      );
      if (Platform.environment['PDF_SORTIE'] case final dossier?) {
        File('$dossier/cartes.pdf').writeAsBytesSync(pdf);
        File(
          '$dossier/jetons.txt',
        ).writeAsStringSync([for (final c in cartes) c.contenuQr].join('\n'));
      }
      final t = texteDuPdf(pdf);
      if (t == null) return;
      for (final x in [
        'CARTE SCOLAIRE',
        'Élève 12',
        'PHOTO',
        'Si cette carte est trouvée',
        '70 00 00 00',
        'Cachet et signature du directeur',
      ]) {
        expect(t, contains(x));
      }
      final pages = Process.runSync('pdfinfo', ['-']);
      expect(pages, isNotNull);
    },
  );
}
