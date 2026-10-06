/// Catégorie d'une vente directe (hors commande de couture sur mesure).
/// Les valeurs JSON doivent rester synchronisées avec le CHECK constraint
/// `ventes.categorie` du schéma SQL.
enum CategorieVente {
  pretAPorter,
  tissu,
  articleCouture;

  static CategorieVente depuisJson(String valeur) {
    return CategorieVente.values.firstWhere(
      (c) => c.valeurJson == valeur,
      orElse: () => throw ArgumentError('Catégorie de vente inconnue : $valeur'),
    );
  }

  String get valeurJson => switch (this) {
        CategorieVente.pretAPorter => 'pret_a_porter',
        CategorieVente.tissu => 'tissu',
        CategorieVente.articleCouture => 'article_couture',
      };

  String get libelle => switch (this) {
        CategorieVente.pretAPorter => 'Prêt-à-porter',
        CategorieVente.tissu => 'Tissu',
        CategorieVente.articleCouture => 'Article de couture',
      };

  /// Unité dans laquelle se compte la quantité vendue : un tissu se vend au
  /// mètre, le prêt-à-porter et les articles de couture à la pièce.
  String get uniteLabel => switch (this) {
        CategorieVente.tissu => 'mètre',
        CategorieVente.pretAPorter || CategorieVente.articleCouture => 'pièce',
      };

  /// Exemple affiché en indication dans le champ "désignation" du
  /// formulaire d'enregistrement, pour guider un tailleur peu technophile.
  String get exempleDesignation => switch (this) {
        CategorieVente.pretAPorter => 'Ex : Robe rouge taille M',
        CategorieVente.tissu => 'Ex : Wax bleu motif fleurs',
        CategorieVente.articleCouture => 'Ex : Fermeture éclair 20 cm',
      };
}
