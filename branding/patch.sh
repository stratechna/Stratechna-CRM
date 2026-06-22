#!/bin/sh
# Stratechna CRM — patch de branding nos bundles compilados
set -e

ASSETS="/app/packages/twenty-server/dist/front/assets"
INDEX="/app/packages/twenty-server/dist/front/index.html"

echo "[Stratechna] A aplicar patch de branding..."

# Patch nos bundles JS e CSS
find "$ASSETS" -type f \( -name "*.js" -o -name "*.css" \) | while read f; do
  sed -i 's/Twenty CRM/Stratechna CRM/g' "$f"
  sed -i 's/Twenty is /Stratechna CRM is /g' "$f"
  sed -i 's/>Twenty</>Stratechna CRM</g' "$f"
  sed -i 's/Welcome to Twenty/Welcome to Stratechna CRM/g' "$f"
  sed -i 's/twentycrm\.io\/privacy-policy/stratechna.com\/privacidade/g' "$f"
  sed -i 's/twentycrm\.io\/terms/stratechna.com\/termos/g' "$f"
  sed -i 's/app\.twenty\.com/crm.stratechna.com/g' "$f"
done

# Patch no index.html
if [ -f "$INDEX" ]; then
  sed -i 's/<title>Twenty<\/title>/<title>Stratechna CRM<\/title>/g' "$INDEX"
  sed -i 's/twentycrm\.io\/privacy-policy/stratechna.com\/privacidade/g' "$INDEX"
  sed -i 's/twentycrm\.io\/terms/stratechna.com\/termos/g' "$INDEX"
fi

echo "[Stratechna] Patch concluido."
