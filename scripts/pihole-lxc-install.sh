#!/usr/bin/env bash
# =============================================================================
# pihole-lxc-install.sh
# Préparation et installation de Pi-hole dans un LXC Debian 12 — dns-01
#
# Usage : exécuter en root dans le LXC dns-01
#   bash pihole-lxc-install.sh
#
# L'installation Pi-hole est interactive (elle pose des questions).
# Ce script prépare l'environnement puis lance l'installeur Pi-hole.
# =============================================================================

set -euo pipefail

echo "=== Installation Pi-hole — dns-01 ==="
echo "Hôte : $(hostname)"
echo "IP   : $(hostname -I)"
echo "Date : $(date)"
echo ""

# -----------------------------------------------------------------------------
# 1. Vérifier qu'on est root
# -----------------------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
    echo "ERREUR : Ce script doit être exécuté en root"
    exit 1
fi

# -----------------------------------------------------------------------------
# 2. Vérifier la connectivité Internet
# -----------------------------------------------------------------------------
echo "[1/4] Vérification de la connectivité..."
if ! ping -c 1 1.1.1.1 &>/dev/null; then
    echo "ERREUR : Pas de connectivité Internet"
    echo "Vérifier : pfSense démarré, route 10.20.0.1 accessible, DNS 1.1.1.1"
    exit 1
fi
echo "  → Connectivité OK"

# -----------------------------------------------------------------------------
# 3. Mise à jour et paquets nécessaires
# -----------------------------------------------------------------------------
echo "[2/4] Mise à jour du système..."
apt update -q
apt upgrade -y

echo "[3/4] Installation des dépendances..."
apt install -y curl sudo
echo "  → Dépendances installées"

# -----------------------------------------------------------------------------
# 4. Lancer l'installation Pi-hole
# -----------------------------------------------------------------------------
echo "[4/4] Lancement de l'installation Pi-hole..."
echo ""
echo "L'installeur Pi-hole va maintenant démarrer."
echo "Répondre aux questions suivantes :"
echo "  - Interface réseau  : eth0 (ou l'interface disponible)"
echo "  - DNS upstream      : Cloudflare (1.1.1.1) recommandé"
echo "  - Block lists       : garder les listes par défaut"
echo "  - IPv4 address      : confirmer 10.20.0.40/24"
echo "  - IPv6              : Non"
echo "  - Web admin         : Oui"
echo "  - Web server        : Oui (lighttpd)"
echo "  - Log queries       : Oui"
echo ""
echo "Appuyer sur Entrée pour continuer..."
read -r

curl -sSL https://install.pi-hole.net | bash

# -----------------------------------------------------------------------------
# Post-installation
# -----------------------------------------------------------------------------
echo ""
echo "=== Installation Pi-hole terminée ==="
echo ""
echo "IMPORTANT : Changer le mot de passe admin maintenant !"
echo "Commande : pihole -a -p"
echo ""
echo "Interface web : http://$(hostname -I | awk '{print $1}')/admin"
echo ""
echo "Prochaines étapes :"
echo "  1. Changer le mot de passe : pihole -a -p"
echo "  2. Configurer pfSense pour utiliser 10.20.0.40 comme DNS"
echo "  3. Tester : nslookup google.com 10.20.0.40"
