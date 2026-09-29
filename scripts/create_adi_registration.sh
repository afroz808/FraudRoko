#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$ROOT/android/app/src/main/assets/adi-registration.properties"
mkdir -p "$(dirname "$TARGET")"
read -r -s -p "Paste the Google Play Android Developer Verification token: " TOKEN
printf '\n'
if [[ -z "$TOKEN" ]]; then
  echo "Token is empty. Nothing was written."
  exit 1
fi
printf '%s' "$TOKEN" > "$TARGET"
unset TOKEN
chmod 600 "$TARGET"
echo "Created $TARGET"
echo "Keep this file private and do not commit/share it."
