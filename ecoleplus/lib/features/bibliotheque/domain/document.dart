import 'dart:convert';

import 'package:ecoleplus/core/db/app_database.dart';

/// Les deux espaces (module 18).
enum Espace {
  bibliotheque('bibliotheque', 'Bibliothèque pédagogique'),
  archives('archives', 'Archives administratives');

  new(this.code, this.titre);
  final String code;
  final String titre;

  static Espace depuis(String code) =>
      code == 'archives' ? archives : bibliotheque;
}

/// Types de documents proposés (texte libre possible).
const typesBibliotheque = [
  'Programme officiel',
  'Guide du maître',
  'Manuel',
  'Fiche de préparation',
  'Exercices',
  'Sujet d’examen',
  'Évaluation',
  'Corrigé',
  'Document divers',
];

const typesArchives = [
  'Formulaire signé',
  'Registre',
  'Procès-verbal',
  'Courrier',
  'Rapport',
  'Programme / bilan',
  'Document divers',
];

/// Rappels affichés à l'ajout (18.7, 18.9).
const avertissementAjout =
    'N’ajoutez pas ici de documents contenant des notes, photos, '
    'informations de santé ou autres données personnelles d’élèves.';
const rappelDroitAuteur =
    'N’ajoutez que des documents que vous avez le droit d’utiliser.';

/// Fiche saisie à l'ajout (appliquée à tout le lot).
class FicheDocument {
  const new({
    this.titre,
    this.commun = false,
    this.classes = const [],
    this.niveaux = const [],
    this.type,
    this.matiereId,
    this.anneeId,
    this.source,
    this.motsCles = const [],
    this.sensible = false,
  });

  /// Titre (un seul fichier) ; sinon le nom de chaque fichier.
  final String? titre;
  final bool commun;
  final List<String> classes;
  final List<String> niveaux;
  final String? type;
  final String? matiereId;
  final String? anneeId;
  final String? source;
  final List<String> motsCles;
  final bool sensible;
}

/// Type de fichier selon l'extension.
String typeMime(String nom) {
  final ext = nom.contains('.') ? nom.split('.').last.toLowerCase() : '';
  return switch (ext) {
    'pdf' => 'application/pdf',
    'txt' => 'text/plain',
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls' => 'application/vnd.ms-excel',
    'xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt' => 'application/vnd.ms-powerpoint',
    'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'odt' => 'application/vnd.oasis.opendocument.text',
    'ods' => 'application/vnd.oasis.opendocument.spreadsheet',
    _ => 'application/octet-stream',
  };
}

/// Nom de fichier sans caractères gênants pour le chemin du serveur.
String nomSur(String nom) {
  const accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
    'î': 'i', 'ï': 'i', 'ô': 'o', 'ö': 'o', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c',
  };
  final b = StringBuffer();
  for (final c in nom.toLowerCase().split('')) {
    b.write(accents[c] ?? (RegExp('[a-z0-9._-]').hasMatch(c) ? c : '_'));
  }
  final s = b.toString().replaceAll(RegExp('_+'), '_');
  return s.isEmpty ? 'fichier' : s;
}

/// Titre proposé : le nom du fichier sans l'extension.
String titreDepuisNom(String nom) {
  final sansExt = nom.contains('.')
      ? nom.substring(0, nom.lastIndexOf('.'))
      : nom;
  return sansExt.replaceAll(RegExp('[_-]+'), ' ').trim();
}

List<String> listeJson(String texte) {
  try {
    return [for (final v in jsonDecode(texte) as List<dynamic>) '$v'];
  } on Object {
    return const [];
  }
}

extension DocumentRowX on DocumentRow {
  List<String> get motsCles => listeJson(keywords);
  List<String> get classes => listeJson(classIds);
  List<String> get niveaux => listeJson(levelCodes);
  bool get enCorbeille => trashedAt != null;

  /// Texte cherché sur le téléphone (titre et fiche).
  String get texteRecherche => [
    title,
    docType,
    sourceAuthor,
    originalName,
    ...motsCles,
  ].whereType<String>().join(' ');
}

/// État d'indexation lisible.
String texteIndexation(DocumentRow d) => switch (d.indexStatus) {
  'indexe' => 'Texte lu : cherchable',
  'echec' => 'Lecture du texte impossible',
  'exclu' => 'Non indexé',
  _ =>
    d.uploadedAt == null ? 'Envoi à terminer' : 'Lecture du texte en attente',
};

/// « 1,2 Mo », « 350 Ko ».
String tailleTexte(int octets) {
  String un(double v) => v.toStringAsFixed(1).replaceAll('.', ',');
  const mo = 1024 * 1024;
  if (octets >= 1024 * mo) return '${un(octets / (1024 * mo))} Go';
  if (octets >= mo) return '${un(octets / mo)} Mo';
  return '${(octets / 1024).ceil()} Ko';
}

/// Sans accents ni majuscules, pour chercher « geographie » dans
/// « Géographie ».
String sansAccents(String s) {
  const a = 'àâäéèêëîïôöùûüç';
  const b = 'aaaeeeeiioouuuc';
  return s.toLowerCase().split('').map((c) {
    final i = a.indexOf(c);
    return i < 0 ? c : b[i];
  }).join();
}
