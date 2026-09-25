# Phase 5 — Facture, notification WhatsApp & clôture de caisse

Suite de [PHASE4.md](./PHASE4.md) (contrôle, validation & encaissement,
validée). Dernière phase du périmètre annoncé depuis la Phase 1
(PHASE1.md sections 1 et 9).

---

## 1. Périmètre fonctionnel exact de la phase

Inclus :
- **Facture** : récapitulatif d'une commande (boisson, quantité, sous-
  total, total, encaissé, reste à payer, statut), généré à partir des
  données déjà en base — aucune nouvelle table.
- **Notification WhatsApp** : envoi de la facture au client via un lien
  WhatsApp pré-rempli, ouvert directement par le téléphone.
- **Clôture de caisse** : complète le squelette posé en Phase 1
  (`clotures`) avec les totaux financiers du jour (ventes, espèces,
  Mobile Money, nombre de commandes) et l'historique des clôtures
  passées.
- **Correction exceptionnelle d'une clôture** (`historique_corrections`,
  déjà annoncée en PHASE1.md section 7) : réservée au Propriétaire/
  Propriétaire-Gérant, jamais une modification directe de la ligne de
  clôture (immuable).

---

## 2. Hypothèses posées, signalées explicitement

1. **"Notification WhatsApp" = lien "wa.me" ouvert par le téléphone**,
   pas l'API WhatsApp Business. Cette dernière exige un compte
   professionnel Meta vérifié, des modèles de message pré-approuvés et
   une intégration serveur payante — disproportionné pour une seule
   cave de quartier, et un renversement complet d'architecture (jusqu'ici
   zéro service payant externe dans ce projet). Le lien "wa.me" ne
   nécessite ni compte ni clé API : le téléphone du Gérant/Agent ouvre
   simplement WhatsApp (déjà installé) avec un message pré-rempli, que
   l'utilisateur envoie lui-même. Si le client n'a pas de numéro
   enregistré, WhatsApp s'ouvre sans destinataire fixé : l'utilisateur
   choisit le contact lui-même dans l'application. À reconsidérer si un
   usage réel (envoi automatique sans intervention humaine) l'exige.
2. **La clôture ne couvre jamais une plage de dates fixe** ("aujourd'hui
   00h-24h"), mais "tout ce qui n'a pas encore été rattaché à une
   clôture précédente" (`cloture_id is null` sur `commandes`/
   `encaissements`). Une seule clôture par jour calendaire reste imposée
   (contrainte déjà posée en Phase 1 : `unique(cave_id, date_cloture)`),
   mais son contenu n'est jamais perdu si elle est faite après minuit ou
   si un jour a été oublié : rien ne peut être compté deux fois, ni
   oublié.
3. **Le total des ventes et le total encaissé sont deux notions
   distinctes** dans une clôture : `total_ventes` vient de
   `commandes.total` (valeur de marchandise vendue, stock déjà
   décrémenté à la validation), `total_especes`/`total_mobile_money`
   viennent des `encaissements` (mouvement de caisse réel). Nécessaire
   pour représenter correctement une vente à crédit (validée, stock
   sorti, mais pas encore payée) sans la compter comme "argent en
   caisse" avant qu'elle le soit réellement.
4. **La correction d'une clôture n'est pas soumise à
   `cloture_accessible_proprietaire`** (le réglage qui limite l'accès
   quotidien du Propriétaire à la clôture) : un Propriétaire peut
   toujours corriger, même si la cave ne lui donne pas accès aux
   opérations de clôture du quotidien — autorité de dernier recours,
   distincte de la participation aux opérations courantes.
5. **Pas de génération de PDF** : la facture est un texte formaté,
   affiché à l'écran et copié tel quel dans le message WhatsApp.
   Suffisant pour l'usage annoncé (notification au client) ; un PDF
   téléchargeable n'a pas été demandé et ajouterait une dépendance
   (bibliothèque de rendu PDF) pour un bénéfice non requis.

---

## 3. Modèle de données Supabase

Fichier : `supabase/migrations/0015_phase5_facture_whatsapp_cloture.sql`.

| Élément | Rôle |
|---|---|
| `clotures` (colonnes ajoutées) | `total_ventes`, `total_especes`, `total_mobile_money`, `nombre_commandes` |
| `commandes.cloture_id` / `encaissements.cloture_id` *(nouvelles colonnes)* | Rattachement à la clôture qui les a "consommés" |
| `cloturer_caisse(cave_id)` *(nouvelle fonction, security definer)* | Calcule les totaux non encore clôturés, écrit une ligne `clotures`, rattache les commandes/encaissements — seule façon de créer une clôture |
| `historique_corrections` *(nouvelle table)* | Correction exceptionnelle (delta signé + motif), lecture réservée à Propriétaire/Propriétaire-Gérant |
| `corriger_cloture(cloture_id, montant, motif)` *(nouvelle fonction, security definer)* | Seule façon de créer une correction |

