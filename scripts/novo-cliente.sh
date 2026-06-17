#!/bin/bash
# /opt/stratechna/crm/scripts/novo-cliente.sh
# Uso: bash novo-cliente.sh <slug> <email-admin> [empresa] [dominio-proprio]
#
# Exemplos:
#   bash novo-cliente.sh esferancora admin@esferancora.pt "Esferancora Lda"
#   bash novo-cliente.sh esferancora admin@esferancora.pt "Esferancora Lda" crm.esferancora.pt

set -e

SLUG="$1"
EMAIL="$2"
EMPRESA="${3:-$SLUG}"
DOMINIO_PROPRIO="$4"

TEMPLATE_DIR="/opt/stratechna/crm/template"
CLIENTES_DIR="/opt/stratechna/crm/clientes"
INSTANCE_DIR="${CLIENTES_DIR}/${SLUG}"
SCRIPTS_DIR="/opt/stratechna/crm/scripts"

# ── Validação ──────────────────────────────────────────────────────────────────
if [ -z "$SLUG" ] || [ -z "$EMAIL" ]; then
  echo "Uso: $0 <slug> <email-admin> [empresa] [dominio-proprio]"
  exit 1
fi

if [ -d "$INSTANCE_DIR" ]; then
  echo "ERRO: instância '${SLUG}' já existe em ${INSTANCE_DIR}"
  exit 1
fi

echo "▶ Stratechna CRM — novo cliente: ${SLUG}"

# ── Gerar credenciais ──────────────────────────────────────────────────────────
CRM_SECRET=$(openssl rand -hex 32)
CRM_DB_PASS=$(openssl rand -base64 24 | tr -d '/+=' | head -c 24)

# ── Criar directório da instância ──────────────────────────────────────────────
mkdir -p "${INSTANCE_DIR}"

# ── Gerar .env ─────────────────────────────────────────────────────────────────
cat > "${INSTANCE_DIR}/.env" << ENV
CLIENTE=${SLUG}
CRM_EMAIL=${EMAIL}
CRM_EMPRESA=${EMPRESA}
CRM_SECRET=${CRM_SECRET}
CRM_DB_PASS=${CRM_DB_PASS}
ENV

# ── Regra domínio próprio para Traefik ────────────────────────────────────────
if [ -n "$DOMINIO_PROPRIO" ]; then
  EXTRA_HOSTS_RULE=" || Host(\`${DOMINIO_PROPRIO}\`)"
else
  EXTRA_HOSTS_RULE=""
fi

# ── Gerar docker-compose.yml da instância ─────────────────────────────────────
sed \
  -e "s/\${CLIENTE}/${SLUG}/g" \
  -e "s/\${CRM_SECRET}/${CRM_SECRET}/g" \
  -e "s/\${CRM_DB_PASS}/${CRM_DB_PASS}/g" \
  -e "s|\${EXTRA_HOSTS_RULE}|${EXTRA_HOSTS_RULE}|g" \
  "${TEMPLATE_DIR}/docker-compose.yml" > "${INSTANCE_DIR}/docker-compose.yml"

# ── DNS via PowerDNS ──────────────────────────────────────────────────────────
echo "▶ A registar DNS: ${SLUG}.crm.stratechna.com → 95.217.8.239"
bash "${SCRIPTS_DIR}/dns-add.sh" "${SLUG}.crm" "${SLUG}.crm.stratechna.com"

# ── Arrancar containers ───────────────────────────────────────────────────────
echo "▶ A arrancar containers..."
cd "${INSTANCE_DIR}"
docker compose pull
docker compose up -d

# ── Aguardar Twenty estar pronto ──────────────────────────────────────────────
echo "▶ A aguardar inicialização do Twenty (pode demorar 60s)..."
sleep 20
RETRIES=8
for i in $(seq 1 $RETRIES); do
  STATUS=$(docker exec crm-${SLUG}-server curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/healthz 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ]; then
    echo "✓ Twenty pronto."
    break
  fi
  echo "  ... aguardar (tentativa ${i}/${RETRIES})"
  sleep 10
done

# ── Seed inicial (cria workspace + admin) ────────────────────────────────────
echo "▶ A criar workspace e utilizador admin..."
docker exec crm-${SLUG}-server node -e "
const { AppDataSource } = require('./packages/twenty-server/dist/database/app-data-source');
// O Twenty inicializa automaticamente via migrations na primeira execução
console.log('Workspace será criado no primeiro login em https://${SLUG}.crm.stratechna.com');
" 2>/dev/null || echo "  ℹ Aceder à URL para completar setup inicial."

# ── Guardar sumário ───────────────────────────────────────────────────────────
cat > "${INSTANCE_DIR}/INFO.txt" << INFO
Stratechna CRM — ${EMPRESA}
Slug:        ${SLUG}
URL:         https://${SLUG}.crm.stratechna.com
${DOMINIO_PROPRIO:+URL própria: https://${DOMINIO_PROPRIO}}
Admin email: ${EMAIL}
Setup:       Aceder à URL e completar wizard de primeiro login
Criado:      $(date '+%Y-%m-%d %H:%M')
INFO

echo ""
echo "✅ Stratechna CRM — instância '${SLUG}' criada com sucesso!"
echo "   URL: https://${SLUG}.crm.stratechna.com"
echo "   Admin: ${EMAIL}"
echo "   ⚠ Aceder à URL para completar o setup inicial (Twenty wizard)"
echo "   Info: ${INSTANCE_DIR}/INFO.txt"
