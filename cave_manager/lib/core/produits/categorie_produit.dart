/// Une catégorie de boissons (Bières, Vins rouges, ...), propre à une cave
/// et personnalisable (ajout, suppression si vide, masquage) — voir
/// `categories_produits` côté Supabase, qui remplace un enum fermé pour
/// permettre à l'utilisateur d'en ajouter sans nouvelle version de l'app.
class CategorieProduit {
  const CategorieProduit({
    required this.id,
    required this.caveId,
    required this.nom,
    required this.ordre,
    required this.visible,
  });

  final String id;
  final String caveId;
  final String nom;
  final int ordre;
  final bool visible;

  factory CategorieProduit.depuisJson(Map<String, dynamic> json) {
    return CategorieProduit(
      id: json['id'] as String,
      caveId: json['cave_id'] as String,
      nom: json['nom'] as String,
      ordre: json['ordre'] as int,
      visible: json['visible'] as bool,
    );
  }
}