**Durcissement corrigeant un écart avec PHASE1.md** : la policy
`clotures_write` posée en migration 0001 (`for all`) autorisait en
réalité UPDATE/DELETE, alors que PHASE1.md décrivait déjà une clôture
comme immuable dès la Phase 1. Cette migration supprime `clotures_write`
et révoque les privilèges `insert`/`update`/`delete` du rôle
`authenticated` sur `clotures` : la seule écriture possible passe
désormais par `cloturer_caisse` (propriétaire de la fonction = rôle
superutilisateur des migrations, qui contourne RLS — même mécanisme déjà
utilisé par `creer_cave_et_proprietaire` en Phase 1).

---

## 4. Matrice de permissions (complète la matrice de PHASE1.md)

| Table/Fonction | PROP | PG | GER | AGENT | Détail |
|---|---|---|---|---|---|
| `cloturer_caisse` | Si `cloture_accessible_proprietaire` | Toujours | Toujours | **—** | Vérifié dans la fonction elle-même |
| `historique_corrections` (lecture) | R | R | **—** | **—** | Même un Gérant qui clôture ne voit pas les corrections |
| `corriger_cloture` | W | W | **—** | **—** | Jamais soumis à `cloture_accessible_proprietaire` |
| Facture / WhatsApp | Toujours | Toujours | Toujours | Toujours | Aucune donnée nouvelle exposée (déjà visible sur `CommandeDetailScreen`) |

---

## 5. Vérifications effectuées sur PostgreSQL 16 local (RLS réellement active)

Avant tout envoi vers la production :

1. Un Agent tente de clôturer → refusé (exception explicite, pas une
   erreur RLS brute).
2. Un Gérant clôture → réussit ; totaux corrects (32 100 de ventes,
   10 000 espèces, 20 000 Mobile Money, 2 commandes — vérifié contre les
   données de test des Phases 3/4).
3. Une deuxième clôture le même jour → refusée avec un message explicite
   avant même d'atteindre la contrainte `unique`.
4. Les commandes/encaissements clôturés ont bien `cloture_id` renseigné
   (0 ligne restante à `null` après clôture).
5. Un Agent tente de lire `clotures` → 0 ligne.
6. Un Gérant lit l'historique des clôtures → réussit.
7. Un Gérant tente une correction → refusé (réservé au Propriétaire).
8. Un Propriétaire fait une correction → réussit, relisible ensuite.
9. Un Gérant tente de lire `historique_corrections` → 0 ligne.
10. Un Propriétaire tente une modification directe de `clotures`
    (contournement de la RPC) → refusé (`permission denied`).
11. Un Gérant tente une suppression directe de `clotures` → refusée, la
    ligne reste inchangée.

---

## 6. Écrans Flutter livrés

- `ClotureScreen` ("Clôture de caisse", accessible depuis l'accueil pour
  les responsables) : aperçu de ce qui n'est pas encore clôturé, bouton
  "Clôturer la caisse", historique des clôtures passées.
- `ClotureDetailScreen` : détail d'une clôture (totaux figés) et ses
  corrections ; bouton "Ajouter une correction" pour Propriétaire/
  Propriétaire-Gérant uniquement.
- `FactureScreen` (accessible depuis `CommandeDetailScreen`, bouton
  "Voir la facture") : texte de la facture (`genererTexteFacture`,
  fonction pure testée unitairement comme `calculerResteAPayer`), bouton
  "Envoyer via WhatsApp".

Tout passe par des requêtes directes Supabase (comme le reste de
l'historique des ventes) : nécessite le réseau, cohérent avec les
hypothèses déjà posées en Phase 3 (la prise de commande elle-même reste
la seule action strictement offline-first).

---

## Non vérifié sur téléphone réel à la rédaction

Aucun test encore fait sur l'appareil réel (seulement en local avec
RLS). Nécessite `flutter pub get` (nouvelle dépendance `url_launcher`,
prise en charge automatiquement par `flutter run`) — aucun
`build_runner` nécessaire (aucune nouvelle table Drift locale).

---

## En attente de votre validation — dernière phase du périmètre annoncé.
