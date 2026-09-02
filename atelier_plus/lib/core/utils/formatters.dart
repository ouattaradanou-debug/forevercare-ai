import 'package:intl/intl.dart';

/// Formatage des montants (FCFA) et des dates en français, centralisé pour
/// garantir une présentation cohérente dans toute l'application — public
/// cible peu technophile, donc des libellés simples et sans ambiguïté.
class Formatters {
  const Formatters._();

  static final NumberFormat _formatMontant = NumberFormat.decimalPattern('fr_FR');

  static final DateFormat _formatDateCourte = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final DateFormat _formatDateLongue = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
  static final DateFormat _formatHeure = DateFormat('HH:mm', 'fr_FR');
  static final DateFormat _formatDateHeure = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');

  /// Ex : "25 000 FCFA".
  static String montant(num valeur) => '${_formatMontant.format(valeur)} FCFA';

  /// Ex : "02/09/2026".
  static String dateCourte(DateTime date) => _formatDateCourte.format(date);

  /// Ex : "mercredi 2 septembre 2026".
  static String dateLongue(DateTime date) => _formatDateLongue.format(date);

  /// Ex : "14:30".
  static String heure(DateTime date) => _formatHeure.format(date);

  /// Ex : "02/09/2026 à 14:30".
  static String dateHeure(DateTime date) => _formatDateHeure.format(date);
}
