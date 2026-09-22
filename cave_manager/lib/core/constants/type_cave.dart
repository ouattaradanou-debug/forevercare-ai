/// Type de cave choisi à la configuration initiale (point 1 du cahier des
/// charges). Synchronisé avec `public.type_cave` côté Supabase.
enum TypeCave {
  vin('vin', 'Cave à vin'),
  boissonsDiverses('boissons_diverses', 'Cave à boissons diverses'),
  vinEtBoissonsDiverses('vin_et_boissons', 'Cave à vin + boissons diverses');

  const TypeCave(this.nomPostgres, this.libelle);

  final String nomPostgres;
  final String libelle;

  static TypeCave depuisPostgres(String valeur) {
    return TypeCave.values.firstWhere(
      (t) => t.nomPostgres == valeur,
      orElse: () => throw ArgumentError('Type de cave inconnu : $valeur'),
    );
  }
}
