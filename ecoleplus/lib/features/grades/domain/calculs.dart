/// Notes, moyennes et classement (module 6 de l'ANNEXE A, évolution A15).
///
/// Les notes sont en CENTIÈMES ENTIERS (14,5 → 1450). Les calculs
/// intermédiaires sont EXACTS (fractions, aucune erreur d'arrondi) ; seules
/// les valeurs affichées sont arrondies au centième « au plus proche »
/// (6,125 → 6,13).
///
/// Méthode selon le type d'école (« Mon école ») :
///  * publique : par trimestre, une composition par matière ;
///    moyenne du trimestre = Σ notes ÷ nombre de matières notées ;
///  * privée : par trimestre, une évaluation ET une composition par matière ;
///    moyenne de la matière = (évaluation + composition) ÷ 2 (une seule note
///    présente : elle fait la moyenne de la matière) ;
///  * les deux : moyenne annuelle = (T1 + T2 + T3) ÷ 3, seulement quand les
///    trois moyennes de trimestre existent.
/// Les coefficients (1 par défaut) pondèrent les matières ; avec 1 partout,
/// on retrouve exactement « Σ ÷ nombre de matières ».
library;

enum StatutNote { note, absent, dispense }

/// Règle de l'élève absent, choisie par l'école (`schools.absent_rule`).
enum RegleAbsent {
  /// L'absence n'est pas comptée : « Abs. », la matière est calculée sur les
  /// autres notes (ou exclue s'il n'y en a pas).
  nonCompte,

  /// L'absence compte pour zéro.
  zero,
}

/// Type d'école (`schools.school_type`) : décide de la méthode de calcul.
enum TypeEcole {
  publique,
  privee;

  static TypeEcole depuis(String? v) =>
      v == 'privee' ? TypeEcole.privee : TypeEcole.publique;
}

/// Épreuve d'un trimestre (`assessments.kind`).
enum TypeEpreuve {
  composition,
  evaluation;

  static TypeEpreuve depuis(String? v) =>
      v == 'evaluation' ? TypeEpreuve.evaluation : TypeEpreuve.composition;
}

class Matiere {
  const new(this.id, this.nom, this.coefficient);
  final String id;
  final String nom;

  /// En centièmes (1 → 100 ; 0,5 → 50).
  final int coefficient;
}

class Composition {
  const new(
    this.id,
    this.libelle,
    this.bareme, {
    this.trimestre = 1,
    this.type = TypeEpreuve.composition,
  });
  final String id;
  final String libelle;

  /// Note maximale, en centièmes (10 → 1000).
  final int bareme;

  /// 1, 2 ou 3 (`assessments.sequence`).
  final int trimestre;
  final TypeEpreuve type;
}

class Note {
  const new({
    required this.eleveId,
    required this.matiereId,
    required this.compositionId,
    this.valeur,
    this.statut = StatutNote.note,
  });
  final String eleveId;
  final String matiereId;
  final String compositionId;

  /// En centièmes ; null si absent ou dispensé.
  final int? valeur;
  final StatutNote statut;
}

class Eleve {
  const new(this.id, this.nom, {this.fille = false});
  final String id;
  final String nom;
  final bool fille;
}

/// Fraction exacte (valeurs positives), pour les calculs intermédiaires.
class Fraction {
  const new _(this.num, this.den);

  /// num / den, simplifiée.
  factory de(int num, int den) {
    final g = _pgcd(num.abs(), den.abs());
    return Fraction._(num ~/ g, den ~/ g);
  }

  static const zero = Fraction._(0, 1);

  final int num;
  final int den;

  Fraction operator +(Fraction o) =>
      Fraction.de(num * o.den + o.num * den, den * o.den);
  Fraction fois(int k) => Fraction.de(num * k, den);
  Fraction divisePar(int k) => Fraction.de(num, den * k);

  /// Arrondi à l'entier le plus proche (0,5 → 1).
  int arrondi() => divArrondi(num, den);

  static int _pgcd(int a, int b) => b == 0 ? (a == 0 ? 1 : a) : _pgcd(b, a % b);
  @override
  String toString() => '$num/$den';
}

/// Résultat d'un élève (valeurs affichées en centièmes, arrondies).
class Resultat {
  new(
    this.eleve,
    this.moyennesMatieres,
    this.total,
    this.exacte, {
    this.uneSeuleNote = const {},
  }) : moyenne = exacte?.arrondi();
  final Eleve eleve;

  /// Colonne → moyenne arrondie (null : aucune note). Colonnes : les
  /// matières (trimestre) ou « t1 », « t2 », « t3 » (année).
  final Map<String, int?> moyennesMatieres;

  /// Total des points (Σ moyenne × coefficient), arrondi ; null pour l'année.
  final int? total;

  /// Moyenne exacte (centièmes) ; null : pas de moyenne (non classé).
  final Fraction? exacte;

