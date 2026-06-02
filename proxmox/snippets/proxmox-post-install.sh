#!/usr/bin/env bash
# =============================================================================
# proxmox-post-install.sh
# Configuration post-installation de Proxmox VE 9.x (sans abonnement)
#
# Usage : exécuter en tant que root sur pve-01
#   bash proxmox-post-install.sh
#
# Idempotent : peut être relancé sans effets indésirables
# =============================================================================

set -euo pipefail

echo "=== Post-installation Proxmox VE ==="
echo "Hôte : $(hostname)"
echo "Date : $(date)"
echo ""

# -----------------------------------------------------------------------------
# 1. Désactiver le dépôt Enterprise (nécessite un abonnement payant)
# -----------------------------------------------------------------------------
echo "[1/5] Désactivation du dépôt Enterprise..."

ENTERPRISE_LIST="/etc/apt/sources.list.d/pve-enterprise.list"
if [ -f "$ENTERPRISE_LIST" ]; then
    # Commenter la ligne si pas déjà commentée
    sed -i 's|^deb |# deb |g' "$ENTERPRISE_LIST"
    echo "  → Dépôt Enterprise commenté : $ENTERPRISE_LIST"
else
    echo "  → Fichier non trouvé, rien à faire"
fi

# Désactiver aussi le dépôt Ceph Enterprise si présent
CEPH_LIST="/etc/apt/sources.list.d/ceph.list"
if [ -f "$CEPH_LIST" ]; then
    sed -i 's|^deb |# deb |g' "$CEPH_LIST"
    echo "  → Dépôt Ceph Enterprise commenté"
fi

# -----------------------------------------------------------------------------
# 2. Ajouter le dépôt no-subscription (gratuit)
# -----------------------------------------------------------------------------
echo "[2/5] Ajout du dépôt no-subscription..."

NO_SUB_LIST="/etc/apt/sources.list.d/pve-no-subscription.list"
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

if grep -q "pve-no-subscription" "$NO_SUB_LIST" 2>/dev/null; then
    echo "  → Dépôt no-subscription déjà configuré"
else
    echo "deb http://download.proxmox.com/debian/pve ${CODENAME} pve-no-subscription" \
        > "$NO_SUB_LIST"
    echo "  → Dépôt no-subscription ajouté pour ${CODENAME}"
fi

# -----------------------------------------------------------------------------
# 3. Mise à jour du système
# -----------------------------------------------------------------------------
echo "[3/5] Mise à jour du système..."
apt update -q
apt full-upgrade -y
echo "  → Système à jour"

# -----------------------------------------------------------------------------
# 4. Installer des outils utiles
# -----------------------------------------------------------------------------
echo "[4/5] Installation des outils..."
apt install -y \
    htop \
    curl \
    vim \
    net-tools \
    iptables \
    ethtool \
    lsof \
    tcpdump
echo "  → Outils installés"

# -----------------------------------------------------------------------------
# 5. Patch interface web — supprimer l'alerte d'abonnement (optionnel)
# -----------------------------------------------------------------------------
echo "[5/5] Suppression de l'alerte d'abonnement..."

PROXMOX_LIB="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

if [ -f "$PROXMOX_LIB" ]; then
    # Vérifier si le patch est déjà appliqué
    if grep -q "data.status !== 'Active'" "$PROXMOX_LIB"; then
        # Créer une sauvegarde
        cp -f "$PROXMOX_LIB" "${PROXMOX_LIB}.bak"
        # Appliquer le patch
        sed -i "s/data.status !== 'Active'/false/g" "$PROXMOX_LIB"
        systemctl restart pveproxy
        echo "  → Patch appliqué, pveproxy redémarré"
    else
        echo "  → Patch déjà appliqué ou fichier modifié"
    fi
else
    echo "  → Fichier proxmoxlib.js non trouvé, patch ignoré"
fi

# -----------------------------------------------------------------------------
# Résumé
# -----------------------------------------------------------------------------
echo ""
echo "=== Post-installation terminée ==="
echo "Version Proxmox :"
pveversion
echo ""
echo "Prochaines étapes :"
echo "  1. Créer le bridge vmbr1 (interface web → Network)"
echo "  2. Uploader les ISOs (pfSense, Debian, TrueNAS)"
echo "  3. Créer les VMs"
