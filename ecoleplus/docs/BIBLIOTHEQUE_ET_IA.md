# Bibliothèque, reconnaissance de texte et indexation — estimations phase 0

> Les chiffres marqués **mesuré** ont été obtenus dans l'environnement de développement le 20/10/2026. Les tarifs proviennent de pages publiques consultées le même jour (sources en bas de page) : **à revérifier avant tout engagement**. Conversion indicative : 1 USD ≈ 600 FCFA (à vérifier).

## 1. Hypothèses de volume (à valider sur le terrain)

| Hypothèse | Valeur | Origine |
|---|---|---|
| Documents par classe | 200 | spécification 18.1 |
| Classes par école | 12 | spécification 18.1 |
| Documents par école | 2 400 | calcul |
| Poids moyen d'un document | 2 Mo | spécification 18.1 ; cohérent avec la mesure ci-dessous (~100 Ko par page JPEG à 150 ppp) |
| Pages par document | 10 | **hypothèse** |
| Part de documents scannés (OCR nécessaire) | 50 % | **hypothèse** |
| Passages (« chunks ») par page | 2 (~800 caractères, ~200 jetons) | choix technique |

Soit par école : 24 000 pages, 12 000 pages à reconnaître, 48 000 passages.

## 2. Stockage

| Poste | Par école | Mesure / calcul |
|---|---|---|
| Fichiers (Supabase Storage) | ~4,8 Go | 2 400 × 2 Mo |
| Index en base (texte + vecteur 1024 + index HNSW) | ~0,49 Go | **mesuré** : 10 178 octets par passage (6 991 sans index HNSW) × 48 000 |

Coûts mensuels indicatifs (plan Supabase Pro à 25 $/mois : 100 Go de fichiers et 8 Go de base inclus ; au-delà ~0,021 $/Go de fichiers et 0,125 $/Go de base) :
* jusqu'à ~20 écoles, fichiers inclus dans le forfait ; ensuite ~0,10 $/école/mois (~60 FCFA) ;
* index : ~16 écoles tiennent dans les 8 Go inclus ; ensuite ~0,06 $/école/mois.
* Levier si besoin : vecteurs en demi-précision (`halfvec`) ou dimension 512 → environ −30 à −40 % de l'index.

