FROM twentycrm/twenty:latest

LABEL org.opencontainers.image.title="Stratechna CRM"
LABEL org.opencontainers.image.vendor="Stratechna"
LABEL org.opencontainers.image.source="https://github.com/stratechna/Stratechna-CRM"

# Copiar assets de branding
COPY branding/patch.sh /tmp/patch.sh
COPY branding/icons/ /tmp/branding-icons/
COPY branding/logo.svg /app/packages/twenty-server/dist/front/images/integrations/twenty-logo.svg
COPY branding/app-config.json /app/packages/twenty-server/dist/branding.json

# Aplicar patch como root
USER root
RUN chmod +x /tmp/patch.sh && /tmp/patch.sh

USER node
