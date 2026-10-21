#!/usr/bin/env bash
# Restauration d'une sauvegarde chiffrée dans une base VIDE dont la structure
# a été créée par les migrations (nouveau projet après « supabase db push »,
# ou base locale après « supabase db reset --no-seed »).
# Usage : BACKUP_PASSPHRASE=... tools/restauration_serveur.sh fichier.sql.gz.gpg "$DB_URL"
set -euo pipefail
FICHIER="$1"
DB_URL="$2"
: "${BACKUP_PASSPHRASE:?Définissez BACKUP_PASSPHRASE}"
gpg --batch --quiet --decrypt --passphrase-fd 3 3<<<"$BACKUP_PASSPHRASE" "$FICHIER" |
  gunzip -c |
  psql "$DB_URL" --quiet -v ON_ERROR_STOP=1 --single-transaction -f - > /dev/null
echo "Restauration terminée depuis $FICHIER"
