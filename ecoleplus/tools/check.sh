#!/usr/bin/env bash
# Pipeline local : format, analyse, tests Flutter, tests de la base, puis
# tests d'intégration contre le serveur local (Supabase démarré).
set -euo pipefail
cd "$(dirname "$0")/.."
SB="npx --yes supabase@2.121.0"
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/core test/features
node --experimental-strip-types tools/identifiant_parity.mjs
$SB db reset
$SB test db
if curl -s -o /dev/null http://127.0.0.1:54321/functions/v1/gerer-membres; then
  export SUPABASE_URL=http://127.0.0.1:54321
  SUPABASE_ANON_KEY=$($SB status -o env | sed -n 's/^ANON_KEY="\(.*\)"/\1/p')
  export SUPABASE_ANON_KEY
  $SB db reset
  flutter test test/integration
else
  echo "Tests d'intégration ignorés : lancez « $SB functions serve » dans un autre terminal."
fi