**Quota par école : 5 Go conservé** (proche de l'estimation de 4,8 Go). À réévaluer avec le poids réel mesuré en phase 9 ; l'écran affichera « N % utilisé ».

## 3. Reconnaissance de texte (OCR) en français — deux options comparées

### Option A — Tesseract 5 (modèle `fra`), hébergé par nous (tâche de fond sur un petit serveur)
**Mesuré** sur 18 pages **simulées** (texte original en français avec accents, chiffres décimaux, guillemets ; dégradées comme une photo de téléphone : rotation, flou, bruit, éclairage inégal, JPEG) — script `tools/ocr_bench/bench_tesseract.py` :

| Dégradation | Taux d'erreur par caractère (CER) | Temps par page | Poids image |
|---|---|---|---|
| Nulle (6 pages) | 0,0 à 0,2 % | 0,66 à 0,71 s | ~105 Ko |
| Moyenne (6 pages) | 0,0 à 0,7 % | 0,62 à 0,71 s | ~108 Ko |
| Forte (6 pages) | 2,5 à 9,5 % | 0,64 à 0,84 s | ~96 Ko |

⚠️ Ce sont des pages simulées, imprimées en caractères nets : de **vrais** scans (papier jauni, photocopies, tampons, colonnes, manuels anciens) donneront des résultats moins bons. La mesure sur de vrais documents se fait avec la procédure du §6.

* Coût : gratuit (logiciel libre) ; ~2,3 h de calcul pour les 12 000 pages d'une école (sur 1 cœur), à faire une fois.
* Limite : ne tourne pas dans une Edge Function Supabase (binaire natif, limite de temps CPU) → il faut un petit serveur ou conteneur « travailleur » qui lit la file d'indexation.
* Confidentialité : les documents ne quittent pas notre infrastructure.

### Option B — Service d'OCR en ligne (appelé par la tâche de fond)
| Service | Tarif public | 12 000 pages / école | Remarques |
|---|---|---|---|
| Google Cloud Vision (Document Text Detection) | 1 000 pages/mois gratuites, puis 1,50 $ / 1 000 | ~16,50 $ (une fois) | robuste sur photos ; extraits envoyés à Google |
| Mistral OCR | ~4 $ / 1 000 (2 $ en lot asynchrone) selon les sources | ~24 à 48 $ (une fois) | sources contradictoires sur le tarif |

* Qualité : généralement supérieure à Tesseract sur photos difficiles (**non mesuré ici** : nécessite un compte et de vrais scans).
* Appelable depuis une Edge Function (simple requête HTTP).
* Confidentialité : extraits envoyés à un tiers → à mentionner dans le texte d'information.

### Recommandation
Tesseract (option A) par défaut — gratuit, données gardées chez nous, très bon sur des pages correctes — **avec bascule automatique vers l'option B** pour les pages où Tesseract renvoie une confiance faible, si le directeur l'autorise. Décision définitive après la mesure sur 20 vrais scans fournis par l'école pilote (§6). Hors périmètre V1 : écriture manuscrite.

Pour mémoire : Google ML Kit (reconnaissance sur le téléphone, gratuite et hors ligne) serait pertinent pour la numérisation par caméra (P3, reportée) ; non retenu pour l'indexation, qui se fait côté serveur.

## 4. Indexation — deux options comparées

| Critère | Option I1 — Texte intégral Postgres (`tsvector` français + `pg_trgm`) | Option I2 — Vecteurs sémantiques (`pgvector`) via une API d'« embeddings » |
|---|---|---|
| Ce que ça trouve | les mots (avec racines : « multiplications décimales » trouve « multiplication des nombres décimaux », **testé**) | les passages de même sens, même sans les mêmes mots |
| Coût | gratuit | ex. OpenAI `text-embedding-3-small` : 0,02 $ / million de jetons → ~0,19 $ par école (9,6 M de jetons, une fois) |
| Poids | ~3 Ko par passage | +4 Ko par passage (1024 dimensions) + index HNSW (~3 Ko) |
| Hors ligne | catalogue consultable ; recherche plein texte côté serveur | non |
| Confidentialité | aucun envoi | extraits envoyés au fournisseur (documents autorisés seulement) |
| Usage | barre de recherche de la bibliothèque (18.4) | « Sources utilisées » de l'IA (11.5) |

**Recommandation : les deux (recherche hybride)**. I1 pour la recherche des utilisateurs et comme repli ; I2 uniquement pour les documents de bibliothèque autorisés pour l'IA, non sensibles (garanti par la base : `CHECK` + trigger testés). Fusion des deux classements pour l'IA. La dimension des vecteurs (1024 provisoire) sera fixée en phase 9 avec le fournisseur retenu.

## 5. Coût total indicatif par école (12 classes)

| Poste | Une fois | Par mois |
|---|---|---|
| OCR (option A / option B Google) | ~0 $ / ~16,50 $ | — |
| Vecteurs | ~0,19 $ | négligeable (nouveaux documents) |
| Stockage fichiers + index (au-delà du forfait) | — | ~0,16 $ |
| Questions à l'IA | — | dépend du modèle choisi (plafond par école via `ai_quotas`) |

Le poste dominant n'est pas la bibliothèque mais le **forfait Supabase** (25 $/mois partagés entre toutes les écoles) et l'**usage de l'IA générative** (phase 12).

## 6. Procédure de mesure sur de vrais scans (à faire avec l'école pilote)
1. Photographier au téléphone 20 pages réelles variées (manuel, sujet d'examen, fiche photocopiée, page pâle…), sans données d'élèves.
2. Pour chaque photo `page01.jpg`, taper le texte exact dans `page01.txt` (UTF-8).
3. Mettre les paires dans un dossier, puis lancer : `python3 -I tools/ocr_bench/bench_tesseract.py CHEMIN_DU_DOSSIER`.
4. Reporter le CER moyen dans ce document ; si > 5 %, tester l'option B sur les mêmes pages.

## Sources des tarifs (consultées le 20/10/2026)
* Supabase : synthèses tierces de la page de tarifs (makerkit.dev, jetadmin.io, schematichq.com) — page officielle supabase.com/pricing non consultée directement.
* Google Cloud Vision : cloud.google.com/vision/pricing.
* Mistral OCR : articles tiers (edenai.co, tech-insider.org) — tarif contradictoire.
* OpenAI `text-embedding-3-small` : developers.openai.com (fiche du modèle).
