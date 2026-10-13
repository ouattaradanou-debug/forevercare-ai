/// Liste de questions secrètes courantes proposées au propriétaire
/// (création de compte, Paramètres) pour récupérer l'accès à son compte en
/// cas de code PIN oublié — voir AuthRepository.definirQuestionSecrete. La
/// dernière entrée ("Autre...") signale qu'un champ libre doit être
/// affiché à la place.
const List<String> questionsSecretesPredefinies = [
  'Quel est le prénom de votre mère ?',
  'Quelle est votre ville de naissance ?',
  'Quel est le nom de votre premier atelier ?',
  'Quel était le surnom de votre enfance ?',
  'Autre (à écrire vous-même)',
];
