# Correspondance « colonne de formulaire → champ en base » (ANNEXE B)

Légende : `table.colonne` ; **calculé** = obtenu à l'impression à partir des champs cités ; **fixe** = texte imprimé du modèle (à reprendre mot pour mot depuis le scan) ; **à confirmer** = libellé ou interprétation à valider avec le directeur.
Pour tous les formulaires : « Fait à … » → `official_forms.signed_place` ; « le … » → `official_forms.signed_on` ; nom du directeur → `official_forms.director_name` (prérempli depuis `schools.director_name`) ; signature → `schools.director_signature_path` ; cachet → `schools.stamp_path` ; année scolaire → `school_years.label` ; versions imprimées → `form_versions` ; état → `official_forms.status`.

**Phase 2** : les champs propres aux registres et à la fiche de scolarité (C.E.P., venant de, allant à, motif, diplômes, observations, race, religion) sont dans `student_registry` (même identifiant que l'élève), table que l'enseignant ne peut jamais lire.

**Contrôle : 0 colonne sans champ** (le script de vérification est le tableau lui-même ; chaque ligne cite une colonne existante du schéma).

## B1 — Fiche de renseignement du personnel par école (A4 paysage)

| Élément du modèle | Champ en base |
|---|---|
| En-tête « CEB de ____ » | `admin_headers.ceb` (de l'année) |
| « année scolaire ____ » | `school_years.label` |
| « école de ____ » | `admin_headers.school_label` |
| N° d'ordre | **calculé** : rang de la ligne dans la liste imprimée (ordre : `teachers.last_name`, puis prénoms — à confirmer) |
| Matricule | `teachers.matricule` |
| Nom et Prénoms | `teachers.last_name` + `teachers.first_names` |
| Emploi | `teachers.emploi` |
| Catégorie ; Échelon | `teachers.categorie` ; `teachers.echelon` |
| Date de naissance | `teachers.birth_date` |
| Sexe | `teachers.sex` |
| Service/classe tenue | `teacher_year_assignments.class_id` → `classes.name`, sinon `teacher_year_assignments.service_label` |
| Fonction ou poste occupé | `teacher_year_assignments.fonction` |
| Dernier diplôme académique (position sous/à côté d'« Ancienneté » : à confirmer) | **calculé** : `teacher_diplomas.nature` le plus récent (`delivered_on`) avec `is_academic = true` |
| Ancienneté — Générale | **calculé** : `official_forms.reference_date` − `teachers.seniority_general_from` |
| Ancienneté — Dans l'emploi | **calculé** : `reference_date` − `teachers.seniority_emploi_from` |
| Ancienneté — Dans la région | **calculé** : `reference_date` − `teachers.seniority_region_from` |
| Ancienneté — Dans la fonction | **calculé** : `reference_date` − `teachers.seniority_fonction_from` |
| Contact | `teachers.phone` |

Règle de calcul des durées (années, mois ; arrondi) : **hypothèse à valider**, aucune règle officielle inventée.

## B2 — Registre matricule des élèves (« Mod. 557 »)

| Élément du modèle | Champ en base |
|---|---|
| Couverture : Province de | `admin_headers.province` |
| Département de | `admin_headers.departement` |
| Commune de | `admin_headers.commune` |
| École | `admin_headers.school_label` |
| « admis à l'école du 1er janvier 20__ au ____ » | `official_forms.register_period_from` / `official_forms.register_period_to` |
| 1 Numéro d'ordre | `students.registry_number` (attribué par le serveur, jamais réutilisé) |
| 2 Noms et prénoms des élèves | `students.last_name` + `students.first_names` |
| 3 Date de naissance | `students.birth_date` |
| 4 Noms et prénoms des parents ou tuteurs | `guardians.full_name` (relations `pere`, `mere`, `tuteur`, ordre `sort_order`) |
| 5 Profession et domicile des parents ou tuteurs | `guardians.profession` + `guardians.domicile` |
| 6 Date de l'entrée à l'école | `students.entry_date` |
| 7 Date de l'obtention du C.E.P. | `student_registry.cep_date` |
| 8 Date de sortie définitive de l'école | `students.exit_date` |
| 9 Observations | `student_registry.registry_observations` (+ rappel imprimé du modèle : **fixe**, libellé exact à reprendre du scan) ; école d'origine préremplie depuis `student_registry.origin_school` |

## B3 — Registre du personnel enseignant (A4 paysage, double page)

| Colonne | Champ en base |
|---|---|
| 1 Noms et prénoms | `teachers.last_name` + `teachers.first_names` |
| 2 Date et lieu de naissance | `teachers.birth_date` + `teachers.birth_place` |
| 3 Date de la nomination dans la commune | `teachers.commune_nomination_date` |
| 4 Titulaire ou stagiaire (T ou S) | `teachers.tenure_status` |
| 5 Classe | `teacher_year_assignments.class_id` → `classes.name` (année en cours) |
| 6 Service antérieur — élève à l'école de (dates d'entrée et de sortie) | `teachers.pupil_school_name`, `teachers.pupil_school_entry_date`, `teachers.pupil_school_exit_date` |
| 7 Service antérieur — Date de la première nomination dans l'enseignement | `teachers.first_teaching_nomination_date` |
| 8 Communes successives (date de chaque nomination) | liste `teacher_postings` (`commune`, `nominated_on`, `sort_order`) |
| 9 Interruptions de service (causes et durées) | liste `teacher_interruptions` (`cause`, `starts_on`, `ends_on`, `duration_text`) |
| 10 Récompenses obtenues | liste `teacher_awards` (`label`, `awarded_on`) |
| 11 Titres de capacité (nature, date de délivrance) | liste `teacher_diplomas` (`nature`, `delivered_on`) |
| 12 Date de cessation de fonctions dans la commune et nouveau poste | `teachers.commune_cessation_date` + `teachers.new_post` |
| 13 Observations | `teachers.observations` (rappel « n'indiquez pas d'informations médicales ») |

## B4 — Fiche de scolarité (A4 paysage, une par élève)

| Élément du modèle | Champ en base |
|---|---|
| En-tête : ministère | `admin_headers.ministry` |
| direction régionale | `admin_headers.regional_direction` |
| direction provinciale | `admin_headers.provincial_direction` |
| emblème | `admin_headers.emblem_path` |
| « BURKINA FASO » (+ devise) | `admin_headers.country` (+ `admin_headers.motto`) |
| Nom | `students.last_name` + `students.first_names` |
| Sexe | `students.sex` |
| né(e) le / à | `students.birth_date` / `students.birth_place` |
| Fils ou fille de / Profession | `guardians` (`relation = 'pere'`) `.full_name` / `.profession` |
| et de / Profession | `guardians` (`relation = 'mere'`) `.full_name` / `.profession` |
| Domicilié à | `students.domicile` |
| Race (facultatif, masqué par défaut) | `student_registry.race` (imprimé seulement si `schools.show_race_religion`) |
| Religion (facultatif, masqué par défaut) | `student_registry.religion` (idem) |
| N° Mle | `students.registry_number` (équivalence avec B2 **à confirmer**) |
| École | `admin_headers.school_label` (défaut `schools.name`) |
| Nom et adresse du logeur (Père ou Tuteur) | `guardians` (`is_lodger = true`) `.full_name` + `.address` |
| Entré le / Venant de | `students.entry_date` / `student_registry.origin_school` |
| Sorti le / allant à / Motif du départ | `students.exit_date` / `student_registry.destination` / `student_registry.exit_reason` |
| Cours suivis : colonnes C.P.1 … C.M.2 (2 sous-colonnes = redoublement, **à confirmer**) | `annual_results.level_code` + `annual_results.attempt` |
| ligne Date | `annual_results.result_date` |
| ligne Moyenne générale | `annual_results.general_average` |
| ligne Classement (1) | **calculé** : `annual_results.rank` + « e/ » + `annual_results.class_size` (ex. « 7e/39 » ; mention ex-aequo selon `rank_ex_aequo`, à confirmer) |
| Diplômes obtenus et date d'obtention | `student_registry.diplomas` (+ `student_registry.cep_date`) |
| Observations du Directeur | `student_registry.director_observations` |
| Signature du Directeur | `schools.director_signature_path` / `official_forms.director_name` |
| Année en cours (phase 4) | **calculée en direct** depuis les notes (moyenne annuelle (T1 + T2 + T3) ÷ 3, rang, effectif) : une note corrigée change aussitôt la fiche |
| Logeur (si aucun parent n'est marqué logeur) | `guardians` « logeur », puis « tuteur », puis « père » |
| Blocs de suite (établissements suivants) | imprimés **vierges** en page 2 (deux blocs), à remplir à la main |
| Copie conforme | mention « COPIE CONFORME » + date ; chaque génération dans `scolarity_copy_log` (journal d'activité) |
| Emblème, image de signature | non imprimés pour l'instant (images à ajouter avec la phase des cartes) |
| Blocs de suite : N° Mle / École / Logeur | `scolarity_followups.registry_number` / `.school_name` / `.lodger_name_address` |
| Entré le / Venant de | `scolarity_followups.entered_on` / `.came_from` |
| Sorti le / allant à / Motif du départ | `scolarity_followups.left_on` / `.going_to` / `.exit_reason` |
| Cours suivis (Date, Classement) | `scolarity_followup_courses.level_code`, `.attempt`, `.result_date`, `.ranking_text` |
| Diplômes / Observations du Directeur | `scolarity_followups.diplomas` / `.director_observations` |
| Signature du Directeur (bloc de suite) | emplacement vide à l'impression |
| Observations générales imprimées | **fixe** (texte du modèle, mot pour mot, à reprendre du scan) |
| Mention « copie conforme » | `form_versions.is_certified_copy` + journal `scolarity_copy_log` |

## B5 — Fiche médico-scolaire (module optionnel, schéma `medical`)

| Élément du modèle | Champ en base |
|---|---|
| A) I Familiaux : Diabète ; Asthme ; HTA ; Autres | `medical.records.fam_diabete`, `.fam_asthme`, `.fam_hta`, `.fam_autres` |
| A) II a) Hémoglobine ; Groupe sanguin rhésus | `.hemoglobine`, `.groupe_sanguin_rhesus` |
| Diabète ; Asthme | `.diabete`, `.asthme` |
| Rhinites à répétitions ; Angines à répétitions | `.rhinites_repetition`, `.angines_repetition` |
| Trachome ; Poliomyélite ; Rougeole ; Autres | `.trachome`, `.poliomyelite`, `.rougeole`, `.autres_medicaux` |
| Vaccinations : B.C.G. ; D.T.C.P. ; Anti-rougeoleux ; Anti-amarile ; Anti-méningococcique | `.vacc_bcg`, `.vacc_dtcp`, `.vacc_antirougeoleux`, `.vacc_antiamarile`, `.vacc_antimeningococcique` |
| A) II b) chirurgicaux | `.antecedents_chirurgicaux` |
| B) I Constantes, colonnes « 20… » (×8) | une ligne `medical.yearly_exams` par année (`year_label`) |
| Urines (Alb., Sucre) | `yearly_exams.urines_alb`, `.urines_sucre` |
| AV (OD, OG) | `yearly_exams.av_od`, `.av_og` |
| AA (OD, OG) | `yearly_exams.aa_od`, `.aa_og` |
| Poids ; Taille | `yearly_exams.poids`, `.taille` |
| B) II Examen physique, lignes « 20… » (×8) | `yearly_exams.examen_physique` |
| OBSERVATIONS : Apte / À surveiller / Inapte temporaire / Inapte définitif | `medical.fitness.aptitude` (par année ; `expose_to_teacher` pour la seule mention exposable) |

