// Fonction Edge Supabase : récupération d'un compte propriétaire dont le
// code PIN a été oublié, via question secrète (voir
// supabase/schema.sql : question_secrete / reponse_secrete_hash /
// verifier_reponse_secrete).
//
// Volontairement PUBLIQUE (pas de session requise — c'est tout l'intérêt :
// le tailleur a justement perdu l'accès à son compte) : doit être déployée
// avec `--no-verify-jwt`. Utilise la clé `service_role` (jamais exposée au
// client) pour lire la question et réinitialiser le mot de passe Auth sans
// jamais exposer l'empreinte de la réponse elle-même.
//
// Deux actions, choisies via `body.action` :
//   - "question"      : { telephone } -> { question } | { erreur }
//   - "reinitialiser" : { telephone, reponse, nouveauPin } -> { ok: true } | { erreur }
//
// Déploiement : `supabase functions deploy recuperer-compte --no-verify-jwt`
// (voir supabase/README.md).

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const enTetesCors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function reponseJson(corps: unknown, statut = 200): Response {
  return new Response(JSON.stringify(corps), {
    status: statut,
    headers: { ...enTetesCors, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (requete) => {
  if (requete.method === 'OPTIONS') {
    return new Response('ok', { headers: enTetesCors });
  }

  try {
    const urlSupabase = Deno.env.get('SUPABASE_URL')!;
    const cleServiceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const clientAdmin = createClient(urlSupabase, cleServiceRole);

    const corps = await requete.json();
    const action = String(corps.action ?? '');
    const telephone = String(corps.telephone ?? '').replace(/[^0-9]/g, '');

    if (telephone.length < 8) {
      return reponseJson({ erreur: 'Numéro de téléphone invalide.' }, 400);
    }

    if (action === 'question') {
      const { data: ligne } = await clientAdmin
        .from('utilisateurs')
        .select('question_secrete')
        .eq('telephone', telephone)
        .eq('role', 'proprietaire')
        .maybeSingle();

      if (!ligne || !ligne.question_secrete) {
        return reponseJson(
          { erreur: 'Aucune question secrète définie pour ce numéro.' },
          404,
        );
      }
      return reponseJson({ question: ligne.question_secrete });
    }

    if (action === 'reinitialiser') {
      const reponseUtilisateur = String(corps.reponse ?? '');
      const nouveauPin = String(corps.nouveauPin ?? '');

      if (!reponseUtilisateur || !/^[0-9]{6}$/.test(nouveauPin)) {
        return reponseJson({ erreur: 'Champs invalides.' }, 400);
      }

      const { data: resultat, error: erreurVerification } = await clientAdmin
        .rpc('verifier_reponse_secrete', {
          p_telephone: telephone,
          p_reponse: reponseUtilisateur,
        })
        .single();

      if (erreurVerification || !resultat || !resultat.valide || !resultat.utilisateur_id) {
        return reponseJson({ erreur: 'Réponse incorrecte.' }, 403);
      }

      const { error: erreurMiseAJour } = await clientAdmin.auth.admin.updateUserById(
        resultat.utilisateur_id as string,
        { password: nouveauPin },
      );

      if (erreurMiseAJour) {
        return reponseJson({ erreur: 'Échec de la réinitialisation du code PIN.' }, 500);
      }

      return reponseJson({ ok: true });
    }

    return reponseJson({ erreur: 'Action inconnue.' }, 400);
  } catch (erreur) {
    console.error(erreur);
    return reponseJson({ erreur: 'Erreur interne.' }, 500);
  }
});
