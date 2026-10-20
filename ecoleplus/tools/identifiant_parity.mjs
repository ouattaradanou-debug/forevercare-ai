// Vérifie que la règle TypeScript (fonction serveur) donne les mêmes
// résultats que la règle Dart sur les exemples communs.
// Usage : node --experimental-strip-types tools/identifiant_parity.mjs
import { readFileSync } from "node:fs";
const { identifiantVersEmail } = await import("../supabase/functions/_shared/identifiant.ts");
const cas = JSON.parse(readFileSync(new URL("../test/fixtures/identifiants.json", import.meta.url)));
let echecs = 0;
for (const [saisie, attendu] of cas) {
  const obtenu = identifiantVersEmail(saisie);
  if (obtenu !== attendu) {
    echecs++;
    console.log(`ÉCHEC « ${saisie} » : ${obtenu} au lieu de ${attendu}`);
  }
}
console.log(`${cas.length - echecs}/${cas.length} identiques`);
process.exit(echecs ? 1 : 0);
