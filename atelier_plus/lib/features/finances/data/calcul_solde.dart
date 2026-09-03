/// Calcul du reste à payer d'une commande.
///
/// Fonction pure, isolée de toute dépendance base de données/réseau
/// spécifiquement pour rester facile à tester unitairement (voir la liste
/// de tests prioritaires de la Phase 5). Peut renvoyer une valeur négative
/// en cas de trop-perçu : ce n'est pas une erreur à masquer ici, c'est à
/// l'écran de décider comment l'afficher (voir EcranFinancesClient).
double resteAPayer({
  required double montantTotal,
  required double avance,
  required double sommePaiements,
}) {
  return montantTotal - avance - sommePaiements;
}
