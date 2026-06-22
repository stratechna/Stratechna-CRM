#!/bin/sh
# Stratechna CRM — patch de branding nos bundles compilados
set -e

ASSETS="/app/packages/twenty-server/dist/front/assets"
FRONT="/app/packages/twenty-server/dist/front"
INDEX="$FRONT/index.html"

echo "[Stratechna] A aplicar patch de branding..."

# ── 1. Substituir ícones PNG ───────────────────────────────────────────────────
cp /tmp/branding-icons/icon-48.png  "$FRONT/images/icons/android/android-launchericon-48-48.png"
cp /tmp/branding-icons/icon-192.png "$FRONT/images/icons/android/android-launchericon-192-192.png"
cp /tmp/branding-icons/icon-512.png "$FRONT/images/icons/android/android-launchericon-512-512.png"
cp /tmp/branding-icons/icon-180.png "$FRONT/images/icons/ios/180.png"
cp /tmp/branding-icons/icon-192.png "$FRONT/images/icons/ios/192.png"

# ── 2. Patch texto nos bundles JS e CSS ───────────────────────────────────────
find "$ASSETS" -type f -name "*.js" -o -name "*.css" | while read f; do
  sed -i 's/Twenty CRM/Stratechna CRM/g' "$f"
  sed -i 's/Twenty is /Stratechna CRM is /g' "$f"
  sed -i 's/>Twenty</>Stratechna CRM</g' "$f"
  sed -i 's/Welcome to Twenty/Welcome to Stratechna CRM/g' "$f"
  sed -i 's/twentycrm\.io\/privacy-policy/stratechna.com\/privacidade/g' "$f"
  sed -i 's/twentycrm\.io\/terms/stratechna.com\/termos/g' "$f"
  sed -i 's/app\.twenty\.com/crm.stratechna.com/g' "$f"
done

# ── 3. Patch index.html ───────────────────────────────────────────────────────
if [ -f "$INDEX" ]; then
  sed -i 's/<title>Twenty<\/title>/<title>Stratechna CRM<\/title>/g' "$INDEX"
  sed -i 's/A modern open-source CRM/Stratechna CRM/g' "$INDEX"
  sed -i 's/twentycrm\.io\/privacy-policy/stratechna.com\/privacidade/g' "$INDEX"
  sed -i 's/twentycrm\.io\/terms/stratechna.com\/termos/g' "$INDEX"
  sed -i 's|content="Twenty"|content="Stratechna CRM"|g' "$INDEX"
fi

echo "[Stratechna] Patch concluido."
