FROM twentycrm/twenty:latest

LABEL org.opencontainers.image.title="Stratechna CRM"
LABEL org.opencontainers.image.vendor="Stratechna"
LABEL org.opencontainers.image.source="https://github.com/stratechna/Stratechna-CRM"

# ── Branding frontend ─────────────────────────────────────────────────────────
# O Twenty serve logo.svg em dois locais fixos (sem hash no nome)
COPY branding/logo.svg /app/packages/twenty-front/dist/assets/logo.svg
COPY branding/logo.svg /app/packages/twenty-front/dist/icons/logo.svg

# Patch de texto nos JS/HTML compilados (inline, sem script externo)
USER root
RUN find /app/packages/twenty-front/dist -type f \( -name "*.js" -o -name "*.html" -o -name "*.css" \) \
    -exec sed -i \
      -e 's/Twenty CRM/Stratechna CRM/g' \
      -e 's/Twenty is/Stratechna CRM is/g' \
      -e 's|"Twenty"|"Stratechna CRM"|g' \
      -e 's|>Twenty<|>Stratechna CRM<|g' \
      {} +

# ── Branding backend ──────────────────────────────────────────────────────────
COPY branding/app-config.json /app/packages/twenty-server/dist/branding.json

# Voltar ao utilizador da imagem upstream
USER node
