#!/bin/sh
# Stratechna CRM — branding patch
# Corre durante docker build (não em runtime)
set -e

FRONT_DIST="/app/packages/twenty-front/dist"
LOGO_SRC="/tmp/stratechna-logo.svg"

echo "[Stratechna] A aplicar branding na build..."

# ── 1. Substituir logo SVG (ficheiro com hash no nome) ────────────────────────
# O Vite gera algo como: twenty-logo-HASH.svg ou logo-HASH.svg
LOGO_FILE=$(find "$FRONT_DIST/assets" -name "*.svg" 2>/dev/null | head -1)
if [ -n "$LOGO_FILE" ]; then
  cp "$LOGO_SRC" "$LOGO_FILE"
  echo "[Stratechna] Logo substituído: $LOGO_FILE"
fi

# Também substituir em icons/ se existir
find "$FRONT_DIST" -name "*.svg" 2>/dev/null | while read f; do
  cp "$LOGO_SRC" "$f"
  echo "[Stratechna] SVG substituído: $f"
done

# ── 2. Substituir favicon (icons/) ────────────────────────────────────────────
ICONS_DIR="$FRONT_DIST/icons"
if [ -d "$ICONS_DIR" ]; then
  for f in "$ICONS_DIR"/*.svg 2>/dev/null; do
    [ -f "$f" ] && cp "$LOGO_SRC" "$f"
  done
fi

# ── 3. Patch texto "Twenty" → "Stratechna CRM" nos JS/HTML compilados ─────────
find "$FRONT_DIST" -type f \( -name "*.js" -o -name "*.html" -o -name "*.css" \) | while read f; do
  sed -i "s/Twenty CRM/Stratechna CRM/g" "$f" 2>/dev/null || true
  sed -i "s/>Twenty</>Stratechna CRM</g" "$f" 2>/dev/null || true
  sed -i "s/"Twenty"/"Stratechna CRM"/g" "$f" 2>/dev/null || true
  sed -i "s/Twenty is/Stratechna CRM is/g" "$f" 2>/dev/null || true
done

# ── 4. Patch title no index.html ──────────────────────────────────────────────
INDEX="$FRONT_DIST/index.html"
if [ -f "$INDEX" ]; then
  sed -i "s/<title>.*<\/title>/<title>Stratechna CRM<\/title>/g" "$INDEX"
  echo "[Stratechna] index.html title actualizado"
fi

echo "[Stratechna] Branding completo."