## B6 — Programme d'activités au titre de l'année scolaire (A4 paysage)

| Élément du modèle | Champ en base |
|---|---|
| Couverture : ministère, région, direction régionale, direction provinciale, CEB, école | `admin_headers.ministry`, `.region`, `.regional_direction`, `.provincial_direction`, `.ceb`, `.school_label` |
| Titre « PROGRAMME D'ACTIVITÉS AU TITRE DE L'ANNÉE SCOLAIRE » | **fixe** |
| Année | `school_years.label` |
| N° d'ordre | position de l'objectif (tri par `activity_objectives.order_no`, H65) |
| Objectifs (cellule fusionnée) | `activity_objectives.label` |
| Activités prévues | `activity_lines.planned_activity` |
| Échéances | `activity_lines.deadline_on` (ou `deadline_text`) |
| Contrainte de réalisation | `activity_lines.constraint_text` |
| Résultats attendus | `activity_lines.expected_result` |
| Fait à … le … ; directeur (nom, signature, cachet) | voir en-tête du document |
| L'inspecteur, chef de la circonscription (nom, signature, cachet) | emplacement **laissé vide** à l'impression (aucune donnée) |
| Version finale (17.4) | `form_versions` (instantané `snapshot`, ajout seul) ; verrou `official_forms.locked_version` |

