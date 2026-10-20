/// Ce qui disparaît quand un module est désactivé (affiché avant de confirmer).
const Map<String, List<String>> elementsMasques = {
  'maternelle': [
    'les classes de maternelle',
    'les domaines d’apprentissage',
    'les livrets d’évaluation',
  ],
  'cantine': [
    'les élèves bénéficiaires de la cantine',
    'le pointage des repas',
    'le stock de vivres et les menus',
    'les cotisations de cantine',
  ],
  'medico_scolaire': ['les fiches médico-scolaires des élèves'],
};

const avertissementMedical =
    'Ce module enregistre des données de santé d’enfants. Elles ne seront '
    'visibles que par le directeur, ne seront jamais envoyées à l’assistant '
    'IA et ne figureront dans aucun rapport général. Informez les parents '
    'avant de remplir les fiches.';

/// Au moins un niveau (primaire ou maternelle) doit rester géré.
bool niveauxValides({required bool primaire, required bool maternelle}) =>
    primaire || maternelle;

/// Un module est réellement actif si son module requis l'est aussi.
bool moduleActif(
  String key,
  Map<String, bool> etats,
  Map<String, String?> dependances,
) {
  if (!(etats[key] ?? false)) return false;
  final requis = dependances[key];
  return requis == null || moduleActif(requis, etats, dependances);
}

/// Droits délégables, avec leur intitulé en français simple.
const Map<String, String> droitsDelegables = {
  'finances': 'Finances (encaissements, reçus, dépenses)',
  'cartes': 'Cartes scolaires',
  'eleves': 'Fiches des élèves',
  'registres': 'Registres et personnel',
  'formulaires': 'Formulaires officiels et en-têtes',
  'archives': 'Archives',
  'cantine': 'Cantine',
};

/// Droits proposés à l'écran : ceux d'un module désactivé n'apparaissent pas.
List<String> droitsVisibles({required bool cantineActive}) => [
  for (final k in droitsDelegables.keys)
    if (k != 'cantine' || cantineActive) k,
];
