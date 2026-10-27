# Hypothèses à valider sur le terrain (R8)

Toutes sont paramétrables ; aucune n'est présentée comme une règle officielle.

| N° | Hypothèse | Où elle intervient | Paramètre |
|---|---|---|---|
| H1 | Barème par défaut : notes sur 10 par matière | Notes (phase 3) | `schools.grading_scale`, `assessments.max_score` |
| H2 | Coefficient 1 par défaut ; un coefficient 0 n'influence pas la moyenne | Notes | `class_subjects.coefficient` |
| H3 | Élève absent : pas de note (« Abs. »), composition manquante non comptée à zéro (décision du porteur, valeur de départ) ; une matière sans aucune note est exclue du calcul | Notes, classement | `schools.absent_rule` (`non_compte` / `zero`) — à confirmer avec un directeur avant la phase 3 |
| H4 | Moyenne de classe = moyenne des moyennes générales des élèves classés | Classement | — |
| H5 | Terminologie de la maternelle : Petite / Moyenne / Grande section | Classes | table `levels` |
| H6 | Le « Numéro d'ordre » du registre matricule (B2) est le « N° Mle » de la fiche de scolarité (B4) | B2, B4 | — |
| H7 | Les enfants de maternelle reçoivent eux aussi un numéro du registre matricule (le modèle B2 parle d'« instruction primaire ») | B2 | **phase 2 : un seul compteur pour toute l'école** (maternelle comprise si le module est actif) — à confirmer avec le directeur |
| H8 | Les deux sous-colonnes par niveau de la fiche de scolarité servent au redoublement | B4 | `annual_results.attempt` |
| H9 | N° d'ordre de B1 = ordre alphabétique des enseignants | B1 | — |
| H10 | Calcul des anciennetés (B1) en années et mois révolus à une date de référence choisie par le directeur | B1 | `official_forms.reference_date` |
| H11 | Numérotation des reçus continue **par appareil** (série A, B…) et non pour toute l'école — acceptable pour la comptabilité de l'école | Finances | `devices.series_code` |
| H12 | 10 pages par document, 50 % de scans, 2 Mo par document | Bibliothèque | quota `schools.library_quota_bytes` |
| H13 | Qualité de la reconnaissance vocale native en classe (accents, bruit) | Dictée | — |
| H14 | Qualité de l'OCR sur de vrais scans (mesuré seulement sur pages simulées) | Bibliothèque | — |
| H15 | Pratiques financières des écoles publiques (contributions, cotisations) | Finances | rubriques libres |
| H16 | Sens de « cantine endogène » pour l'école | Cantine | `canteen_settings.local_definition` |
| H17 | Domaines d'apprentissage de la maternelle (à confronter au programme officiel du préscolaire) | Maternelle | `learning_domains` |
| H18 | Les enseignants et délégués se connectent avec leur numéro de téléphone (sans SMS) ; seul le directeur a besoin d'une adresse e-mail | Connexion | — |
| H19 | Un enseignant ne voit que les classes de l'année **en cours** ; les années archivées restent consultables par le directeur | Droits | `app.my_class_ids()` |
| H20 | Un téléphone appartient à une seule école à la fois ; changer de compte efface les données locales (après avertissement si des éléments ne sont pas envoyés) | Hors ligne | — |
| H21 | Rentrée scolaire en octobre : l'année proposée par défaut change en septembre | Années | `anneeScolaireProposee` |
| H22 | En production, confirmation de l'adresse e-mail du directeur à la création du compte (désactivée en local) | Connexion | `config.toml` |

Sigles repris sans développement (non confirmés) : PAC, PAI, AGR, COGES, CPI, C.E.P., T/S, AV, AA, OD, OG, HTA, D.T.C.P., CEB.
| H23 | Alerte de synchronisation : données en attente depuis **3 jours** (1 jour en période de composition, branché en phase 3) ; sans données en attente, alerte seulement après **30 jours** sans synchronisation | Accueil, téléphones | `ReglesAlerte` |
| H24 | Le code est redemandé après **2 minutes** en arrière-plan | Verrouillage | `delaiVerrouillage` |
| H25 | Le code de verrouillage est **obligatoire** pour tous | Verrouillage | — |
| H26 | Déconnecter un téléphone ferme **toutes** les sessions de la personne (elle se reconnecte sur son nouveau téléphone) | Téléphones | `revoke_device` |
| H27 | Jetons de connexion valables 15 minutes : un téléphone déconnecté perd tout accès au plus tard 15 minutes après, et efface ses données dès sa prochaine synchronisation | Sécurité | `jwt_expiry` |
| H25 | **Remplacée** (22/10/2026) : ouverture par code **ou** empreinte, au choix | Verrouillage | — |
| H28 | Ancienneté (B1) : années, mois et jours **révolus** entre la date de départ et la date de référence (le 31/01 + 1 mois = 29/02) ; les interruptions de service **ne sont pas déduites** automatiquement | B1 | `Anciennete.entre` |
| H29 | Date de référence des anciennetés : **31 décembre** de l'année en cours par défaut, modifiable sur la fiche B1 | B1 | `official_forms.reference_date` |
| H30 | « Dernier diplôme académique » (B1) = le titre le plus récent coché « académique » sur la fiche | B1 | `teacher_diplomas.is_academic` |
| H31 | Ordre des lignes : B1 par nom puis prénoms ; B3 par date de nomination dans la commune puis nom ; B2 par numéro d'ordre | B1, B2, B3 | `lignesB1/B2/B3` |
| H32 | Registre du personnel (B3) « double page » : page de gauche = colonnes 1 à 7, page de droite = colonnes 8 à 13, 8 enseignants par double page | B3 | `pdfB3` |
| H33 | Le « N° Mle » de la fiche de scolarité (B4) est le numéro d'ordre du registre matricule (B2) | B2, B4 | `students.registry_number` |
| H34 | Le texte imprimé sous « Observations » du registre matricule est reconstitué depuis l'ANNEXE B : le **libellé exact du scan** reste à reprendre | B2 | `rappelObservationsB2` |
| H35 | Hors ligne, un élève reçoit un numéro **provisoire** (`P-A-0001`) ; le numéro d'ordre définitif est attribué par le serveur dans l'ordre d'**arrivée** des synchronisations (pas forcément l'ordre d'inscription entre deux téléphones hors ligne) | B2 | `assign_registry_number` |
| H36 | Import : un élève est un doublon s'il a les mêmes nom, prénoms et date de naissance qu'un élève existant ; un enseignant, le même matricule (sinon mêmes nom, prénoms, naissance) | Import | `cleEleve`, `cleEnseignant` |
| H37 | Dictée : reconnaissance native du téléphone en français (`fr_FR` si disponible) ; qualité avec les accents d'Afrique de l'Ouest et le bruit de classe **à mesurer sur le terrain** | Dictée | `DicteeNative` |
| H38 | Pas de micro sur les mots de passe, codes et réponses secrètes : la reconnaissance vocale du téléphone peut passer par Internet, et on peut être entendu | Dictée | — |
| H39 | Nombres dictés : un numéro de téléphone se dit chiffre par chiffre ou deux par deux (« soixante-dix, cinquante-six… ») ; une date se dit « vingt-deux octobre deux mille onze » | Dictée | `numeroDicte`, `dateDictee` |
| H40 | **Remplacée** (23/10/2026, A15) : calculs intermédiaires **exacts** (fractions) ; seules les moyennes affichées sont arrondies au centième, au plus proche (6,125 → 6,13) | Notes | `Fraction`, `divArrondi` |
| H41 | Élève **absent** à une matière : la matière ne compte pas pour lui (réglage de l'école `absent_rule` = « non compté ») ; autre réglage possible : l'absence vaut 0. **À confirmer avec un directeur (E3)** | Notes | `schools.absent_rule` |
| H42 | Effectif du classement (« 7e/39 ») = élèves **inscrits dans la classe**, y compris ceux sans note (« Non classé ») | Classement | `Statistiques.effectif` |
| H43 | Aucune mention n'est imposée : chaque école définit les siennes (de … à … → libellé) | Classement | `mention_scales` |
| H44 | Cumul de l'année : une note sur un autre barème est ramenée au barème de l'école (12/20 → 6/10) avant la moyenne | Notes | `calculerClassement` |
| H45 | Moyenne de la classe = moyenne des moyennes générales des élèves classés | Classement | `Statistiques.moyenneClasse` |
| H46 | Période de composition (alerte de synchronisation à 1 jour) : une composition datée des 7 derniers jours ou des 3 prochains, ou des notes pas encore envoyées | Accueil | `periodeCompositionProvider` |
| H47 | Le rang se fait sur la moyenne **affichée** (arrondie) : deux élèves qui affichent la même moyenne sont ex-aequo | Classement | `_classer` |
| H48 | Trimestre d'une épreuve = `assessments.sequence` (1, 2, 3) ; ses épreuves sont créées à la première ouverture du trimestre, au barème de l'école, datées de ce jour (sert à l'alerte « période de composition ») ; une ancienne « Composition 2 » compte pour le 2e trimestre | Notes | `preparerTrimestre` |
| H49 | Moyenne annuelle = (T1 + T2 + T3) ÷ 3 à partir des moyennes **exactes** des trimestres ; les résultats annuels ne sont gardés que pour les élèves qui ont les trois | Notes | `classementAnnuel` |
| H50 | Fiche de scolarité : la **seconde sous-colonne** de chaque cours sert au **redoublement** (l'élève est marqué « Redouble cette classe » sur sa fiche) — **à confirmer sur le scan** | B4 | `annual_results.attempt`, `enrollments.is_repeat` |
| H51 | Texte des « observations générales » de la fiche de scolarité reconstitué depuis l'ANNEXE B : le **libellé exact du scan** reste à reprendre mot pour mot | B4 | `observationsGeneralesB4` |
| H52 | Ex-aequo sur la fiche de scolarité écrit « 7e ex/39 » (la case est étroite) | B4 | `CoursSuivi.classement` |
| H53 | Bulletins : un par trimestre (lié à la composition du trimestre) et un pour l'année ; décisions proposées « Passe en classe supérieure », « Redouble », « Admis(e) au C.E.P. », texte libre possible | Bulletins | `report_cards`, `decisionsProposees` |
| H54 | Bulletins et fiche de scolarité de l'**année en cours** : notes, moyennes et rangs toujours **recalculés en direct** ; les années passées viennent des résultats gardés ; date du cours = fin d'année scolaire (sinon jour de l'impression) | Bulletins, B4 | `bulletins()`, `_anneeEnCours` |
| H55 | Bulletin annuel : par matière, les moyennes des 3 trimestres et leur moyenne (pour information) ; la moyenne annuelle générale reste (T1 + T2 + T3) ÷ 3 | Bulletins | `_moyenneMatiereAnnee` |
| H56 | Blocs de suite de la fiche de scolarité : **deux blocs vierges** imprimés en page 2, à remplir à la main par les écoles suivantes (pas de transfert numérique : P7, version 3) | B4 | `pdfB4` |
| H57 | **Chaque** fiche de scolarité générée est inscrite au journal (copie conforme ou non), avec son auteur ; seuls le directeur et les délégués « registres » peuvent en générer | B4 | `scolarity_copy_log` |
| H58 | L'enseignant écrit l'appréciation de sa classe ; seul le directeur écrit l'observation et la décision (une valeur envoyée par un enseignant est ignorée par le serveur) | Bulletins | `app.report_card_guard` |
