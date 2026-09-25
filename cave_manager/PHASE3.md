# Phase 3 — Vente & Commandes

Suite de [PHASE2.md](./PHASE2.md) (produits, stock, validée). Cette phase ajoute
la prise de commande, conformément au périmètre annoncé depuis la Phase 1
(PHASE1.md, sections 7 et 9, déjà planifié avant même d'être codé).

---

## 1. Périmètre fonctionnel exact de la phase

Inclus :
- Clients optionnels rattachés à une commande (vente comptoir anonyme
  possible si aucun client n'est choisi).
- Prise de commande (panier : un ou plusieurs produits, quantités en
  cartons/casiers et en bouteilles, prix figés au moment de la vente) par
  les 4 rôles.
- Historique des commandes : un Agent de vente ne voit que les siennes,
  les responsables voient toutes les commandes de la cave.
- Annulation d'une commande encore en attente, par un responsable
  uniquement.
- Mécanisme offline pour la prise de commande : "toute prise de commande"
  doit fonctionner hors connexion (exigence déjà actée en PHASE1.md,
  section 10, point 4) — passe par la file de synchronisation locale déjà
  en place depuis la Phase 1/2, pas par un appel réseau direct.

Explicitement **hors périmètre** de cette phase (reportés comme convenu
depuis la Phase 1) : contrôle/validation d'une commande et décrémentation
du stock qui en découle, encaissement (Phase 4), facture/WhatsApp/clôture
(Phase 5).

**Frontière imposée au niveau base de données, pas seulement dans
l'interface** : la policy RLS `commandes_update` n'autorise que la
transition `en_attente` → `annulee`. Même un appel API direct (hors de
l'app) ne peut pas faire passer une commande à `validee` avant que la
Phase 4 n'ajoute sa propre policy dédiée — cohérent avec le principe déjà
posé en Phase 1 : la validation et la décrémentation de stock doivent
être une seule unité atomique, jamais improvisée en avance.

---

## 2. Hypothèses posées, signalées explicitement

1. **Client toujours facultatif sur une commande.** Le cahier des charges
   (matrice PHASE1.md section 9) prévoit une table `clients` mais ne
   précise pas si elle est obligatoire par vente. Rendue facultative
   délibérément : exiger un client bloquerait toute vente comptoir rapide
   hors ligne (le choix/la création d'un client suppose le réseau, la
   vente elle-même non). À reconsidérer si un usage réel montre le
   contraire.
2. **Choisir/créer un client nécessite le réseau**, contrairement à la
   vente elle-même. Cohérent avec la distinction déjà faite en Phase 1
   entre "première connexion" (en ligne, exception ponctuelle) et
   "toute prise de commande" (hors ligne, exigence répétée) : un client
   n'est ni l'un ni l'autre au sens strict, traité comme une commodité de
   confort plutôt que comme une donnée métier critique.
3. **Aucune vérification de stock disponible côté Agent** au moment de la
   vente : cohérent avec le principe déjà acté (point 2.3, PHASE1/PHASE2)
   que l'Agent de vente n'a jamais accès à `stock`. Il se fie au rayon
   physique, comme pour l'ajustement de stock en Phase 2.
4. **Suppression physique jamais possible sur `commandes`/`commande_lignes`**,
   uniquement l'annulation (changement de statut). Même principe
   d'immuabilité déjà appliqué à `mouvements_stock` et `clotures`.

---

## 3. Modèle de données Supabase

Fichier : `supabase/migrations/0012_phase3_ventes_commandes.sql`.

| Table | Rôle | Colonnes clés |
|---|---|---|
| `clients` *(nouvelle)* | Client optionnel | `nom`, `telephone` |
| `commandes` *(nouvelle)* | Une vente | `client_id`, `statut`, `total` (recalculé par trigger) |
| `commande_lignes` *(nouvelle)* | Une ligne (un produit) d'une commande | `produit_id`, `quantite_cartons`, `quantite_bouteilles`, `prix_gros_unitaire`, `prix_detail_unitaire`, `sous_total` |

**Prix figés au moment de la vente** (`prix_gros_unitaire`/
`prix_detail_unitaire` sur `commande_lignes`, pas une référence live à
`produits`) : si le catalogue change plus tard, l'historique des ventes
reste exact. `sous_total` est vérifié par une contrainte `check`
(`quantite_cartons * prix_gros_unitaire + quantite_bouteilles *
prix_detail_unitaire`), pas seulement calculé côté client.

**Trigger `appliquer_ligne_commande`** (`AFTER INSERT` sur
`commande_lignes`, jamais `UPDATE`) : additionne chaque ligne au total de
la commande — même mécanisme, même garantie d'idempotence au retry réseau
que `appliquer_mouvement_stock` en Phase 2 (voir son commentaire dans la
migration 0007 pour le raisonnement complet).

---

## 4. Matrice de permissions (complète la matrice de PHASE1.md/PHASE2.md)

| Table | PROP | PG | GER | AGENT | Policy RLS |
|---|---|---|---|---|---|
| `clients` | R/W/D | R/W/D | R/W | R/W(création) | `clients_select` (toute la cave), `clients_insert` (tous), `clients_update` (`is_responsable()`), `clients_delete` (`is_admin()`) |
| `commandes` | R(cave)/W/annulation | R(cave)/W/annulation | R(cave)/W/annulation | R(propres)/W(création) | `commandes_select` (responsables : toute la cave ; Agent : `created_by = auth.uid()`), `commandes_insert` (tous), `commandes_update` (`is_responsable()`, transition `en_attente`→`annulee` uniquement) |
| `commande_lignes` | hérite `commandes` | idem | idem | idem | `commande_lignes_select`/`insert` via sous-requête sur la commande parente |

---

## 5. Vérifications effectuées sur PostgreSQL 16 local (RLS réellement active)

Avant tout envoi vers la production, comme pour toutes les migrations
précédentes (16 scénarios testés) :

1. Agent crée un client, une commande, une ligne → réussit ; le total de
   la commande est correctement recalculé par le trigger (7 400 pour
   1 carton à 6 000 + 2 bouteilles à 700).
2. Ligne avec un `sous_total` incohérent avec les quantités/prix → rejetée
   par la contrainte `check`, pas seulement par une validation applicative.
3. Un Agent ne voit que ses propres commandes ; un Gérant voit toutes les
   commandes de la cave (Agent + Gérant confondus).
4. Un Agent tente d'annuler une commande (y compris la sienne) → refusé
   (`UPDATE 0`, pas responsable).
5. Un Gérant tente de faire passer une commande directement à `validee`
   → bloqué par la policy RLS (erreur explicite), pas seulement
   contourné côté interface.
6. Un Gérant annule la commande d'un Agent → réussit.
7. Ajouter une ligne sur une commande déjà annulée → bloqué par RLS.
8. Un Agent tente de modifier/supprimer un client → refusé ; un Gérant
   peut modifier mais pas supprimer ; seul le Propriétaire peut supprimer.
9. Un Agent tente d'ajouter une ligne à la commande d'un autre utilisateur
   → refusé.

---

## 6. Écrans Flutter livrés

- `CommandesListScreen` ("Commandes", accessible depuis `HomeScreen` via
  le bouton "Vendre / Commandes") : historique filtré par rôle (RLS),
  bouton flottant vers `NouvelleCommandeScreen`.
- `NouvelleCommandeScreen` ("Vendre") : sélection/création d'un client
  facultatif, ajout de produits au panier (quantités cartons/casiers et
  bouteilles, sous-total calculé en direct), total, "Enregistrer la
  vente" — un seul bouton principal.
- `CommandeDetailScreen` : lignes de la commande, total, statut, et pour
  un responsable un bouton "Annuler la commande" tant qu'elle est encore
  en attente.

**Prise de commande** : passe par `VentesDao` (nouvelle, file de
synchronisation locale Drift, même mécanisme que `StockDao` en Phase 2)
pour fonctionner réellement hors ligne. **Clients et lecture de
l'historique** : requêtes directes Supabase (comme le catalogue produits),
nécessitent le réseau — cohérent avec les hypothèses de la section 2.

Aucune nouvelle table Drift locale n'a été nécessaire (contrairement à
`LocalStock` en Phase 2) : `VentesDao` n'écrit que dans la file de
synchronisation générique déjà existante, donc `schemaVersion` n'a pas
changé.

---

## 7. Vérifié sur téléphone réel (Propriétaire/Gérant)

Testé sur l'appareil réel, contre la production Supabase : création d'un
client, ajout d'un produit au panier, "Enregistrer la vente", la
commande apparaît dans l'historique avec le bon total et le statut
"En attente". Un bug a été trouvé et corrigé pendant ce test :
`ref.read(produitsProvider).valueOrNull` lisait l'état du catalogue avant
qu'il ait fini de charger (jamais "watch" ailleurs dans cet écran), donc
"Ajouter un produit" affichait toujours un catalogue vide au premier
appui — remplacé par `await ref.read(produitsProvider.future)`.

---

## 8. Ajustement demandé : corriger une vente avant validation

**Demande** : afficher le détail d'une commande dans un tableau (boisson,
quantité, prix unitaire, total par produit), avec la possibilité de
modifier une quantité ou de retirer un produit dont le client a renoncé.

**Modifications** :
- `supabase/migrations/0013_modifier_lignes_commande.sql` : ajoute les
  policies `commande_lignes_update`/`commande_lignes_delete` (bloquées
  jusqu'ici, migration 0012 — les lignes étaient immuables par design).
  Autorisées uniquement tant que la commande parente est `en_attente`,
  par son créateur ou un responsable — jamais après annulation, et
  jamais après une future validation (Phase 4). Le trigger
  `appliquer_ligne_commande` passe de `AFTER INSERT` à
  `AFTER INSERT OR UPDATE OR DELETE`, en appliquant le delta réel
  (`new.sous_total - old.sous_total` en update, `-old.sous_total` en
  delete) — reste sûr en cas de retry réseau pour la même raison qu'en
  Phase 2 (un insert rejoué devient un update avec un delta nul).
- **Une ligne ne mélange plus jamais cartons et bouteilles à la fois**
  (choix fait à l'ajout : "Par carton/casier" ou "À la bouteille") —
  sans ça, "prix unitaire" n'aurait pas de sens unique dans le tableau
  demandé. Ajouter le même produit dans les deux unités donne
  volontairement deux lignes distinctes.
- `VentesDao.modifierLigne`/`supprimerLigne` (nouvelles) : mêmes principes
  offline-first que `creerCommande`, via la file de synchronisation.
- `VentesService.obtenirCommande` (nouvelle) : relit le total recalculé
  après une modification.
- `CommandeDetailScreen` refaite : tableau (`Table`, pas `DataTable` —
  voir la justification déjà documentée pour le catalogue en Phase 2),
  avec icônes "modifier"/"retirer" par ligne, visibles uniquement pour le
  créateur de la commande ou un responsable, et seulement tant qu'elle
  est en attente — exactement les mêmes conditions que côté serveur.

**Vérifié en local sur PostgreSQL 16 (RLS réelle)** avant envoi en
production :
1. Modifier la quantité d'une ligne → le total de la commande est
   recalculé par le delta (8 100 → 14 100 pour +6 000).
2. Supprimer une ligne → le total redescend du montant de la ligne
   retirée (14 100 → 12 000 pour -2 100).
3. Un Gérant peut modifier/supprimer une ligne d'une commande créée par
   un Agent, tant qu'elle est en attente.
4. Une fois la commande annulée, plus personne ne peut modifier ses
   lignes (`UPDATE 0`).

---

## 9. Vérifié sur téléphone réel (section 8)

Modification et suppression d'une ligne testées sur l'appareil réel,
contre la production Supabase : le total se met à jour correctement
après chaque action. Trois ajustements d'affichage faits pendant ce
test :
- Les deux `IconButton` (modifier/retirer) débordaient hors de l'écran
  dans la colonne d'actions, trop étroite — remplacés par un seul
  `PopupMenuButton` (icône ⋮) qui ouvre un menu "Modifier la
  quantité"/"Retirer".
- `listerLignes` ne précisait pas d'ordre explicite : l'ordre
  d'affichage des lignes pouvait changer après une modification (Postgres
  ne garantit rien sans `ORDER BY`) — ajout de `.order('created_at')`.
- Les colonnes Qté/P.U./Total ont été réajustées (plus de largeur, plus
  de "cart."/"bout." superflu) et les chiffres sont maintenant dans un
  `FittedBox` qui rétrécit la police au besoin plutôt que de couper un
  montant sur deux lignes.

---

## En attente de votre validation avant la Phase 4 (Contrôle, validation & encaissement).
