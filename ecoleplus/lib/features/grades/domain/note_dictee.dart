import 'package:ecoleplus/core/dictee/nombres_dictes.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';

/// Ce que la dictée a compris pour une note.
sealed class NoteEntendue {
  const new();
}

/// Une note, en centièmes (« quatorze virgule cinq » → 1450).
class ValeurEntendue extends NoteEntendue {
  const new(this.centiemes);
  final int centiemes;
}

/// « absent », « absente ».
class AbsenceEntendue extends NoteEntendue {
  const new();
}

/// Note dictée → valeur, absence, ou null si rien n'est compris.
/// Accepte les chiffres (« 14,5 ») et les lettres (« quatorze virgule cinq »,
/// « douze et demi », « dix-sept sur vingt »). Le barème n'est pas vérifié
/// ici : l'écran refuse ensuite une note trop grande.
NoteEntendue? noteDictee(String texte) {
  var t = texte.toLowerCase().trim();
  if (t.isEmpty) return null;
  if (RegExp(r'^absente?s?\b').hasMatch(t)) return const AbsenceEntendue();
  // « … sur vingt » : le barème dit à voix haute est ignoré.
  t = t.replaceFirst(RegExp(r'\s+sur\s+.*$'), '').trim();
  final direct = centiemesDepuis(t.replaceAll(' ', ''));
  if (direct != null) return ValeurEntendue(direct);

  final mots = t
      .replaceAll(RegExp('[-;:!?]'), ' ')
      .replaceAll(RegExp(r'(?<=\d),(?=\d)'), ' virgule ')
      .replaceAll(RegExp(r'(?<=\d)\.(?=\d)'), ' virgule ')
      .replaceAll(RegExp('[,.]'), ' ')
      .split(RegExp(r'\s+'))
      .where((m) => m.isNotEmpty)
      .toList();
  if (mots.isEmpty) return null;

  // « douze et demi » / « douze et demie ».
  if (mots.length >= 3 &&
      mots[mots.length - 2] == 'et' &&
      (mots.last == 'demi' || mots.last == 'demie')) {
    final e = _entier(mots.sublist(0, mots.length - 2));
    return e == null ? null : ValeurEntendue(e * 100 + 50);
  }
  final sep = mots.indexWhere((m) => m == 'virgule' || m == 'point');
  if (sep < 0) {
    final e = _entier(mots);
    return e == null ? null : ValeurEntendue(e * 100);
  }
  final e = _entier(mots.sublist(0, sep));
  final apres = mots.sublist(sep + 1);
  if (e == null || apres.isEmpty) return null;
  // « virgule zéro cinq » → 0,05 ; « virgule cinq » → 0,5 ;
  // « virgule vingt-cinq » → 0,25.
  final zeroDevant = apres.first == 'zéro' || apres.first == 'zero';
  final reste = zeroDevant ? apres.sublist(1) : apres;
  final d = reste.isEmpty ? 0 : _entier(reste);
  if (d == null) return null;
  final int dec;
  if (zeroDevant) {
    if (d > 9) return null;
    dec = d;
  } else if (d < 10) {
    dec = d * 10;
  } else if (d < 100) {
    dec = d;
  } else {
    return null;
  }
  return ValeurEntendue(e * 100 + dec);
}

int? _entier(List<String> mots) {
  final m = mots.where((m) => m != 'et').toList();
  if (m.isEmpty) return null;
  return nombreEnLettres(m);
}
