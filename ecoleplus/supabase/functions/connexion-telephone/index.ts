// Connexion avec le numéro de téléphone d'un compte à e-mail (A11).
//   { telephone, password } → { email } si le numéro ET le mot de passe
//   correspondent ; sinon un refus identique, que le numéro existe ou non.
// L'application se connecte ensuite normalement avec cet e-mail.
// 5 essais ratés en une heure sur un numéro le bloquent temporairement.
import { identifiantVersEmail } from "../_shared/identifiant.ts";

const url = Deno.env.get("SUPABASE_URL")!;
const cle = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const entetes = { apikey: cle, Authorization: `Bearer ${cle}`, "content-type": "application/json" };

function reponse(statut: number, corps: Record<string, unknown>): Response {
  return new Response(JSON.stringify(corps), {
    status: statut,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return reponse(405, { erreur: "Méthode non autorisée." });
  let p: Record<string, unknown>;
  try {
    p = await req.json();
  } catch {
    return reponse(400, { erreur: "Demande illisible." });
  }
  const email = identifiantVersEmail(String(p.telephone ?? ""));
  if (!email || !email.endsWith("@tel.ecoleplus.invalid")) {
    return reponse(400, { erreur: "Numéro de téléphone non reconnu." });
  }
  const telephone = email.split("@")[0];
  const r = await fetch(`${url}/rest/v1/rpc/login_lookup`, {
    method: "POST",
    headers: entetes,
    body: JSON.stringify({ p_phone: telephone, p_password: String(p.password ?? "") }),
  });
  if (!r.ok) return reponse(502, { erreur: "Serveur indisponible. Réessayez." });
  const resultat = await r.json() as { statut: string; email?: string };
  switch (resultat.statut) {
    case "ok":
      return reponse(200, { email: resultat.email });
    case "bloque":
      return reponse(429, {
        erreur: "Trop d'essais avec ce numéro. Réessayez dans une heure, ou connectez-vous avec votre e-mail.",
      });
    default:
      return reponse(401, { erreur: "Identifiant ou mot de passe incorrect." });
  }
});
