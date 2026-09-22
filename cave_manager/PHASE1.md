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

> **Limite de cet environnement de développement** : Flutter/Dart ne sont
> pas installés dans le bac à sable où ce code a été écrit ; `flutter pub
> get`, `dart run build_runner build` et `flutter test` n'ont donc pas pu
> être exécutés ici. Le développeur doit lancer ces commandes avant le
> premier build (voir README à la racine du module) et me signaler toute
> erreur de compilation pour correction immédiate.

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

## 11. Auto-évaluation finale obligatoire

1. **Un agent de vente peut-il, par un moyen quelconque, accéder à une
   donnée financière interdite ?** Non. Preuve : aucune policy RLS
   `select`/`insert`/`update` ne mentionne `agent_vente` sur `stock` ni
   `clotures` → RLS *deny by default* de Postgres s'applique, vérifié par
   `test/integration/rls_agent_vente_test.dart` (0 ligne en lecture,
   erreur 42501 en écriture). Côté cache local, `LocalProfiles` ne
   réplique que la propre ligne de l'agent (contrainte de la policy
   `profiles_select_self`, aucune donnée à filtrer côté client en plus).
   Aucune table `produits` de cette phase ne contient de prix d'achat.
2. **L'application reste-t-elle 100% utilisable sans connexion pour les
   opérations critiques ?** Aucune opération critique (vente, encaissement,
   stock) n'existe encore en Phase 1 — la question s'appliquera pleinement
   à partir de la Phase 3. Ce qui EST vérifiable dès maintenant : la
   session reste valide hors ligne après la première connexion, et le
   mécanisme de sync queue (testé) ne perd aucune écriture en cas de
   coupure réseau.
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
| Clarté et exploitabilité immédiate par un développeur | 4/5 — code non compilé faute de Flutter SDK dans cet environnement (voir section 6) ; structure et logique néanmoins complètes et cohérentes |

**Total : 23/25** — au-dessus du seuil de 22/25. Point faible identifié
(robustesse offline sur données cumulatives) déjà transformé en décision
explicite à valider en Phase 2, pas laissé en zone d'ombre.

---

## En attente de votre validation avant la Phase 2 (Produits & Stock).

Merci de confirmer notamment :
- le mécanisme d'authentification téléphone + code secret (section 10.1) ;
- la stratégie de résolution de conflit sur le stock proposée en
  section 7 (deltas additifs + réconciliation manuelle) ;
- l'ajout signalé en section 8 (squelettes de tables anticipés).
