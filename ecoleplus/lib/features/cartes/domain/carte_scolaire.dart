import 'dart:math';
import 'dart:typed_data';

/// Une carte scolaire (module 12). Le QR code ne contient qu'un identifiant
/// opaque, sans aucune donnée personnelle.
class CarteScolaire {
  const new({
    required this.nom,
    required this.prenoms,
    required this.classe,
    required this.annee,
    required this.identifiant,
    required this.ecole,
    required this.jeton,
    this.commune,
    this.photo,
  });

  final String nom;
  final String prenoms;
  final String classe;
  final String annee;
  final String identifiant;
  final String ecole;
  final String? commune;

  /// Photo JPEG (null : cadre vide « PHOTO »).
  final Uint8List? photo;

  /// Identifiant opaque du QR code (32 caractères hexadécimaux).
  final String jeton;

  /// Contenu du QR code.
  String get contenuQr => 'EP1-$jeton';
}

/// Verso et en-tête : commun à toutes les cartes du lot.
class EcoleCarte {
  const new({
    required this.nom,
    this.commune,
    this.telephone,
    this.adresse,
    this.email,
    this.logo,
    this.couleur = '#1B6E3C',
  });

  final String nom;
  final String? commune;
  final String? telephone;
  final String? adresse;
  final String? email;
  final Uint8List? logo;

  /// Couleur du bandeau (« #1B6E3C »).
  final String couleur;

  int get couleurArgb =>
      0xFF000000 | int.parse(couleur.substring(1), radix: 16);
}

/// Format carte bancaire (ISO/CEI 7810 ID-1), en millimètres.
const largeurCarteMm = 85.6;
const hauteurCarteMm = 54.0;

/// 10 cartes par planche A4 : 2 colonnes × 5 lignes (choix du porteur).
const colonnesPlanche = 2;
const lignesPlanche = 5;
const int cartesParPlanche = colonnesPlanche * lignesPlanche;

/// Espaces entre les cartes (mm) : de quoi découper.
const ecartHorizontalMm = 4.0;
const ecartVerticalMm = 2.0;

/// Position d'une carte sur la planche (mm depuis le coin haut gauche),
/// recto ; au verso, les colonnes sont inversées (impression recto-verso
/// retournée sur le grand côté).
({double x, double y}) positionCarte(int index, {required bool verso}) {
  const largeurA4 = 210.0;
  const hauteurA4 = 297.0;
  const blocL =
      colonnesPlanche * largeurCarteMm +
      (colonnesPlanche - 1) * ecartHorizontalMm;
  const blocH =
      lignesPlanche * hauteurCarteMm + (lignesPlanche - 1) * ecartVerticalMm;
  const margeX = (largeurA4 - blocL) / 2;
  const margeY = (hauteurA4 - blocH) / 2;
  final ligne = index ~/ colonnesPlanche;
  var colonne = index % colonnesPlanche;
  if (verso) colonne = colonnesPlanche - 1 - colonne;
  return (
    x: margeX + colonne * (largeurCarteMm + ecartHorizontalMm),
    y: margeY + ligne * (hauteurCarteMm + ecartVerticalMm),
  );
}

/// Nouvel identifiant opaque (aléatoire, 128 bits).
String nouveauJeton([Random? alea]) {
  final r = alea ?? Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// Couleurs proposées pour le bandeau des cartes.
const couleursCartes = {
  '#1B6E3C': 'Vert',
  '#1565C0': 'Bleu',
  '#B71C1C': 'Rouge',
  '#E65100': 'Orange',
  '#4A148C': 'Violet',
  '#263238': 'Gris foncé',
};

/// Texte d'information des parents sur les photos (modèle proposé).
String texteInformationPhotos(String ecole) =>
    'L’école $ecole prend une photo de chaque élève pour sa carte scolaire. '
    'La photo est facultative : vous pouvez la refuser, l’enfant recevra '
    'quand même sa carte, avec un cadre vide.\n\n'
    'La photo est gardée de façon privée : seuls le directeur, les personnes '
    'qu’il désigne et l’enseignant(e) de la classe peuvent la voir. Elle '
    'n’est jamais publiée sur Internet ni transmise à d’autres personnes.\n\n'
    'Le QR code de la carte ne contient aucun nom ni aucune information '
    'personnelle : seulement un numéro sans signification, connu de '
    'l’école.\n\n'
    'Vous pouvez demander à tout moment le remplacement ou le retrait de la '
    'photo de votre enfant.\n\n'
    'Je soussigné(e) ………………………………, parent ou tuteur de '
    '………………………………, accepte / refuse (rayer la mention inutile) que '
    'mon enfant soit photographié pour sa carte scolaire.\n\n'
    'Fait à ……………………, le ……………………        Signature :';
