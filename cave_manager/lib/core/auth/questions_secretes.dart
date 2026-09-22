/// Liste fixe de questions secrètes proposées à la création d'un compte,
/// utilisées pour la récupération de code PIN (voir
/// `supabase/migrations/0002_recuperation_pin.sql`).
///
/// Une liste fermée plutôt qu'une question libre : plus simple à
/// comprendre et à ressaisir fidèlement pour un utilisateur à faible
/// littératie numérique (point 29 du cahier des charges), et évite les
/// questions mal formulées.
const List<String> questionsSecretesDisponibles = [
  'Quel est le prénom de votre mère ?',
  'Quel est le nom de votre village d\'origine ?',
  'Quel est votre plat préféré ?',
  'Quel est le nom de votre premier animal ?',
];
