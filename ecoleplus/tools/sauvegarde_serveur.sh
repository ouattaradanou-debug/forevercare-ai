#!/usr/bin/env bash
# Sauvegarde chiffrée de TOUTES les données de la base (écoles, comptes).
# Usage : BACKUP_PASSPHRASE=... tools/sauvegarde_serveur.sh "$DB_URL" dossier_sortie
# La phrase secrète n'est jamais écrite sur le disque ; sans elle, le fichier
# est illisible. Les fichiers (images) du stockage sont à copier à part.
set -euo pipefail
DB_URL="$1"
OUT="${2:-.}"
: "${BACKUP_PASSPHRASE:?Définissez BACKUP_PASSPHRASE}"
SB="${SUPABASE_CLI:-npx --yes supabase@2.121.0}"
mkdir -p "$OUT"
STAMP=$(date -u +%Y-%m-%d_%H%M)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
# Données seulement : la structure est recréée par les migrations du dépôt.
# Exclues : tables remplies par les migrations elles-mêmes.
$SB db dump --db-url "$DB_URL" --data-only --use-copy \
  --schema public,medical,app,auth \
  -x auth.schema_migrations -x public.levels -x public.modules_catalog -x app.sync_tables \
  -f "$TMP/donnees.sql"
FICHIER="$OUT/ecoleplus-$STAMP.sql.gz.gpg"
gzip -9 -c "$TMP/donnees.sql" |
  gpg --batch --yes --quiet --symmetric --cipher-algo AES256 \
      --passphrase-fd 3 3<<<"$BACKUP_PASSPHRASE" -o "$FICHIER"
echo "Sauvegarde : $FICHIER ($(du -h "$FICHIER" | cut -f1))"
sha256sum "$FICHIER"
