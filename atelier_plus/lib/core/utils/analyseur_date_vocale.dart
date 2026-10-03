/// Analyse un texte français dicté (reconnaissance vocale) pour en extraire
/// une date et une heure de rendez-vous — permet à un tailleur qui ne sait
/// pas écrire de dicter "dans 4 jours à 15h" ou "le 20 mars à 10h30" et
/// d'obtenir directement un DateTime exploitable, sans jamais planter : si
/// rien d'exploitable n'est trouvé, [analyser] retourne `null` et l'écran
/// appelant redemande au tailleur de répéter.
class ResultatAnalyseDateVocale {
  const ResultatAnalyseDateVocale({required this.dateHeure, required this.heureDeduite});

  /// Date et heure du rendez-vous déduites de la dictée.
  final DateTime dateHeure;

  /// true si aucune heure n'a été dictée : [dateHeure] utilise alors une
  /// heure par défaut qu'il faut annoncer comme telle lors de la
  /// confirmation orale au tailleur avant d'enregistrer.
  final bool heureDeduite;
}

class AnalyseurDateVocale {
  const AnalyseurDateVocale._();

  static const _heureParDefaut = 9;

  /// Du plus long au plus court : un remplacement glouton doit essayer
  /// "vingt et un" avant "vingt", sinon "vingt et un" deviendrait "20 et 1".
  static final List<MapEntry<String, int>> _nombres = (() {
    final table = <String, int>{
      'zéro': 0, 'zero': 0,
      'un': 1, 'une': 1,
      'deux': 2, 'trois': 3, 'quatre': 4, 'cinq': 5,
      'six': 6, 'sept': 7, 'huit': 8, 'neuf': 9, 'dix': 10,
      'onze': 11, 'douze': 12, 'treize': 13, 'quatorze': 14, 'quinze': 15,
      'seize': 16, 'dix sept': 17, 'dix huit': 18, 'dix neuf': 19,
      'vingt': 20,
      'vingt et un': 21, 'vingt un': 21,
      'vingt deux': 22, 'vingt trois': 23, 'vingt quatre': 24, 'vingt cinq': 25,
      'vingt six': 26, 'vingt sept': 27, 'vingt huit': 28, 'vingt neuf': 29,
      'trente': 30,
      'trente et un': 31, 'trente un': 31,
    };
    final entrees = table.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    return entrees;
  })();

  static const _mois = {
    'janvier': 1,
    'février': 2, 'fevrier': 2,
    'mars': 3,
    'avril': 4,
    'mai': 5,
    'juin': 6,
    'juillet': 7,
    'août': 8, 'aout': 8,
    'septembre': 9,
    'octobre': 10,
    'novembre': 11,
    'décembre': 12, 'decembre': 12,
  };

  static const _joursSemaine = {
    'lundi': DateTime.monday,
    'mardi': DateTime.tuesday,
    'mercredi': DateTime.wednesday,
    'jeudi': DateTime.thursday,
    'vendredi': DateTime.friday,
    'samedi': DateTime.saturday,
    'dimanche': DateTime.sunday,
  };

  static ResultatAnalyseDateVocale? analyser(String texteDicte, {DateTime? maintenant}) {
    if (texteDicte.trim().isEmpty) return null;
    final now = maintenant ?? DateTime.now();
    final texte = _convertirNombresEnChiffres(_normaliser(texteDicte));

    final jour = _extraireJour(texte, now);
    if (jour == null) return null;

    final heure = _extraireHeure(texte);
    final dateHeure = DateTime(
      jour.year,
      jour.month,
      jour.day,
      heure?.$1 ?? _heureParDefaut,
      heure?.$2 ?? 0,
    );
    return ResultatAnalyseDateVocale(dateHeure: dateHeure, heureDeduite: heure == null);
  }

