# Tests de la phase 1 — procédure pour un testeur non technique

Durée : 1 heure. **Sur un vrai téléphone** : installez l'APK d'essai (voir `GUIDE_TEST_TELEPHONE.md`) et sautez l'étape 0. Sur ordinateur : il faut le projet installé (README.md), Android Studio avec un émulateur, et le serveur local démarré.

## 0. Préparer
1. Dans le dossier `ecoleplus`, tapez : `npx supabase start`, puis `npx supabase db reset`.
2. Dans un **second** terminal : `npx supabase functions serve` (laissez-le ouvert).
3. Copiez `.env.example` en `.env` et collez la valeur `ANON_KEY` affichée par `npx supabase status` après `SUPABASE_ANON_KEY=`.
4. Lancez l'application : `flutter run --dart-define-from-file=.env`.

Comptes de test (mot de passe `motdepasse-test`) : `directeur@ecole-test.local`, `enseignant1@ecole-test.local`, `secretaire@ecole-test.local`, `directeur@ecole-temoin.local`. Boîte e-mail de test : http://127.0.0.1:54324

## 1. Première connexion du directeur
1. Touchez « Se connecter », tapez `directeur@ecole-test.local` et le mot de passe.
2. ✅ L'application demande de choisir un **code**. Essayez `1234` : ✅ refusé (« trop facile »). Choisissez un autre code, tapez-le deux fois.
3. ✅ « Bonjour Directeur Test », six gros boutons, bandeau « Tout est synchronisé », et une carte « Choisissez une question secrète ».

## 2. Mode avion (le plus important)
1. Activez le mode avion de l'émulateur.
2. « Mon école » → changez la commune. ✅ Le bandeau affiche « 1 élément en attente — envoi au retour du réseau ». Aucun message d'erreur, rien ne bloque.
3. Fermez complètement l'application et rouvrez-la (toujours en mode avion). ✅ Elle demande votre code (pas de réseau nécessaire), puis affiche l'accueil ; la commune modifiée est toujours là.
4. Désactivez le mode avion. ✅ En quelques secondes : « Tout est synchronisé ».

## 3. Années scolaires et en-têtes
1. « Années scolaires » → « Préparer l'année 2026-2027 ». ✅ Message : en-têtes recopiés.
2. Touchez 2026-2027, changez la région. Revenez, touchez 2025-2026. ✅ La région de 2025-2026 n'a pas changé (chaque année garde ses en-têtes).
3. « Passer à l'année 2026-2027 » → confirmez. ✅ 2026-2027 « Année en cours », 2025-2026 « Archivée — consultable » : on peut encore l'ouvrir.
4. Dans les en-têtes, « Choisir une image » → une image PNG ou JPEG. ✅ L'image s'affiche.

## 4. Options de l'école
1. « Options de l'école » → activez la cantine, puis désactivez-la. ✅ Avant de désactiver, la liste de ce qui sera masqué et « Vos données sont conservées ».
2. Essayez de décocher « Primaire ». ✅ Refus expliqué : au moins un niveau.
3. Activez le dossier médico-scolaire. ✅ Avertissement « Données de santé » avant l'activation (vous pouvez annuler).

## 5. Comptes et droits
1. « Personnes et droits » → « Ajouter une personne » : nom « Test Ajout », profil Enseignant, identifiant `70 12 34 56`. Notez le mot de passe provisoire. ✅ Message « Compte créé » avec l'identifiant et le mot de passe.
2. Ajoutez une personne « Délégué » en cochant « Fiches des élèves ». ✅ La case « Cantine » n'apparaît que si la cantine est activée.
3. Se déconnecter, puis se connecter avec `70 12 34 56` et le mot de passe provisoire. ✅ « Bonjour Test Ajout », aucun bouton de gestion de l'école.

## 6. Ce qu'un enseignant ne peut pas faire
1. Connectez-vous avec `enseignant1@ecole-test.local`. ✅ Pas de boutons « Options », « Personnes », « Mon école ».
2. (Contrôle technique, à faire par le développeur) `npx supabase test db` : ✅ « Result: PASS » (132 vérifications : un enseignant ne voit que sa classe, une école ne voit jamais une autre école, modules OFF/ON/OFF…).

## 7. Mot de passe oublié
1. Se déconnecter → « Se connecter » → « Mot de passe oublié ? » → `secretaire@ecole-test.local` → « Recevoir un code ».
2. Ouvrez http://127.0.0.1:54324, lisez le code à 6 chiffres. Tapez-le avec un nouveau mot de passe. ✅ Connexion directe.
3. Avec un numéro de téléphone : ✅ message « demandez à votre directeur ».

## 8. Sauvegarde
1. Directeur → « Sauvegarde » → « Créer une sauvegarde ». ✅ Le téléphone propose d'envoyer le fichier `ecoleplus-sauvegarde-AAAA-MM-JJ_HHhMM.sqlite`.

