# Phase 2 — Produits & Stock

Suite de [PHASE1.md](./PHASE1.md) (fondations, validées). Cette phase ajoute le
CRUD produits et la gestion de stock, conformément au périmètre annoncé en
Phase 1 (section 1) et à la stratégie de conflit hors ligne validée avec vous
avant codage (PHASE1.md section 7).

---

## 1. Périmètre fonctionnel exact de la phase

Inclus :
- Catalogue produits : création/modification (Propriétaire,
  Propriétaire/Gérant et Gérant), consultation (tous les rôles).
- Prix d'achat, séparé du reste du produit, visible et modifiable par
  Propriétaire, Propriétaire/Gérant et Gérant — l'Agent de vente en reste
  seul exclu (mis à jour par rapport au point 18 initial du cahier des
  charges, voir section 8).
- Stock : consultation et ajustement (Propriétaire, Propriétaire/Gérant,
  Gérant) — l'Agent de vente n'y a **aucun** accès, ni en lecture ni en
  écriture (point 2.3).
- Mécanisme de synchronisation offline pour les ajustements de stock :
  chaque ajustement est un *delta*, jamais une valeur absolue ; deux
  appareils qui ajustent le même produit hors ligne voient leurs deltas
  s'additionner au retour de connexion (validé avec vous avant
  implémentation, voir décision ci-dessous).

Explicitement **hors périmètre** de cette phase (reportés comme convenu) :
vente/commandes (Phase 3), contrôle/validation/encaissement (Phase 4),
facture/WhatsApp/clôture (Phase 5).

**Non implémenté dans cette phase, signalé explicitement** : le mécanisme de
"réconciliation manuelle" au-delà d'un seuil d'écart significatif, évoqué en
Phase 1 comme piste possible. Le stock ne descend jamais sous zéro (filet de
sécurité côté trigger), mais aucun signalement automatique d'écart anormal
n'existe encore — l'historique complet des mouvements (`mouvements_stock`)
reste consultable pour une réconciliation manuelle si besoin. À ajouter si un
usage réel en montre la nécessité, plutôt que construit par anticipation.

---

## 2. Décision validée avec vous avant implémentation

**Question posée** : comment gérer un conflit quand deux appareils modifient
le même stock hors ligne puis se resynchronisent ?

**Réponse retenue : deltas additifs.** Chaque ajustement de stock est
enregistré comme une variation (`+3 cartons`, `-2 bouteilles`...), jamais
comme une quantité absolue. Au retour de connexion, tous les mouvements
en attente s'appliquent, et s'additionnent au total existant — aucun
écrasement possible, contrairement à un Last-Write-Wins qui ferait perdre
un des deux mouvements.

---

## 3. Modèle de données Supabase

Fichier : `supabase/migrations/0007_phase2_produits_stock.sql`.

| Table | Rôle | Colonnes clés |
|---|---|---|
| `produits` (enrichie) | Catalogue | + `type_emballage`, `bouteilles_par_emballage` (voir section 10) |
| `produits_couts` *(nouvelle)* | Prix d'achat, séparé | `produit_id`, `prix_achat` |
| `mouvements_stock` *(nouvelle)* | Journal append-only des deltas | `delta_cartons`, `delta_bouteilles`, `motif`, `created_by` |
| `stock` (déjà créée en Phase 1) | Total courant, recalculé par trigger | inchangée |

