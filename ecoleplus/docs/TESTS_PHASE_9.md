# Tests de la phase 9 — Bibliothèque pédagogique et archives

Pour un directeur testeur. Durée : environ 40 minutes. Téléphone avec la
nouvelle version, serveur de test « École Test » (300 Mo d'espace).
Comptes : `directeur@ecole-test.local`, `enseignant1@ecole-test.local`
(CM1 A), `enseignant2@ecole-test.local` (CM2 A) — mot de passe
`motdepasse-test`. **Documents de test uniquement** (fiches, exercices,
programmes publics) : pas de notes, photos ou informations de santé
d'élèves. ✅ = ce que vous devez constater.

Préparez sur le téléphone une dizaine de fichiers (PDF, Word, photos de
pages), dont un **scan** (photo ou PDF d'une page imprimée).

## 1. Ajouter des documents (plusieurs à la fois)
1. Accueil → « Bibliothèque » (ou « Documents » → section « École » →
   « Bibliothèque pédagogique »). ✅ En haut : « x % utilisé (… sur 300 Mo) ».
2. « Ajouter des documents » → choisissez **plusieurs fichiers** d'un coup.
   ✅ Deux rappels : pas de données personnelles d'élèves ; seulement des
   documents que vous avez le droit d'utiliser.
3. Cochez « Commun à toute l'école » (ou choisissez des classes), un type,
   des mots-clés → « Ajouter ». ✅ Les documents apparaissent tout de suite
   dans la liste, avec « Envoi … % » tant qu'ils ne sont pas sur le serveur.
4. Ajoutez une 2e fois les mêmes fichiers. ✅ « 0 document(s) ajouté(s) ;
   n déjà présent(s) » : pas de doublon.

## 2. Coupure de réseau pendant l'envoi (critère du GO)
1. Ajoutez 4 ou 5 gros fichiers ; pendant l'envoi, passez en **mode avion**.
   ✅ Carte « n fichiers à envoyer — l'envoi reprend tout seul là où il
   s'est arrêté ».
2. Rétablissez le réseau → « Envoyer » (ou attendez). ✅ L'envoi repart du
   pourcentage atteint (pas de zéro) ; à la fin, plus rien à envoyer et
   aucun document en double.

## 3. Sans Internet
1. Ouvrez un document → « Garder sur mon téléphone ». ✅ « Sur ce
   téléphone (… Ko) : s'ouvre sans Internet ».
2. Retour → « Libérer » (bas de page). ✅ Seuls les documents épinglés
   restent sur le téléphone.
3. **Mode avion** : la liste et la recherche par titre / mots-clés
   marchent. ✅ Le document épinglé s'ouvre **en moins de 3 secondes**
   (aperçu des PDF et des images ; Word / Excel : « Ouvrir avec… »).
   ✅ Un document non épinglé : « Ce document n'est pas sur le téléphone :
   connectez-vous à Internet… ».

## 4. Recherche dans le texte (lecture automatique)
1. Après l'envoi du scan, attendez la lecture du texte (toutes les 15
   minutes, voir le rapport : elle doit être activée sur GitHub). La fiche
   du document passe de « Lecture du texte en attente » à « Texte lu :
   cherchable ».
2. Tapez un mot **écrit dans le scan** (pas dans le titre) → « Chercher
   « … » dans le texte ». ✅ Le document est trouvé, avec le n° de page et
   un extrait, le mot entre « ».
3. Même recherche en mode avion. ✅ Message : connexion nécessaire ; la
   recherche par titre reste possible.

## 5. Droits (critère du GO)
1. Directeur : ajoutez un document réservé au **CM1 A** et un réservé au
   **CM2 A**.
2. `enseignant1` → « Bibliothèque ». ✅ Il voit le commun et le CM1 A,
   **jamais le CM2 A** (ni dans la liste, ni dans la recherche dans le
   texte).
3. `enseignant1` → « Ajouter des documents ». ✅ « Vos documents seront
   visibles par les autres après validation du directeur » ; le document
   apparaît « En attente de validation ».
4. Directeur → ce document → « Valider ». ✅ Il devient visible par la
   classe choisie. Le réglage « Ajout de documents par les enseignants »
   (bas de la bibliothèque) permet aussi « sans validation » ou « Non ».

## 6. Archives administratives
1. Directeur → bouton **« Archives »** de l'accueil (commande à part, plus
   dans « Documents »). ✅ Rappel :
   réservées au directeur et aux personnes désignées, **jamais utilisées
   par l'assistant IA**.
