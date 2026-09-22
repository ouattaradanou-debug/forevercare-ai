// Edge Function : create-team-member
//
// Pourquoi une Edge Function et non un simple appel SQL depuis le client ?
// Créer un compte (Gérant ou Agent de vente) nécessite d'insérer une ligne
// dans auth.users, ce qui requiert la clé "service role" de Supabase.
// Cette clé ne doit JAMAIS être embarquée dans l'application Flutter (elle
// donnerait un accès total, en contournant RLS, à quiconque décompile
// l'APK). Elle ne peut donc vivre que côté serveur : cette fonction.
//
// Appelée par un Propriétaire ou Propriétaire/Gérant authentifié
// (le JWT de l'appelant est vérifié ci-dessous avant toute action).
//
// Déploiement : supabase functions deploy create-team-member

import { createClient } from 'jsr:@supabase/supabase-js@2';

interface Requete {
  nom: string;
  prenom: string;
  telephone: string;
  role: 'gerant' | 'agent_vente';
  motDePasseInitial: string;
}

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return reponseErreur('Authentification requise.', 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;

    // Client "appelant" : n'utilise que le JWT reçu, respecte RLS.
    // Sert uniquement à vérifier qui appelle et avec quel rôle/cave.
    const clientAppelant = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user: appelant },
    } = await clientAppelant.auth.getUser();

    if (!appelant) {
      return reponseErreur('Session invalide.', 401);
    }

    const { data: profilAppelant, error: erreurProfil } = await clientAppelant
      .from('profiles')
      .select('cave_id, role, actif')
      .eq('id', appelant.id)
      .single();

    if (erreurProfil || !profilAppelant) {
      return reponseErreur('Profil introuvable pour cet utilisateur.', 403);
    }

    if (!profilAppelant.actif || !['proprietaire', 'proprietaire_gerant'].includes(profilAppelant.role)) {
      return reponseErreur(
        'Seul un Propriétaire ou Propriétaire/Gérant actif peut créer un compte Gérant ou Agent de vente.',
        403,
      );
    }

    const body: Requete = await req.json();

    if (!body.nom || !body.prenom || !body.telephone || !body.role || !body.motDePasseInitial) {
      return reponseErreur('Champs manquants (nom, prenom, telephone, role, motDePasseInitial).', 400);
    }

    if (!['gerant', 'agent_vente'].includes(body.role)) {
      return reponseErreur('Rôle invalide : seuls "gerant" et "agent_vente" peuvent être créés ici.', 400);
    }

    // Client "admin" : clé service role, utilisé uniquement pour l'étape
    // qui nécessite de créer une ligne auth.users. Jamais exposé au client.
    const clientAdmin = createClient(supabaseUrl, serviceRoleKey);

    const emailTechnique = telephoneVersEmailTechnique(body.telephone);

    const { data: nouvelUtilisateur, error: erreurCreation } = await clientAdmin.auth.admin.createUser({
      email: emailTechnique,
      password: body.motDePasseInitial,
      email_confirm: true,
      user_metadata: { telephone: body.telephone },
    });

    if (erreurCreation || !nouvelUtilisateur?.user) {
      return reponseErreur(`Échec de création du compte : ${erreurCreation?.message ?? 'inconnue'}`, 500);
    }

    const { error: erreurInsertionProfil } = await clientAdmin.from('profiles').insert({
      id: nouvelUtilisateur.user.id,
      cave_id: profilAppelant.cave_id,
      nom: body.nom,
      prenom: body.prenom,
      telephone: body.telephone,
      role: body.role,
      created_by: appelant.id,
    });

    if (erreurInsertionProfil) {
      // Rollback : évite un compte Auth orphelin sans profil applicatif.
      await clientAdmin.auth.admin.deleteUser(nouvelUtilisateur.user.id);
      return reponseErreur(`Échec de création du profil : ${erreurInsertionProfil.message}`, 500);
    }

    return new Response(JSON.stringify({ id: nouvelUtilisateur.user.id }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (erreur) {
    return reponseErreur(`Erreur interne : ${erreur instanceof Error ? erreur.message : String(erreur)}`, 500);
  }
});

function telephoneVersEmailTechnique(telephone: string): string {
  const chiffres = telephone.replace(/\D/g, '');
  return `${chiffres}@cave.internal`;
}

function reponseErreur(message: string, status: number): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
