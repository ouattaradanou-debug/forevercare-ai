import 'package:ecoleplus/core/import/tableur.dart';

/// Colonne attendue dans le fichier, reconnue par plusieurs intitulés
/// possibles (sans tenir compte des majuscules, accents et ponctuation).
class Colonne {
  const new(this.cle, this.libelle, this.noms, {this.obligatoire = false});
  final String cle;
  final String libelle;
  final List<String> noms;
  final bool obligatoire;
}

class LigneImport {
  const new(this.numero, this.valeurs);

  /// Numéro de la ligne dans le tableur (comme dans Excel).
  final int numero;
  final Map<String, String?> valeurs;
  String? operator [](String cle) => valeurs[cle];
}

class Remarque {
  const new(this.numero, this.message);
  final int numero;
  final String message;
  @override
  String toString() => 'Ligne $numero : $message';
}

class AnalyseImport {
  const new({
    required this.valides,
    required this.erreurs,
    required this.doublons,
    required this.vides,
    required this.colonnesReconnues,
    required this.colonnesIgnorees,
  });

  /// Lignes prêtes à être importées.
  final List<LigneImport> valides;

  /// Lignes refusées, avec la raison (à corriger dans le fichier).
  final List<Remarque> erreurs;

  /// Lignes ignorées car déjà présentes (dans l'école ou plus haut).
  final List<Remarque> doublons;

  /// Lignes entièrement vides, ignorées.
  final int vides;
  final List<String> colonnesReconnues;
  final List<String> colonnesIgnorees;
}

/// Minuscules, sans accents ni espaces ni ponctuation : « Prénom(s) » →
/// « prenoms ».
String normaliser(String s) {
  const de = 'àâäáãéèêëíìîïóòôöõúùûüçñ';
  const vers = 'aaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = de.indexOf(c);
    final x = i < 0 ? c : vers[i];
    if (RegExp('[a-z0-9]').hasMatch(x)) b.write(x);
  }
  return b.toString();
}

/// Analyse un tableur : repère la ligne d'en-tête, associe les colonnes,
/// ignore les lignes vides, refuse les lignes invalides (avec la raison) et
/// écarte les doublons.
AnalyseImport analyserImport(
  List<List<String?>> lignes, {
  required List<Colonne> colonnes,
  required String? Function(LigneImport l) valider,
  required String? Function(LigneImport l) cleDoublon,
  Set<String> existants = const {},
}) {
  final iEntete = lignes.indexWhere((l) => l.any((c) => c != null));
  if (iEntete < 0) {
    throw const TableurIllisible('Le fichier est vide.');
  }
  final entete = lignes[iEntete];
  final position = <String, int>{};
  final ignorees = <String>[];
  for (final (i, titre) in entete.indexed) {
    if (titre == null) continue;
    final n = normaliser(titre);
    final col = colonnes
        .where((c) => !position.containsKey(c.cle))
        .where((c) => c.noms.any((x) => normaliser(x) == n))
        .firstOrNull;
    if (col == null) {
      ignorees.add(titre);
    } else {
      position[col.cle] = i;
    }
  }
  final manquantes = [
    for (final c in colonnes)
      if (c.obligatoire && !position.containsKey(c.cle)) '« ${c.libelle} »',
  ];
  if (manquantes.isNotEmpty) {
    throw TableurIllisible(
      'Colonne${manquantes.length > 1 ? 's' : ''} introuvable'
      '${manquantes.length > 1 ? 's' : ''} : ${manquantes.join(', ')}. La '
      'première ligne du fichier doit contenir les titres des colonnes.',
    );
  }

  final valides = <LigneImport>[];
  final erreurs = <Remarque>[];
  final doublons = <Remarque>[];
  final vus = <String, int>{};
  var vides = 0;
  for (var i = iEntete + 1; i < lignes.length; i++) {
    final brute = lignes[i];
    final l = LigneImport(i + 1, {
      for (final MapEntry(key: cle, value: p) in position.entries)
        cle: p < brute.length ? brute[p] : null,
    });
    if (l.valeurs.values.every((v) => v == null)) {
      vides++;
      continue;
    }
    final erreur = valider(l);
    if (erreur != null) {
      erreurs.add(Remarque(l.numero, erreur));
      continue;
    }
    final cle = cleDoublon(l);
    if (cle != null && existants.contains(cle)) {
      doublons.add(Remarque(l.numero, 'déjà enregistré dans l’école'));
      continue;
    }
    if (cle != null && vus.containsKey(cle)) {
      doublons.add(
        Remarque(l.numero, 'même personne qu’à la ligne ${vus[cle]}'),
      );
      continue;
    }
    if (cle != null) vus[cle] = l.numero;
    valides.add(l);
  }
  return AnalyseImport(
    valides: valides,
    erreurs: erreurs,
    doublons: doublons,
    vides: vides,
    colonnesReconnues: [
      for (final c in colonnes)
        if (position.containsKey(c.cle)) c.libelle,
    ],
    colonnesIgnorees: ignorees,
  );
}

/// « F », « Fille », « Féminin », « Femme » → F ; « M », « G », « H »,
/// « Garçon », « Masculin », « Homme » → M.
String? sexeDeCellule(String? v) {
  if (v == null) return null;
  final n = normaliser(v);
  if (const {'f', 'fille', 'feminin', 'femme', 'fem'}.contains(n)) return 'F';
  if (const {
    'm',
    'g',
    'h',
    'garcon',
    'masculin',
    'homme',
    'masc',
  }.contains(n)) {
    return 'M';
  }
  return '?';
}
