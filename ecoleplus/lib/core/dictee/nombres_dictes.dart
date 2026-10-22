// Conversion des nombres et des dates dictés en français (« soixante-dix »,
// « vingt-deux octobre deux mille onze ») en chiffres. La reconnaissance du
// téléphone renvoie souvent déjà des chiffres : ils sont gardés tels quels.

const _unites = {
  'zero': 0,
  'zéro': 0,
  'un': 1,
  'une': 1,
  'premier': 1,
  'première': 1,
  'deux': 2,
  'trois': 3,
  'quatre': 4,
  'cinq': 5,
  'six': 6,
  'sept': 7,
  'huit': 8,
  'neuf': 9,
  'dix': 10,
  'onze': 11,
  'douze': 12,
  'treize': 13,
  'quatorze': 14,
  'quinze': 15,
  'seize': 16,
};
const _dizaines = {
  'vingt': 20,
  'vingts': 20,
  'trente': 30,
  'quarante': 40,
  'cinquante': 50,
  'soixante': 60,
};

List<String> _mots(String texte) => texte
    .toLowerCase()
    .replaceAll(RegExp('[-,.;:!?]'), ' ')
    .split(RegExp(r'\s+'))
    .where((m) => m.isNotEmpty && m != 'et')
    .toList();

bool _estNombre(String m) =>
    _unites.containsKey(m) ||
    _dizaines.containsKey(m) ||
    const {'cent', 'cents', 'mille', 'mil'}.contains(m) ||
    RegExp(r'^\d+$').hasMatch(m);

/// Valeur d'une suite de mots formant UN nombre (« quatre vingt dix sept »
/// → 97, « deux mille onze » → 2011). null si un mot n'est pas un nombre.
int? nombreEnLettres(List<String> mots) {
  if (mots.isEmpty) return null;
  var total = 0;
  var courant = 0;
  for (final m in mots) {
    if (RegExp(r'^\d+$').hasMatch(m)) {
      courant += int.parse(m);
    } else if (_unites[m] case final u?) {
      courant += u;
    } else if (_dizaines[m] case final d?) {
      // « quatre vingt » = 80.
      courant = (d == 20 && courant % 100 == 4)
          ? courant - 4 + 80
          : courant + d;
    } else if (m == 'cent' || m == 'cents') {
      courant = (courant == 0 ? 1 : courant) * 100;
    } else if (m == 'mille' || m == 'mil') {
      total += (courant == 0 ? 1 : courant) * 1000;
      courant = 0;
    } else {
      return null;
    }
  }
  return total + courant;
}

/// Numéro dicté (téléphone, matricule…) : « soixante-dix cinquante-six
/// dix-sept quarante » → « 70561740 » ; « 70 56 17 40 » → « 70561740 ».
/// Les lettres éventuelles (matricule « MAT 12 ») sont conservées.
String numeroDicte(String texte) {
  final sortie = StringBuffer();
  var groupe = <String>[];
  void fermer() {
    if (groupe.isEmpty) return;
    final v = nombreEnLettres(groupe);
    if (v != null) sortie.write(v);
    groupe = [];
  }

  for (final m in _mots(texte)) {
    if (RegExp(r'^\d+$').hasMatch(m)) {
      fermer();
      sortie.write(m);
      continue;
    }
    if (!_estNombre(m)) {
      fermer();
      sortie.write(m);
      continue;
    }
    final v = nombreEnLettres([...groupe, m]);
    final avant = nombreEnLettres(groupe) ?? 0;
    // Nouveau nombre quand le mot ne peut pas prolonger le précédent
    // (« cinquante six » = 56, mais « six sept » = 6 puis 7).
    final prolonge =
        groupe.isNotEmpty &&
        v != null &&
        ((_unites[m] != null &&
                _unites[m]! < 10 &&
                avant % 10 == 0 &&
                avant >= 20) ||
            (_unites[m] != null &&
                _unites[m]! >= 10 &&
                (avant == 60 || avant == 80)) ||
            (m.startsWith('vingt') && avant == 4) ||
            (_unites[m] == 7 && avant == 10) ||
            ((_unites[m] == 8 || _unites[m] == 9) && avant == 10));
    if (!prolonge) fermer();
    groupe.add(m);
  }
  fermer();
  return sortie.toString();
}

const _mois = {
  'janvier': 1,
  'fevrier': 2,
  'février': 2,
  'mars': 3,
  'avril': 4,
  'mai': 5,
  'juin': 6,
  'juillet': 7,
  'aout': 8,
  'août': 8,
  'septembre': 9,
  'octobre': 10,
  'novembre': 11,
  'decembre': 12,
  'décembre': 12,
};

/// Date dictée → « jj/mm/aaaa », ou null si incompréhensible.
/// « vingt-deux octobre deux mille onze », « le 1er mars 2017 »,
/// « 22 10 2011 », « 22/10/2011 ».
String? dateDictee(String texte) {
  final brut = texte.trim().toLowerCase().replaceAll('1er', '1');
  final chiffres = RegExp(
    r'(\d{1,2})\s*[/.\- ]\s*(\d{1,2})\s*[/.\- ]\s*(\d{2,4})',
  ).firstMatch(brut);
  int? jour;
  int? mois;
  int? annee;
  if (chiffres != null) {
    jour = int.parse(chiffres[1]!);
    mois = int.parse(chiffres[2]!);
    annee = int.parse(chiffres[3]!);
  } else {
    final mots = _mots(brut).where((m) => m != 'le').toList();
    final iMois = mots.indexWhere(_mois.containsKey);
    if (iMois <= 0) return null;
    jour = nombreEnLettres(mots.sublist(0, iMois));
    mois = _mois[mots[iMois]];
    annee = nombreEnLettres(mots.sublist(iMois + 1));
  }
  if (jour == null || mois == null || annee == null) return null;
  if (annee < 100) annee += annee > 50 ? 1900 : 2000;
  final d = DateTime.utc(annee, mois, jour);
  if (d.month != mois || d.day != jour || annee < 1900 || annee > 2100) {
    return null;
  }
  String deux(int n) => n.toString().padLeft(2, '0');
  return '${deux(jour)}/${deux(mois)}/$annee';
}
