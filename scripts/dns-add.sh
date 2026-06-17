#!/bin/bash
# /opt/stratechna/crm/scripts/dns-add.sh
# (mesmo padrão do desk/scripts/dns-add.sh)

SUBDOMAIN="$1"
FQDN="$2"
IP="95.217.8.239"
DOMAIN="stratechna.com"
PDNS_DB="/var/lib/powerdns/pdns.sqlite3"

if [ -z "$SUBDOMAIN" ]; then
  echo "Uso: $0 <subdomain> <fqdn>"
  exit 1
fi

DOMAIN_ID=$(sqlite3 "$PDNS_DB" "SELECT id FROM domains WHERE name='${DOMAIN}' LIMIT 1;")
if [ -z "$DOMAIN_ID" ]; then
  echo "ERRO: domínio ${DOMAIN} não encontrado no PowerDNS"
  exit 1
fi

sqlite3 "$PDNS_DB" "
  INSERT OR REPLACE INTO records (domain_id, name, type, content, ttl, prio)
  VALUES (${DOMAIN_ID}, '${FQDN}.', 'A', '${IP}', 300, 0);
"

pdns_control reload 2>/dev/null || true
echo "  DNS: ${FQDN} → ${IP} (registado)"
