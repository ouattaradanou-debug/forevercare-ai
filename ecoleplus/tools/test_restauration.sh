#!/usr/bin/env bash
# Essai complet sur la base locale : compte les lignes, sauvegarde, vide la
# base, restaure, recompte et vérifie qu'un compte peut se connecter.
set -euo pipefail
cd "$(dirname "$0")/.."
DB="postgresql://postgres:postgres@127.0.0.1:54322/postgres"
SB="${SUPABASE_CLI:-npx --yes supabase@2.121.0}"
export BACKUP_PASSPHRASE="phrase-de-test-$(date +%s)"
COMPTE="select string_agg(t || '=' || n, ' ' order by t) from (
  select table_schema || '.' || table_name as t,
         (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from %I.%I', table_schema, table_name), false, true, '')))[1]::text as n
    from information_schema.tables
   where table_type = 'BASE TABLE' and table_schema in ('public', 'medical', 'app')
     or (table_schema = 'auth' and table_name in ('users', 'identities'))) x"
AVANT=$(psql "$DB" -Atc "$COMPTE")
OUT=$(mktemp -d)
tools/sauvegarde_serveur.sh "$DB" "$OUT" 2>/dev/null
$SB db reset --no-seed > /dev/null 2>&1
VIDE=$(psql "$DB" -Atc "select count(*) from public.students")
tools/restauration_serveur.sh "$OUT"/ecoleplus-*.sql.gz.gpg "$DB"
APRES=$(psql "$DB" -Atc "$COMPTE")
echo "Élèves après remise à zéro : $VIDE"
if [ "$AVANT" = "$APRES" ]; then
  echo "OK : les $(echo "$APRES" | wc -w) tables ont le même nombre de lignes qu'avant."
else
  echo "ÉCART :"; diff <(echo "$AVANT" | tr ' ' '\n') <(echo "$APRES" | tr ' ' '\n'); exit 1
fi
ANON=$($SB status -o env 2>/dev/null | sed -n 's/^ANON_KEY="\(.*\)"/\1/p')
curl -sf -X POST "http://127.0.0.1:54321/auth/v1/token?grant_type=password" \
  -H "apikey: $ANON" -H "content-type: application/json" \
  -d '{"email":"directeur@ecole-test.local","password":"motdepasse-test"}' > /dev/null \
  && echo "OK : le directeur se connecte avec son mot de passe après restauration."
