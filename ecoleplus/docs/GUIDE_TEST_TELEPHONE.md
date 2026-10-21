# Tester sur un vrai téléphone après chaque phase (A7)

Principe : un **serveur de test** en ligne (Supabase, offre gratuite) + un **APK** construit automatiquement par GitHub. À la fin de chaque phase, il suffit de lancer « Livraison téléphone » et de télécharger l'APK sur le téléphone.

⚠️ Serveur de test = **données fictives uniquement** (« École Test »). Ne jamais y mettre de vrais élèves.

## A. Une seule fois : créer le serveur de test (15 minutes)
1. Sur un ordinateur, allez sur https://supabase.com et créez un compte (gratuit).
2. « New project » : nom `ecoleplus-test` ; choisissez un **mot de passe de base de données** long et notez-le ; région : la plus proche (par exemple Europe de l'Ouest).
3. Une fois le projet créé, notez (menu « Project Settings ») :
   * **Project ref** : les 20 lettres dans l'adresse du projet (`https://supabase.com/dashboard/project/XXXXXXXXXXXXXXXXXXXX`) ;
   * **Project URL** (« Data API ») : `https://XXXXXXXXXXXXXXXXXXXX.supabase.co` ;
   * **Clé publique** (« API Keys » → *publishable* ou *anon*). Elle n'est pas secrète.
4. Créez un **jeton d'accès** : avatar en haut à droite → « Access Tokens » → « Generate new token » (nom : `github-ecoleplus`). Copiez-le.
5. Pour la sauvegarde quotidienne : « Connect » → copiez la **chaîne de connexion** (*Session pooler*), en remplaçant `[YOUR-PASSWORD]` par le mot de passe de l'étape 2.

## B. Une seule fois : enregistrer ces informations dans GitHub
Dépôt `forevercare-ai` → **Settings** → **Secrets and variables** → **Actions**.

Onglet **Secrets** (« New repository secret ») — jamais ailleurs, jamais dans un message :

| Nom | Valeur |
|---|---|
| `SUPABASE_ACCESS_TOKEN` | le jeton de l'étape A4 |
| `SUPABASE_PROJECT_REF` | les 20 lettres de l'étape A3 |
| `SUPABASE_DB_PASSWORD` | le mot de passe de l'étape A2 |
| `SUPABASE_DB_URL` | la chaîne de connexion de l'étape A5 |
| `BACKUP_PASSPHRASE` | une phrase longue inventée (ex. 6 mots) — **écrivez-la aussi sur papier, rangée à l'école** : sans elle, les sauvegardes sont illisibles |

Onglet **Variables** (« New repository variable ») :

| Nom | Valeur |
|---|---|
| `SUPABASE_URL` | l'adresse de l'étape A3 |
| `SUPABASE_ANON_KEY` | la clé publique de l'étape A3 |

## C. À chaque phase : produire l'APK
1. GitHub → onglet **Actions** → « EcolePlus — livraison téléphone » → **Run workflow**.
   * La **première fois**, cochez « Remettre le serveur de test à zéro » (installe « École Test »).
   * Ensuite, laissez décoché : vos essais sont conservés et seules les nouveautés sont ajoutées.
2. Attendez la coche verte (10 à 15 minutes). Le résumé indique le **poids de l'APK**.
3. Sur le téléphone : ouvrez GitHub → **Releases** → la dernière « essai téléphone » → touchez `ecoleplus-test-recent.apk` (≈ 23 Mo, la plupart des téléphones). S'il refuse de s'installer, prenez `ecoleplus-test-ancien.apk` (≈ 21 Mo, téléphones anciens).
4. Android demande d'autoriser l'installation depuis le navigateur : acceptez (une fois).
5. Ouvrez EcolePlus et suivez `docs/TESTS_PHASE_N.md` de la phase.

Comptes de test (mot de passe `motdepasse-test`) : `directeur@ecole-test.local`, `enseignant1@ecole-test.local`, `enseignant2@ecole-test.local`, `secretaire@ecole-test.local`.

## D. Bon à savoir
* L'offre gratuite de Supabase met le projet **en pause après une semaine sans utilisation** : il suffit de le relancer depuis supabase.com (bouton « Restore »).
* L'envoi d'e-mails intégré à Supabase est très limité (quelques messages par heure, et seulement vers les adresses de l'équipe du projet). Pour l'essai, utilisez plutôt la **question secrète** ; pour l'école pilote, il faudra configurer un service d'e-mail (SMTP).
* Je ne peux pas lancer ces étapes à votre place : les secrets doivent être saisis par vous dans GitHub. Une fois enregistrés, dites-le-moi : je lance la livraison et je vérifie le résultat.
