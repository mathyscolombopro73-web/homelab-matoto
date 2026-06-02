# Créer la VM Debian Docker — srv-02

Procédure de création et de configuration de la VM Debian 12 pour Docker.

---

## Pré-requis

- Proxmox VE 9.1 avec `vmbr1` créé
- pfSense opérationnel (DHCP sur 10.20.0.0/24)
- ISO Debian 12 (Bookworm) uploadée dans Proxmox

---

## 1. Uploader l'ISO Debian

1. Télécharger l'ISO : https://www.debian.org/distrib/ (netinstall ou DVD)
2. Dans Proxmox : `local (pve-01) → ISO Images → Upload`

---

## 2. Créer la VM

### Onglet General

| Paramètre | Valeur    |
|-----------|-----------|
| VM ID     | `102`     |
| Name      | `srv-02`  |

### Onglet OS

| Paramètre | Valeur                    |
|-----------|---------------------------|
| ISO Image | debian-12.X.X-amd64-netinst.iso |
| Type      | Linux                     |
| Version   | 6.x - 2.6 Kernel          |

### Onglet System

| Paramètre  | Valeur     |
|------------|------------|
| SCSI       | VirtIO SCSI |
| Machine    | q35        |

### Onglet Disks

| Paramètre  | Valeur     |
|------------|------------|
| Bus/Device | SCSI 0     |
| Disk size  | 50 Go      |
| Storage    | local-lvm  |
| Cache      | Write back |

### Onglet CPU

| Paramètre | Valeur |
|-----------|--------|
| Sockets   | 1      |
| Cores     | 2      |
| Type      | x86-64-v2-AES |

### Onglet Memory

| Paramètre | Valeur          |
|-----------|-----------------|
| Memory    | 4096 Mo (4 Go)  |
| Ballooning | Désactivé (stable) |

### Onglet Network

| Paramètre | Valeur     |
|-----------|------------|
| Bridge    | `vmbr1`    |
| Model     | VirtIO     |

---

## 3. Installer Debian 12

1. Démarrer la VM et ouvrir la console
2. Choisir **Install** (mode texte)
3. Langue, pays, clavier : French
4. Hostname : `srv-02`
5. Domain : `homelab.matoto.local`
6. Mot de passe root : **utiliser un mot de passe fort** (ne pas mettre dans Git)
7. Créer un utilisateur standard (ex: `admin`)
8. Partitionnement : **Guided - use entire disk** (tout sur une partition)
9. Mirror Debian : choisir un miroir français (ex: `ftp.fr.debian.org`)
10. Sélection des logiciels :
    - Décocher tout sauf **standard system utilities** et **SSH server**
    - Ne pas installer l'interface graphique

---

## 4. Configurer l'IP statique

Après l'installation, configurer l'IP fixe.

Éditer `/etc/network/interfaces` :

```bash
nano /etc/network/interfaces
```

```text
# Interface loopback
auto lo
iface lo inet loopback

# Interface principale (vérifier le nom : ens18, eth0, etc.)
auto ens18
iface ens18 inet static
    address 10.20.0.20
    netmask 255.255.255.0
    gateway 10.20.0.1
    dns-nameservers 1.1.1.1
```

Appliquer :

```bash
systemctl restart networking
ip addr show ens18
```

Éditer `/etc/resolv.conf` :

```text
nameserver 1.1.1.1
nameserver 8.8.8.8
```

---

## 5. Mises à jour et paquets de base

```bash
apt update && apt upgrade -y
apt install -y curl git vim htop sudo ca-certificates gnupg lsb-release
```

---

## 6. Installer Docker

```bash
# Supprimer les anciennes versions
apt remove -y docker docker-engine docker.io containerd runc

# Ajouter la clé GPG officielle Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Ajouter le dépôt Docker
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# Ajouter l'utilisateur au groupe docker (remplacer "admin" par ton utilisateur)
usermod -aG docker admin
```

---

## 7. Vérifications

```bash
# Version Docker
docker --version
docker compose version

# Test Docker
docker run --rm hello-world

# Connectivité réseau
ping -c 3 10.20.0.1   # gateway pfSense
ping -c 3 1.1.1.1     # Internet
nslookup google.com    # DNS
```

---

## Script automatisé

Le script `scripts/debian-docker-install.sh` automatise les étapes 5 et 6.

```bash
# Sur srv-02, après l'installation Debian
curl -O https://raw.githubusercontent.com/TON_COMPTE/homelab-matoto/main/scripts/debian-docker-install.sh
chmod +x debian-docker-install.sh
./debian-docker-install.sh
```

---

## Étape suivante

Déployer les services Docker : voir [docker/README.md](../docker/README.md)
