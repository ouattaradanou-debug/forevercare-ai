import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';

/// Programme d'activités (B6) ou bilan annuel (B7) : les deux formulaires
/// partagent les mêmes lignes « objectif → activités ».
enum FormulaireActivites {
  programme('B6', 'Programme d’activités'),
  bilan('B7', 'Bilan annuel des activités');

  new(this.code, this.titre);
  final String code;
  final String titre;

  static FormulaireActivites depuis(String code) =>
      values.firstWhere((f) => f.code == code);

  /// Titre imprimé, mot pour mot comme le modèle.
  String get titrePdf => switch (this) {
    programme => 'PROGRAMME D’ACTIVITÉS AU TITRE DE L’ANNÉE SCOLAIRE',
    bilan => 'BILAN DE PROGRAMME ANNUEL D’ACTIVITÉS',
  };
}

/// Une activité prévue et, pour le bilan, ce qui a été atteint.
class ActiviteProgramme {
  const new({
    required this.activite,
    this.id = '',
    this.echeanceDate,
    this.echeanceTexte,
    this.contrainte,
    this.attendu,
    this.atteint,
    this.taux,
  });

  factory depuisJson(Map<String, dynamic> j) => ActiviteProgramme(
    activite: j['activite'] as String? ?? '',
    echeanceDate: j['echeance_date'] as String?,
    echeanceTexte: j['echeance_texte'] as String?,
    contrainte: j['contrainte'] as String?,
    attendu: j['attendu'] as String?,
    atteint: j['atteint'] as String?,
    taux: (j['taux'] as num?)?.toDouble(),
  );

  final String id;
  final String activite;

  /// Échéance : une date (ISO) ou un texte (« Toute l'année »).
  final String? echeanceDate;
  final String? echeanceTexte;
  final String? contrainte;
  final String? attendu;
  final String? atteint;

  /// Taux de réussite en % (0 à 100).
  final double? taux;

  /// Échéance imprimée : le texte s'il est donné, sinon la date.
  String get echeance {
    final t = echeanceTexte?.trim() ?? '';
    if (t.isNotEmpty) return t;
    return echeanceDate == null ? '' : jjmmaaaa(echeanceDate);
  }

  Map<String, Object?> versJson() => {
    'activite': activite,
    'echeance_date': echeanceDate,
    'echeance_texte': echeanceTexte,
    'contrainte': contrainte,
    'attendu': attendu,
    'atteint': atteint,
    'taux': taux,
  };
}

/// Un objectif et ses activités, dans l'ordre d'impression.
class ObjectifProgramme {
  const new({required this.libelle, required this.activites, this.id = ''});

  factory depuisJson(Map<String, dynamic> j) => ObjectifProgramme(
    libelle: j['libelle'] as String? ?? '',
    activites: [
      for (final a in j['activites'] as List<dynamic>? ?? const [])
        ActiviteProgramme.depuisJson(a as Map<String, dynamic>),
    ],
  );

  final String id;
  final String libelle;
  final List<ActiviteProgramme> activites;

  /// Moyenne des taux renseignés de l'objectif (null si aucun).
  double? get tauxMoyen {
    final t = [for (final a in activites) ?a.taux];
    if (t.isEmpty) return null;
    return t.reduce((a, b) => a + b) / t.length;
  }

  Map<String, Object?> versJson() => {
    'libelle': libelle,
    'activites': [for (final a in activites) a.versJson()],
  };
}

/// Tout ce qui est imprimé : sert au PDF et à l'instantané d'une version.
class DonneesProgramme {
  const new({
    required this.formulaire,
    required this.entete,
    required this.objectifs,
    this.signataire = const Signataire(),
    this.faitA,
    this.faitLe,
    this.moyenneParObjectif = false,
  });

