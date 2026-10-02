import '../../../data/models/depense.dart';
import '../../../data/models/paiement.dart';

/// Recettes/dépenses cumulées sur une période — calcul pur, testable sans
/// dépendance réseau/base de données (même esprit que `etat_abonnement.dart`).
class RecapitulatifPeriode {
  const RecapitulatifPeriode({required this.recettes, required this.depenses});

  final double recettes;
  final double depenses;

  double get solde => recettes - depenses;
}

/// Début (inclus) du jour, de la semaine (lundi) ou du mois contenant
/// [date], en heure locale.
DateTime debutDuJour(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime debutDeLaSemaine(DateTime date) {
  final jour = debutDuJour(date);
  return jour.subtract(Duration(days: jour.weekday - 1));
}

DateTime debutDuMois(DateTime date) => DateTime(date.year, date.month);

DateTime debutDeLAnnee(DateTime date) => DateTime(date.year);

double _sommePaiements(List<Paiement> paiements, DateTime debut, DateTime finExclusive) {
  var total = 0.0;
  for (final p in paiements) {
    final local = p.datePaiement.toLocal();
    if (!local.isBefore(debut) && local.isBefore(finExclusive)) total += p.montant;
  }
  return total;
}

double _sommeDepenses(List<Depense> depenses, DateTime debut, DateTime finExclusive) {
  var total = 0.0;
  for (final d in depenses) {
    if (!d.date.isBefore(debut) && d.date.isBefore(finExclusive)) total += d.montant;
  }
  return total;
}

RecapitulatifPeriode calculerPeriode({
  required List<Paiement> paiements,
  required List<Depense> depenses,
  required DateTime debut,
  required DateTime finExclusive,
}) {
  return RecapitulatifPeriode(
    recettes: _sommePaiements(paiements, debut, finExclusive),
    depenses: _sommeDepenses(depenses, debut, finExclusive),
  );
}

/// Les quatre lignes affichées en haut de l'écran "Suivi des finances" :
/// jour, semaine, mois et année en cours.
class RecapitulatifGlobal {
  const RecapitulatifGlobal({
    required this.jour,
    required this.semaine,
    required this.mois,
    required this.annee,
  });

  final RecapitulatifPeriode jour;
  final RecapitulatifPeriode semaine;
  final RecapitulatifPeriode mois;
  final RecapitulatifPeriode annee;
}

RecapitulatifGlobal calculerRecapitulatifGlobal({
  required List<Paiement> paiements,
  required List<Depense> depenses,
  DateTime? maintenant,
}) {
  final now = maintenant ?? DateTime.now();
  final finJour = debutDuJour(now).add(const Duration(days: 1));
  final finSemaine = debutDeLaSemaine(now).add(const Duration(days: 7));
  final finMois = DateTime(now.year, now.month + 1);
  final finAnnee = DateTime(now.year + 1);

  return RecapitulatifGlobal(
    jour: calculerPeriode(
      paiements: paiements,
      depenses: depenses,
      debut: debutDuJour(now),
      finExclusive: finJour,
    ),
    semaine: calculerPeriode(
      paiements: paiements,
      depenses: depenses,
      debut: debutDeLaSemaine(now),
      finExclusive: finSemaine,
    ),
    mois: calculerPeriode(
      paiements: paiements,
      depenses: depenses,
      debut: debutDuMois(now),
      finExclusive: finMois,
    ),
    annee: calculerPeriode(
      paiements: paiements,
      depenses: depenses,
      debut: debutDeLAnnee(now),
      finExclusive: finAnnee,
    ),
  );
}

/// Une ligne par mois de [annee] (index 0 = janvier ... 11 = décembre).
List<RecapitulatifPeriode> calculerRecapitulatifMensuel({
  required List<Paiement> paiements,
  required List<Depense> depenses,
  required int annee,
}) {
  return List.generate(12, (index) {
    final mois = index + 1;
    return calculerPeriode(
      paiements: paiements,
      depenses: depenses,
      debut: DateTime(annee, mois),
      finExclusive: DateTime(annee, mois + 1),
    );
  });
}
