import 'package:ecoleplus/core/import/analyse_import.dart';
import 'package:ecoleplus/core/import/tableur.dart';

const colonnesEnseignants = [
  Colonne('nom', 'Nom', ['nom', 'noms', 'nom de famille'], obligatoire: true),
  Colonne('prenoms', 'Prénoms', [
    'prenom',
    'prenoms',
    'prenom(s)',
  ], obligatoire: true),
  Colonne('sexe', 'Sexe', ['sexe', 'genre']),
  Colonne('matricule', 'Matricule', ['matricule', 'mle', 'n° mle']),
  Colonne('telephone', 'Téléphone', ['telephone', 'tel', 'contact']),
  Colonne('naissance', 'Date de naissance', [
    'date de naissance',
    'ne le',
    'nee le',
    'ne(e) le',
    'naissance',
  ]),
  Colonne('lieu', 'Lieu de naissance', ['lieu de naissance', 'ne a', 'lieu']),
  Colonne('emploi', 'Emploi', ['emploi']),
  Colonne('categorie', 'Catégorie', ['categorie']),
  Colonne('echelon', 'Échelon', ['echelon']),
  Colonne('ts', 'Titulaire ou stagiaire (T/S)', [
    't/s',
    'titulaire ou stagiaire',
    'statut',
  ]),
  Colonne('classe', 'Classe tenue', ['classe', 'classe tenue', 'service']),
  Colonne('fonction', 'Fonction', ['fonction', 'poste', 'fonction ou poste']),
];

String? Function(LigneImport) validerEnseignant(Set<String> classesConnues) =>
    (l) {
      if (l['nom'] == null) return 'le nom manque';
      if (l['prenoms'] == null) return 'les prénoms manquent';
      if (sexeDeCellule(l['sexe']) == '?') {
        return 'sexe « ${l['sexe']} » non reconnu (F ou H)';
      }
      if (l['naissance'] != null && dateDeCellule(l['naissance']) == null) {
        return 'date de naissance « ${l['naissance']} » illisible '
            '(attendu : 14/03/1985)';
      }
      if (l['ts'] != null && tsDeCellule(l['ts']) == null) {
        return '« ${l['ts']} » : T (titulaire) ou S (stagiaire) attendu';
      }
      if (l['classe'] != null &&
          !classesConnues.contains(normaliser(l['classe']!))) {
        return 'la classe « ${l['classe']} » n’existe pas cette année';
      }
      return null;
    };

String? tsDeCellule(String? v) {
  if (v == null) return null;
  final n = normaliser(v);
  if (n == 't' || n.startsWith('titulaire')) return 'T';
  if (n == 's' || n.startsWith('stagiaire')) return 'S';
  return null;
}

/// Même enseignant : même matricule, sinon mêmes nom, prénoms et naissance.
String cleEnseignant(
  String nom,
  String prenoms,
  String? naissance,
  String? matricule,
) => matricule != null && matricule.trim().isNotEmpty
    ? 'mle|${normaliser(matricule)}'
    : '${normaliser(nom)}|${normaliser(prenoms)}|${naissance ?? ''}';

String? cleDoublonEnseignant(LigneImport l) => cleEnseignant(
  l['nom']!,
  l['prenoms']!,
  dateDeCellule(l['naissance']),
  l['matricule'],
);
