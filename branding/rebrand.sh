#!/bin/bash
# /docker-entrypoint.d/99-stratechna-rebrand.sh
# Substitui "Twenty" por "Stratechna CRM" nos assets compilados do frontend React

set -e

FRONT_DIST="/app/packages/twenty-front/dist"

echo "[Stratechna CRM] A aplicar branding..."

if [ -d "$FRONT_DIST" ]; then
  find "$FRONT_DIST" -type f \( -name "*.js" -o -name "*.html" -o -name "*.css" \) | while read f; do
    # Nome visível na UI
    sed -i 's/Twenty CRM/Stratechna CRM/g'  "$f" 2>/dev/null || true
    sed -i 's/\bTwenty\b/Stratechna CRM/g'  "$f" 2>/dev/null || true
    # Classe CSS / atributos (lowercase)
    sed -i 's/twenty-crm/stratechna-crm/g'  "$f" 2>/dev/null || true
    # Título da página
    sed -i 's/<title>Twenty<\/title>/<title>Stratechna CRM<\/title>/g' "$f" 2>/dev/null || true
  done

  # Substituir no index.html especificamente
  INDEX="${FRONT_DIST}/index.html"
  if [ -f "$INDEX" ]; then
    sed -i 's/Twenty/Stratechna CRM/g' "$INDEX"
    sed -i 's|assets/logo|assets/logo|g' "$INDEX"
  fi
fi

echo "[Stratechna CRM] Branding aplicado."