  /// Moyenne affichée (centièmes, arrondie).
  final int? moyenne;

  /// École privée : matières où une seule des deux notes existe.
  final Set<String> uneSeuleNote;
  int? rang;
  bool exAequo = false;
  String? mention;

  /// « 1er », « 1re », « 2e », « 3e ex-aequo », « Non classé ».
  String get rangTexte {
    if (rang == null) return 'Non classé';
    final r = rang == 1 ? (eleve.fille ? '1re' : '1er') : '${rang}e';
    return exAequo ? '$r ex-aequo' : r;
  }
}

class Statistiques {
  const new({
    required this.classes,
    required this.effectif,
    this.meilleure,
    this.plusFaible,
    this.moyenneClasse,
  });

  /// Meilleure et plus faible moyenne, moyenne de la classe (moyenne des
  /// moyennes des élèves classés), en centièmes arrondis.
  final int? meilleure;
  final int? plusFaible;
  final int? moyenneClasse;

  /// Élèves classés / élèves de la classe.
  final int classes;
  final int effectif;
}

class Mention {
  const new(this.min, this.max, this.libelle);
  final int min;
  final int max;
  final String libelle;
}

class Classement {
  const new(this.resultats, this.statistiques);

  /// Triés : rang croissant, puis nom ; non classés à la fin.
  final List<Resultat> resultats;
  final Statistiques statistiques;
}

/// Division entière arrondie au plus proche (valeurs positives).
int divArrondi(int a, int b) => (2 * a + b) ~/ (2 * b);

/// Épreuves comptées pour un trimestre : en école publique, les compositions
/// seulement (des évaluations saisies du temps où l'école était privée
/// restent enregistrées mais ne comptent pas) ; en école privée, évaluation
/// et composition.
List<Composition> epreuvesDuTrimestre(
  List<Composition> toutes,
  int trimestre,
  TypeEcole type,
) => [
  for (final c in toutes)
    if (c.trimestre == trimestre &&
        (type == TypeEcole.privee || c.type == TypeEpreuve.composition))
      c,
];

/// Classement d'un trimestre selon le type d'école.
Classement classementTrimestre({
  required TypeEcole type,
  required int trimestre,
  required List<Eleve> eleves,
  required List<Matiere> matieres,
  required List<Composition> compositions,
  required List<Note> notes,
  required RegleAbsent regle,
  int echelle = 1000,
  List<Mention> mentions = const [],
}) => calculerClassement(
  eleves: eleves,
  matieres: matieres,
  compositions: epreuvesDuTrimestre(compositions, trimestre, type),
  notes: notes,
  regle: regle,
  echelle: echelle,
  mentions: mentions,
  signalerUneSeuleNote: type == TypeEcole.privee,
);

/// Classement de l'année : moyenne annuelle = (T1 + T2 + T3) ÷ 3, à partir
/// des moyennes EXACTES des trimestres ; un élève sans les trois moyennes
/// n'a pas de moyenne annuelle (« Non classé »). Colonnes : « t1 », « t2 »,
/// « t3 ».
Classement classementAnnuel({
  required TypeEcole type,
  required List<Eleve> eleves,
  required List<Matiere> matieres,
  required List<Composition> compositions,
  required List<Note> notes,
  required RegleAbsent regle,
  int echelle = 1000,
  List<Mention> mentions = const [],
}) {
  final parTrimestre = [
    for (final t in const [1, 2, 3])
      {
        for (final r in classementTrimestre(
          type: type,
          trimestre: t,
          eleves: eleves,
          matieres: matieres,
          compositions: compositions,
          notes: notes,
          regle: regle,
          echelle: echelle,
        ).resultats)
          r.eleve.id: r,
      },
  ];
  final resultats = [
    for (final e in eleves)
      () {
        final t = [for (final p in parTrimestre) p[e.id]?.exacte];
        final complet = t.every((x) => x != null);
        return Resultat(
          e,
          {for (final (i, x) in t.indexed) 't${i + 1}': x?.arrondi()},
          null,
          complet ? (t[0]! + t[1]! + t[2]!).divisePar(3) : null,
        );
      }(),
  ];
  return _classer(resultats, eleves.length, mentions);
}

