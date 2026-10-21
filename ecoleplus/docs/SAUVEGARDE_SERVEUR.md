# Sauvegarde et restauration du serveur (A6, point 4)

## Ce qui est sauvegardé
Toutes les données de la base : écoles, années, en-têtes, comptes (avec leurs mots de passe chiffrés), droits, téléphones, journal d'activité, questions secrètes (réponses chiffrées) et, au fil des phases, élèves, notes, finances… La **structure** n'est pas copiée : elle est recréée par les migrations du dépôt.

**Pas encore inclus** : les fichiers du stockage (images d'en-tête aujourd'hui ; photos et documents plus tard). Ils restent sur le stockage Supabase ; leur copie automatique sera ajoutée avec les photos (phase 8).

## Quand
Chaque nuit (01 h 17, heure du Burkina Faso), par GitHub Actions (« EcolePlus — sauvegarde du serveur »), et à la demande (« Run workflow »). Chaque copie est **chiffrée (AES-256)** avec la phrase `BACKUP_PASSPHRASE`, puis gardée **30 jours**.

## Restaurer (après une panne ou une erreur grave)
1. Créer un projet Supabase neuf (ou vider l'actuel) et y appliquer la structure : `npx supabase link --project-ref NOUVEAU_REF` puis `npx supabase db push`.
2. Télécharger la sauvegarde voulue : GitHub → Actions → « sauvegarde du serveur » → l'exécution du jour → « Artifacts ».
3. Restaurer : `BACKUP_PASSPHRASE="la phrase" tools/restauration_serveur.sh ecoleplus-AAAA-MM-JJ_HHMM.sql.gz.gpg "CHAINE_DE_CONNEXION"`.
4. Mettre à jour `SUPABASE_URL` / `SUPABASE_ANON_KEY` si le projet a changé, puis relancer « livraison téléphone ».

## Preuve
`tools/test_restauration.sh` (lancé aussi à chaque modification par l'intégration continue) : comptage de toutes les tables, sauvegarde chiffrée, **base vidée**, restauration, recomptage, connexion du directeur avec son mot de passe. Résultat obtenu le 21/10/2026 : « les 77 tables ont le même nombre de lignes qu'avant » et connexion réussie.