  static String _normaliser(String texte) {
    return texte.toLowerCase().trim().replaceAll('’', "'").replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _convertirNombresEnChiffres(String texte) {
    var resultat = texte.replaceAll('-', ' ');
    for (final entree in _nombres) {
      resultat = resultat.replaceAll(RegExp('\\b${entree.key}\\b'), '${entree.value}');
    }
    return resultat;
  }

  static DateTime? _extraireJour(String texte, DateTime now) {
    final aujourdHui = DateTime(now.year, now.month, now.day);

    // "dans N jours" / "dans N semaines" / "dans N mois".
    final relatif = RegExp(r'dans\s+(\d+)\s*(jour|semaine|mois)').firstMatch(texte);
    if (relatif != null) {
      final n = int.parse(relatif.group(1)!);
      switch (relatif.group(2)) {
        case 'jour':
          return aujourdHui.add(Duration(days: n));
        case 'semaine':
          return aujourdHui.add(Duration(days: n * 7));
        default:
          return DateTime(now.year, now.month + n, now.day);
      }
    }

    if (texte.contains('après demain') || texte.contains('apres demain')) {
      return aujourdHui.add(const Duration(days: 2));
    }
    if (texte.contains('demain')) {
      return aujourdHui.add(const Duration(days: 1));
    }
    if (texte.contains("aujourd'hui") || texte.contains('aujourdhui')) {
      return aujourdHui;
    }

    // Date explicite avec mois en toutes lettres : "15 mars", "le 15 mars 2026".
    for (final entree in _mois.entries) {
      final motif = RegExp('(\\d{1,2})\\s*(?:er)?\\s*${entree.key}(?:\\s+(\\d{4}))?');
      final m = motif.firstMatch(texte);
      if (m != null) {
        final jourNum = int.parse(m.group(1)!);
        final annee = m.group(2) != null ? int.parse(m.group(2)!) : now.year;
        if (jourNum >= 1 && jourNum <= 31) return DateTime(annee, entree.value, jourNum);
      }
    }

    // Date numérique : "15/03", "15-03-2026" (le tiret devient un espace
    // dans _convertirNombresEnChiffres, donc "15 03 2026" est aussi accepté).
    final numerique =
        RegExp(r'\b(\d{1,2})[\/. ](\d{1,2})(?:[\/. ](\d{2,4}))?\b').firstMatch(texte);
    if (numerique != null) {
      final jourNum = int.parse(numerique.group(1)!);
      final moisNum = int.parse(numerique.group(2)!);
      if (jourNum >= 1 && jourNum <= 31 && moisNum >= 1 && moisNum <= 12) {
        var annee = now.year;
        final grAnnee = numerique.group(3);
        if (grAnnee != null) {
          annee = grAnnee.length == 2 ? 2000 + int.parse(grAnnee) : int.parse(grAnnee);
        }
        return DateTime(annee, moisNum, jourNum);
      }
    }

    // Jour de la semaine : "lundi", "ce lundi", "lundi prochain" — toujours
    // la PROCHAINE occurrence (jamais aujourd'hui, un rendez-vous se prend
    // pour une date à venir).
    for (final entree in _joursSemaine.entries) {
      if (texte.contains(entree.key)) {
        var decalage = (entree.value - now.weekday) % 7;
        if (decalage <= 0) decalage += 7;
        return aujourdHui.add(Duration(days: decalage));
      }
    }

    // Jour seul, sans mois précisé : "le 20" → mois en cours, et le mois
    // suivant si ce jour est déjà passé ce mois-ci.
    final jourSeul = RegExp(r'\ble\s+(\d{1,2})\b').firstMatch(texte);
    if (jourSeul != null) {
      final jourNum = int.parse(jourSeul.group(1)!);
      if (jourNum >= 1 && jourNum <= 31) {
        var candidate = DateTime(now.year, now.month, jourNum);
        if (candidate.isBefore(aujourdHui)) {
          candidate = DateTime(now.year, now.month + 1, jourNum);
        }
        return candidate;
      }
    }

    return null;
  }

  /// Retourne (heure, minute), ou `null` si aucune heure n'a été dictée.
  ///
  /// L'heure chiffrée ("15h", "3 heures") est cherchée AVANT le repli sur
  /// "midi"/"minuit" tout seuls, car "midi"/"soir" peuvent aussi n'être que
  /// des qualificatifs d'une heure déjà chiffrée ("3 heures de l'après-
  /// midi" doit donner 15h, pas être confondu avec "midi" = 12h00).
  static (int, int)? _extraireHeure(String texte) {
    final avecH = RegExp(r'\b(\d{1,2})\s*h\s*(\d{1,2})?\b').firstMatch(texte);
    final match = avecH ?? RegExp(r'\b(\d{1,2})\s*heures?\b').firstMatch(texte);

    if (match != null) {
      var heure = int.parse(match.group(1)!);
      var minute = 0;
      if (match.groupCount >= 2 && match.group(2) != null) {
        minute = int.parse(match.group(2)!);
      } else if (texte.contains('et quart')) {
        minute = 15;
      } else if (texte.contains('et demi')) {
        minute = 30;
      } else if (texte.contains('moins le quart') || texte.contains('moins quart')) {
        heure -= 1;
        minute = 45;
      }

      if ((texte.contains('après midi') ||
              texte.contains('apres midi') ||
              texte.contains('du soir')) &&
          heure < 12) {
        heure += 12;
      }

      if (heure < 0) heure += 24;
      if (heure > 23) heure = 23;
      if (minute > 59) minute = 59;
      return (heure, minute);
    }

    final estApresMidi = texte.contains('après midi') || texte.contains('apres midi');
    if (texte.contains('midi') && !estApresMidi) return (12, 0);
    if (texte.contains('minuit')) return (0, 0);

    return null;
  }
}
