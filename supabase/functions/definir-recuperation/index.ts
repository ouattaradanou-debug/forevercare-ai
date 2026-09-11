// Edge Function : définit (ou remplace) la question secrète de
// récupération de compte de l'utilisateur connecté.
//
// Pourquoi une Edge Function et pas un appel direct depuis l'app Flutter ?
// La table `recuperation_compte` n'accorde volontairement aucune policy
// RLS (voir supabase/migration_phase7_recuperation_compte.sql) : n'importe
// quel membre de l'atelier pourrait sinon lire la question/réponse du
// propriétaire via un simple appel à l'API (les policies RLS de
// `utilisateurs` sont au niveau de la ligne, pas de la colonne). Cette
// fonction s'exécute côté serveur : elle vérifie la session de l'appelant,
// puis utilise la clé service_role pour hacher la réponse et l'enregistrer
// — jamais en clair, même côté serveur.
//
// Déploiement (une fois le projet Supabase créé) :
//   supabase functions deploy definir-recuperation

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

async function hacher(texte: string): Promise<string> {
  const donnees = new TextEncoder().encode(texte.trim().toLowerCase());
  const hachage = await crypto.subtle.digest('SHA-256', donnees);
  return Array.from(new Uint8Array(hachage))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
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

    const { question, reponse } = await req.json();
    if (!question || !reponse) {
      return reponseJson({ error: 'Champs manquants (question, reponse).' }, 400);
    }
    if (String(reponse).trim().length < 2) {
      return reponseJson({ error: 'La réponse est trop courte.' }, 400);
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

    const reponseHash = await hacher(String(reponse));

    // Client "admin" : privilèges élevés, jamais exposés côté mobile.
    const clientAdmin = createClient(supabaseUrl, serviceRoleKey);
    const { error } = await clientAdmin.from('recuperation_compte').upsert({
      utilisateur_id: authData.user.id,
      question: String(question).trim(),
      reponse_hash: reponseHash,
    });

    if (error) {
      return reponseJson({ error: error.message }, 400);
    }

    return reponseJson({ success: true }, 200);
  } catch (erreur) {
    return reponseJson({ error: String(erreur) }, 500);
  }
});