## B7 — Bilan de programme annuel d'activités (A4 paysage)

| Élément du modèle | Champ en base |
|---|---|
| Couverture (même en-tête que B6), titre « BILAN DE PROGRAMME ANNUEL D'ACTIVITÉS », année | `admin_headers.*`, **fixe**, `school_years.label` |
| N° d'ordre | `activity_objectives.order_no` |
| Objectifs | `activity_objectives.label` |
| Activités prévues | `activity_lines.planned_activity` |
| Résultats attendus | `activity_lines.expected_result` |
| Résultats atteints | `activity_lines.achieved_result` |
| Taux de réussite (%) | `activity_lines.success_rate` (saisi ; moyenne par objectif **calculée** en option : `official_forms.show_objective_average`) |
| Bloc de fin | identique à B6 |

## Documents du directeur (A17, modèles du porteur)

| Élément | Source |
|---|---|
| En-tête long : ministère, direction régionale, direction provinciale, circonscription, école ; « BURKINA FASO », devise | `admin_headers` (`ministry`, `regional_direction`, `provincial_direction`, `ceb`, `school_label`, `country`, `motto`) ; à défaut `schools.name` |
| En-tête court (demi-page) : circonscription, école ; année scolaire | `admin_headers.ceb`, `school_label` ; `school_years.label` |
| « Je soussigné(e) Madame/Monsieur …, Directrice/Directeur … » ; nom ; grade | `schools.director_civility`, `schools.director_name`, `schools.director_grade` |
| Élève : nom, né(e) le, à, fils/fille de … et de …, professions | `students`, `guardians` (père, mère) |
| N° matricule, « fréquente depuis le » | `students.registry_number`, `students.entry_date` |
| Classe, niveau | `enrollments` (année en cours, sinon la dernière) + `classes.name` / `level_code` |
| Enseignant : nom, matricule, emploi | `teachers.last_name`, `first_names`, `matricule`, `emploi` |
| Décision d'affectation n° … du … ; prise de service le … | `teachers.assignment_decision_number`, `assignment_decision_date`, `service_start_date` |
| Journal (sans numéro) | `issued_documents` |
