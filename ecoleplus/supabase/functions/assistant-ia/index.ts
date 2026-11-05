// Assistant IA pédagogique (phase 12) — SEUL point d'appel du fournisseur
// d'IA. La clé reste ici (variable d'environnement AI_API_KEY), jamais
// dans l'application. Sans clé (ou AI_PROVIDER=simule) : réponses
// simulées, pour les tests et l'essai.
//
// Étapes : personne connectée et membre de l'école (enseignant ou
// directeur) → limites du mois (enseignant, école, budget) → noms d'élèves
// retirés → passages de la bibliothèque cherchés AVEC LES DROITS de la
// personne (jamais une autre classe, les archives, un document exclu) →
// appel du modèle (consignes en cache, réponse JSON imposée) → longs
// extraits retirés → demande enregistrée (coût) → réponse.
import {
  anonymiser,
  CONSIGNES,
  coutMicroUsd,
  type Demande,
  type Fiche,
  ficheSimulee,
  message,
  type Passage,
  retirerCopies,
  SCHEMA,
} from "./consignes.ts";

const url = Deno.env.get("SUPABASE_URL")!;
const cleService = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const cleAnon = Deno.env.get("SUPABASE_ANON_KEY")!;
const cleIa = Deno.env.get("AI_API_KEY") ?? "";
const fournisseur = (Deno.env.get("AI_PROVIDER") ?? (cleIa ? "anthropic" : "simule")).toLowerCase();
const modele = Deno.env.get("AI_MODEL") ?? "claude-haiku-5-5";

