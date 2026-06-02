#!/usr/bin/env bash
# =============================================================================
# check-lab-connectivity.sh
# Vérification rapide de la connectivité du homelab
#
# Usage : exécuter sur srv-02 (ou n'importe quelle machine du lab)
#   bash check-lab-connectivity.sh
#
# Teste :
#   - Gateway pfSense
#   - Connectivité Internet
#   - Résolution DNS
#   - Accès aux services si déployés
# =============================================================================

set -uo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
PASS=0
FAIL=0
WARN=0

# Fonction d'affichage
check_ok()   { echo -e "  [${GREEN}OK${NC}]   $1"; ((PASS++)); }
check_fail() { echo -e "  [${RED}FAIL${NC}] $1"; ((FAIL++)); }
check_warn() { echo -e "  [${YELLOW}WARN${NC}] $1"; ((WARN++)); }

# Fonction : ping rapide
ping_test() {
    local host="$1"
    local label="$2"
    if ping -c 1 -W 2 "$host" &>/dev/null; then
        check_ok "$label ($host)"
    else
        check_fail "$label ($host) — pas de réponse"
    fi
}

# Fonction : test TCP port
port_test() {
    local host="$1"
    local port="$2"
    local label="$3"
    if timeout 3 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then
        check_ok "$label — $host:$port"
    else
        check_warn "$label — $host:$port non accessible (service déployé ?)"
    fi
}

# =============================================================================
echo "======================================================"
echo "  Vérification connectivité — Homelab MATOTO"
echo "  Hôte  : $(hostname)"
echo "  IP    : $(hostname -I | awk '{print $1}')"
echo "  Date  : $(date)"
echo "======================================================"
echo ""

# -----------------------------------------------------------------------------
echo "--- [1] Réseau local lab ---"
# -----------------------------------------------------------------------------
ping_test "10.20.0.1"  "Gateway pfSense (LAN)"
ping_test "10.20.0.20" "srv-02 (Debian Docker)"
ping_test "10.20.0.30" "nas-01 (TrueNAS)"
ping_test "10.20.0.40" "dns-01 (Pi-hole)"
echo ""

# -----------------------------------------------------------------------------
echo "--- [2] Internet ---"
# -----------------------------------------------------------------------------
ping_test "1.1.1.1"   "Cloudflare DNS (Internet)"
ping_test "8.8.8.8"   "Google DNS (Internet)"
echo ""

# -----------------------------------------------------------------------------
echo "--- [3] Résolution DNS ---"
# -----------------------------------------------------------------------------
if nslookup google.com 1.1.1.1 &>/dev/null; then
    check_ok "DNS externe (google.com via 1.1.1.1)"
else
    check_fail "DNS externe (google.com via 1.1.1.1)"
fi

if ping -c 1 -W 2 10.20.0.40 &>/dev/null; then
    if nslookup google.com 10.20.0.40 &>/dev/null; then
        check_ok "DNS Pi-hole (google.com via 10.20.0.40)"
    else
        check_fail "DNS Pi-hole non fonctionnel — vérifier Pi-hole"
    fi
else
    check_warn "Pi-hole inaccessible — test DNS ignoré"
fi
echo ""

# -----------------------------------------------------------------------------
echo "--- [4] Services Docker (optionnel — teste si déployés) ---"
# -----------------------------------------------------------------------------
port_test "10.20.0.20" "9000" "Portainer"
port_test "10.20.0.20" "3001" "Uptime Kuma"
port_test "10.20.0.20" "3000" "Homepage"
port_test "10.20.0.20" "3002" "Grafana"
port_test "10.20.0.20" "3003" "Gitea"
port_test "10.20.0.20" "81"   "Nginx Proxy Manager"
port_test "10.20.0.40" "80"   "Pi-hole WebUI"
port_test "10.20.0.30" "80"   "TrueNAS WebUI"
echo ""

# -----------------------------------------------------------------------------
echo "======================================================"
echo "  Résultats : OK=${PASS}  FAIL=${FAIL}  WARN=${WARN}"
echo "======================================================"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Des tests ont échoué. Voir operations/troubleshooting.md"
    exit 1
fi

exit 0
