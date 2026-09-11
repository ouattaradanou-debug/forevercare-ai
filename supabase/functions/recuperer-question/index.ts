// Edge Function : renvoie la question secrète de récupération d'un compte
// propriétaire, à partir de son numéro de téléphone — première étape de
// l'écran "Code oublié ?" (voir CodeOubliePage), avant de demander la
// réponse et le nouveau code PIN (voir reinitialiser-code).
//
// Appel PUBLIC (sans session) : c'est justement le but, un tailleur qui a
// perdu son téléphone n'a plus aucune session active. Ne renvoie jamais
// la réponse elle-même, seulement l'intitulé de la question — voir
// supabase/migration_phase7_recuperation_compte.sql pour le détail de la
// table et de son absence volontaire de policy RLS.
//
// Déploiement (une fois le projet Supabase créé) :
//   supabase functions deploy recuperer-question --no-verify-jwt

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
    const { telephone } = await req.json();
    if (!telephone) {
      return reponseJson({ error: 'Numéro de téléphone manquant.' }, 400);
    }

    const telephoneNettoye = String(telephone).replace(/[^0-9]/g, '');

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const clientAdmin = createClient(supabaseUrl, serviceRoleKey);

    const { data: utilisateur } = await clientAdmin
      .from('utilisateurs')
      .select('id')
      .eq('telephone', telephoneNettoye)
      .eq('role', 'proprietaire')
      .maybeSingle();

    if (!utilisateur) {
      return reponseJson({ error: 'Aucun compte trouvé pour ce numéro.' }, 404);
    }

    const { data: recuperation } = await clientAdmin
      .from('recuperation_compte')
      .select('question')
      .eq('utilisateur_id', utilisateur.id)
      .maybeSingle();

    if (!recuperation) {
      return reponseJson(
        {
          error:
            "Aucune question de récupération n'a été configurée pour ce compte.",
        },
        404,
      );
    }

    return reponseJson({ question: recuperation.question }, 200);
  } catch (erreur) {
    return reponseJson({ error: String(erreur) }, 500);
  }
});
