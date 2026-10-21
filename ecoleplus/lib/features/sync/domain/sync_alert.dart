/// Seuils de l'alerte de synchronisation (paramétrables, hypothèse H23).
class ReglesAlerte {
  const new({
    this.attenteNormale = const Duration(days: 3),
    this.attenteComposition = const Duration(days: 1),
    this.sansNouvelles = const Duration(days: 30),
  });

  /// Données non envoyées depuis plus longtemps que ce délai : alerte.
  final Duration attenteNormale;

  /// Même règle, plus courte, pendant les périodes de composition.
  final Duration attenteComposition;

  /// Rien en attente mais aucune nouvelle du serveur depuis ce délai.
  final Duration sansNouvelles;
}

/// Alerte CONDITIONNELLE (décision du 21/10/2026) : elle ne se déclenche que
/// s'il y a des données non envoyées sur le téléphone (seuil plus court en
/// période de composition) ; sans données en attente, seulement après un
/// long délai sans aucune synchronisation. Renvoie null s'il n'y a rien à dire.
String? alerteSynchronisation({
  required int enAttente,
  required DateTime maintenant,
  DateTime? plusAncienneAttente,
  DateTime? derniereSynchro,
  bool periodeComposition = false,
  ReglesAlerte regles = const ReglesAlerte(),
}) {
  if (enAttente > 0 && plusAncienneAttente != null) {
    final seuil = periodeComposition
        ? regles.attenteComposition
        : regles.attenteNormale;
    final age = maintenant.difference(plusAncienneAttente);
    if (age >= seuil) {
      final elements = enAttente == 1
          ? '1 élément saisi'
          : '$enAttente éléments saisis';
      return '$elements ${_depuis(age)} ne sont pas encore envoyés. '
          'Connectez-vous à Internet pour ne pas les perdre si le téléphone '
          'est perdu ou changé.';
    }
    return null;
  }
  if (enAttente == 0 && derniereSynchro != null) {
    final age = maintenant.difference(derniereSynchro);
    if (age >= regles.sansNouvelles) {
      return 'Ce téléphone n’a pas reçu les nouveautés de l’école '
          '${_depuis(age)}. Connectez-vous à Internet.';
    }
  }
  return null;
}

String _depuis(Duration d) => d.inDays >= 1
    ? 'depuis ${d.inDays} jour${d.inDays > 1 ? 's' : ''}'
    : 'depuis ${d.inHours} heure${d.inHours > 1 ? 's' : ''}';
