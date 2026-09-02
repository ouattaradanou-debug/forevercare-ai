// Fonction Edge Supabase : création d'un compte apprenti par le propriétaire
// de l'atelier.
//
// Pourquoi une fonction serveur et pas un simple appel client `auth.signUp` ?
// Le SDK Supabase ne gère qu'une session à la fois sur l'appareil : appeler
// `signUp` pour créer l'apprenti depuis l'appareil du propriétaire déjà
// connecté remplacerait immédiatement sa session par celle du nouvel
// apprenti. Cette fonction utilise la clé `service_role` (jamais exposée au
// client) pour créer le compte Auth de l'apprenti sans toucher à la session
// de l'appelant.
//
// Déploiement : `supabase functions deploy creer-apprenti`
// (nécessite la CLI Supabase et un projet lié, voir supabase/README.md).

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

function emailSynthetique(telephone: string): string {
  return `tel-${telephone}@atelierplus.local`;
}

Deno.serve(async (requete) => {
  if (requete.method === 'OPTIONS') {
    return new Response('ok', { headers: enTetesCors });
  }

  try {
    const enTeteAuth = requete.headers.get('Authorization');
    if (!enTeteAuth) {
      return reponseJson({ erreur: 'Authentification requise.' }, 401);
    }

    const urlSupabase = Deno.env.get('SUPABASE_URL')!;
    const cleAnon = Deno.env.get('SUPABASE_ANON_KEY')!;
    const cleServiceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    // Client "appelant" : exécute avec les droits RLS du propriétaire qui
    // a invoqué la fonction, pour vérifier légitimement son rôle.
    const clientAppelant = createClient(urlSupabase, cleAnon, {
      global: { headers: { Authorization: enTeteAuth } },
    });

    const { data: donneesUtilisateur, error: erreurUtilisateur } = await clientAppelant.auth.getUser();
    if (erreurUtilisateur || !donneesUtilisateur.user) {
      return reponseJson({ erreur: 'Session invalide.' }, 401);
    }
    const idAppelant = donneesUtilisateur.user.id;

    const { data: ligneAppelant, error: erreurLigneAppelant } = await clientAppelant
      .from('utilisateurs')
      .select('atelier_id, role')
      .eq('id', idAppelant)
      .single();

    if (erreurLigneAppelant || !ligneAppelant) {
      return reponseJson({ erreur: 'Profil introuvable.' }, 403);
    }
    if (ligneAppelant.role !== 'proprietaire') {
      return reponseJson(
        { erreur: 'Seul le propriétaire de l\'atelier peut créer un compte apprenti.' },
        403,
      );
    }

    const corps = await requete.json();
    const nom = String(corps.nom ?? '').trim();
    const telephone = String(corps.telephone ?? '').replace(/[^0-9]/g, '');
    const pin = String(corps.pin ?? '');

    if (!nom || telephone.length < 8 || !/^[0-9]{6}$/.test(pin)) {
      return reponseJson({ erreur: 'Champs invalides.' }, 400);
    }

    // Client "admin" : seule cette fonction possède la clé service_role,
    // jamais le client mobile.
    const clientAdmin = createClient(urlSupabase, cleServiceRole);

    const { data: nouvelUtilisateurAuth, error: erreurCreationAuth } =
      await clientAdmin.auth.admin.createUser({
        email: emailSynthetique(telephone),
        password: pin,
        email_confirm: true,
      });

    if (erreurCreationAuth || !nouvelUtilisateurAuth.user) {
      const dejaExistant = erreurCreationAuth?.message?.toLowerCase().includes('already registered');
      return reponseJson(
        { erreur: dejaExistant ? 'Ce numéro est déjà utilisé.' : 'Échec de création du compte.' },
        dejaExistant ? 409 : 500,
      );
    }

    const { data: ligneUtilisateur, error: erreurInsertion } = await clientAdmin
      .from('utilisateurs')
      .insert({
        id: nouvelUtilisateurAuth.user.id,
        atelier_id: ligneAppelant.atelier_id,
        nom,
        telephone,
        role: 'apprenti',
      })
      .select()
      .single();

    if (erreurInsertion) {
      // Compte Auth créé mais profil non inséré : nettoyage best-effort
      // pour ne pas laisser de compte Auth orphelin sans profil utilisable.
      await clientAdmin.auth.admin.deleteUser(nouvelUtilisateurAuth.user.id);
      return reponseJson({ erreur: 'Échec de création du profil apprenti.' }, 500);
    }

    return reponseJson(ligneUtilisateur, 201);
  } catch (erreur) {
    console.error(erreur);
    return reponseJson({ erreur: 'Erreur interne.' }, 500);
  }
});
