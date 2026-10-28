/// Fiche médico-scolaire (B5, module 19). Données de santé de mineurs :
/// jamais gardées sur le téléphone, jamais envoyées à l'IA, jamais dans les
/// exports ni les recherches générales. Tous les champs sont facultatifs.
library;

/// Un champ de la fiche : colonne du serveur et libellé du modèle.
typedef ChampMedical = (String colonne, String libelle);

/// A) I — Antécédents familiaux.
const antecedentsFamiliaux = <ChampMedical>[
  ('fam_diabete', 'Diabète'),
  ('fam_asthme', 'Asthme'),
  ('fam_hta', 'HTA'),
  ('fam_autres', 'Autres'),
];

/// A) II a) — Antécédents personnels médicaux.
const antecedentsMedicaux = <ChampMedical>[
  ('hemoglobine', 'Hémoglobine'),
  ('groupe_sanguin_rhesus', 'Groupe sanguin rhésus'),
  ('diabete', 'Diabète'),
  ('asthme', 'Asthme'),
  ('rhinites_repetition', 'Rhinites à répétitions'),
  ('angines_repetition', 'Angines à répétitions'),
  ('trachome', 'Trachome'),
  ('poliomyelite', 'Poliomyélite'),
  ('rougeole', 'Rougeole'),
  ('autres_medicaux', 'Autres'),
];

/// Vaccinations.
const vaccinations = <ChampMedical>[
  ('vacc_bcg', 'B.C.G.'),
  ('vacc_dtcp', 'D.T.C.P.'),
  ('vacc_antirougeoleux', 'Anti-rougeoleux'),
  ('vacc_antiamarile', 'Anti-amarile'),
  ('vacc_antimeningococcique', 'Anti-méningococcique'),
];

/// A) II b) — Antécédents chirurgicaux.
const antecedentsChirurgicaux = <ChampMedical>[
  ('antecedents_chirurgicaux', 'Antécédents chirurgicaux'),
];

/// Tous les champs de la partie A.
const champsFiche = <ChampMedical>[
  ...antecedentsFamiliaux,
  ...antecedentsMedicaux,
  ...vaccinations,
  ...antecedentsChirurgicaux,
];

/// B) I — Constantes (une colonne par année sur le modèle).
const constantes = <ChampMedical>[
  ('urines_alb', 'Urines : Alb.'),
  ('urines_sucre', 'Urines : Sucre'),
  ('av_od', 'AV : OD'),
  ('av_og', 'AV : OG'),
  ('aa_od', 'AA : OD'),
  ('aa_og', 'AA : OG'),
  ('poids', 'Poids'),
  ('taille', 'Taille'),
];

/// Huit années sur le modèle.
const anneesSurLeModele = 8;

/// OBSERVATIONS : la mention d'aptitude, seule information exposable à
/// l'enseignant(e) si le directeur le choisit.
const aptitudes = {
  'apte': 'Apte',
  'a_surveiller': 'À surveiller',
  'inapte_temporaire': 'Inapte temporaire',
  'inapte_definitif': 'Inapte définitif',
};

/// Une année d'examen : constantes et examen physique.
class ExamenAnnuel {
  new(this.annee, [Map<String, String?>? valeurs]) : valeurs = valeurs ?? {};

  /// « 2025-2026 ».
  final String annee;
  final Map<String, String?> valeurs;

  String? get examenPhysique => valeurs['examen_physique'];

  Map<String, Object?> versJson() => {
    'year_label': annee,
    for (final (c, _) in constantes) c: _vide(valeurs[c]),
    'examen_physique': _vide(valeurs['examen_physique']),
  };
}

/// Aptitude d'une année scolaire.
class AptitudeAnnee {
  const new({
    required this.anneeId,
    required this.aptitude,
    this.exposee = false,
  });
  final String anneeId;
  final String aptitude;
  final bool exposee;
}

/// Le dossier d'un élève tel que lu au serveur.
class DossierMedical {
  new({
    Map<String, String?>? fiche,
    List<ExamenAnnuel>? examens,
    List<AptitudeAnnee>? aptitudesParAnnee,
  }) : fiche = fiche ?? {},
       examens = examens ?? [],
       aptitudesParAnnee = aptitudesParAnnee ?? [];

  factory depuisJson(Map<String, dynamic> j) {
    final r = j['record'] as Map<String, dynamic>? ?? const {};
    return DossierMedical(
      fiche: {for (final (c, _) in champsFiche) c: r[c] as String?},
      examens: [
        for (final e in j['examens'] as List<dynamic>? ?? const [])
          ExamenAnnuel((e as Map<String, dynamic>)['year_label'] as String, {
            for (final (c, _) in constantes) c: e[c] as String?,
            'examen_physique': e['examen_physique'] as String?,
          }),
      ],
      aptitudesParAnnee: [
        for (final a in j['aptitudes'] as List<dynamic>? ?? const [])
          AptitudeAnnee(
            anneeId: (a as Map<String, dynamic>)['school_year_id'] as String,
            aptitude: a['aptitude'] as String,
            exposee: a['expose_to_teacher'] as bool? ?? false,
          ),
      ],
    );
  }

  final Map<String, String?> fiche;
  final List<ExamenAnnuel> examens;
  final List<AptitudeAnnee> aptitudesParAnnee;

  /// Fiche complète envoyée au serveur (un champ vide est effacé).
  Map<String, Object?> ficheJson() => {
    for (final (c, _) in champsFiche) c: _vide(fiche[c]),
  };
}

String? _vide(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();

/// Ligne du journal d'accès.
class LigneJournalMedical {
  const new({
    required this.quand,
    required this.qui,
    required this.action,
    required this.autorise,
    this.eleve,
  });
  final DateTime quand;
  final String qui;
  final String? eleve;
  final String action;
  final bool autorise;
}

/// Texte d'information des parents (modèle proposé, à faire valider
/// localement avant usage réel — voir docs/MEDICO_POINTS_JURIDIQUES.md).
String texteInformationParents(String ecole) =>
    'L’école $ecole tient, pour chaque élève, une fiche médico-scolaire '
    '(antécédents, vaccinations, constantes, examen physique, aptitude). '
    'Ces informations servent uniquement à protéger la santé de votre enfant '
    'à l’école.\n\n'
    'Seul le directeur (ou la directrice) peut les consulter. Chaque '
    'consultation est enregistrée. Elles ne sont jamais communiquées aux '
    'autres parents, ni à un service d’intelligence artificielle, ni '
    'utilisées dans les rapports de l’école. Si le directeur le décide, '
    'l’enseignant(e) de la classe peut seulement savoir si votre enfant est '
    '« apte », « à surveiller » ou « inapte », sans aucun détail médical.\n\n'
    'Vous pouvez demander à voir la fiche de votre enfant, à la faire '
    'corriger, ou refuser que certaines informations y soient inscrites : '
    'tous les champs sont facultatifs.\n\n'
    'Je soussigné(e) ………………………………, parent ou tuteur de '
    '………………………………, déclare avoir été informé(e).\n\n'
    'Fait à ……………………, le ……………………        Signature :';
