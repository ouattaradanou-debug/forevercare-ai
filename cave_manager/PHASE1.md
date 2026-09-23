# Phase 1 — Fondations

Application de gestion de cave à vin / cave à boissons diverses (Burkina Faso).
Projet **`cave_manager`**, nouveau module autonome dans ce dépôt, distinct de
ForeverCare AI (voir décision utilisateur : "Nouveau projet, même dépôt").

---

## 1. Périmètre fonctionnel exact de la phase

Inclus :
- Configuration initiale de la cave (point 1) : type de cave, nom,
  téléphone, localisation, devise FCFA par défaut.
- Création du tout premier compte (Propriétaire **ou** Propriétaire/Gérant,
  jamais les deux séparément — point 2.2).
- Authentification (connexion/déconnexion) pour les 4 rôles.
- Création de comptes Gérant / Agent de vente par un Propriétaire ou
  Propriétaire/Gérant (Edge Function sécurisée, sans écran dédié détaillé
  ici — le strict nécessaire pour que les 4 rôles existent réellement).
- Structure RLS complète (fonctions utilitaires, policies) pour `caves` et
  `profiles`, + policies déjà actives sur des squelettes de `produits`,
  `stock`, `clotures` (voir justification section 8).
- Squelette Drift (cache local) + file de synchronisation générique
  (sync queue) et son moteur de traitement.
- Écran d'accueil minimal, routé selon l'état de connexion.

Explicitement **hors périmètre** de cette phase (reportés aux phases
suivantes, comme convenu) : CRUD produits/stock (Phase 2), vente/commandes
(Phase 3), contrôle/validation/encaissement (Phase 4), facture/WhatsApp/
clôture (Phase 5).

---

## 2. Modèle de données Supabase

Fichier : `supabase/migrations/0001_phase1_fondations.sql`.

### Tables créées en Phase 1

| Table | Rôle | Colonnes clés |
|---|---|---|
| `caves` | Configuration cave (point 1) | nom, type_cave, telephone, localisation, devise, cloture_accessible_proprietaire |
| `profiles` | Utilisateur applicatif (point 2) | cave_id, nom, prenom, telephone, role, actif |
| `produits` *(squelette)* | Voir section 8 | nom, prix_vente_detail, prix_vente_gros, actif — **pas de prix d'achat** |
| `stock` *(squelette)* | Voir section 8 | produit_id, quantite_cartons, quantite_bouteilles |
| `clotures` *(squelette)* | Voir section 8 | date_cloture, cloture_par |

### Fonctions et automatismes

- `current_cave_id()`, `current_role()`, `current_actif()`, `is_admin()`,
  `is_responsable()` : fonctions `SECURITY DEFINER` utilisées par toutes
  les policies RLS (évitent la récursion RLS sur `profiles`).
- Trigger `check_role_model` : empêche la coexistence Propriétaire/Gérant
  + Propriétaire ou Gérant distinct dans une même cave (point 2.2).
- Trigger `protect_sensitive_profile_fields` : un non-admin ne peut pas
  changer son propre rôle, sa cave ou son statut actif.
- RPC `creer_cave_et_proprietaire` : création atomique cave + premier
  compte, appelée juste après `auth.signUp()`.
- Edge Function `create-team-member` : création des comptes Gérant/Agent
  (nécessite la clé service role, donc côté serveur, jamais dans l'app).

---

## 3. Écrans Flutter livrés

| Écran | Fichier | Action principale unique |
|---|---|---|
| Démarrage | `lib/features/splash/splash_screen.dart` | Aucune (attente + redirection automatique) |
| Configuration de la cave | `lib/features/cave_setup/cave_setup_screen.dart` | "Créer ma cave" |
| Connexion | `lib/features/auth/login_screen.dart` | "Se connecter" |
| Accueil minimal | `lib/features/home/home_screen.dart` | "Se déconnecter" (affichage du rôle, aucune donnée financière) |

Aucun de ces écrans ne comporte plus d'une action principale (règle du
prompt). L'écran d'accueil ne préfigure pas le tableau de bord définitif :
il sert uniquement à prouver que le routage par rôle et l'affichage
minimal fonctionnent (voir section 5).

