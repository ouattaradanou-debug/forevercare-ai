/// Notes, moyennes et classement (module 6 de l'ANNEXE A).
///
/// Tous les calculs se font en CENTIÈMES ENTIERS (14,5 → 1450) : aucune
/// erreur d'arrondi due aux nombres à virgule. Arrondi « au plus proche »
/// (0,005 → 0,01), à chaque étape affichée, comme un calcul fait à la main :
///   moyenne par matière (arrondie) → total des points (arrondi)
///   → moyenne générale = total ÷ Σ coefficients (arrondie).
library;

enum StatutNote { note, absent, dispense }

/// Règle de l'élève absent, choisie par l'école (`schools.absent_rule`).
enum RegleAbsent {
  /// L'absence n'est pas comptée : « Abs. », la matière est calculée sur les
  /// autres compositions (ou exclue s'il n'y en a pas).
  nonCompte,

  /// L'absence compte pour zéro.
  zero,
}

class Matiere {
  const new(this.id, this.nom, this.coefficient);
  final String id;
  final String nom;

  /// En centièmes (1 → 100 ; 0,5 → 50).
  final int coefficient;
}

class Composition {
  const new(this.id, this.libelle, this.bareme);
  final String id;
  final String libelle;

  /// Note maximale, en centièmes (10 → 1000).
  final int bareme;
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

/// Résultat d'un élève (tout en centièmes).
class Resultat {
  new(this.eleve, this.moyennesMatieres, this.total, this.moyenne);
  final Eleve eleve;

  /// matière → moyenne (null : aucune note dans la matière).
  final Map<String, int?> moyennesMatieres;
  final int total;

  /// null : aucune note comptée (élève non classé).
  final int? moyenne;
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

  /// Meilleure et plus faible moyenne générale, moyenne de la classe
  /// (moyenne des moyennes générales), en centièmes.
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

/// Calcule le classement d'une classe sur [compositions] (une seule pour un
/// classement « par composition », toutes pour le « cumul »).
///
/// [echelle] : barème commun de l'école (en centièmes, 10 → 1000) ; une note
/// sur un autre barème est ramenée à cette échelle (12/20 → 6/10).
Classement calculerClassement({
  required List<Eleve> eleves,
  required List<Matiere> matieres,
  required List<Composition> compositions,
  required List<Note> notes,
  required RegleAbsent regle,
  int echelle = 1000,
  List<Mention> mentions = const [],
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
    var total = 0;
    var coefs = 0;
    for (final m in matieres) {
      final valeurs = <int>[];
      for (final n in siennes.where((n) => n.matiereId == m.id)) {
        switch (n.statut) {
          case StatutNote.note when n.valeur != null:
            final bareme = compos[n.compositionId]!.bareme;
            valeurs.add(
              bareme == echelle
                  ? n.valeur!
                  : divArrondi(n.valeur! * echelle, bareme),
            );
          case StatutNote.absent when regle == RegleAbsent.zero:
            valeurs.add(0);
          case StatutNote.note:
          case StatutNote.absent:
          case StatutNote.dispense:
            break; // note vide, absence non comptée, dispense
        }
      }
      final moy = valeurs.isEmpty
          ? null
          : divArrondi(valeurs.fold(0, (a, b) => a + b), valeurs.length);
      moyennes[m.id] = moy;
      if (moy != null && m.coefficient > 0) {
        total += moy * m.coefficient; // centièmes × centièmes
        coefs += m.coefficient;
      }
    }
    final totalCentiemes = divArrondi(total, 100);
    resultats.add(
      Resultat(
        e,
        moyennes,
        totalCentiemes,
        coefs == 0 ? null : divArrondi(totalCentiemes * 100, coefs),
      ),
    );
  }

  // Rang : même moyenne = même rang ; le suivant reprend le rang réel.
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
  final moyennes = [for (final r in classes) r.moyenne!];
  return Classement(
    [...classes, ...nonClasses],
    Statistiques(
      meilleure: moyennes.isEmpty ? null : moyennes.first,
      plusFaible: moyennes.isEmpty ? null : moyennes.last,
      moyenneClasse: moyennes.isEmpty
          ? null
          : divArrondi(moyennes.fold(0, (a, b) => a + b), moyennes.length),
      classes: classes.length,
      effectif: eleves.length,
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