2. Ajoutez un procès-verbal scanné. ✅ Fiche : « Jamais utilisé par
   l'assistant IA (archives) ».
3. `enseignant1` / `enseignant2`. ✅ Aucun bouton « Archives » sur l'accueil ; un mot du
   procès-verbal n'est jamais trouvé par la recherche.
4. Formulaire **B1** (ou B3, B6, B7) imprimé et signé : « Archiver la copie
   signée (scan PDF ou photo) » → choisissez le scan. ✅ « Copie signée
   archivée » ; l'état passe à « Signé et archivé » ; le scan est dans les
   archives.

## 7. Corbeille et espace
1. Un document → « Mettre à la corbeille ». ✅ Il quitte la liste ;
   « Corbeille » → « Restaurer » le remet. Au bout de 30 jours, il est
   effacé du serveur.
2. ✅ Le pourcentage utilisé augmente avec les ajouts. Si l'espace est
   plein : « Document « … » — Espace plein : X Mo utilisés sur 300 Mo.
   Videz la corbeille ou demandez plus d'espace. » (dans « Synchroniser »),
   et le fichier n'est pas envoyé.

## Résultats automatiques (mesurés le 28/10/2026)
- Téléphone : **183 tests ✅**, dont 5 pour la phase 9 :
  - 50 fichiers ajoutés hors ligne, envoi **coupé après 40 morceaux puis
    repris** : 50 fichiers sur le serveur, identiques octet par octet,
    150 morceaux reçus au total (aucun renvoyé), aucun doublon ; même lot
    ajouté une 2e fois : 50 doublons reconnus ;
  - mode avion : document épinglé ouvert en **127 ms** ; document libéré :
    message clair ; recherche dans le texte hors ligne : message clair ;
  - enseignant : ajout en attente de validation ; espace plein : refus
    expliqué, rien n'est envoyé, rien ne reste en attente ;
  - copie signée du B1 rangée dans les archives (jamais pour l'IA),
    formulaire « Signé et archivé ».
- **200 documents ajoutés d'un coup** (40 Ko chacun, sans Internet) :
  ajout 1,5 s ; catalogue + recherche par titre et mot-clé **28 ms** ;
  envoi complet (serveur simulé) 1,2 s.
- Serveur (pgTAP) : **334 tests ✅**, dont 24 pour la phase 9 (enseignant :
  fonds commun et sa classe seulement, ni archives ni passages des
  archives ; autre école : rien ; quota : message clair ; **un directeur ne
  peut pas augmenter son propre quota**).
- Intégration (vrai serveur local) : **21 tests ✅**, dont un document de
  **14 Mo envoyé par morceaux de 6 Mo, coupé après le 1er puis repris**
  (3 morceaux au total, fichier identique) ; reçu par l'enseignante du
  CM1 A, refusé à l'enseignant du CM2 A ; archives refusées aux deux.
- Lecture du texte (Tesseract français, serveur local) : scan d'une page
  lu en 1,8 s ; le mot « karité » est trouvé par le directeur et par
  l'enseignant ; un mot d'un procès-verbal des archives est trouvé par le
  directeur, **jamais par l'enseignant** ; coût mesuré 0,0002 $ par page
  (temps de calcul GitHub).
