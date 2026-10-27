import 'dart:convert';

import 'package:ecoleplus/features/grades/domain/calculs.dart';

/// Réglages du bulletin choisis par le directeur (`report_templates`).
/// Toute valeur absente prend sa valeur par défaut.
class ModeleBulletin {
  const new({
    this.titre = 'BULLETIN DE NOTES',
    this.afficherCoefficients = true,
    this.afficherTotal = true,
    this.afficherRang = true,
    this.afficherMention = true,
    this.afficherStatistiques = true,
    this.signatureParents = true,
    this.libelleEnseignant = 'L’enseignant(e)',
    this.libelleDirecteur = 'Le Directeur',
    this.piedDePage = '',
  });

  /// Réglages lus depuis le JSON du serveur (objet, ou texte JSON).
  factory depuis(Object? settings) {
    var v = settings;
    for (var i = 0; i < 2 && v is String; i++) {
      try {
        v = jsonDecode(v);
      } on FormatException {
        v = null;
      }
    }
    final m = v is Map ? v : const <Object?, Object?>{};
    const d = ModeleBulletin();
    bool b(String k, {required bool sinon}) => switch (m[k]) {
      final bool x => x,
      _ => sinon,
    };
    String t(String k, {required String sinon}) => switch (m[k]) {
      final String x when x.trim().isNotEmpty => x.trim(),
      _ => sinon,
    };
    return ModeleBulletin(
      titre: t('titre', sinon: d.titre),
      afficherCoefficients: b('coefficients', sinon: d.afficherCoefficients),
      afficherTotal: b('total', sinon: d.afficherTotal),
      afficherRang: b('rang', sinon: d.afficherRang),
      afficherMention: b('mention', sinon: d.afficherMention),
      afficherStatistiques: b('statistiques', sinon: d.afficherStatistiques),
      signatureParents: b('parents', sinon: d.signatureParents),
      libelleEnseignant: t('enseignant', sinon: d.libelleEnseignant),
      libelleDirecteur: t('directeur', sinon: d.libelleDirecteur),
      piedDePage: switch (m['pied']) {
        final String x => x.trim(),
        _ => '',
      },
    );
  }

  final String titre;
  final bool afficherCoefficients;
  final bool afficherTotal;
  final bool afficherRang;
  final bool afficherMention;

  /// Moyenne de la classe, meilleure et plus faible moyenne.
  final bool afficherStatistiques;
  final bool signatureParents;
  final String libelleEnseignant;
  final String libelleDirecteur;
  final String piedDePage;

  Map<String, Object> versJson() => {
    'titre': titre,
    'coefficients': afficherCoefficients,
    'total': afficherTotal,
    'rang': afficherRang,
    'mention': afficherMention,
    'statistiques': afficherStatistiques,
    'parents': signatureParents,
    'enseignant': libelleEnseignant,
    'directeur': libelleDirecteur,
    'pied': piedDePage,
  };

  ModeleBulletin avec(Map<String, Object> changements) =>
      ModeleBulletin.depuis({...versJson(), ...changements});
}

/// Une ligne du tableau des notes.
class LigneBulletin {
  const new({
    required this.matiere,
    required this.coefficient,
    required this.cases,
    required this.moyenne,
    this.uneSeuleNote = false,
  });
  final String matiere;

  /// Centièmes (100 = coefficient 1).
  final int coefficient;

  /// Notes affichées : (Éval., Compo.) en école privée, (Compo.) en école
  /// publique, (1er, 2e, 3e trimestre) pour l'année.
  final List<String> cases;

  /// Moyenne de la matière (centièmes) ; null : aucune note.
  final int? moyenne;
  final bool uneSeuleNote;

  /// Points = moyenne × coefficient (centièmes).
  int? get points =>
      moyenne == null ? null : divArrondi(moyenne! * coefficient, 100);
}

/// Tout ce qui s'imprime sur le bulletin d'un élève.
class Bulletin {
  const new({
    required this.entete,
    required this.ecole,
    required this.annee,
    required this.classe,
    required this.periode,
    required this.eleve,
    required this.titresCases,
    required this.lignes,
    required this.resultat,
    required this.statistiques,
    this.echelle = 1000,
    this.matricule,
    this.neLe,
    this.sexe,
    this.appreciation,
    this.observation,
    this.decision,
    this.annuel = false,
  });

  /// Lignes d'en-tête administratif (pays, ministère, directions…).
  final List<String> entete;
  final String ecole;
  final String annee;
  final String classe;

  /// « 1er trimestre », « 2e trimestre », « 3e trimestre », « Année ».
  final String periode;
  final String eleve;
  final String? matricule;
  final String? neLe;
  final String? sexe;

  /// Titres des colonnes de notes (voir [LigneBulletin.cases]).
  final List<String> titresCases;
  final List<LigneBulletin> lignes;
  final Resultat resultat;
  final Statistiques statistiques;

  /// Barème de l'école (centièmes, 10 → 1000) : « 7,5 / 10 ».
  final int echelle;
  final String? appreciation;
  final String? observation;
  final String? decision;
  final bool annuel;

  /// « 7e/39 », « 2e ex-aequo/39 », « Non classé ».
  String get rang => resultat.rang == null
      ? resultat.rangTexte
      : '${resultat.rangTexte}/${statistiques.effectif}';
}

/// Décisions proposées en fin d'année (le directeur peut écrire autre chose).
const decisionsProposees = [
  'Passe en classe supérieure',
  'Redouble',
  'Admis(e) au C.E.P.',
];