**Trigger `appliquer_mouvement_stock`** (`AFTER INSERT` sur
`mouvements_stock`, jamais `UPDATE`) : additionne chaque delta au total
existant dans `stock` (`upsert`), avec un plancher à zéro
(`greatest(..., 0)`). Le choix "`AFTER INSERT` seulement" est ce qui rend
un nouvel essai réseau (retry) sûr : le `RemoteWriter` générique déjà en
place (Phase 1) envoie chaque mouvement via `upsert` avec un id généré côté
client — si le même mouvement est renvoyé deux fois (accusé de réception
perdu, pas l'écriture elle-même), PostgreSQL traite la deuxième tentative
comme une mise à jour d'une ligne déjà existante (`ON CONFLICT DO UPDATE`),
pas comme une nouvelle insertion : le trigger ne se redéclenche donc pas, et
le delta n'est jamais appliqué deux fois. **Vérifié explicitement en local**
(voir section 5).

---

## 4. Matrice de permissions (complète la matrice de PHASE1.md)

| Table | PROP | PG | GER | AGENT | Policy RLS |
|---|---|---|---|---|---|
| `produits` | R/W/D | R/W/D | R/W/D | R | `produits_select` (toute la cave), `produits_write` (`is_responsable()` depuis la migration 0008 — le Gérant doit pouvoir créer/modifier des produits, sans accès au prix d'achat) |
| `produits_couts` | R/W | R/W | R/W | **—** | `produits_couts_select`, `produits_couts_write` (`is_responsable()` depuis la migration 0009 — voir section 8) |
| `stock` | R/W | R/W | R/W | **—** | inchangées depuis la Phase 1 |
| `mouvements_stock` | R/W(insert) | R/W(insert) | R/W(insert) | **—** | `mouvements_stock_select`, `mouvements_stock_insert` — mêmes rôles que `stock`. Aucune policy `UPDATE`/`DELETE` : un mouvement, une fois créé, est immuable (corriger = ajouter un nouveau mouvement, jamais modifier l'historique) |

---

## 5. Vérifications effectuées sur PostgreSQL 16 local (RLS réellement active)

Avant tout envoi vers la production, comme pour toutes les migrations
précédentes :

1. **Fusion additive** : stock initial 10 cartons → deux mouvements de -2
   chacun (simulant deux appareils hors ligne) → stock final = 6 (pas -2
   écrasé par l'autre).
2. **Idempotence au retry** : un mouvement rejoué une deuxième fois avec le
   même id (simulation d'un accusé de réception réseau perdu) → stock
   passe de 6 à 5 (delta appliqué une seule fois), pas à 4.
3. **Agent de vente** : lit les prix de vente (`produits`), bloqué sur
   `produits_couts` (0 ligne, RLS silencieuse) et sur
   `mouvements_stock`/`produits` en écriture (erreur RLS explicite).
4. **Gérant** : peut créer un mouvement de stock, bloqué sur
   `produits_couts` et sur la création de produits.
5. **Propriétaire/Gérant** : accès complet, y compris prix d'achat.

---

## 6. Écrans Flutter livrés

- `ProduitsListScreen` : catalogue, bouton "+" (création) réservé à
  Propriétaire/Propriétaire-Gérant/Gérant (`estResponsable`).
- `ProduitDetailScreen` : infos de vente pour tous ; stock ("Ajuster le
  stock"), prix d'achat et "Modifier le produit" pour Propriétaire/
  Propriétaire-Gérant/Gérant — l'Agent de vente n'a accès à aucun des
  trois.
- `ProduitFormScreen` : création/modification (nom, prix détail, prix gros,
  bouteilles/carton, prix d'achat, actif), un seul bouton "Enregistrer" —
  accessible uniquement aux rôles `estResponsable` (ni le paramétrage ni le
  blocage réel du prix d'achat ne dépendent plus de `estAdministrateur`,
  voir section 9).
- Accessible depuis `HomeScreen` via un nouveau bouton "Produits" (visible
  pour les 4 rôles, chacun voyant un sous-ensemble différent une fois dans
  le détail d'un produit, selon la matrice ci-dessus).

**Catalogue produits (lecture/écriture)** : requêtes directes Supabase
(comme `ConfigurationCaveScreen` en Phase 1) — se configure typiquement
avec réseau, changements peu fréquents. **Ajustements de stock** : passent
par la file de synchronisation locale Drift (`StockDao`, nouvelle table
`LocalStock`) pour fonctionner réellement hors ligne — c'est la seule
partie de cette phase où l'offline-first était un besoin explicite du
cahier des charges (agent en tournée sans réseau).

---

## 7. Vérifié sur téléphone réel (Propriétaire)

Testé sur l'appareil réel (TECNO KI5k), contre le projet Supabase de
production :

1. **Création de produit** : "SOBEBRA" créé avec prix détail/gros,
   bouteilles/carton, et prix d'achat (table séparée `produits_couts`) —
   tous les champs s'affichent correctement sur `ProduitDetailScreen`.
2. **Ajustement de stock** : deux ajustements successifs déclenchés depuis
   l'écran ("Ajuster le stock"), cache local mis à jour immédiatement
   (0 → 12 cartons / 15 bouteilles).
3. **Synchronisation réelle** : les deux mouvements sont bien arrivés dans
   `mouvements_stock` côté serveur (12/13 puis 0/2), et le trigger
   `appliquer_mouvement_stock` a correctement additionné les deltas dans
   `stock` (12 cartons / 15 bouteilles) — confirmé par requête SQL directe
   dans le tableau de bord Supabase.

**Reste à vérifier** (non bloquant pour la validation du mécanisme
principal, mais pas encore testé sur l'appareil réel) : le comportement
des écrans Produits/Stock avec un compte Gérant ou Agent de vente (seule
la simulation RLS locale en Postgres l'a couvert jusqu'ici).

---

## 8. Ajustement demandé : le Gérant doit pouvoir créer des produits

**Demande** : le Gérant, en plus de consulter et d'ajuster le stock, doit
pouvoir créer et modifier des produits (nom, prix de vente, bouteilles/
carton) — pas seulement le Propriétaire/Propriétaire-Gérant.

**Ce qui ne change pas (à ce stade)** : le prix d'achat (`produits_couts`)
reste réservé à Propriétaire/Propriétaire-Gérant, conformément au point 18
du cahier des charges ("jamais visible par le Gérant ni l'Agent de
vente") — cette demande ne le remet pas en cause, seule la création de la
fiche produit (infos de vente) s'ouvre au Gérant. *(Révisé en section 9 :
le Gérant a ensuite obtenu l'accès complet au prix d'achat, sur demande
explicite.)*

**Modifications** :
- `supabase/migrations/0008_gerant_creer_produits.sql` : policy
  `produits_write` passe de `is_admin()` à `is_responsable()` (même
  fonction déjà utilisée pour `caves_update` depuis la migration 0003).
- `ProduitsListScreen` : bouton "+" visible pour `estResponsable` (au lieu
  de `estAdministrateur`).
- `ProduitFormScreen` : nouveau paramètre requis `autoriserPrixAchat` —
  le champ prix d'achat (affichage, chargement, sauvegarde) n'apparaît que
  si vrai (Propriétaire/Propriétaire-Gérant). Un Gérant qui ouvre ce
  formulaire ne voit tout simplement pas ce champ.
- `ProduitDetailScreen` : bouton "Modifier le produit" détaché du bloc
  prix d'achat, visible pour `estResponsable` ; le bloc prix d'achat reste
  seul sous `estAdministrateur`.

**Vérifié en local sur PostgreSQL 16 (RLS réelle, rôle non-superuser
`app_test`)**, avant envoi en production :
1. Gérant crée un produit → réussit (échouait avant la migration).
2. Gérant modifie un produit existant → réussit.
3. Gérant tente d'écrire dans `produits_couts` (prix d'achat) → toujours
   bloqué par RLS.
4. Agent de vente tente de créer un produit → toujours bloqué par RLS.
5. Propriétaire crée un produit et son prix d'achat → toujours OK (aucune
   régression sur les rôles déjà autorisés).

---

## 9. Ajustement demandé : le Gérant doit aussi voir/modifier le prix d'achat

**Demande** : revenir sur la restriction posée en section 8 — le Gérant
doit pouvoir enregistrer, voir et modifier le prix d'achat, pas seulement
la fiche produit. Seul l'Agent de vente reste exclu de cette donnée.

**Modifications** :
- `supabase/migrations/0009_gerant_prix_achat.sql` : les policies
  `produits_couts_select`/`produits_couts_write` passent de `is_admin()` à
  `is_responsable()`.
- `ProduitDetailScreen` : le bloc prix d'achat (affichage + chargement +
  bouton "Modifier le produit") passe sous `estResponsable`, comme le bloc
  stock — les deux sont maintenant fusionnés en un seul bloc.
- `ProduitFormScreen` : le paramètre `autoriserPrixAchat` ajouté en
  section 8 devenait toujours vrai aux deux points d'appel (les deux
  écrans étant déjà réservés à `estResponsable`, qui a maintenant accès
  complet au prix d'achat) — retiré pour éviter un paramètre mort ; le
  champ prix d'achat est de nouveau toujours affiché dans ce formulaire.

**Vérifié en local sur PostgreSQL 16 (RLS réelle)**, avant envoi en
production :
1. Gérant lit `produits_couts` → réussit (échouait avant cette migration).
2. Gérant crée puis modifie un prix d'achat → réussit.
3. Agent de vente lit `produits_couts` → 0 ligne (RLS silencieuse).
4. Agent de vente tente d'écrire dans `produits_couts` → bloqué par RLS.
5. Propriétaire toujours OK (aucune régression).

---

## 10. Ajustement demandé : type d'emballage (carton ou casier)

**Demande** : à la création d'un produit, choisir un type d'emballage
(carton ou casier). Le stock doit ensuite s'exprimer en nombre
d'emballages (du type choisi) et en nombre de bouteilles qui n'atteignent
pas un emballage complet.

**Constat** : le mécanisme de stock existant (`quantite_cartons` +
`quantite_bouteilles`, deltas additifs, trigger) faisait déjà exactement
ça — seul l'intitulé "carton" était en dur partout dans l'interface, y
compris pour un produit qui se vend en casiers. Aucun changement du
mécanisme de stock n'était donc nécessaire, seulement l'ajout du choix de
type et son utilisation pour l'affichage.

**Modifications** :
- `supabase/migrations/0010_type_emballage_produits.sql` : nouveau type
  enum Postgres `type_emballage` ('carton' | 'casier') ; colonne
  `produits.type_emballage` (défaut `'carton'`, donc aucune perte pour les
  produits déjà créés) ; colonne `bouteilles_par_carton` renommée en
  `bouteilles_par_emballage` (rename Postgres : données et contrainte
  `check (> 0)` conservées).
- `lib/core/constants/type_emballage.dart` (nouveau) : enum Dart
  `TypeEmballage` (carton/casier), même schéma que `TypeCave`.
- `Produit` (modèle) : `bouteillesParCarton` → `bouteillesParEmballage` +
  nouveau champ `typeEmballage`.
- `ProduitsService.creerProduit`/`modifierProduit` : nouveau paramètre
  `typeEmballage`, renommage `bouteillesParEmballage`.
- `ProduitFormScreen` : nouveau sélecteur "Type d'emballage" (carton /
  casier, `RadioGroup`, même widget que `TypeCave` en Phase 1) ; le champ
  "Bouteilles par carton/casier" change de libellé selon le choix.
- `ProduitDetailScreen` : tous les libellés liés au stock ("Stock
  (cartons)"/"Stock (casiers)", "Variation (...)", "Bouteilles par ...")
  dépendent désormais de `produit.typeEmballage` au lieu d'être en dur.

**Vérifié en local sur PostgreSQL 16** avant envoi en production :
1. Produits déjà créés (avant la migration) : `type_emballage = 'carton'`
   par défaut, aucune donnée perdue par le rename de colonne.
2. Propriétaire crée un produit avec `type_emballage = 'casier'` → réussit.
3. Une valeur hors énumération (`'bidon'`) est rejetée par Postgres au
   niveau du type, pas seulement par une contrainte applicative.
4. Gérant crée un produit avec `type_emballage = 'casier'` → réussit
   (cohérent avec la policy `produits_write` étendue en migration 0008).

---

## En attente de votre validation avant la Phase 3 (Vente & Commandes).
