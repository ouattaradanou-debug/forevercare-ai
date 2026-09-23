/// Type d'emballage d'un produit (carton ou casier), choisi à la création
/// du produit. Détermine le libellé affiché pour le nombre de bouteilles
/// par emballage et pour le stock correspondant. Synchronisé avec
/// `public.type_emballage` côté Supabase.
enum TypeEmballage {
  carton('carton', 'Carton'),
  casier('casier', 'Casier');

  const TypeEmballage(this.nomPostgres, this.libelle);

  final String nomPostgres;
  final String libelle;

  static TypeEmballage depuisPostgres(String valeur) {
    return TypeEmballage.values.firstWhere(
      (t) => t.nomPostgres == valeur,
      orElse: () => throw ArgumentError('Type d\'emballage inconnu : $valeur'),
    );
  }
}
