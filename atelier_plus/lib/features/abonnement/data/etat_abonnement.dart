import '../../../data/models/abonnement.dart';

/// Calculs purs sur l'état d'un abonnement — isolés de toute dépendance
/// base de données/réseau pour rester faciles à tester unitairement.
///
/// Important : `statut == 'essai'` n'est PAS automatiquement remplacé par
/// 'expire' quand `date_fin_essai` est dépassée (aucune tâche planifiée
/// côté serveur ne le fait) — c'est ici, côté application, que l'échéance
/// réelle est déterminée en comparant la date actuelle à `date_fin_essai`.

/// Nombre de jours restants avant la fin de l'essai (peut être négatif si
/// déjà dépassé). N'a de sens que si `abonnement.statut == 'essai'`.
int joursRestantsEssai(Abonnement abonnement, {DateTime? maintenant}) {
  final now = maintenant ?? DateTime.now().toUtc();
  return abonnement.dateFinEssai.difference(now).inDays;
}

/// Vrai si l'atelier doit basculer en lecture seule : essai dépassé sans
/// abonnement actif, ou abonnement explicitement expiré/suspendu. Ne
/// bloque jamais un abonnement 'actif'.
bool estEnModeConsultationSeule(Abonnement abonnement, {DateTime? maintenant}) {
  switch (abonnement.statut) {
    case 'actif':
      return false;
    case 'expire':
    case 'suspendu':
      return true;
    case 'essai':
    default:
      final now = maintenant ?? DateTime.now().toUtc();
      return now.isAfter(abonnement.dateFinEssai);
  }
}

/// Vrai si le bandeau de rappel doit être affiché (J-7 à J-1 inclus,
/// tant que l'essai n'est pas terminé).
bool doitAfficherRappelEssai(Abonnement abonnement, {DateTime? maintenant}) {
  if (abonnement.statut != 'essai') return false;
  final jours = joursRestantsEssai(abonnement, maintenant: maintenant);
  return jours >= 0 && jours <= 7;
}
