import 'package:ecoleplus/core/import/analyse_import.dart';
import 'package:ecoleplus/core/import/tableur.dart';

/// Colonnes reconnues pour l'import des élèves. Seuls le nom et les prénoms
/// sont obligatoires (R5).
const colonnesEleves = [
  Colonne('nom', 'Nom', ['nom', 'noms', 'nom de famille'], obligatoire: true),
  Colonne('prenoms', 'Prénoms', [
    'prenom',
    'prenoms',
    'prenom(s)',
  ], obligatoire: true),
  Colonne('sexe', 'Sexe', ['sexe', 'genre', 'f/g', 'f/m']),
  Colonne('naissance', 'Date de naissance', [
    'date de naissance',
    'ne le',
    'nee le',
    'ne(e) le',
    'naissance',
    'date naissance',
  ]),
  Colonne('lieu', 'Lieu de naissance', [
    'lieu de naissance',
    'ne a',
    'nee a',
    'ne(e) a',
    'lieu',
  ]),
  Colonne('classe', 'Classe', ['classe', 'cours']),
  Colonne('identifiant', 'Identifiant', [
    'identifiant',
    'code',
    'code eleve',
    'id',
  ]),
  Colonne('numero', 'Numéro d’ordre (registre)', [
    'numero d’ordre',
    'n° d’ordre',
    'no d’ordre',
    'numero',
    'n°',
    'matricule',
    'n° mle',
  ]),
  Colonne('parent', 'Parent ou tuteur', [
    'parent',
    'tuteur',
    'parent ou tuteur',
    'parent/tuteur',
    'nom du parent',
    'pere',
    'noms et prenoms des parents ou tuteurs',
  ]),
  Colonne('profession', 'Profession du parent', [
    'profession',
    'profession du parent',
    'profession des parents',
  ]),
  Colonne('domicile', 'Domicile', ['domicile', 'quartier', 'adresse']),
  Colonne('telephone', 'Téléphone du parent', [
    'telephone',
    'tel',
    'téléphone du parent',
    'contact',
  ]),
  Colonne('entree', 'Date d’entrée', [
    'date d’entree',
    'date de l’entree a l’ecole',
    'entree',
    'entre le',
  ]),
];

/// Vérifie une ligne d'élève ; renvoie la raison du refus (texte simple).
String? Function(LigneImport) validerEleve(Set<String> classesConnues) => (l) {
  if (l['nom'] == null) return 'le nom manque';
  if (l['prenoms'] == null) return 'les prénoms manquent';
  if (sexeDeCellule(l['sexe']) == '?') {
    return 'sexe « ${l['sexe']} » non reconnu (F ou G)';
  }
  if (l['naissance'] != null && dateDeCellule(l['naissance']) == null) {
    return 'date de naissance « ${l['naissance']} » illisible '
        '(attendu : 14/03/2017)';
  }
  if (l['entree'] != null && dateDeCellule(l['entree']) == null) {
    return 'date d’entrée « ${l['entree']} » illisible';
  }
  if (l['classe'] != null &&
      !classesConnues.contains(normaliser(l['classe']!))) {
    return 'la classe « ${l['classe']} » n’existe pas cette année '
        '(créez-la d’abord)';
  }
  final n = l['numero'];
  if (n != null && (int.tryParse(n.replaceAll('.0', '')) ?? 0) <= 0) {
    return 'numéro d’ordre « $n » : un nombre entier est attendu';
  }
  return null;
};

/// Même élève : nom + prénoms + date de naissance (si connue).
String cleEleve(String nom, String prenoms, String? naissance) =>
    '${normaliser(nom)}|${normaliser(prenoms)}|${naissance ?? ''}';

String? cleDoublonEleve(LigneImport l) =>
    cleEleve(l['nom']!, l['prenoms']!, dateDeCellule(l['naissance']));
