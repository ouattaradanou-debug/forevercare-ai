/// Un produit du catalogue (point 5 du cahier des charges).
///
/// Ne contient volontairement pas le prix d'achat — voir [InfosCout],
/// stocké dans une table séparée (`produits_couts`) avec ses propres
/// règles d'accès (Propriétaire/Propriétaire-Gérant uniquement).
class Produit {
  const Produit({
    required this.id,
    required this.caveId,
    required this.nom,
    required this.prixVenteDetail,
    required this.prixVenteGros,
    required this.bouteillesParCarton,
    required this.actif,
  });

  final String id;
  final String caveId;
  final String nom;
  final int prixVenteDetail;
  final int prixVenteGros;
  final int bouteillesParCarton;
  final bool actif;

  factory Produit.depuisJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] as String,
      caveId: json['cave_id'] as String,
      nom: json['nom'] as String,
      prixVenteDetail: json['prix_vente_detail'] as int,
      prixVenteGros: json['prix_vente_gros'] as int,
      bouteillesParCarton: json['bouteilles_par_carton'] as int,
      actif: json['actif'] as bool,
    );
  }
}
