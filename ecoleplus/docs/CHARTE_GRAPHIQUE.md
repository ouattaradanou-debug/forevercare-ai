# Charte graphique d'EcolePlus (A28)

Une seule identité visuelle pour toute l'application, centralisée dans
`lib/app/charte.dart` (couleurs, rayons, ombre) et `lib/app/theme.dart`
(boutons, champs, dialogues, messages…). **Aucune couleur n'est codée en dur
dans les modules** : on change la charte à un seul endroit.

Aucun nom, logo ni texte d'entreprise de développement n'apparaît. Le seul
logo affiché est celui de **l'établissement** (en-tête de l'accueil), quand
il a été ajouté dans « Mon école ».

## 1. Palette
| Rôle | Couleur | HEX | Fond doux associé |
|---|---|---|---|
| Principale : en-têtes, titres, boutons Enregistrer / Valider | Bleu marine | `#13315C` | `#E7ECF4` |
| Texte principal | Marine foncé | `#0B2545` | — |
| Interactif secondaire, liens, module Élèves | Bleu | `#2563B5` | `#EAF1FB` (bleu clair : cartes) |
| Accent : actions phares, sélection, chiffres à mettre en évidence | Orange | `#F28C28` | `#FFF1E0` |
| Texte orange lisible, module Rapports | Orange foncé | `#B35C00` | `#FFF1E0` |
| Surfaces | Blanc | `#FFFFFF` | — |
| Arrière-plan, zones secondaires | Gris très clair | `#F4F6FA` | — |
| Bordures, séparateurs | Gris | `#E2E7EF` | — |
| Texte secondaire | Gris ardoise | `#5B6576` | — |
| Réussite, situation positive, module Finances | Vert | `#1E8E4E` | `#E6F5EC` |
| Erreur, alerte | Rouge | `#D03A3A` | `#FDECEC` |
| Attention (en attente, en retard, conseil) | Ambre | `#B7791F` | `#FFF6E0` |
| Module Administration | Violet | `#6D4ED8` | `#F0ECFE` |
| Module Pédagogie | Turquoise | `#0E9AA7` | `#E2F6F7` |
| Module Bibliothèque et IA | Prune | `#8A4FBF` | `#F5EDFB` |

Règle : beaucoup de blanc ; le marine structure (barre du haut, en-têtes de
tableaux) ; l'orange est rare et signale ce qui compte. Chaque module garde
**sa** couleur partout (tuile d'accueil, page du module, carte du tableau de
bord), uniquement en petite pastille d'icône.

## 2. Formes et typographie
- Police : Roboto (celle d'Android). Titres 20 gras marine ; sous-titres 16
  demi-gras ; texte 15–17 ; texte secondaire 13 gris ardoise.
- Rayons : cartes et tableaux 14 ; boutons et champs 12 ; dialogues 20.
- Ombre unique, très discrète (`0 3 10`, marine à 8 %). Pas de dégradé.

## 3. Composants (mêmes partout)
| Composant | Apparence |
|---|---|
| Bouton principal (Enregistrer, Valider) | plein marine, 54 de haut |
| Action phare (Encaisser, Faire l'appel) | plein orange (`StylesBoutons.accent`) |
| Action secondaire (Imprimer, Excel, Partager) | contour marine |
| Action destructive (Supprimer, Annuler un reçu) | contour rouge (`StylesBoutons.danger`), confirmation |
| Lien, petite action | texte bleu |
| Champ de saisie, liste déroulante | fond blanc, bord gris arrondi, bord marine épais au focus, erreur en rouge |
| Case, interrupteur, bouton radio | marine quand actif |
| Filtre choisi, segment choisi | fond orange pâle |
| Carte | blanche, bord gris, ombre discrète |
| Tableau | en-tête marine texte blanc, lignes alternées gris très clair, total sur fond orange pâle, montants alignés à droite |
| Pastille de statut | Soldé/Payé (vert), Partiel/En attente (ambre), Impayé/Erreur (rouge), Info (bleu) — `PastilleStatut` |
| Titre de section | marine gras précédé d'un trait orange |
| Fenêtre de dialogue | blanche, coins arrondis 20, titre marine |
| Message de réussite / d'erreur | bandeau flottant vert / rouge avec icône |
| Chargement | barre ou cercle orange |
| Synchronisation | Synchronisé (vert), En cours (bleu), En attente (ambre), Problème (rouge) |
| Notifications | cloche de l'en-tête, compteur orange |

## 4. Accueil mobile (sans défilement)
1. **En-tête** (60) : logo de l'école (sinon ses initiales), nom de l'école,
   cloche avec compteur, profil (Mon compte, Synchronisation, Me déconnecter).
2. **Bienvenue** : « Bonjour, *nom* ! » + phrase courte + petite
   illustration (livre et coiffe).
3. **État** : pastille de synchronisation + l'alerte la plus importante (une
   ligne ; le détail est dans les notifications).
4. **Grille de 3 colonnes** : Tableau de bord, Rechercher, puis les modules.
   La hauteur des tuiles est calculée selon l'espace restant ; sur un très
   petit écran, le contenu de la tuile se réduit au lieu de déborder.
5. **Bas** : Se déconnecter.

Enseignant : une bande « Ma journée » (cours du jour, bouton « Faire
l'appel ») s'ajoute sous l'état. Tablette et ordinateur : 4 ou 5 colonnes,
contenu centré, largeur limitée à 880.

Vérifié automatiquement (`test/features/a28_accueil_test.dart`) sur
360 × 800, 360 × 740, 375 × 812, 390 × 844 et 412 × 915, avec la barre d'état
(24) et la barre de navigation Android (48) : tout visible, aucun
chevauchement, aucun défilement, chaque accès ouvre le bon écran.

## 5. Documents
Reçus, rapports, finances, cantine, classements, bulletins, livrets,
emploi du temps : titres marine, en-têtes de tableaux marine texte blanc,
lignes alternées gris très clair, totaux orange pâle. Les **formulaires
officiels** (B1 à B7, B4, B5) restent noir et blanc, fidèles aux modèles de
l'État.
