/// Une ligne d'une commande (un produit vendu, quantité + prix figés au
/// moment de la vente — voir commentaire de `public.commande_lignes`).
class CommandeLigne {
  const CommandeLigne({
    required this.id,
    required this.commandeId,
    required this.produitId,
    required this.produitNom,
    required this.quantiteCartons,
    required this.quantiteBouteilles,
    required this.prixGrosUnitaire,
    required this.prixDetailUnitaire,
    required this.sousTotal,
  });

  final String id;
  final String commandeId;
  final String produitId;
  final String produitNom;
  final int quantiteCartons;
  final int quantiteBouteilles;
  final int prixGrosUnitaire;
  final int prixDetailUnitaire;
  final int sousTotal;

  /// Attend une ligne obtenue via `.select('*, produits(nom)')` (le nom du
  /// produit vient d'une jointure, la table `commande_lignes` elle-même ne
  /// stocke que `produit_id`).
  factory CommandeLigne.depuisJson(Map<String, dynamic> json) {
    return CommandeLigne(
      id: json['id'] as String,
      commandeId: json['commande_id'] as String,
      produitId: json['produit_id'] as String,
      produitNom: (json['produits'] as Map<String, dynamic>)['nom'] as String,
      quantiteCartons: json['quantite_cartons'] as int,
      quantiteBouteilles: json['quantite_bouteilles'] as int,
      prixGrosUnitaire: json['prix_gros_unitaire'] as int,
      prixDetailUnitaire: json['prix_detail_unitaire'] as int,
      sousTotal: json['sous_total'] as int,
    );
  }
}
