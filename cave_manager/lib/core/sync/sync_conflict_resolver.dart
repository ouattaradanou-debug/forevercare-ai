/// Issue de la résolution d'un conflit de synchronisation.
enum GagnantConflit { local, distant, identique }

class ResolutionConflit {
  const ResolutionConflit(this.gagnant);
  final GagnantConflit gagnant;
}

/// Règle de résolution de conflit retenue pour la Phase 1 (cas limite
/// explicitement demandé par le prompt : "deux appareils modifient la
/// même donnée hors ligne simultanément").
///
/// **Règle : dernier écrit gagne (Last-Write-Wins), basée sur l'horodatage
/// `updated_at` du serveur.**
///
/// Justification : en Phase 1, les seules données concernées sont
/// déclaratives et non cumulatives (nom/téléphone/localisation de la cave,
/// nom/prénom/téléphone d'un profil). Pour ce type de champ, "le dernier
/// qui a modifié a raison" est un comportement prévisible et sans risque
/// de perte financière.
///
/// **Cette règle ne sera PAS reconduite telle quelle pour les données
/// cumulatives** (quantités de stock, montants de caisse) introduites en
/// Phase 2 et Phase 5 : un LWW naïf sur un compteur ferait perdre l'écart
/// entre deux appareils qui ont chacun décrémenté le stock indépendamment
/// hors ligne. Pour ces tables, la stratégie prévue (à valider en Phase 2)
/// est : applique les deltas des deux appareils de façon additive plutôt
/// que d'en écraser un, puis, si l'écart entre le stock attendu et le
/// stock constaté dépasse un seuil significatif, place la ligne en
/// "réconciliation manuelle" au lieu de la résoudre automatiquement —
/// exactement l'exemple donné dans le prompt d'origine.
ResolutionConflit resoudreConflitDerniereEcriture({
  required DateTime localModifieLe,
  required DateTime distantModifieLe,
}) {
  if (localModifieLe.isAfter(distantModifieLe)) {
    return const ResolutionConflit(GagnantConflit.local);
  }
  if (distantModifieLe.isAfter(localModifieLe)) {
    return const ResolutionConflit(GagnantConflit.distant);
  }
  return const ResolutionConflit(GagnantConflit.identique);
}
