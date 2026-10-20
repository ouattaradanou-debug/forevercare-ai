#!/usr/bin/env bash
# Pipeline local : analyse, format, tests Flutter, puis tests de la base.
set -euo pipefail
cd "$(dirname "$0")/.."
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
npx --yes supabase@2.121.0 db reset
npx --yes supabase@2.121.0 test db