/// Calcule le classement sur [compositions] (les épreuves d'un trimestre, ou
/// toute autre sélection).
///
/// Moyenne d'une matière = moyenne des notes présentes (une note manquante
/// n'est jamais un zéro) ; moyenne générale = Σ(moyenne × coef) ÷ Σ coef.
/// [echelle] : barème commun de l'école (en centièmes, 10 → 1000) ; une note
/// sur un autre barème y est ramenée (12/20 → 6/10).
Classement calculerClassement({
  required List<Eleve> eleves,
  required List<Matiere> matieres,
  required List<Composition> compositions,
  required List<Note> notes,
  required RegleAbsent regle,
  int echelle = 1000,
  List<Mention> mentions = const [],
  bool signalerUneSeuleNote = false,
}) {
  final compos = {for (final c in compositions) c.id: c};
  final parEleve = <String, List<Note>>{};
  for (final n in notes) {
    if (compos.containsKey(n.compositionId)) {
      (parEleve[n.eleveId] ??= []).add(n);
    }
  }
  final resultats = <Resultat>[];
  for (final e in eleves) {
    final siennes = parEleve[e.id] ?? const <Note>[];
    final moyennes = <String, int?>{};
    final seules = <String>{};
    var pondere = Fraction.zero; // Σ moyenne × coef (centièmes²)
    var coefs = 0;
    for (final m in matieres) {
      var somme = Fraction.zero;
      var nombre = 0;
      for (final n in siennes.where((n) => n.matiereId == m.id)) {
        switch (n.statut) {
          case StatutNote.note when n.valeur != null:
            final bareme = compos[n.compositionId]!.bareme;
            somme += Fraction.de(n.valeur! * echelle, bareme);
            nombre++;
          case StatutNote.absent when regle == RegleAbsent.zero:
            nombre++;
          case StatutNote.note:
          case StatutNote.absent:
          case StatutNote.dispense:
            break; // note vide, absence non comptée, dispense
        }
      }
      if (nombre == 0) {
        moyennes[m.id] = null;
        continue;
      }
      final moy = somme.divisePar(nombre);
      moyennes[m.id] = moy.arrondi();
      if (signalerUneSeuleNote && nombre == 1) seules.add(m.id);
      if (m.coefficient > 0) {
        pondere += moy.fois(m.coefficient);
        coefs += m.coefficient;
      }
    }
    resultats.add(
      Resultat(
        e,
        moyennes,
        pondere.divisePar(100).arrondi(),
        coefs == 0 ? null : pondere.divisePar(coefs),
        uneSeuleNote: seules,
      ),
    );
  }
  return _classer(resultats, eleves.length, mentions);
}

/// Rangs (sur la moyenne AFFICHÉE : deux moyennes affichées égales sont
/// ex-aequo ; le suivant reprend le rang réel), mentions, statistiques.
Classement _classer(
  List<Resultat> resultats,
  int effectif,
  List<Mention> mentions,
) {
  final classes = resultats.where((r) => r.moyenne != null).toList()
    ..sort((a, b) {
      final c = b.moyenne!.compareTo(a.moyenne!);
      return c != 0 ? c : a.eleve.nom.compareTo(b.eleve.nom);
    });
  for (var i = 0; i < classes.length; i++) {
    final r = classes[i];
    r.rang = i > 0 && classes[i - 1].moyenne == r.moyenne
        ? classes[i - 1].rang
        : i + 1;
    r.exAequo =
        (i > 0 && classes[i - 1].moyenne == r.moyenne) ||
        (i + 1 < classes.length && classes[i + 1].moyenne == r.moyenne);
    r.mention = mentions
        .where((m) => r.moyenne! >= m.min && r.moyenne! <= m.max)
        .firstOrNull
        ?.libelle;
  }
  final nonClasses = resultats.where((r) => r.moyenne == null).toList()
    ..sort((a, b) => a.eleve.nom.compareTo(b.eleve.nom));
  var somme = Fraction.zero;
  for (final r in classes) {
    somme += r.exacte!;
  }
  return Classement(
    [...classes, ...nonClasses],
    Statistiques(
      meilleure: classes.firstOrNull?.moyenne,
      plusFaible: classes.lastOrNull?.moyenne,
      moyenneClasse: classes.isEmpty
          ? null
          : somme.divisePar(classes.length).arrondi(),
      classes: classes.length,
      effectif: effectif,
    ),
  );
}

/// Meilleure et plus faible note d'une matière pour une composition
/// (notes saisies seulement), en centièmes.
(int?, int?) extremesMatiere(
  List<Note> notes,
  String matiereId,
  String compositionId,
) {
  final v = [
    for (final n in notes)
      if (n.matiereId == matiereId &&
          n.compositionId == compositionId &&
          n.statut == StatutNote.note &&
          n.valeur != null)
        n.valeur!,
  ];
  if (v.isEmpty) return (null, null);
  v.sort();
  return (v.last, v.first);
}

/// 1450 → « 14,5 » ; 700 → « 7 » ; 1425 → « 14,25 ».
String centiemesTexte(int? c) {
  if (c == null) return '—';
  final entier = c ~/ 100;
  final reste = c % 100;
  if (reste == 0) return '$entier';
  return reste % 10 == 0
      ? '$entier,${reste ~/ 10}'
      : '$entier,${reste.toString().padLeft(2, '0')}';
}

/// « 14,5 », « 14.5 », « 14 » → 1450 ; null si illisible.
int? centiemesDepuis(String texte) {
  final t = texte.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(t)) return null;
  final parts = t.split('.');
  final dec = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));
  return int.parse(parts[0]) * 100 + dec;
}
