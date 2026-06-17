FROM twentyhq/twenty:latest AS upstream

LABEL org.opencontainers.image.title="Stratechna CRM"
LABEL org.opencontainers.image.vendor="Stratechna"
LABEL org.opencontainers.image.source="https://github.com/stratechna/Stratechna-CRM"

# ── Branding frontend (Twenty usa Vite/React) ─────────────────────────────────
# Os ficheiros estáticos compilados ficam em /app/packages/twenty-front/dist
# O logo e favicon são servidos directamente

COPY branding/logo.svg         /app/packages/twenty-front/dist/assets/logo.svg
COPY branding/logo.svg         /app/packages/twenty-front/dist/icons/logo.svg
COPY branding/favicon.png      /app/packages/twenty-front/dist/favicon.ico
COPY branding/favicon.png      /app/packages/twenty-front/dist/favicon.png

# Patch de nome: substitui "Twenty" por "Stratechna CRM" nos assets compilados
COPY branding/rebrand.sh       /docker-entrypoint.d/99-stratechna-rebrand.sh
RUN chmod +x /docker-entrypoint.d/99-stratechna-rebrand.sh

# ── Branding backend (NestJS) ─────────────────────────────────────────────────
# Email templates e configuração de nome da app
COPY branding/app-config.json  /app/packages/twenty-server/dist/branding.json
