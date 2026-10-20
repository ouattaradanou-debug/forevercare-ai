// Normalisation de l'identifiant de connexion — MÊME règle que
// lib/features/auth/domain/identifiant.dart (testée des deux côtés).
//   * contient « @ »            → adresse e-mail réelle ;
//   * numéro de téléphone (BF)   → 226XXXXXXXX@tel.ecoleplus.invalid ;
//   * sinon identifiant libre    → identifiant@id.ecoleplus.invalid.
// Le domaine « .invalid » est réservé (RFC 2606) : aucun e-mail n'y part jamais.

export function identifiantVersEmail(saisie: string): string | null {
  const brut = saisie.trim().toLowerCase();
  if (brut.length === 0) return null;
  if (brut.includes("@")) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(brut) ? brut : null;
  }
  const chiffres = brut.replace(/[\s.\-()]/g, "").replace(/^\+/, "").replace(/^00/, "");
  if (/^\d+$/.test(chiffres)) {
    if (chiffres.length === 8) return `226${chiffres}@tel.ecoleplus.invalid`;
    if (chiffres.length === 11 && chiffres.startsWith("226")) return `${chiffres}@tel.ecoleplus.invalid`;
    return null;
  }
  const ident = brut.normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/\s+/g, ".");
  return /^[a-z0-9][a-z0-9._-]{2,39}$/.test(ident) ? `${ident}@id.ecoleplus.invalid` : null;
}
