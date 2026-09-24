/// Statut d'une commande (point 5 — Phase 3 du cahier des charges).
///
/// `validee` existe dès ce schéma pour préparer la Phase 4 (contrôle/
/// validation, qui décrémente le stock), mais aucune transition vers ce
/// statut n'est encore possible : la policy RLS `commandes_update` de
/// cette phase autorise uniquement `en_attente` -> `annulee`. Synchronisé
/// avec `public.statut_commande` côté Supabase.
enum StatutCommande {
  enAttente('en_attente', 'En attente'),
  validee('validee', 'Validée'),
  annulee('annulee', 'Annulée');

  const StatutCommande(this.nomPostgres, this.libelle);

  final String nomPostgres;
  final String libelle;

  static StatutCommande depuisPostgres(String valeur) {
    return StatutCommande.values.firstWhere(
      (s) => s.nomPostgres == valeur,
      orElse: () => throw ArgumentError('Statut de commande inconnu : $valeur'),
    );
  }
}
