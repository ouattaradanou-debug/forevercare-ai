import 'package:ecoleplus/features/grades/domain/calculs.dart';

/// Niveaux du tableau « Cours suivis » de la fiche de scolarité (B4).
const niveauxB4 = ['CP1', 'CP2', 'CE1', 'CE2', 'CM1', 'CM2'];
const libellesNiveauxB4 = {
  'CP1': 'C.P.1',
  'CP2': 'C.P.2',
  'CE1': 'C.E.1',
  'CE2': 'C.E.2',
  'CM1': 'C.M.1',
  'CM2': 'C.M.2',
};

/// Une année suivie dans un niveau : première année (essai 1) ou
/// redoublement (essai 2), deuxième sous-colonne du niveau (H50).
class CoursSuivi {
  const new({
    required this.niveau,
    required this.essai,
    this.date,
    this.moyenne,
    this.rang,
    this.exAequo = false,
    this.effectif,
    this.fille = false,
  });
  final String niveau;
  final int essai;

  /// Date ISO du résultat.
  final String? date;

  /// Moyenne générale annuelle (centièmes).
  final int? moyenne;
  final int? rang;
  final bool exAequo;
  final int? effectif;
  final bool fille;

  /// « 7e/39 », « 1re/39 », « 7e ex/39 » (ex-aequo) ; « » si inconnu.
  String get classement {
    if (rang == null || effectif == null) return '';
    final r = rang == 1 ? (fille ? '1re' : '1er') : '${rang}e';
    return '$r${exAequo ? ' ex' : ''}/$effectif';
  }

  String get moyenneTexte => moyenne == null ? '' : centiemesTexte(moyenne);
}

/// Cours suivis à imprimer : le plus récent par niveau et par essai ; le
/// résultat calculé en direct pour l'année en cours remplace celui gardé
/// pour la même année (une note corrigée change aussitôt la fiche).
Map<(String, int), CoursSuivi> coursParCase(Iterable<CoursSuivi> cours) {
  final m = <(String, int), CoursSuivi>{};
  for (final c in cours) {
    if (!niveauxB4.contains(c.niveau)) continue;
    final e = c.essai.clamp(1, 2);
    final avant = m[(c.niveau, e)];
    if (avant == null || (c.date ?? '').compareTo(avant.date ?? '') >= 0) {
      m[(c.niveau, e)] = c;
    }
  }
  return m;
}

/// Tout ce qui s'imprime sur la fiche de scolarité d'un élève.
class FicheScolarite {
  const new({
    required this.entete,
    required this.pays,
    required this.nom,
    required this.ecole,
    required this.cours,
    this.devise,
    this.sexe,
    this.neLe,
    this.lieuNaissance,
    this.pere,
    this.professionPere,
    this.mere,
    this.professionMere,
    this.domicile,
    this.race,
    this.religion,
    this.raceReligion = false,
    this.matricule,
    this.logeur,
    this.entreLe,
    this.venantDe,
    this.sortiLe,
    this.allantA,
    this.motifDepart,
    this.diplomes,
    this.observations,
    this.copieConforme = false,
    this.dateCopie,
  });

  /// Ministère, directions (gauche de l'en-tête).
  final List<String> entete;
  final String pays;
  final String? devise;
  final String nom;
  final String? sexe;
  final String? neLe;
  final String? lieuNaissance;
  final String? pere;
  final String? professionPere;
  final String? mere;
  final String? professionMere;
  final String? domicile;
  final String? race;
  final String? religion;

  /// Champs « race » et « religion » : masqués par défaut (R4).
  final bool raceReligion;
  final String? matricule;
  final String ecole;

  /// Nom et adresse du logeur (père ou tuteur).
  final String? logeur;
  final String? entreLe;
  final String? venantDe;
  final String? sortiLe;
  final String? allantA;
  final String? motifDepart;
  final Map<(String, int), CoursSuivi> cours;
  final String? diplomes;
  final String? observations;
  final bool copieConforme;
  final String? dateCopie;
}

/// Observations générales imprimées sur le modèle (ANNEXE B, B4) : le
/// libellé exact du scan reste à reprendre mot pour mot (H51).
const List<String> observationsGeneralesB4 = [_remise, _mutation];
const _remise =
    'La présente fiche ne doit en aucun cas être remise à l’enfant à sa '
    'sortie définitive de l’école. Il ne peut en être délivré qu’une copie '
    'conforme.';
const _mutation =
    'En cas de mutation, la fiche est transmise directement, sur sa demande, '
    'au nouveau directeur.';
