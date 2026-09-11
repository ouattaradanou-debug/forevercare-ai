// Edge Function : réinitialise le code PIN d'un compte propriétaire après
// vérification de la réponse à sa question secrète — seconde et dernière
// étape de l'écran "Code oublié ?" (voir CodeOubliePage et
// recuperer-question).
//
// Appel PUBLIC (sans session) : c'est justement le but. Utilise la clé
// service_role pour changer le mot de passe Supabase Auth de l'utilisateur
// une fois la réponse validée — un client mobile ne doit jamais détenir de
// privilèges permettant de changer le mot de passe d'un tiers, d'où
// l'Edge Function plutôt qu'un appel direct.
//
// Déploiement (une fois le projet Supabase créé) :
//   supabase functions deploy reinitialiser-code --no-verify-jwt

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
    const { telephone, reponse, nouveauPin } = await req.json();
    if (!telephone || !reponse || !nouveauPin) {
      return reponseJson(
        { error: 'Champs manquants (telephone, reponse, nouveauPin).' },
        400,
      );
    }
    if (String(nouveauPin).length !== 6) {
      return reponseJson({ error: 'Le code PIN doit contenir 6 chiffres.' }, 400);
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
      .select('reponse_hash')
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

    const reponseHash = await hacher(String(reponse));
    if (reponseHash !== recuperation.reponse_hash) {
      return reponseJson({ error: 'Réponse incorrecte.' }, 403);
    }

    const { error } = await clientAdmin.auth.admin.updateUserById(
      utilisateur.id,
      { password: String(nouveauPin) },
    );
    if (error) {
      return reponseJson({ error: error.message }, 400);
    }

    return reponseJson({ success: true }, 200);
  } catch (erreur) {
    return reponseJson({ error: String(erreur) }, 500);
  }
});
