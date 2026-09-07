// Edge Function : création d'un compte apprenti.
//
// Pourquoi une Edge Function et pas un appel direct depuis l'app Flutter ?
// Créer un compte Supabase Auth pour un tiers (l'apprenti) nécessite la clé
// service_role, qui ne doit jamais être embarquée dans une application
// mobile (elle contourne toute politique RLS). Cette fonction s'exécute
// côté serveur Supabase : elle vérifie que l'appelant est bien le
// propriétaire de l'atelier, puis utilise la clé service_role en toute
// sécurité pour créer le compte, la ligne `utilisateurs` (role = apprenti)
// et la ligne `permissions_apprenti` associée (tout désactivé par défaut).
//
// Déploiement (une fois le projet Supabase créé) :
//   supabase functions deploy create-apprentice

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

function reponseJson(corps: unknown, statut: number): Response {
  return new Response(JSON.stringify(corps), {
    status: statut,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const enTeteAuth = req.headers.get('Authorization');
    if (!enTeteAuth) {
      return reponseJson({ error: 'Non authentifié.' }, 401);
    }

    const { nom, telephone, pin } = await req.json();
    if (!nom || !telephone || !pin) {
      return reponseJson({ error: 'Champs manquants (nom, telephone, pin).' }, 400);
    }
    if (String(pin).length !== 6) {
      return reponseJson({ error: 'Le code PIN doit contenir 6 chiffres.' }, 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    // Client "appelant" : n'a que les droits RLS de la personne connectée.
    const clientAppelant = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: enTeteAuth } },
    });

    const { data: authData, error: erreurAuth } =
      await clientAppelant.auth.getUser();
    if (erreurAuth || !authData.user) {
      return reponseJson({ error: 'Session invalide.' }, 401);
    }

    const { data: appelant, error: erreurAppelant } = await clientAppelant
      .from('utilisateurs')
      .select('atelier_id, role')
      .eq('id', authData.user.id)
      .single();

    if (erreurAppelant || !appelant) {
      return reponseJson({ error: 'Utilisateur introuvable.' }, 404);
    }
    if (appelant.role !== 'proprietaire') {
      return reponseJson(
        { error: 'Seul le propriétaire peut créer un compte apprenti.' },
        403,
      );
    }

    const telephoneNettoye = String(telephone).replace(/[^0-9]/g, '');
    const email = `${telephoneNettoye}@atelierplus.app`;

    // Client "admin" : privilèges élevés, jamais exposés côté mobile.
    const clientAdmin = createClient(supabaseUrl, serviceRoleKey);

    const { data: nouveauCompte, error: erreurCreation } =
      await clientAdmin.auth.admin.createUser({
        email,
        password: String(pin),
        email_confirm: true,
      });

    if (erreurCreation || !nouveauCompte.user) {
      return reponseJson(
        { error: erreurCreation?.message ?? 'Création du compte impossible.' },
        400,
      );
    }

    const idApprenti = nouveauCompte.user.id;

    const { error: erreurUtilisateur } = await clientAdmin
      .from('utilisateurs')
      .insert({
        id: idApprenti,
        atelier_id: appelant.atelier_id,
        nom,
        telephone: telephoneNettoye,
        role: 'apprenti',
      });

    if (erreurUtilisateur) {
      // Évite de laisser un compte Auth orphelin sans ligne utilisateurs.
      await clientAdmin.auth.admin.deleteUser(idApprenti);
      return reponseJson({ error: erreurUtilisateur.message }, 400);
    }

    const { error: erreurPermissions } = await clientAdmin
      .from('permissions_apprenti')
      .insert({ utilisateur_id: idApprenti });

    if (erreurPermissions) {
      return reponseJson({ error: erreurPermissions.message }, 400);
    }

    return reponseJson({ id: idApprenti }, 200);
  } catch (erreur) {
    return reponseJson({ error: String(erreur) }, 500);
  }
});
