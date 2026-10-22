import 'package:flutter/foundation.dart' show immutable;

/// Ancienneté (B1) : durée calendaire entre la date de départ saisie par le
/// directeur et une date de référence choisie (par défaut le 31 décembre de
/// l'année en cours ; paramétrable sur la fiche B1).
///
/// Règle retenue (à valider avec le directeur, R8) : années, mois et jours
/// révolus, comme on compte un âge. Aucune règle officielle n'est inventée :
/// les interruptions de service ne sont PAS déduites automatiquement.
@immutable
class Anciennete {
  const new(this.ans, this.mois, this.jours);

  final int ans;
  final int mois;
  final int jours;

  /// null si la date de départ manque ou est postérieure à la référence.
  static Anciennete? entre(DateTime? depart, DateTime reference) {
    if (depart == null) return null;
    final d = DateTime.utc(depart.year, depart.month, depart.day);
    final r = DateTime.utc(reference.year, reference.month, reference.day);
    if (d.isAfter(r)) return null;
    // Plus grand nombre de mois entiers m tel que départ + m mois ≤ référence
    // (le jour est ramené au dernier jour du mois si besoin : 31/01 + 1 mois
    // = 29/02).
    var m = (r.year - d.year) * 12 + r.month - d.month;
    if (_plusMois(d, m).isAfter(r)) m -= 1;
    final ans = m ~/ 12;
    final mois = m % 12;
    final jours = r.difference(_plusMois(d, m)).inDays;
    return Anciennete(ans, mois, jours);
  }

  static DateTime _plusMois(DateTime d, int m) {
    final total = d.year * 12 + d.month - 1 + m;
    final annee = total ~/ 12;
    final mois = total % 12 + 1;
    final dernier = DateTime.utc(annee, mois + 1, 0).day;
    return DateTime.utc(annee, mois, d.day > dernier ? dernier : d.day);
  }

  /// « 12 ans 3 mois », « 8 mois 4 j », « 0 j ».
  String get texte {
    final parts = [
      if (ans > 0) '$ans an${ans > 1 ? 's' : ''}',
      if (mois > 0) '$mois mois',
      if (jours > 0 || (ans == 0 && mois == 0)) '$jours j',
    ];
    return parts.join(' ');
  }

  @override
  bool operator ==(Object other) =>
      other is Anciennete &&
      other.ans == ans &&
      other.mois == mois &&
      other.jours == jours;

  @override
  int get hashCode => Object.hash(ans, mois, jours);

  @override
  String toString() => texte;
}

/// Date de référence par défaut : 31 décembre de l'année de [aujourdhui].
DateTime referenceParDefaut(DateTime aujourdhui) =>
    DateTime(aujourdhui.year, 12, 31);
