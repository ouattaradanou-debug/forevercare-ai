# Tests de la phase 1 — procédure pour un testeur non technique

Durée : 45 minutes. Il faut l'ordinateur où le projet est installé (README.md), Android Studio avec un émulateur, et le serveur local démarré.

## 0. Préparer
1. Dans le dossier `ecoleplus`, tapez : `npx supabase start`, puis `npx supabase db reset`.
2. Dans un **second** terminal : `npx supabase functions serve` (laissez-le ouvert).
3. Copiez `.env.example` en `.env` et collez la valeur `ANON_KEY` affichée par `npx supabase status` après `SUPABASE_ANON_KEY=`.
4. Lancez l'application : `flutter run --dart-define-from-file=.env`.

Comptes de test (mot de passe `motdepasse-test`) : `directeur@ecole-test.local`, `enseignant1@ecole-test.local`, `secretaire@ecole-test.local`, `directeur@ecole-temoin.local`. Boîte e-mail de test : http://127.0.0.1:54324

## 1. Première connexion du directeur
1. Touchez « Se connecter », tapez `directeur@ecole-test.local` et le mot de passe.
2. ✅ « Bonjour Directeur Test », cinq gros boutons, bandeau « Tout est synchronisé ».

## 2. Mode avion (le plus important)
1. Activez le mode avion de l'émulateur.
2. « Mon école » → changez la commune. ✅ Le bandeau affiche « 1 élément en attente — envoi au retour du réseau ». Aucun message d'erreur, rien ne bloque.
3. Fermez complètement l'application et rouvrez-la (toujours en mode avion). ✅ Elle s'ouvre directement sur l'accueil ; la commune modifiée est toujours là.
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