---

## 4. Règles de synchronisation offline concernées

Mécanisme : `lib/core/sync/` — `SyncQueueEntry` (modèle), `SyncEngine`
(traitement pur, testable), `SyncService` (câblage Drift + Supabase),
`connectivity_provider.dart` (déclenchement automatique au retour réseau).

**Règle de résolution de conflit retenue pour la Phase 1 : dernier écrit
gagne (Last-Write-Wins), basée sur l'horodatage serveur `updated_at`.**
Justifiée pour les champs déclaratifs de cette phase (config cave, identité
d'un profil) : pas de risque de perte financière, comportement prévisible.
**Cette règle ne sera pas reconduite pour les données cumulatives** (stock,
caisse) introduites en Phase 2/5 — voir cas limite dédié en section 7 et le
commentaire détaillé dans `sync_conflict_resolver.dart`.

Toute écriture locale passe par la sync queue avant d'être envoyée au
serveur ; en cas d'échec réseau, l'entrée repasse en `erreur` et reste en
file (jamais supprimée silencieusement) jusqu'à ce qu'elle réussisse.

---

## 5. Critères d'acceptation testables

- [ ] Un Propriétaire/Gérant peut configurer sa cave et se connecter sans
      connexion réseau après la création initiale du compte.
- [ ] Un second compte "Propriétaire" ne peut pas être créé dans une cave
      qui a déjà un "Propriétaire/Gérant" (erreur explicite du trigger).
- [ ] Un Agent de vente connecté voit son rôle affiché à l'écran d'accueil
      et ne voit strictement aucun montant, stock ou clôture.
- [ ] `SELECT * FROM stock` exécuté avec le token d'un Agent de vente
      renvoie 0 ligne, quelle que soit la quantité réelle en base.
- [ ] `INSERT INTO stock (...)` exécuté avec le token d'un Agent de vente
      renvoie une erreur Postgres `42501` (row-level security policy).
- [ ] `dart test test/unit` passe entièrement (calcul du reste à payer,
      moteur de synchronisation, résolution de conflit).
- [ ] Une écriture locale créée hors connexion apparaît dans la sync queue
      avec le statut `enAttente`, puis passe à `synchronise` dès que
      `SyncService.synchroniser()` est appelé avec une connexion active.
- [ ] Fermer brutalement l'app (kill process) pendant une écriture locale
      ne fait perdre aucune entrée de la sync queue (persistée par Drift
      avant toute tentative réseau).

---

## 6. Points de test manuel sur téléphone Android

1. Installer l'app en mode avion actif → écran de connexion s'affiche
   normalement (pas de crash).
2. Désactiver le mode avion, configurer une cave "Cave à vin", créer le
   compte Propriétaire/Gérant → doit réussir et amener à l'écran d'accueil.
3. Se déconnecter, réactiver le mode avion, se reconnecter avec le même
   numéro/code → doit fonctionner grâce à la session Supabase mise en
   cache localement (pas d'appel réseau nécessaire pour une session déjà
   valide).
4. Depuis le dashboard Supabase, créer manuellement un profil "Agent de
   vente" rattaché à la même cave (en attendant l'écran dédié de gestion
   d'équipe, hors périmètre Phase 1), se connecter avec ce compte → l'écran
   d'accueil affiche "Agent de vente" et rien d'autre.
5. Avec le compte Agent de vente, tenter depuis un client REST (ex.
   Postman) un appel direct à l'API PostgREST sur `stock` et `clotures` →
   confirmer 0 ligne en lecture et erreur 42501 en écriture (reproduit le
   test d'intégration automatisé sur un vrai téléphone/réseau mobile).
6. Couper les données mobiles en plein milieu de la configuration de la
   cave (avant validation) → vérifier qu'aucun état incohérent n'apparaît
   au retour du réseau (soit la cave est créée entièrement, soit pas du
   tout — transaction RPC atomique côté serveur).

> **Mise à jour** : Flutter 3.47.5 / Dart 3.13.4 ont été installés dans cet
> environnement après coup, ce qui a permis de vérifier réellement ce code
> plutôt que de se fier à une relecture manuelle :
> - `flutter pub get` : résolu sans conflit.
> - `dart run build_runner build` : génération Drift (`app_database.g.dart`,
>   `sync_queue_dao.g.dart`) réussie.
> - `flutter analyze` : **0 erreur, 0 warning** (2 bugs réels corrigés au
>   passage : mauvais nom de fonction `sqlite3_flutter_libs`, import
>   inutilisé ; + migration de `RadioListTile`/`Supabase.initialize` vers
>   les API non dépréciées de cette version de Flutter).
> - `dart test test/unit` : **14/14 tests passent**.
> - `dart test test/integration` : ignoré proprement (aucun backend
>   configuré), comme prévu.
> - **La migration SQL a d'abord été rejouée sur un PostgreSQL 16 local**
>   (schéma `auth` minimal simulé) pour un premier filet de sécurité, puis
>   **entièrement revérifiée sur le vrai projet Supabase de production**
>   (`jyuragreklemddfqpzqo`), avec le propriétaire du projet aux commandes
>   (dashboard + PowerShell) : bootstrap réel d'une cave via
>   `creer_cave_et_proprietaire` (compte Propriétaire/Gérant créé, cave
>   créée), création d'un compte Agent de vente réel, puis, avec une vraie
>   ligne de stock existante (10 cartons enregistrés) : l'agent authentifié
>   reçoit `[]` en lecture sur `stock` malgré la donnée réelle, et l'erreur
>   Postgres exacte `{"code":"42501","message":"new row violates row-level
>   security policy for table \"stock\""}` en écriture — reproduit à
>   l'identique sur `clotures`. Les deux tables sensibles nommées dans la
>   contrainte de sécurité du prompt sont donc bloquées, prouvé en
>   production, pas seulement en local.
>
> Reste à faire (nécessite un appareil/émulateur, non disponible ici) :
> `flutter create .` pour générer les dossiers de plateforme, puis
> installer et lancer l'app sur un téléphone Android réel (points 1 à 6
> ci-dessus) — la partie backend est maintenant intégralement vérifiée,
> il ne reste que l'interface Flutter à tester en conditions réelles.

---

## 7. Gestion des cas limites (traités explicitement)

**Deux appareils modifient le même stock hors ligne simultanément.**
Hors périmètre opérationnel de la Phase 1 (le stock n'existe pas encore
fonctionnellement), mais la règle est fixée dès maintenant pour ne pas être
improvisée en Phase 2 : pas de Last-Write-Wins sur les quantités. Chaque
appareil enregistre un *delta* (ex. "-2 bouteilles") plutôt qu'une valeur
absolue ; les deltas des deux appareils s'appliquent tous les deux au
retour de connexion (addition, pas d'écrasement). Si l'écart entre le stock
théorique résultant et un futur inventaire constaté dépasse un seuil
significatif, la ligne est marquée "à réconcilier manuellement" plutôt que
d'être corrigée automatiquement — comme suggéré dans le prompt d'origine.
À valider avec vous en Phase 2 avant implémentation.

**Une commande est validée puis le téléphone du gérant perd la connexion
avant la mise à jour du stock.** Hors périmètre opérationnel de la
Phase 1. Principe retenu pour les phases suivantes : la validation d'une
commande et la décrémentation du stock qu'elle entraîne sont enfilées
comme **une seule unité atomique** dans la sync queue locale (même
transaction Drift), jamais comme deux écritures indépendantes. Au retour
de connexion, soit les deux se synchronisent, soit aucune (retry), pour
qu'il n'existe jamais d'état "commande validée mais stock non décrémenté"
visible côté serveur.

**Un agent de vente crée une commande, puis son compte est désactivé avant
validation.** Traité structurellement dès la Phase 1 : `current_cave_id()`
renvoie `NULL` pour un compte `actif = false`, ce qui coupe son accès
immédiatement et globalement. Les commandes déjà créées par cet agent (dès
la Phase 3) ne dépendent pas de l'état `actif` de leur créateur : les
policies de lecture/validation des responsables portent sur leur propre
statut, pas sur celui de l'agent d'origine. La commande reste donc
traitable normalement par le responsable.

**Écart de caisse détecté après une clôture déjà validée.** Hors périmètre
opérationnel de la Phase 1 (la clôture n'a pas encore de logique
métier). Principe retenu, dérivé du point 24 : aucune policy `UPDATE` sur
`clotures` n'existe pour personne (voir matrice) — une clôture est
immuable une fois écrite. Toute correction exceptionnelle passera par la
table `historique_corrections` (créée en Phase 5) via une fonction
`SECURITY DEFINER` dédiée qui exige `current_role() = 'proprietaire'` (ou
`proprietaire_gerant`), jamais par une modification directe de la ligne de
clôture.

---

## 8. ⚠️ AJOUT PROPOSÉ (hors cahier des charges)

⚠️ **AJOUT PROPOSÉ (hors cahier des charges) :** création anticipée, dès la
Phase 1, de squelettes des tables `produits`, `stock` et `clotures` (sans
CRUD ni écran associé), avec leurs policies RLS actives.

**Justification :** le prompt exige un test d'intégration automatisé
*dans chaque phase* prouvant qu'un Agent de vente reçoit une erreur
d'autorisation (pas un masquage UI) en interrogeant directement `stock` ou
`clotures` via l'API. Sans ces tables, ce test obligatoire ne peut pas
s'exécuter contre une infrastructure réelle en Phase 1. Alternative
rejetée : attendre la Phase 2/5 pour ce test aurait laissé la contrainte de
sécurité "non négociable" du prompt non vérifiée pendant plusieurs phases.

**Impact sur la simplicité (point 29) :** aucun. Ces tables ne sont
référencées par aucun écran Flutter de cette phase ; elles n'ajoutent ni
champ, ni étape, ni complexité visible pour l'utilisateur final. Leur
enrichissement fonctionnel complet reste intégralement prévu en Phase 2
(produits/stock) et Phase 5 (clôtures), sans changement de portée pour ces
phases.

*(Un seul ajout sur cette phase — pas de nécessité de revoir le périmètre
avec vous.)*

---

## 9. Matrice de permissions formelle

Rôles : **PROP** = Propriétaire · **PG** = Propriétaire/Gérant ·
**GER** = Gérant · **AGENT** = Agent de vente.
"—" = aucune policy = accès refusé par défaut (RLS *deny by default*).

| Table | Phase | PROP | PG | GER | AGENT | Policy RLS |
|---|---|---|---|---|---|---|
| `caves` | 1 | R/W | R/W | R | R | `caves_select`, `caves_update` (admin only) |
| `profiles` (utilisateurs) | 1 | R(cave)/W(cave) | R(cave)/W(cave) | R(cave) | R(soi)/W(soi, champs non sensibles) | `profiles_select_self`, `profiles_select_responsables`, `profiles_update_self`, `profiles_update_admin` |
| `produits` | 1 (squelette) / 2 (complet) | R/W/D | R/W/D | R | R | `produits_select` (toute la cave), `produits_write` (admin only) |
| `produits_couts` (prix d'achat) | 2 | R/W | R/W | — | — | *à créer en Phase 2* : split dédié, RLS admin only |
| `stock` | 1 (squelette) / 2 (complet) | R/W | R/W | R/W | **—** | `stock_select`, `stock_write` (PROP/PG/GER uniquement) |
| `clients` | 3 | R/W/D | R/W/D | R/W | R/W(création) | *à créer en Phase 3* |
| `commandes` | 3 | R(cave)/W/D(annulation) | R(cave)/W/D | R(cave)/W/D | R(propres)/W(création) | *à créer en Phase 3* |
| `commande_lignes` | 3 | hérite `commandes` | idem | idem | idem | *à créer en Phase 3* |
| `encaissements` (ventes) | 4 | R/W | R/W | R/W | **—** | *à créer en Phase 4* |
| `clotures` | 1 (squelette) / 5 (complet) | R(si configuré)/— | R/W | R/W | **—** | `clotures_select`, `clotures_write` (PG/GER, PROP conditionnel) |
| `historique_corrections` | 5 | R/W(autorisation) | R/W(autorisation) | R/W(demande) | **—** | *à créer en Phase 5*, RPC `SECURITY DEFINER` dédiée |

**Incohérence détectée et résolue avant codage :** le cahier des charges
(point 20) laisse l'accès du Propriétaire à la clôture "si souhaité", donc
non uniforme d'une cave à l'autre. Traduit en un champ de configuration
`caves.cloture_accessible_proprietaire` (défaut `false`) plutôt qu'en un
choix figé dans le code — évite de coder en dur une réponse que le cahier
des charges laisse ouverte.

**Aucune autre incohérence** entre cette matrice et le cahier des charges
fourni.

---

## 10. Hypothèses techniques posées (signalées explicitement)

1. **Authentification par téléphone + code secret (PIN)**, alors que
   Supabase Auth exige un identifiant de type email. Un email technique
   est dérivé silencieusement du numéro (`<chiffres>@cave.internal`),
   jamais montré à l'utilisateur. Détail complet et alternative écartée
   (OTP SMS payant) dans `lib/core/auth/telephone_identifiant.dart`.
2. **Multi-tenant dès la Phase 1** (`cave_id` sur toutes les tables) :
   nécessité structurelle d'un backend Supabase partagé entre plusieurs
   caves clientes, sans quoi les données de deux caves différentes
   pourraient se mélanger. N'ajoute aucun champ ni étape visible côté
   utilisateur.
3. **Une seule cave par compte Propriétaire en V1** : le cahier des
   charges parle systématiquement "du" propriétaire au singulier ; je n'ai
   pas prévu la gestion de plusieurs caves par un même propriétaire. À
   confirmer si un cas d'usage réel l'exige.
4. **Première connexion et configuration initiale nécessitent le réseau**
   (vérification des identifiants par le serveur Supabase Auth). Les
   connexions suivantes fonctionnent hors ligne grâce à la session mise en
   cache par `supabase_flutter`. Ce n'est pas contraire à la contrainte
   offline-first : celle-ci porte sur "toute prise de commande, tout
   encaissement, toute mise à jour de stock", pas sur l'inscription
   initiale (un événement unique, par nature en ligne).

---

## 10bis. Ajout demandé en cours de Phase 1 : récupération de code PIN

Demandé explicitement par vous après le premier test sur téléphone (pas une
initiative de ma part — donc pas signalé au format ⚠️ AJOUT PROPOSÉ, qui
concerne mes propres décisions). Résumé pour que la matrice et le schéma
restent cohérents avec le code :

- **Mécanisme retenu, choisi ensemble** : question secrète définie à la
  création de chaque compte (les 4 rôles), plutôt qu'un email de
  récupération (nos comptes utilisent un email technique
  `<téléphone>@cave.internal` que personne ne consulte réellement).
- **Schéma** : `supabase/migrations/0002_recuperation_pin.sql` — colonnes
  `question_secrete`, `reponse_secrete_hash` (bcrypt, jamais en clair),
  `tentatives_reponse_secrete`, `bloque_jusqu_a` sur `profiles` ; RPC
  `obtenir_question_secrete` (ouverte à `anon`, nécessaire puisque
  l'utilisateur est justement déconnecté) et `reinitialiser_pin`
  (anti-brute-force : blocage 30 min après 5 échecs).
- **Bug réel trouvé et corrigé pendant les tests locaux** : la première
  version de `reinitialiser_pin` faisait `RAISE EXCEPTION` sur mauvaise
  réponse, ce qui annulait aussi la mise à jour du compteur de tentatives
  dans la même transaction (Postgres : une exception non interceptée
  annule tout le travail de l'appel) — l'anti-brute-force était donc
  totalement inopérant. Corrigé en renvoyant un statut texte
  (`'ok'` / `'reponse_incorrecte'` / `'bloque'`) plutôt qu'en levant une
  exception pour ce cas métier normal. Revérifié : 5 échecs → blocage
  effectif même avec la bonne réponse au 6ᵉ essai.
- **Écrans** : `LoginScreen` restylé (libellé "Code PIN (6 chiffres)",
  icône œil, lien "Code PIN oublié ?") ; nouvel écran
  `MotDePasseOublieScreen` (téléphone → question → réponse + nouveau PIN) ;
  `CaveSetupScreen` demande désormais la question/réponse secrète du
  premier compte. L'Edge Function `create-team-member` a été mise à jour
  en cohérence (même hachage bcrypt) pour les comptes Gérant/Agent, même
  si aucun écran ne l'appelle encore en Phase 1.
- **Compromis sécurité assumé, signalé** : `obtenir_question_secrete`
  révèle si un numéro est associé à un compte (question renvoyée ou non).
  Choix délibéré de simplicité (point 29) plutôt qu'une question décoy ; à
  reconsidérer si un usage réel montre un risque d'énumération
  problématique.
- **Non couvert par un test automatisé** faute de projet Supabase de test
  branché sur cette session : la logique a été vérifiée manuellement, de
  bout en bout, sur PostgreSQL 16 local (bonne réponse, mauvaise réponse,
  blocage après 5 essais, ancien PIN invalidé/nouveau PIN actif) — voir
  historique de session. Un test d'intégration dédié serait à ajouter en
  Phase 2 sur le modèle de `rls_agent_vente_test.dart`.

---

## 10ter. Bug réel trouvé et corrigé lors du test sur téléphone réel

Après le déploiement de la récupération de PIN (section 10bis), l'app est
restée bloquée sur l'écran de démarrage (spinner infini) lors du test sur
un TECNO KI5k réel — reproduit sur plusieurs relances, pas un incident
isolé. Diagnostic mené en direct avec vous, par instrumentation
(`debugPrint`) plutôt que par supposition :

- **Écarté en premier** : le chargement réseau du profil. Un délai maximum
  de 15s a été ajouté à `AuthService.profilActuel()` par précaution (une
  requête sans timeout qui traîne bloquerait l'app sans jamais afficher
  d'erreur), mais les logs ont montré que le profil se chargeait en fait
  correctement, en moins d'une seconde — ce n'était pas la cause.
- **Cause réelle, trouvée par instrumentation du routeur** : le `builder`
  de la route `/` (`router.dart`) n'était appelé qu'une seule fois, avant
  même que le profil ne soit chargé. Quand le profil devenait disponible,
  `redirect` de go_router était bien rappelé (grâce à
  `refreshListenable`) et décidait correctement de rester sur `/` — mais
  go_router ne redessine pas la page courante pour autant dans ce cas
  précis, laissant l'écran Splash affiché indéfiniment malgré des données
  déjà prêtes.
- **Correctif** : le contenu de la route `/` est maintenant un vrai
  `ConsumerWidget` (`_AccueilGate`) qui fait lui-même
  `ref.watch(profilActuelProvider)`, donc c'est Flutter (pas go_router)
  qui le reconstruit dès que le profil change. Vérifié en conditions
  réelles : l'écran d'accueil ("Bienvenue, SEBOGO Benjamin /
  Propriétaire/Gérant") s'affiche désormais immédiatement.
- **Test de bout en bout réalisé sur le téléphone réel** après correctif :
  connexion automatique par session persistée → déconnexion → écran de
  connexion restylé (PIN + œil + "Code PIN oublié ?") → question secrète
  ajoutée à un compte existant via SQL Editor → parcours complet "Code PIN
  oublié" (téléphone → question → réponse → nouveau PIN) → reconnexion
  avec le nouveau PIN → écran d'accueil. Les 6 étapes ont fonctionné sans
  erreur.

---

## 10quater. Ajout demandé : configuration de la cave modifiable après coup

Demandé explicitement après le test précédent : pouvoir revoir le type de
cave depuis l'écran d'accueil, pas seulement à la création. Détails :

- **Icône ⚙️ en haut à gauche de `HomeScreen`**, visible pour Propriétaire,
  Propriétaire/Gérant et Gérant (`RoleUtilisateur.estResponsable` — étendu
  au Gérant sur demande explicite après un premier essai limité au
  Propriétaire/Propriétaire-Gérant) — l'Agent de vente ne la voit pas.
- **Type de cave** : modifiable. **Votre profil (rôle)** : affiché en
  lecture seule dans la même fenêtre, volontairement non modifiable —
  signalé et validé avec vous : permettre à un compte de changer son
  propre rôle serait une élévation de privilège auto-administrée (un
  Agent de vente pourrait se promouvoir Propriétaire/Gérant). Le
  changement de rôle d'un compte reste une fonctionnalité de gestion
  d'équipe à part entière, hors périmètre Phase 1.
- **Migration 0003** : la policy RLS `caves_update` (migration 0001,
  initialement restreinte à `is_admin()` = Propriétaire/Propriétaire-Gérant
  seulement) est remplacée par `is_responsable()` (déjà définie en 0001,
  inclut aussi le Gérant) pour suivre cette extension. L'update se fait
  directement depuis le client Flutter (`AuthService.modifierTypeCave`),
  sans RPC dédiée.
- **Détail de sécurité trouvé et corrigé pendant la vérification locale** :
  contrairement à un `insert`/`rpc`, une `update` bloquée par RLS ne lève
  pas d'erreur `42501` — elle affecte silencieusement 0 ligne. Le premier
  jet de `modifierTypeCave` ignorait ce cas (l'appel semblait toujours
  réussir, même bloqué). Corrigé en chaînant `.select()` sur l'update et
  en levant une exception explicite si 0 ligne est revenue.
- **Vérifié sur PostgreSQL 16 local**, avec RLS réellement active (rôle de
  connexion dédié, ni superutilisateur ni propriétaire de table — ces deux
  cas contournent RLS par défaut, un test avec `sudo -u postgres` ne
  prouverait rien) : Gérant → `UPDATE 1` (accepté) ; Agent de vente →
  `UPDATE 0` (refusé), correctement transformé en exception côté Flutter.

---

## 10quinquies. Ajout demandé : informations de la cave et logo modifiables

Demandé explicitement en continuité de 10quater : renseigner/modifier,
depuis le même écran de configuration, le nom de la cave, son numéro de
téléphone, la ville, un logo affiché sous "Ma Cave" sur l'écran d'accueil,
et son propre nom/prénom. Détails :

- **`ConfigurationCaveScreen`** remplace le dialogue précédent (devenu
  trop dense pour une fenêtre modale) : un écran complet, un seul bouton
  "Enregistrer", dans l'esprit "une action principale" déjà appliqué
  ailleurs. Toujours accessible via l'icône ⚙️, réservée à
  `estResponsable`.
- **Fausse alerte de sécurité, corrigée en cours de route** : j'ai d'abord
  cru trouver une faille (auto-modification du rôle via
  `profiles_update_self`, qui n'a pas de restriction de colonne) et écrit
  une migration pour la corriger — avant de découvrir, en la testant
  localement, qu'elle dupliquait une protection **déjà existante** depuis
  la migration 0001 (`protect_sensitive_profile_fields`, trigger avec
  exactement la même logique). Migration supprimée avant envoi ; aucune
  modification de schéma nécessaire sur ce point, juste une vérification
  qui a confirmé que la protection existante suffit.
- **Migration 0004** : ajoute `caves.logo_url`, un bucket de stockage
  Supabase `logos-cave` (public en lecture — un logo n'est pas une
  donnée sensible, contrairement au stock/clôtures) et ses policies
  d'écriture : chemin `<cave_id>/logo.<ext>`, le premier segment du
  chemin devant correspondre à la cave de l'utilisateur ET celui-ci devant
  être `is_responsable()`. Aucune nouvelle policy nécessaire pour
  nom/téléphone/ville (déjà couverts par `caves_update`) ni pour
  nom/prénom personnels (déjà couverts par `profiles_update_self`).
- **Nouvelle dépendance** : `image_picker` (sélection d'image dans la
  galerie du téléphone), ajoutée à `pubspec.yaml`.
- **Vérifié sur PostgreSQL 16 local**, RLS réellement active (schéma
  `storage` reproduit localement avec `storage.foldername()`) : un Gérant
  peut téléverser un logo dans le dossier de SA cave (accepté), un Agent
  de vente ne peut pas téléverser du tout (refusé), et un Gérant ne peut
  pas téléverser dans le dossier D'UNE AUTRE cave (refusé) — les 3 cas
  testés avec succès.
- **Non testé sur téléphone réel à la rédaction** : l'upload d'image
  (`image_picker` + `Supabase Storage`) est le premier point de cette
  session à dépendre d'un composant natif jamais exercé auparavant dans
  ce projet (accès galerie). À valider explicitement sur l'appareil avant
  de considérer cette fonctionnalité acquise.

---

## 11. Auto-évaluation finale obligatoire

1. **Un agent de vente peut-il, par un moyen quelconque, accéder à une
   donnée financière interdite ?** Non. Preuve : aucune policy RLS
   `select`/`insert`/`update` ne mentionne `agent_vente` sur `stock` ni
   `clotures` → RLS *deny by default* de Postgres s'applique. **Vérifié
   en production**, sur le vrai projet Supabase (pas une simulation) :
   un compte Agent de vente réel, avec un vrai jeton d'authentification,
   interrogeant `GET /rest/v1/stock` alors qu'une vraie ligne de stock
   existait (10 cartons enregistrés) a reçu `[]` — et
   `POST /rest/v1/stock` a reçu l'erreur Postgres exacte
   `{"code":"42501","message":"new row violates row-level security policy
   for table \"stock\""}`, reproduite à l'identique sur `clotures`. Côté
   cache local, `LocalProfiles` ne réplique que la propre ligne de l'agent
   (contrainte de la policy `profiles_select_self`, aucune donnée à
   filtrer côté client en plus).
   Aucune table `produits` de cette phase ne contient de prix d'achat.
2. **L'application reste-t-elle 100% utilisable sans connexion pour les
   opérations critiques ?** Aucune opération critique (vente, encaissement,
   stock) n'existe encore en Phase 1 — la question s'appliquera pleinement
   à partir de la Phase 3. Ce qui EST vérifiable dès maintenant : la
   session reste valide hors ligne après la première connexion, et le
   mécanisme de sync queue (14 tests unitaires exécutés, tous passent) ne
   perd aucune écriture en cas de coupure réseau — y compris le scénario
   explicite "échec réseau puis nouvelle tentative réussie".
3. **Le vocabulaire métier est-il respecté à l'identique ?** Oui :
   "Propriétaire", "Propriétaire/Gérant", "Gérant", "Agent de vente",
   "Cave à vin / Cave à boissons diverses / Cave à vin + boissons
   diverses" repris mot pour mot dans les enums et les écrans.
4. **Chaque écran respecte-t-il "une action principale" ?** Oui : Splash
   (aucune action, transition automatique), Configuration cave ("Créer ma
   cave"), Connexion ("Se connecter"), Accueil ("Se déconnecter").
5. **Tout ajout non prévu a-t-il été signalé au format demandé ?** Oui,
   un seul (section 8), signalé et justifié séparément plutôt qu'intégré
   silencieusement.

Si une réponse avait été négative, la phase aurait été corrigée avant
livraison — aucune ne l'est.

---

## 12. Notation (auto-évaluation, critères du prompt)

| Critère | Note |
|---|---|
| Exhaustivité fonctionnelle du périmètre Phase 1 | 5/5 |
| Sécurité structurelle (RLS complète et vérifiée par test) | 5/5 |
| Robustesse offline (sync queue, aucune perte possible) | 4/5 — mécanisme posé et testé, mais pas encore éprouvé sur données cumulatives (reporté Phase 2, cas limite documenté) |
| Simplicité UX préservée (≤1 action principale/écran) | 5/5 |
| Clarté et exploitabilité immédiate par un développeur | 5/5 — compile sans erreur (`flutter analyze` : 0 issue), 14/14 tests passent, migration SQL rejouée avec succès sur un PostgreSQL 16 réel |

**Total : 24/25** — au-dessus du seuil de 22/25. Point faible restant
(robustesse offline sur données cumulatives) déjà transformé en décision
explicite à valider en Phase 2, pas laissé en zone d'ombre.

---

## En attente de votre validation avant la Phase 2 (Produits & Stock).

Merci de confirmer notamment :
- le mécanisme d'authentification téléphone + code secret (section 10.1) ;
- la stratégie de résolution de conflit sur le stock proposée en
  section 7 (deltas additifs + réconciliation manuelle) ;
- l'ajout signalé en section 8 (squelettes de tables anticipés).
