#!/usr/bin/env bash
# =============================================================================
# debian-docker-install.sh
# Installation de Docker sur Debian 12 Bookworm — srv-02
#
# Usage : exécuter en root sur srv-02
#   bash debian-docker-install.sh
#
# Idempotent : peut être relancé sans effets indésirables
# =============================================================================

set -euo pipefail

# Nom de l'utilisateur non-root à ajouter au groupe docker
# Modifier cette valeur si besoin
DOCKER_USER="admin"

echo "=== Installation Docker — Debian 12 ==="
echo "Hôte : $(hostname)"
echo "Date : $(date)"
echo ""

# -----------------------------------------------------------------------------
# 1. Vérifier qu'on est root
# -----------------------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
    echo "ERREUR : Ce script doit être exécuté en root (ou via sudo)"
    exit 1
fi

# -----------------------------------------------------------------------------
# 2. Mise à jour et paquets de base
# -----------------------------------------------------------------------------
echo "[1/5] Mise à jour du système..."
apt update -q
apt upgrade -y
echo "  → Système à jour"

echo "[2/5] Installation des paquets de base..."
apt install -y \
    curl \
    git \
    vim \
    htop \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    net-tools \
    wget \
    unzip \
    bash-completion
echo "  → Paquets installés"

# -----------------------------------------------------------------------------
# 3. Supprimer les anciennes versions de Docker
# -----------------------------------------------------------------------------
echo "[3/5] Suppression des anciennes versions Docker..."
for pkg in docker docker-engine docker.io containerd runc docker-compose; do
    if dpkg -l | grep -q "^ii  $pkg "; then
        apt remove -y "$pkg"
        echo "  → $pkg supprimé"
    fi
done
echo "  → Nettoyage terminé"

# -----------------------------------------------------------------------------
# 4. Installer Docker CE officiel
# -----------------------------------------------------------------------------
echo "[4/5] Installation de Docker CE..."

# Clé GPG
install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "  → Clé GPG Docker ajoutée"
fi

# Dépôt Docker
DOCKER_LIST="/etc/apt/sources.list.d/docker.list"
if [ ! -f "$DOCKER_LIST" ]; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | tee "$DOCKER_LIST" > /dev/null
    echo "  → Dépôt Docker ajouté"
fi

apt update -q
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
echo "  → Docker installé"

# Activer et démarrer Docker au boot
systemctl enable docker
systemctl start docker

# -----------------------------------------------------------------------------
# 5. Ajouter l'utilisateur au groupe docker
# -----------------------------------------------------------------------------
echo "[5/5] Configuration utilisateur..."

if id "$DOCKER_USER" &>/dev/null; then
    usermod -aG docker "$DOCKER_USER"
    echo "  → Utilisateur '$DOCKER_USER' ajouté au groupe docker"
    echo "  → Reconnexion nécessaire pour que les changements prennent effet"
else
    echo "  → Utilisateur '$DOCKER_USER' non trouvé — ajout ignoré"
    echo "  → Pour ajouter un utilisateur manuellement : usermod -aG docker NOM_USER"
fi

# -----------------------------------------------------------------------------
# Créer les répertoires de volumes
# -----------------------------------------------------------------------------
echo "Création des répertoires pour les volumes Docker..."
mkdir -p /opt/homelab/{portainer,uptime-kuma,homepage,grafana,prometheus,gitea}
mkdir -p /opt/homelab/nginx-proxy-manager/letsencrypt
echo "  → Répertoires créés dans /opt/homelab/"

# -----------------------------------------------------------------------------
# Résumé
# -----------------------------------------------------------------------------
echo ""
echo "=== Installation terminée ==="
docker --version
docker compose version
echo ""
echo "Test Docker :"
docker run --rm hello-world
echo ""
echo "Prochaines étapes :"
echo "  1. Se déconnecter et reconnecter (pour le groupe docker)"
echo "  2. cd /chemin/homelab-matoto/docker/portainer"
echo "  3. docker compose up -d"
