// Gestion des comptes de l'école par le directeur (connexion requise) :
//   creer          : crée le compte d'un enseignant ou d'un délégué ;
//   reinitialiser  : donne un nouveau mot de passe provisoire.
// La clé service_role reste sur le serveur (variable d'environnement).
// Aucune dépendance externe : appels HTTP directs aux API Auth et REST.
import { identifiantVersEmail } from "../_shared/identifiant.ts";

const url = Deno.env.get("SUPABASE_URL")!;
const cle = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const entetes = { apikey: cle, Authorization: `Bearer ${cle}`, "content-type": "application/json" };

type Ligne = Record<string, unknown>;

async function api(methode: string, chemin: string, corps?: unknown): Promise<{ ok: boolean; data: any }> {
  const r = await fetch(`${url}${chemin}`, {
    method: methode,
    headers: { ...entetes, Prefer: "return=representation" },
    body: corps === undefined ? undefined : JSON.stringify(corps),
  });
  const texte = await r.text();
  return { ok: r.ok, data: texte ? JSON.parse(texte) : null };
}

async function utilisateurAppelant(jeton: string): Promise<{ id: string } | null> {
  const r = await fetch(`${url}/auth/v1/user`, { headers: { apikey: cle, Authorization: `Bearer ${jeton}` } });
  return r.ok ? await r.json() : null;
}

async function inserer(table: string, lignes: Ligne | Ligne[]) {
  return await api("POST", `/rest/v1/${table}`, lignes);
}

const DROITS = ["finances", "cartes", "eleves", "registres", "formulaires", "archives", "cantine"];

function reponse(statut: number, corps: Record<string, unknown>): Response {
  return new Response(JSON.stringify(corps), {
    status: statut,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function estDirecteur(userId: string, schoolId: string): Promise<boolean> {
  if (!uuid.test(userId) || !uuid.test(schoolId)) return false;
  const { data } = await api("GET", `/rest/v1/memberships?select=id&user_id=eq.${userId}` +
    `&school_id=eq.${schoolId}&role=eq.directeur&active=is.true&deleted_at=is.null`);
  return Array.isArray(data) && data.length > 0;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return reponse(405, { erreur: "Méthode non autorisée." });
  const jeton = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  const appelant = await utilisateurAppelant(jeton);
  if (!appelant) return reponse(401, { erreur: "Veuillez vous reconnecter." });

  let p: Record<string, unknown>;
  try {
    p = await req.json();
  } catch {
    return reponse(400, { erreur: "Demande illisible." });
  }

  if (p.action === "creer") {
    const schoolId = String(p.school_id ?? "");
    if (!(await estDirecteur(appelant.id, schoolId))) {
      return reponse(403, { erreur: "Seul le directeur peut créer des comptes." });
    }
    const role = String(p.role ?? "");
    if (!["enseignant", "delegue"].includes(role)) return reponse(400, { erreur: "Profil inconnu." });
    const email = identifiantVersEmail(String(p.login ?? ""));
    if (!email) {
      return reponse(400, {
        erreur: "Identifiant invalide : utilisez un numéro de téléphone, une adresse e-mail " +
          "ou un identifiant de 3 à 40 lettres ou chiffres.",
      });
    }
    if (email.endsWith("@tel.ecoleplus.invalid")) {
      // Numéro déjà choisi par un directeur pour se connecter (A11).
      const pris = await api("POST", "/rest/v1/rpc/login_phone_taken", { p_phone: email.split("@")[0] });
      if (!pris.ok) return reponse(502, { erreur: "Serveur indisponible. Réessayez." });
      if (pris.data === true) {
        return reponse(409, { erreur: "Cet identifiant est déjà utilisé. Choisissez-en un autre." });
      }
    }
    const motDePasse = String(p.password ?? "");
    if (motDePasse.length < 8) return reponse(400, { erreur: "Le mot de passe doit contenir au moins 8 caractères." });
    const droits = Array.isArray(p.permissions) ? p.permissions.map(String) : [];
    if (droits.some((d) => !DROITS.includes(d))) return reponse(400, { erreur: "Droit inconnu." });

    const cree = await api("POST", "/auth/v1/admin/users", { email, password: motDePasse, email_confirm: true });
    if (!cree.ok || !cree.data?.id) {
      const dejaPris = JSON.stringify(cree.data ?? "").toLowerCase().includes("already");
      return reponse(409, {
        erreur: dejaPris ? "Cet identifiant est déjà utilisé. Choisissez-en un autre." : "Création du compte impossible.",
      });
    }
    const insertion = await inserer("memberships", {
      id: p.membership_id ?? undefined,
      school_id: schoolId,
      user_id: cree.data.id,
      role,
      teacher_id: p.teacher_id ?? null,
      display_name: String(p.display_name ?? "").trim() || "Sans nom",
      phone: p.phone ?? null,
      created_by: appelant.id,
      updated_by: appelant.id,
    });
    if (!insertion.ok) {
      await api("DELETE", `/auth/v1/admin/users/${cree.data.id}`);
      return reponse(400, { erreur: "Enregistrement du compte impossible." });
    }
    const membre = insertion.data[0];
    if (role === "delegue" && droits.length > 0) {
      await inserer("delegate_permissions", droits.map((d) => ({
        school_id: schoolId, membership_id: membre.id, permission_key: d,
        created_by: appelant.id, updated_by: appelant.id,
      })));
    }
    await inserer("audit_log", {
      school_id: schoolId, actor_id: appelant.id, action: "creation_compte",
      table_name: "memberships", row_id: membre.id, details: { role, droits },
    });
    return reponse(200, { membre, identifiant: email });
  }

  if (p.action === "reinitialiser") {
    const id = String(p.membership_id ?? "");
    const lu = uuid.test(id) ? await api("GET", `/rest/v1/memberships?select=id,school_id,user_id&id=eq.${id}`) : null;
    const membre = lu?.data?.[0];
    if (!membre || !(await estDirecteur(appelant.id, membre.school_id))) {
      return reponse(403, { erreur: "Seul le directeur de l'école peut réinitialiser ce mot de passe." });
    }
    const motDePasse = String(p.password ?? "");
    if (motDePasse.length < 8) return reponse(400, { erreur: "Le mot de passe doit contenir au moins 8 caractères." });
    const maj = await api("PUT", `/auth/v1/admin/users/${membre.user_id}`, { password: motDePasse });
    if (!maj.ok) return reponse(400, { erreur: "Réinitialisation impossible." });
    await inserer("audit_log", {
      school_id: membre.school_id, actor_id: appelant.id, action: "reinitialisation_mot_de_passe",
      table_name: "memberships", row_id: membre.id,
    });
    return reponse(200, { ok: true });
  }

  return reponse(400, { erreur: "Action inconnue." });
});
