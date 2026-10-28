import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Zone retenue, en fractions de l'image (0 à 1).
class Recadrage {
  const new(this.gauche, this.haut, this.largeur, this.hauteur);
  final double gauche;
  final double haut;
  final double largeur;
  final double hauteur;

  static const tout = Recadrage(0, 0, 1, 1);
}

/// Photo d'identité : 300 × 400 (3:4), JPEG ; poids visé 25 à 50 Ko.
const largeurPhoto = 300;
const hauteurPhoto = 400;
const int poidsMaxPhoto = 50 * 1024;

/// Logo : 256 × 256, JPEG.
const coteLogo = 256;

/// Recadre, réduit et compresse (dans un autre fil d'exécution pour ne pas
/// figer l'écran).
Future<Uint8List> preparerPhoto(Uint8List source, Recadrage r) =>
    Isolate.run(() => _preparer(source, r, largeurPhoto, hauteurPhoto));

Future<Uint8List> preparerLogo(Uint8List source, Recadrage r) =>
    Isolate.run(() => _preparer(source, r, coteLogo, coteLogo, qualite: 85));

Uint8List _preparer(
  Uint8List source,
  Recadrage r,
  int largeur,
  int hauteur, {
  int qualite = 72,
}) {
  final decodee = img.decodeImage(source);
  if (decodee == null) throw const FormatException('Image illisible');
  // Photo prise de travers : remise à l'endroit selon l'appareil.
  final image = img.bakeOrientation(decodee);
  final x = (r.gauche * image.width).round().clamp(0, image.width - 1);
  final y = (r.haut * image.height).round().clamp(0, image.height - 1);
  final w = (r.largeur * image.width).round().clamp(1, image.width - x);
  final h = (r.hauteur * image.height).round().clamp(1, image.height - y);
  final coupee = img.copyCrop(image, x: x, y: y, width: w, height: h);
  final reduite = img.copyResize(
    coupee,
    width: largeur,
    height: hauteur,
    interpolation: img.Interpolation.average,
  );
  var q = qualite;
  var octets = img.encodeJpg(reduite, quality: q);
  // Poids très réduit : on baisse la qualité tant que c'est trop lourd.
  while (octets.length > poidsMaxPhoto && q > 40) {
    q -= 8;
    octets = img.encodeJpg(reduite, quality: q);
  }
  return octets;
}
