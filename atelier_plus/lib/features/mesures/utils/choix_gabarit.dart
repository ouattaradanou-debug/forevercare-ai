import '../../../data/models/type_tenue.dart';

/// Choisit, parmi les gabarits visibles, celui à utiliser pour [sexe] dans
/// un flux sans sélecteur explicite (Nouveau client, fiche client) : la
/// copie propre à l'atelier si elle existe (reflète les modifications
/// faites dans "Champs de mesure"), sinon le gabarit par défaut partagé.
TypeTenue? choisirGabaritPourSexe(List<TypeTenue> liste, String atelierId, String sexe) {
  TypeTenue? propre;
  TypeTenue? parDefaut;
  for (final type in liste) {
    if (type.sexe != sexe) continue;
    if (type.atelierId == atelierId) {
      propre = type;
    } else if (type.estGabaritParDefaut) {
      parDefaut = type;
    }
  }
  return propre ?? parDefaut;
}