const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function reponse(statut: number, corps: Record<string, unknown>): Response {
  return new Response(JSON.stringify(corps), {
    status: statut,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

/** Appel REST avec la clé du serveur (écritures, lectures internes). */
async function service(methode: string, chemin: string, corps?: unknown): Promise<any> {
  const r = await fetch(`${url}${chemin}`, {
    method: methode,
    headers: {
      apikey: cleService,
      Authorization: `Bearer ${cleService}`,
      "content-type": "application/json",
      Prefer: "return=representation",
    },
    body: corps === undefined ? undefined : JSON.stringify(corps),
  });
  const t = await r.text();
  if (!r.ok) throw new Error(`REST ${r.status} ${t}`);
  return t ? JSON.parse(t) : null;
}

/** Appel REST AU NOM de la personne : les règles de lecture (RLS)
 * s'appliquent — c'est ce qui garantit qu'aucun document d'une autre
 * classe ne sort. */
async function auNomDe(jeton: string, chemin: string, corps: unknown): Promise<any> {
  const r = await fetch(`${url}${chemin}`, {
    method: "POST",
    headers: { apikey: cleAnon, Authorization: `Bearer ${jeton}`, "content-type": "application/json" },
    body: JSON.stringify(corps),
  });
  const t = await r.text();
  if (!r.ok) throw new Error(`REST ${r.status} ${t}`);
  return t ? JSON.parse(t) : null;
}

async function appelant(jeton: string): Promise<{ id: string } | null> {
  const r = await fetch(`${url}/auth/v1/user`, { headers: { apikey: cleAnon, Authorization: `Bearer ${jeton}` } });
  return r.ok ? await r.json() : null;
}

const KINDS = ["preparation", "exercices", "remediation"];
const ACTIONS = ["simplifier", "developper", "changer"];
const CHAMPS = [
  "niveau", "matiere", "theme", "duree", "objectif", "nb_eleves", "difficultes", "nb_questions",
  "type_exercice", "difficulte",
];

/** Demande nettoyée : champs connus, textes courts. */
function lireDemande(p: Record<string, unknown>): Demande | string {
  const kind = String(p.kind ?? "");
  if (!KINDS.includes(kind)) return "Type de demande inconnu.";
  const d: Record<string, unknown> = { kind };
  for (const c of CHAMPS) {
    const v = p[c];
    if (typeof v === "string" && v.trim()) d[c] = v.trim().slice(0, 600);
  }
  if (p.action !== undefined && p.action !== null) {
    if (!ACTIONS.includes(String(p.action))) return "Action inconnue.";
    d.action = String(p.action);
    const prec = p.precedent as Fiche | undefined;
    if (!prec || !Array.isArray(prec.sections)) return "Fiche précédente manquante.";
    d.precedent = {
      titre: String(prec.titre ?? "").slice(0, 300),
      sections: prec.sections.slice(0, 20).map((s) => ({
        titre: String(s.titre ?? "").slice(0, 200),
        contenu: String(s.contenu ?? "").slice(0, 4000),
      })),
      sources: [],
      hors_documents: false,
    };
  }
  if (!d.theme && !d.difficultes && !d.action) return "Indiquez le thème (ou la difficulté de l'élève).";
  return d as Demande;
}

/** Le modèle (Claude, SDK officiel) : chargé seulement quand une clé est
 * configurée (le mode simulé n'en dépend pas). */
async function appelerClaude(texte: string) {
  const { appelerClaude: appel } = await import("./claude.ts");
  return await appel({ cle: cleIa, modele, texte });
}

/** Fiche bien formée (une réponse mal formée est refusée proprement). */
function verifier(f: unknown, nbPassages: number): Fiche | null {
  const x = f as Fiche;
  if (!x || typeof x.titre !== "string" || !Array.isArray(x.sections) || x.sections.length === 0) return null;
  const sections = x.sections
    .filter((s) => s && typeof s.titre === "string" && typeof s.contenu === "string")
    .slice(0, 20);
  if (sections.length === 0) return null;
  const sources = [...new Set((Array.isArray(x.sources) ? x.sources : [])
    .filter((n) => Number.isInteger(n) && n >= 1 && n <= nbPassages))];
  return { titre: x.titre.slice(0, 300), sections, sources, hors_documents: sources.length === 0 };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return reponse(405, { erreur: "Méthode non autorisée." });
  const jeton = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  const moi = await appelant(jeton);
  if (!moi) return reponse(401, { erreur: "Veuillez vous reconnecter." });

  let p: Record<string, unknown>;
  try {
    p = await req.json();
  } catch {
    return reponse(400, { erreur: "Demande illisible." });
  }
  const ecole = String(p.school_id ?? "");
  if (!uuid.test(ecole)) return reponse(400, { erreur: "École inconnue." });
  const membre = (await service(
    "GET",
    `/rest/v1/memberships?select=id,role&user_id=eq.${moi.id}&school_id=eq.${ecole}` +
      `&active=is.true&deleted_at=is.null&role=in.(directeur,enseignant)`,
  ))?.[0];
  if (!membre) return reponse(403, { erreur: "L'assistant est réservé aux enseignants et au directeur." });

  // Usage du mois : uniquement la demande « usage » (compteur à l'écran).
  const usage = (await auNomDe(jeton, "/rest/v1/rpc/ia_usage", { p_school: ecole }) as any[])
    .find((u) => u.user_id === moi.id);
  const restants = (u: any) => ({
    enseignant: Math.max(0, (u?.limite ?? 30) - (u?.demandes ?? 0)),
    ecole: Math.max(0, (u?.ecole_limite ?? 300) - (u?.ecole_demandes ?? 0)),
    limite: u?.limite ?? 30,
  });
  if (p.kind === "usage") return reponse(200, { restant: restants(usage), modele, fournisseur });

  const d = lireDemande(p);
  if (typeof d === "string") return reponse(400, { erreur: d });

  // Limites : enseignant, école, budget.
  if (usage && usage.demandes >= usage.limite) {
    return reponse(429, {
      erreur: `Vous avez utilisé vos ${usage.limite} demandes de ce mois. Elles reviennent le 1er du mois ` +
        "prochain ; vos fiches enregistrées restent disponibles.",
      limite: "enseignant",
    });
  }
  if (usage && usage.ecole_demandes >= usage.ecole_limite) {
    return reponse(429, {
      erreur: "L'école a utilisé toutes ses demandes de ce mois. Parlez-en au directeur.",
      limite: "ecole",
    });
  }
  if (usage && usage.ecole_cout_microusd >= usage.ecole_budget_microusd) {
    return reponse(429, { erreur: "Le budget de l'école pour l'assistant est atteint ce mois-ci.", limite: "budget" });
  }

  // Aucun nom d'élève ne part chez le fournisseur.
  const eleves = await service(
    "GET",
    `/rest/v1/students?select=last_name,first_names&school_id=eq.${ecole}&deleted_at=is.null`,
  ) as { last_name: string; first_names: string }[];
  const noms = eleves.flatMap((e) => [
    `${e.last_name} ${e.first_names}`,
    `${e.first_names} ${e.last_name}`,
    ...String(e.first_names ?? "").split(/\s+/),
  ]);
  const demande: Demande = JSON.parse(anonymiser(JSON.stringify(d), noms));

  // Passages de la bibliothèque, avec les droits de la personne.
  const choisis = Array.isArray(p.documents)
    ? (p.documents as unknown[]).map(String).filter((x) => uuid.test(x)).slice(0, 30)
    : null;
  const requete = [demande.theme, demande.objectif, demande.matiere, demande.difficultes].filter(Boolean).join(" ");
  let passages: Passage[] = [];
  if (p.sans_bibliotheque !== true) {
    passages = (await auNomDe(jeton, "/rest/v1/rpc/ia_passages", {
      p_school: ecole,
      p_query: requete,
      p_documents: choisis,
      p_limit: 8,
    }) as Passage[]).map((x) => ({ ...x, contenu: String(x.contenu).slice(0, 1500) }));
  }

  const texte = message(demande, passages);
  let fiche: Fiche | null;
  let u = { entree: 0, sortie: 0, cacheLu: 0, cacheEcrit: 0 };
  let statut = "terminee";
  try {
    if (fournisseur === "simule") {
      fiche = ficheSimulee(demande, passages);
      u = { entree: Math.ceil((CONSIGNES.length + texte.length) / 4), sortie: 400, cacheLu: 0, cacheEcrit: 0 };
    } else {
      const r = await appelerClaude(texte);
      fiche = r.fiche;
      u = r.usage as typeof u;
    }
    fiche = verifier(fiche, passages.length);
    if (!fiche) statut = "echec";
  } catch (e) {
    console.error("assistant-ia", (e as Error).message);
    fiche = null;
    statut = "echec";
  }
  const cout = fournisseur === "simule" ? 0 : coutMicroUsd(modele, u);
  let retraits = 0;
  if (fiche) {
    const r = retirerCopies(fiche, passages);
    fiche = r.fiche;
    retraits = r.retraits;
  }
  const sources = (fiche?.sources ?? []).map((n) => passages[n - 1]).map((x) => ({
    document_id: x.document_id,
    titre: x.titre,
    page: x.page,
  }));
  await service("POST", "/rest/v1/ai_requests", {
    school_id: ecole,
    user_id: moi.id,
    kind: demande.action ? `${demande.kind}:${demande.action}` : demande.kind,
    status: statut,
    request: demande,
    response: fiche,
    used_document_ids: [...new Set(sources.map((s) => s.document_id))],
    tokens_in: u.entree + u.cacheLu + u.cacheEcrit,
    tokens_out: u.sortie,
    cost_microusd: cout,
    created_by: moi.id,
  });
  if (!fiche) {
    return reponse(502, {
      erreur: "L'assistant n'a pas pu répondre correctement. Réessayez ; cette demande n'est pas comptée.",
    });
  }
  const apres = usage ? { ...usage, demandes: usage.demandes + 1, ecole_demandes: usage.ecole_demandes + 1 } : null;
  return reponse(200, {
    fiche,
    sources,
    hors_documents: sources.length === 0,
    extraits_retires: retraits,
    restant: restants(apres),
    modele: fournisseur === "simule" ? "simulé" : modele,
  });
});
