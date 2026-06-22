FROM twentycrm/twenty:latest

LABEL org.opencontainers.image.title="Stratechna CRM"
LABEL org.opencontainers.image.vendor="Stratechna"
LABEL org.opencontainers.image.source="https://github.com/stratechna/Stratechna-CRM"

# ── Branding: patch durante build (assets Vite têm hashes nos nomes) ──────────
COPY branding/logo.svg /tmp/stratechna-logo.svg
COPY branding/rebrand.sh /tmp/rebrand-build.sh

# Executar patch de build
RUN chmod +x /tmp/rebrand-build.sh && /tmp/rebrand-build.sh

# Backend: branding config
COPY branding/app-config.json /app/packages/twenty-server/dist/branding.json
