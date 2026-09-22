/// ⚠️ Hypothèse technique posée pour la Phase 1 (signalée explicitement,
/// comme demandé par le prompt, plutôt qu'implémentée silencieusement) :
///
/// Supabase Auth exige un identifiant de type email pour l'inscription par
/// mot de passe. Beaucoup de gérants de cave au Burkina Faso ont un
/// numéro de téléphone fiable mais pas nécessairement une adresse email
/// qu'ils consultent. Pour respecter la règle de simplicité (point 29 —
/// "éviter les termes techniques"), l'app ne demande JAMAIS d'email à
/// l'utilisateur : à l'écran, on ne voit que "Numéro de téléphone" et
/// "Code secret" (PIN à 4-6 chiffres). En coulisse, un email technique est
/// dérivé du numéro pour satisfaire l'exigence de Supabase Auth.
///
/// Alternative écartée : l'authentification par SMS/OTP (`auth.signInWithOtp`)
/// serait plus naturelle mais nécessite un fournisseur SMS payant
/// (Twilio ou équivalent) non budgété pour une V1 — à revalider si le
/// coût est acceptable pour le porteur de projet.
///
/// Cette même transformation est utilisée côté Edge Function
/// (`supabase/functions/create-team-member/index.ts`) : les deux DOIVENT
/// rester strictement synchronisées.
String telephoneVersEmailTechnique(String telephone) {
  final chiffres = telephone.replaceAll(RegExp(r'\D'), '');
  if (chiffres.isEmpty) {
    throw ArgumentError.value(
        telephone, 'telephone', 'doit contenir au moins un chiffre');
  }
  return '$chiffres@cave.internal';
}
