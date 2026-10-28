import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';

/// Domaines proposés à l'activation du module (modifiables par le
/// directeur) : liste à confronter au programme officiel du préscolaire
/// (H73), jamais imposée.
const domainesParDefaut = [
  'Langage',
  'Éveil mathématique',
  'Éveil à l’environnement',
  'Graphisme et préécriture',
  'Motricité et activités physiques',
  'Expression artistique',
];

/// Un niveau qualitatif : libellé, couleur ET pictogramme (lisible sans
/// la couleur).
class NiveauQualitatif {
  const new({
    required this.code,
    required this.libelle,
    required this.couleur,
    required this.pictogramme,
    this.id = '',
    this.ordre = 0,
  });

  final String id;
  final String code;
  final String libelle;

  /// « #2E7D32 ».
  final String couleur;

  /// Clé du pictogramme : [Pictogramme].
  final String pictogramme;
  final int ordre;

  int get couleurArgb =>
      0xFF000000 | int.parse(couleur.substring(1), radix: 16);
}

/// Pictogrammes : rond plein, demi-rond, rond vide (repris sur l'écran et
/// dans le livret).
enum Pictogramme {
  plein('plein', 'Rond plein'),
  moitie('moitie', 'Demi-rond'),
  vide('vide', 'Rond vide'),
  etoile('etoile', 'Étoile');

  new(this.cle, this.libelle);
  final String cle;
  final String libelle;

  static Pictogramme depuis(String cle) => switch (cle) {
    'moitie' => moitie,
    'vide' || 'x' => vide,
    'etoile' => etoile,
    _ => plein,
  };
}

/// Trois niveaux par défaut (choix du porteur, 28/10/2026).
const niveauxParDefaut = [
  NiveauQualitatif(
    code: 'acquis',
    libelle: 'Acquis',
    couleur: '#2E7D32',
    pictogramme: 'plein',
    ordre: 1,
  ),
  NiveauQualitatif(
    code: 'en_cours',
    libelle: 'En cours d’acquisition',
    couleur: '#E68A00',
    pictogramme: 'moitie',
    ordre: 2,
  ),
  NiveauQualitatif(
    code: 'non_acquis',
    libelle: 'Non acquis',
    couleur: '#C62828',
    pictogramme: 'vide',
    ordre: 3,
  ),
];

/// Couleurs proposées pour un niveau.
const couleursProposees = {
  '#2E7D32': 'Vert',
  '#1565C0': 'Bleu',
  '#E68A00': 'Orange',
  '#C62828': 'Rouge',
  '#6A1B9A': 'Violet',
  '#455A64': 'Gris',
};

/// Trois trimestres par an (choix du porteur, 28/10/2026).
const trimestresMaternelle = ['1er trimestre', '2e trimestre', '3e trimestre'];

/// Points d'un niveau pour le classement facultatif : le premier niveau
/// (le meilleur) vaut le plus.
int pointsNiveau(int index, int nbNiveaux) => nbNiveaux - 1 - index;

/// Classement facultatif (désactivé par défaut) : score moyen des domaines
/// évalués ; mêmes scores = ex-aequo ; un enfant sans évaluation n'est pas
/// classé. Renvoie le rang de chaque enfant classé.
Map<String, int> classerEnfants(Map<String, List<int>> pointsParEnfant) {
  final scores = <String, double>{
    for (final e in pointsParEnfant.entries)
      if (e.value.isNotEmpty)
        e.key: (e.value.reduce((a, b) => a + b) / e.value.length * 100)
            .roundToDouble(),
  };
  final ordre = scores.keys.toList()
    ..sort((a, b) => scores[b]!.compareTo(scores[a]!));
  final rangs = <String, int>{};
  for (final (i, id) in ordre.indexed) {
    rangs[id] = i > 0 && scores[id] == scores[ordre[i - 1]]
        ? rangs[ordre[i - 1]]!
        : i + 1;
  }
  return rangs;
}

/// Une ligne du livret : le domaine et le niveau atteint (null si non
/// évalué).
class LigneLivret {
  const new(this.domaine, this.niveau);
  final String domaine;
  final NiveauQualitatif? niveau;
}

/// Livret d'évaluation de maternelle (aucune note chiffrée).
class LivretMaternelle {
  const new({
    required this.entete,
    required this.classe,
    required this.periode,
    required this.enfant,
    required this.lignes,
    required this.niveaux,
    this.sexe,
    this.neLe,
    this.appreciation,
    this.observation,
    this.absences = 0,
    this.retards = 0,
    this.rang,
    this.effectif,
    this.signataire = const Signataire(),
    this.enseignant,
  });

  final EnteteDocument entete;
  final String classe;
  final String periode;
  final String enfant;
  final String? sexe;
  final String? neLe;
  final List<LigneLivret> lignes;

  /// Légende : tous les niveaux de l'école.
  final List<NiveauQualitatif> niveaux;
  final String? appreciation;
  final String? observation;
  final int absences;
  final int retards;

  /// Seulement si le directeur a activé le classement.
  final int? rang;
  final int? effectif;
  final Signataire signataire;
  final String? enseignant;
}

/// « 1er/12 », « 2e/12 ».
String texteRang(int rang, int effectif) =>
    '$rang${rang == 1 ? 'er' : 'e'}/$effectif';
