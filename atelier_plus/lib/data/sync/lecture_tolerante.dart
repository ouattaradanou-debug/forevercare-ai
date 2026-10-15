/// Applique [traiter] à chaque élément de [lignes] reçu du serveur, en
/// isolant les erreurs ligne par ligne : une ligne malformée (ex. un
/// enregistrement ancien à qui il manque une colonne ajoutée plus tard,
/// comme `updated_at` sur certaines mesures) est ignorée plutôt que de
/// faire échouer tout le rapatriement.
///
/// Sans cela, UNE SEULE ligne de ce type ferait disparaître toutes les
/// AUTRES lignes reçues dans le même lot — qui avaient pourtant bien été
/// récupérées du serveur, comme vécu concrètement avec les mesures : des
/// clients voyaient leurs mesures "manquantes" alors qu'elles existaient
/// bien côté serveur, simplement parce qu'une autre ligne du même
/// rapatriement ne s'était pas laissée convertir.
///
/// Utilisé par tous les `chargerDepuisServeur` de l'application plutôt que
/// la boucle `for` directe qu'ils utilisaient auparavant.
Future<void> pourChaqueLigne<T>(
  Iterable<T> lignes,
  Future<void> Function(T ligne) traiter,
) async {
  for (final ligne in lignes) {
    try {
      await traiter(ligne);
    } catch (_) {
      // Ligne ignorée : voir la remarque ci-dessus. Les autres lignes du
      // lot continuent d'être traitées normalement.
    }
  }
}
