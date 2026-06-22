FROM twentycrm/twenty:latest

LABEL org.opencontainers.image.title="Stratechna CRM"
LABEL org.opencontainers.image.vendor="Stratechna"
LABEL org.opencontainers.image.source="https://github.com/stratechna/Stratechna-CRM"

# ── O frontend está em twenty-server/dist/front/ (não em twenty-front/dist/) ──
# Os bundles JS/CSS têm hashes no nome mas podemos fazer sed directamente

USER root

# 1. Substituir texto "Twenty" nos bundles JS/CSS do frontend
RUN find /app/packages/twenty-server/dist/front/assets -type f \( -name "*.js" -o -name "*.css" \) \
    -exec sed -i \
      -e 's/Twenty CRM/Stratechna CRM/g' \
      -e 's/Twenty is/Stratechna CRM is/g' \
      -e '"'"'s|"Twenty"|"Stratechna CRM"|g'"'"' \
      -e 's|>Twenty<|>Stratechna CRM<|g' \
      -e 's|Welcome to Twenty|Welcome to Stratechna CRM|g' \
      -e 's|twentycrm\.io/privacy-policy|stratechna.com/privacidade|g' \
      -e 's|twentycrm\.io/terms|stratechna.com/termos|g' \
      {} +

# 2. Substituir no index.html
RUN sed -i \
      -e 's/<title>Twenty<\/title>/<title>Stratechna CRM<\/title>/g' \
      -e 's|twentycrm\.io/privacy-policy|stratechna.com/privacidade|g' \
      -e 's|twentycrm\.io/terms|stratechna.com/termos|g' \
      /app/packages/twenty-server/dist/front/index.html 2>/dev/null || true

# 3. Substituir logo nos SVGs de integrations (twenty-logo.svg)
COPY branding/logo.svg /app/packages/twenty-server/dist/front/images/integrations/twenty-logo.svg

# 4. Substituir ícones iOS/Android com o nosso logo (PNG gerado a partir do SVG)
# Por agora mantemos os ícones originais — o workspace logo é configurável na UI

# ── Backend config ────────────────────────────────────────────────────────────
COPY branding/app-config.json /app/packages/twenty-server/dist/branding.json

USER node
