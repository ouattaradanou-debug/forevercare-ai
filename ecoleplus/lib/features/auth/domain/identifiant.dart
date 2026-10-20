/// Normalisation de l'identifiant de connexion — MÊME règle que
/// supabase/functions/_shared/identifiant.ts (exemples communs :
/// test/fixtures/identifiants.json).
///   * contient « @ »          → adresse e-mail réelle ;
///   * numéro de téléphone BF  → 226XXXXXXXX@tel.ecoleplus.invalid ;
///   * sinon identifiant libre → identifiant@id.ecoleplus.invalid.
/// Le domaine « .invalid » est réservé : aucun e-mail n'y est jamais envoyé.
String? identifiantVersEmail(String saisie) {
  final brut = saisie.trim().toLowerCase();
  if (brut.isEmpty) return null;
  if (brut.contains('@')) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(brut) ? brut : null;
  }
  final chiffres = brut
      .replaceAll(RegExp(r'[\s.\-()]'), '')
      .replaceFirst(RegExp(r'^\+'), '')
      .replaceFirst(RegExp('^00'), '');
  if (RegExp(r'^\d+$').hasMatch(chiffres)) {
    if (chiffres.length == 8) return '226$chiffres@tel.ecoleplus.invalid';
    if (chiffres.length == 11 && chiffres.startsWith('226')) {
      return '$chiffres@tel.ecoleplus.invalid';
    }
    return null;
  }
  final ident = _sansAccents(brut).replaceAll(RegExp(r'\s+'), '.');
  return RegExp(r'^[a-z0-9][a-z0-9._-]{2,39}$').hasMatch(ident)
      ? '$ident@id.ecoleplus.invalid'
      : null;
}

/// Type d'identifiant, pour choisir la procédure de mot de passe oublié.
enum TypeIdentifiant { email, telephone, identifiant }

TypeIdentifiant? typeIdentifiant(String saisie) {
  final email = identifiantVersEmail(saisie);
  if (email == null) return null;
  if (email.endsWith('@tel.ecoleplus.invalid')) {
    return TypeIdentifiant.telephone;
  }
  if (email.endsWith('@id.ecoleplus.invalid')) {
    return TypeIdentifiant.identifiant;
  }
  return TypeIdentifiant.email;
}

/// Texte à montrer à l'utilisateur pour un identifiant technique.
String identifiantAffichable(String email) {
  if (email.endsWith('@tel.ecoleplus.invalid')) {
    final n = email.split('@').first.substring(3);
    return '${n.substring(0, 2)} ${n.substring(2, 4)} '
        '${n.substring(4, 6)} ${n.substring(6, 8)}';
  }
  if (email.endsWith('@id.ecoleplus.invalid')) return email.split('@').first;
  return email;
}

String _sansAccents(String s) {
  const avec = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿœæ';
  const sans = 'aaaaaaceeeeiiiinooooouuuuyy';
  final out = StringBuffer();
  for (final ch in s.split('')) {
    if (ch == 'œ') {
      out.write('oe');
    } else if (ch == 'æ') {
      out.write('ae');
    } else {
      final i = avec.indexOf(ch);
      out.write(i >= 0 && i < sans.length ? sans[i] : ch);
    }
  }
  return out.toString();
}
