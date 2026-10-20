/// Année scolaire proposée par défaut : à partir de septembre, l'année qui
/// commence ; avant, celle qui se termine (hypothèse : rentrée en octobre).
String anneeScolaireProposee(DateTime date) {
  final debut = date.month >= 9 ? date.year : date.year - 1;
  return '$debut-${debut + 1}';
}

/// « 2025-2026 » → « 2026-2027 ».
String anneeSuivante(String label) {
  final m = RegExp(r'^(\d{4})-(\d{4})$').firstMatch(label);
  if (m == null) throw FormatException('Année scolaire invalide : $label');
  final debut = int.parse(m.group(1)!) + 1;
  return '$debut-${debut + 1}';
}

bool anneeScolaireValide(String label) {
  final m = RegExp(r'^(\d{4})-(\d{4})$').firstMatch(label.trim());
  return m != null && int.parse(m.group(2)!) == int.parse(m.group(1)!) + 1;
}
