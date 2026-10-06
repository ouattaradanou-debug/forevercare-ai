import 'categorie_vente.dart';

/// Modèle miroir de la table `articles` — un article du catalogue suivi en
/// stock (prêt-à-porter, tissu ou article de couture). `quantiteStock` est
/// la source de vérité du "reste en stock", décrémentée automatiquement à
/// chaque vente qui référence cet article.
class Article {
  const Article({
    required this.id,
    required this.atelierId,
    required this.categorie,
    required this.nom,
    required this.prixUnitaireDefaut,
    required this.quantiteStock,
    required this.seuilAlerte,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final CategorieVente categorie;
  final String nom;
  final double prixUnitaireDefaut;
  final double quantiteStock;
  final double seuilAlerte;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Vrai quand il est temps de réapprovisionner — affiché en alerte sur
  /// l'écran "Gestion du stock".
  bool get stockBas => quantiteStock <= seuilAlerte;

  factory Article.depuisJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      categorie: CategorieVente.depuisJson(json['categorie'] as String),
      nom: json['nom'] as String,
      // Voir Commande.depuisJson : double.parse(toString()) tolère un
      // `numeric` PostgREST renvoyé en nombre ou en texte.
      prixUnitaireDefaut: double.parse(json['prix_unitaire_defaut'].toString()),
      quantiteStock: double.parse(json['quantite_stock'].toString()),
      seuilAlerte: double.parse(json['seuil_alerte'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'categorie': categorie.valeurJson,
      'nom': nom,
      'prix_unitaire_defaut': prixUnitaireDefaut,
      'quantite_stock': quantiteStock,
      'seuil_alerte': seuilAlerte,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
