#!/bin/bash
# /opt/stratechna/crm/scripts/novo-cliente.sh
# Uso: bash novo-cliente.sh <slug> <email-admin> [empresa] [dominio-proprio]

set -e

SLUG="$1"
EMAIL="$2"
EMPRESA="${3:-$SLUG}"
DOMINIO_PROPRIO="$4"

TEMPLATE_DIR="/opt/stratechna/crm/template"
CLIENTES_DIR="/opt/stratechna/crm/clientes"
INSTANCE_DIR="${CLIENTES_DIR}/${SLUG}"
SCRIPTS_DIR="/opt/stratechna/crm/scripts"

if [ -z "$SLUG" ] || [ -z "$EMAIL" ]; then
  echo "Uso: $0 <slug> <email-admin> [empresa] [dominio-proprio]"
  exit 1
fi

if [ -d "$INSTANCE_DIR" ]; then
  echo "ERRO: instância '${SLUG}' já existe em ${INSTANCE_DIR}"
  exit 1
fi

echo "▶ Stratechna CRM — novo cliente: ${SLUG}"

CRM_SECRET=$(openssl rand -hex 32)
CRM_DB_PASS=$(openssl rand -base64 24 | tr -d '/+=' | head -c 24)

mkdir -p "${INSTANCE_DIR}"

cat > "${INSTANCE_DIR}/.env" << ENV
CLIENTE=${SLUG}
CRM_EMAIL=${EMAIL}
CRM_EMPRESA=${EMPRESA}
CRM_SECRET=${CRM_SECRET}
CRM_DB_PASS=${CRM_DB_PASS}
ENV

if [ -n "$DOMINIO_PROPRIO" ]; then
  EXTRA_HOSTS_RULE=" || Host(\`${DOMINIO_PROPRIO}\`)"
else
  EXTRA_HOSTS_RULE=""
fi

sed \
  -e "s/CLIENTE/${SLUG}/g" \
  -e "s/CRM_SECRET/${CRM_SECRET}/g" \
  -e "s/CRM_DB_PASS/${CRM_DB_PASS}/g" \
  -e "s|EXTRA_HOSTS_RULE|${EXTRA_HOSTS_RULE}|g" \
  "${TEMPLATE_DIR}/docker-compose.yml" > "${INSTANCE_DIR}/docker-compose.yml"

echo "▶ A registar DNS: crm.${SLUG}.stratechna.com → 95.217.8.239"
bash "${SCRIPTS_DIR}/dns-add.sh" "crm.${SLUG}" "crm.${SLUG}.stratechna.com"

echo "▶ A arrancar containers..."
cd "${INSTANCE_DIR}"
docker compose up -d

echo "▶ A aguardar DB + migrations (pode demorar 90s)..."
sleep 15
RETRIES=12
for i in $(seq 1 $RETRIES); do
  STATUS=$(docker exec crm-${SLUG}-server wget -qO- http://localhost:3000/healthz 2>/dev/null | head -c 50 || echo "")
  if echo "$STATUS" | grep -qi "ok\|healthy\|true"; then
    echo "✓ Servidor pronto."
    break
  fi
  LOG=$(docker logs crm-${SLUG}-server 2>&1 | tail -3)
  echo "  ... aguardar (${i}/${RETRIES}): $LOG"
  sleep 10
done

cat > "${INSTANCE_DIR}/INFO.txt" << INFO
Stratechna CRM — ${EMPRESA}
Slug:        ${SLUG}
URL:         https://crm.${SLUG}.stratechna.com
Admin email: ${EMAIL}
Setup:       Aceder à URL e completar wizard de primeiro login
Criado:      $(date '+%Y-%m-%d %H:%M')
INFO

echo ""
echo "✅ Stratechna CRM — instância '${SLUG}' criada!"
echo "   URL: https://crm.${SLUG}.stratechna.com"
echo "   Admin: ${EMAIL}"
echo "   ⚠ Aceder à URL para completar o setup inicial (wizard Twenty)"
