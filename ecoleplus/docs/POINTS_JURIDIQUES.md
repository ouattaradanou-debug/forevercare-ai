# Points juridiques à faire valider par un professionnel local

**Rien ici n'est un avis juridique.** Ce document liste les questions à
poser à un juriste du Burkina Faso, ou à l'autorité de protection des
données (Commission de l'Informatique et des Libertés, CIL), **avant**
l'essai pilote avec de vrais élèves. Pour chaque question, la colonne de
droite dit ce que fait l'application aujourd'hui, pour que le juriste puisse
dire si cela suffit.

Les détails du dossier médical et des photos sont dans
`MEDICO_POINTS_JURIDIQUES.md` (J1 à J10) et `PHOTOS_POINTS_JURIDIQUES.md`.

## 1. Données d'enfants mineurs (toute l'application)
| # | Question | Ce que fait l'application |
|---|---|---|
| G1 | Qui est le « responsable du traitement » : l'école, le porteur du projet, les deux ? Faut-il un contrat entre l'école et le porteur (sous-traitance) ? | Chaque école a ses données à part ; le porteur héberge et maintient. **Aucun contrat type n'existe encore.** |
| G2 | Formalités auprès de la CIL (déclaration, autorisation) pour une application de gestion scolaire | Aucune faite ; à faire avant le pilote |
| G3 | Information des parents : qu'écrire, sous quelle forme (papier signé, réunion, affichage), en quelle langue ? | Texte proposé pour le module médical ; **un texte général reste à rédiger** (noms, dates de naissance, notes, absences, photos, paiements) |
| G4 | Durée de conservation des données d'un élève qui quitte l'école ; des registres officiels | Rien n'est effacé automatiquement ; un élève sorti est archivé ; les registres officiels sont gardés (obligation administrative probable) |
| G5 | Droits des parents : consulter, corriger, demander l'effacement | Consultation et correction par le directeur ; l'effacement définitif (A21) existe pour le directeur, avec trace |
| G6 | Hébergement hors du Burkina Faso (Supabase, Union européenne) : autorisé ? conditions ? | Données chiffrées en transit et au repos chez l'hébergeur ; sauvegardes chiffrées |
| G7 | Que faire en cas de fuite (qui prévenir, en combien de temps) ? | Journal de sécurité du directeur ; **pas de procédure écrite** |
| G8 | Le téléphone personnel d'un enseignant peut-il contenir les données de sa classe ? | Base du téléphone chiffrée, code obligatoire, déconnexion à distance par le directeur, données effacées alors |

## 2. Photos des élèves
| # | Question | Ce que fait l'application |
|---|---|---|
| P1 | Faut-il l'accord écrit des parents pour prendre et garder la photo ? | Photo facultative ; cartes possibles sans photo |
| P2 | Usage limité à la carte scolaire et à la fiche ? | Photos jamais publiques, jamais envoyées à l'IA |
| P3 | Durée de conservation des photos | Gardées tant que l'élève est dans l'école |

## 3. Santé (module médico-scolaire, désactivé par défaut)
Voir J1 à J10 dans `MEDICO_POINTS_JURIDIQUES.md`. Question principale : une
école a-t-elle le droit d'enregistrer ces données, et avec quel accord des
parents ?

## 4. Finances
| # | Question | Ce que fait l'application |
|---|---|---|
| F1 | Valeur d'un reçu de l'application (preuve de paiement) ; mentions obligatoires | Reçu numéroté, jamais modifiable, annulation motivée et tracée |
| F2 | Conservation des pièces (reçus, justificatifs de dépenses) : durée | Gardées sans limite ; rien n'est supprimé |
| F3 | Relances d'impayés par WhatsApp : ce qui est permis (ton, fréquence, données) | Message préparé, envoyé seulement par une personne ; jamais automatique |
| F4 | Responsabilité si un économe fait une erreur ou une fraude | Chaque encaissement porte son auteur ; journal de caisse et clôtures |

## 5. Documents de la bibliothèque et IA
| # | Question | Ce que fait l'application |
|---|---|---|
| D1 | Droits d'auteur : une école peut-elle déposer des manuels, guides, sujets scannés et les partager entre ses enseignants ? | Documents visibles seulement dans l'école ; « exclu de l'IA » possible par document ; **l'école reste responsable de ce qu'elle dépose** (à écrire dans les conditions d'utilisation) |
| D2 | Les fiches produites par l'IA à partir de ces documents : à qui appartiennent-elles ? | Les extraits recopiés de plus de 25 mots sont retirés ; sources citées |
| D3 | Envoi de passages de documents au fournisseur d'IA (Anthropic, États-Unis) : permis ? | Seulement des passages autorisés, sans nom d'élève ; jamais de données de santé |

## 6. Documents à rédiger avec le juriste
1. Conditions d'utilisation (école ↔ porteur du projet).
2. Politique de confidentialité (exigée par le Play Store).
3. Note d'information aux parents (générale + photos + santé).
4. Procédure en cas de fuite de données.
5. Accord de l'école pilote pour l'essai.