  factory depuisJson(Map<String, dynamic> j) {
    final e = j['entete'] as Map<String, dynamic>? ?? const {};
    final s = j['signataire'] as Map<String, dynamic>? ?? const {};
    return DonneesProgramme(
      formulaire: FormulaireActivites.depuis(
        j['formulaire'] as String? ?? 'B6',
      ),
      entete: EnteteDocument(
        ecole: e['ecole'] as String? ?? '',
        ministere: e['ministere'] as String?,
        directionRegionale: e['direction_regionale'] as String?,
        directionProvinciale: e['direction_provinciale'] as String?,
        ceb: e['ceb'] as String?,
        pays: e['pays'] as String? ?? 'BURKINA FASO',
        devise: e['devise'] as String?,
        anneeScolaire: e['annee_scolaire'] as String?,
      ),
      signataire: Signataire(
        civilite: s['civilite'] as String?,
        nom: s['nom'] as String?,
        grade: s['grade'] as String?,
      ),
      faitA: j['fait_a'] as String?,
      faitLe: j['fait_le'] as String?,
      moyenneParObjectif: j['moyenne_par_objectif'] as bool? ?? false,
      objectifs: [
        for (final o in j['objectifs'] as List<dynamic>? ?? const [])
          ObjectifProgramme.depuisJson(o as Map<String, dynamic>),
      ],
    );
  }

  final FormulaireActivites formulaire;
  final EnteteDocument entete;
  final List<ObjectifProgramme> objectifs;
  final Signataire signataire;
  final String? faitA;

  /// Date ISO.
  final String? faitLe;

  /// B7 : imprimer la moyenne des taux de chaque objectif.
  final bool moyenneParObjectif;

  Map<String, Object?> versJson() => {
    'formulaire': formulaire.code,
    'entete': {
      'ecole': entete.ecole,
      'ministere': entete.ministere,
      'direction_regionale': entete.directionRegionale,
      'direction_provinciale': entete.directionProvinciale,
      'ceb': entete.ceb,
      'pays': entete.pays,
      'devise': entete.devise,
      'annee_scolaire': entete.anneeScolaire,
    },
    'signataire': {
      'civilite': signataire.civilite,
      'nom': signataire.nom,
      'grade': signataire.grade,
    },
    'fait_a': faitA,
    'fait_le': faitLe,
    'moyenne_par_objectif': moyenneParObjectif,
    'objectifs': [for (final o in objectifs) o.versJson()],
  };
}

/// Taux imprimé : « 66,67 », « 100 » (deux décimales au plus).
String texteTaux(double? t) {
  if (t == null) return '';
  final arrondi = (t * 100).roundToDouble() / 100;
  final s = arrondi == arrondi.truncateToDouble()
      ? arrondi.toStringAsFixed(0)
      : arrondi.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
  return s.replaceAll('.', ',');
}

/// Lit un taux saisi : « 75 », « 66,67 », « 80 % ». Null si vide ;
/// [FormatException] hors de 0 à 100.
double? lireTaux(String? saisie) {
  final s = (saisie ?? '').replaceAll('%', '').replaceAll(',', '.').trim();
  if (s.isEmpty) return null;
  final v = double.tryParse(s);
  if (v == null || v < 0 || v > 100) {
    throw const FormatException('Taux entre 0 et 100');
  }
  return (v * 100).roundToDouble() / 100;
}

/// Exemples tirés des programmes réels : de simples propositions, que le
/// directeur choisit, modifie ou ignore (jamais imposées).
const suggestionsProgramme = <String, List<String>>{
  'Gérer rationnellement les ressources': [
    'Répartition des enseignants dans les classes',
    'Mise à disposition du matériel',
    'Distribution des fournitures',
  ],
  'Contribuer à la formation continue des enseignants': [
    'Visites de classes',
    'Participation aux stages',
    'Participation à la conférence',
  ],
  'Rédiger les différents rapports': [],
  'Gérer le courrier': [],
  'Évaluer les enseignants de l’école': [],
};

/// Activités proposées pour un objectif (comparaison sans casse ni accents).
List<String> suggestionsPour(String objectif) {
  String cle(String s) => s
      .toLowerCase()
      .replaceAll(RegExp("[’']"), ' ')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final k = cle(objectif);
  for (final e in suggestionsProgramme.entries) {
    if (cle(e.key) == k) return e.value;
  }
  return const [];
}
