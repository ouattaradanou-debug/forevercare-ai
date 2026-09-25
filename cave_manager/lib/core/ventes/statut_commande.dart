/// Statut d'une commande (point 5 — Phase 3 du cahier des charges).
///
/// `validee` (transition `en_attente` -> `validee`, réservée aux
/// responsables) décrémente automatiquement le stock côté serveur —
/// voir la policy RLS `commandes_update` et le trigger
/// `appliquer_validation_commande` (migration 0014, Phase 4). Synchronisé
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
