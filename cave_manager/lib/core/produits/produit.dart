import '../constants/type_emballage.dart';

/// Un produit du catalogue (point 5 du cahier des charges).
///
/// Ne contient volontairement pas le prix d'achat — voir `produits_couts`,
/// stocké dans une table séparée avec ses propres règles d'accès
/// (Propriétaire/Propriétaire-Gérant/Gérant, jamais l'Agent de vente).
class Produit {
  const Produit({
    required this.id,
    required this.caveId,
    required this.categorieId,
    required this.nom,
    required this.prixVenteDetail,
    required this.prixVenteGros,
    required this.typeEmballage,
    required this.bouteillesParEmballage,
    required this.actif,
  });

  final String id;
  final String caveId;
  final String categorieId;
  final String nom;
  final int prixVenteDetail;
  final int prixVenteGros;

  /// Carton ou casier — détermine le libellé affiché pour le stock et pour
  /// [bouteillesParEmballage].
  final TypeEmballage typeEmballage;
  final int bouteillesParEmballage;
  final bool actif;

  factory Produit.depuisJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] as String,
      caveId: json['cave_id'] as String,
      categorieId: json['categorie_id'] as String,
      nom: json['nom'] as String,
      prixVenteDetail: json['prix_vente_detail'] as int,
      prixVenteGros: json['prix_vente_gros'] as int,
      typeEmballage: TypeEmballage.depuisPostgres(json['type_emballage'] as String),
      bouteillesParEmballage: json['bouteilles_par_emballage'] as int,
      actif: json['actif'] as bool,
    );
  }
}
