/// Texte comparable : minuscules, sans accents ni signes.
String normaliser(String s) {
  const accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', //
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i',
    'ô': 'o', 'ö': 'o', 'ó': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
    'ç': 'c', 'ÿ': 'y', 'œ': 'oe', 'æ': 'ae',
  };
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    b.write(accents[c] ?? c);
  }
  return b.toString().replaceAll(RegExp('[^a-z0-9]+'), ' ').trim();
}

/// Vrai si chaque mot de [requete] commence un mot de l'un des [textes]
/// (« aich tes » trouve « TEST Aïcha »).
bool correspond(String requete, Iterable<String?> textes) {
  final mots = normaliser(requete).split(' ').where((m) => m.isNotEmpty);
  if (mots.isEmpty) return false;
  final cible = [
    for (final t in textes)
      if (t != null) ...normaliser(t).split(' '),
  ];
  return mots.every((m) => cible.any((c) => c.startsWith(m)));
}

/// Catégories de la recherche rapide, dans l'ordre d'affichage.
enum TypeResultat {
  eleve('Élèves'),
  enseignant('Enseignants'),
  classe('Classes'),
  preparation('Mes fiches de préparation'),
  resultat('Résultats');

  new(this.titre);
  final String titre;
}

class ResultatRecherche {
  const new(this.type, this.titre, this.route, {this.detail, this.extra});
  final TypeResultat type;
  final String titre;
  final String? detail;
  final String route;
  final Object? extra;
}
