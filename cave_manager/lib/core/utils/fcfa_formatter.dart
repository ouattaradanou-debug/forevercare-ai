import 'package:intl/intl.dart';

/// Formate un montant entier (FCFA n'a pas de sous-unité) avec séparateur
/// de milliers, ex. `formaterFcfa(12500)` -> `"12 500 FCFA"`.
///
/// Chaque montant affiché dans l'app doit passer par cette fonction
/// (critère de qualité du prompt : devise unique FCFA, séparateur de
/// milliers obligatoire).
String formaterFcfa(int montant) {
  final formatteur = NumberFormat.decimalPattern('fr_FR');
  return '${formatteur.format(montant)} FCFA';
}
