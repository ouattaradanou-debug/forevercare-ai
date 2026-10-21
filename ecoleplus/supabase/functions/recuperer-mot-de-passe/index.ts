// Mot de passe oublié par question secrète (sans connexion préalable).
//   question  : { login }                        → { question }
//   repondre  : { login, reponse, password }     → { ok }
// 5 réponses fausses en une heure bloquent la récupération ; chaque
// récupération réussie est signalée dans le journal du directeur.
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

async function rpc(nom: string, params: Record<string, unknown>): Promise<unknown> {
  const r = await fetch(`${url}/rest/v1/rpc/${nom}`, {
    method: "POST",
    headers: entetes,
    body: JSON.stringify(params),
  });
  if (!r.ok) throw new Error(`rpc ${nom} : ${r.status}`);
  return await r.json();
}

const aucuneQuestion =
  "Aucune question secrète n'est enregistrée pour cet identifiant. Demandez à votre directeur " +
  "de vous donner un nouveau mot de passe.";

Deno.serve(async (req) => {
  if (req.method !== "POST") return reponse(405, { erreur: "Méthode non autorisée." });
  let p: Record<string, unknown>;
  try {
    p = await req.json();
  } catch {
    return reponse(400, { erreur: "Demande illisible." });
  }
  const email = identifiantVersEmail(String(p.login ?? ""));
  if (!email) return reponse(400, { erreur: "Identifiant non reconnu." });

  if (p.action === "question") {
    const question = await rpc("recovery_lookup", { p_email: email });
    return question ? reponse(200, { question }) : reponse(404, { erreur: aucuneQuestion });
  }

  if (p.action === "repondre") {
    const motDePasse = String(p.password ?? "");
    if (motDePasse.length < 8) {
      return reponse(400, { erreur: "Le nouveau mot de passe doit contenir au moins 8 caractères." });
    }
    const r = await rpc("recovery_verify", { p_email: email, p_answer: String(p.reponse ?? "") }) as {
      statut: string;
      user_id?: string;
    };
    switch (r.statut) {
      case "inconnu":
        return reponse(404, { erreur: aucuneQuestion });
      case "bloque":
        return reponse(429, {
          erreur: "Trop d'essais. Réessayez dans une heure, ou demandez à votre directeur.",
        });
      case "faux":
        return reponse(400, { erreur: "Réponse incorrecte." });
    }
    const maj = await fetch(`${url}/auth/v1/admin/users/${r.user_id}`, {
      method: "PUT",
      headers: entetes,
      body: JSON.stringify({ password: motDePasse }),
    });
    if (!maj.ok) return reponse(400, { erreur: "Changement du mot de passe impossible." });
    return reponse(200, { ok: true });
  }

  return reponse(400, { erreur: "Action inconnue." });
});