## 9. Création d'une nouvelle école
1. Se déconnecter → « Créer mon école ». Remplissez le début du formulaire, quittez l'écran puis revenez. ✅ Ce que vous aviez tapé est toujours là (sauf le mot de passe).
2. Terminez avec une adresse e-mail neuve. ✅ Accueil de la nouvelle école ; « Options » : tout est désactivé.

## 10. Code de verrouillage OU empreinte
1. Rouvrez l'application, tapez un mauvais code 5 fois. ✅ « Trop d'erreurs. Réessayez dans … ».
2. « Code oublié ? » → tapez votre mot de passe (avec Internet). ✅ Nouveau code à choisir ; vos données sont toujours là.
3. Mettez l'application en arrière-plan plus de 2 minutes, revenez. ✅ Le code est redemandé.
4. **Sur un téléphone avec capteur** : à la 1re connexion, deux choix : « Avec mon empreinte » ou « Avec un code ». Choisissez l'empreinte, posez le doigt. ✅ Aucun code demandé. Rouvrez : ✅ « Posez votre doigt sur le capteur », sans clavier.
5. Empreinte : faites-la échouer plusieurs fois (autre doigt). ✅ Le téléphone propose son propre code ou schéma ; il ouvre EcolePlus.
6. « Mon compte » → « Changer ma façon d'ouvrir l'application » → « Avec un code de 4 à 6 chiffres ». Rouvrez : ✅ seul le code est demandé, pas l'empreinte. *(Points 4 à 6 non testables sur l'ordinateur de développement.)*

## 11. Question secrète
1. Connecté comme enseignant (`enseignant1@ecole-test.local`) : « Mon compte » → « Choisir ma question secrète » → une question, une réponse (deux fois) → « Enregistrer ».
2. Déconnectez-vous. « Se connecter » → « Mot de passe oublié ? » → identifiant → « Répondre à ma question secrète ».
3. Mauvaise réponse : ✅ « Réponse incorrecte ». Bonne réponse (même en majuscules) + nouveau mot de passe : ✅ vous êtes connecté.
4. Connectez-vous comme directeur : ✅ carte « 1 événement de sécurité à voir » ; le journal indique « … a changé son mot de passe grâce à sa question secrète ».

## 12. Changement de téléphone (le plus important pour vous)
1. Sur le téléphone A (directeur) : modifiez la commune, ajoutez une image d'en-tête ; attendez « Tout est synchronisé ».
2. Sur un **autre** téléphone B (ou après avoir désinstallé puis réinstallé l'application) : connectez-vous avec le même compte.
3. ✅ Toutes les informations de l'école sont là, **image d'en-tête comprise**.

## 13. Téléphone perdu ou volé
1. Connectez l'enseignant sur le téléphone B. Sur le téléphone A (directeur) : « Sécurité » → « Téléphones de l'école ». ✅ Le téléphone de l'enseignant apparaît, avec sa dernière synchronisation et ses éléments non envoyés.
2. « Déconnecter ce téléphone » → lisez l'avertissement → confirmez.
3. Sur le téléphone B, touchez le bandeau puis « Synchroniser maintenant ». ✅ Les données de l'école disparaissent ; message « Ce téléphone a été déconnecté par le directeur ».
4. L'enseignant se reconnecte avec son mot de passe : ✅ il retrouve ses données.

## 14. Journal d'activité
1. Directeur → « Sécurité » → « Journal d'activité ». ✅ Phrases simples : qui a modifié quoi, quand ; connexions des nouveaux téléphones ; téléphone déconnecté.

## 15. Alerte de synchronisation (conditionnelle)
1. En mode avion, modifiez une information et ne vous reconnectez pas pendant 3 jours. ✅ Carte « … ne sont pas encore envoyés » sur l'accueil.
2. Sans rien en attente, aucune alerte avant 30 jours sans réseau. *(Vérifié par les tests automatiques ; sur téléphone, avancer la date du téléphone permet de le constater.)*

## 12. Connexion du directeur avec son numéro (A11)
1. Connecté comme directeur : Sécurité → Mon compte → « Mon numéro pour me connecter » → votre numéro → « Enregistrer ». ✅ « Numéro enregistré ».
2. Essayez le numéro d'un enseignant déjà créé. ✅ « Ce numéro est déjà utilisé… ».
3. Déconnectez-vous. « Se connecter » avec **le numéro** et un mauvais mot de passe. ✅ Refus, sans afficher votre e-mail.
4. Même numéro, bon mot de passe. ✅ Connexion. Le journal d'activité indique « … s'est connecté avec son numéro de téléphone ».
5. Création d'une nouvelle école : le champ « Votre numéro de téléphone (facultatif) » permet de se connecter ensuite avec ce numéro.

