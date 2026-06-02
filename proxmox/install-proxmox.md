# Installation Proxmox VE 9.1 — pve-01

Guide d'installation de Proxmox VE sur le PC principal du homelab.

---

## Pré-requis matériels

| Composant  | Minimum        | Recommandé         |
|------------|----------------|--------------------|
| CPU        | 64 bits, VT-x/AMD-V activé | 4 cœurs+ |
| RAM        | 8 Go           | 16–32 Go           |
| Stockage   | 50 Go SSD      | 128+ Go NVMe       |
| Réseau     | 1 carte réseau | 1 carte (suffisant) |

> **Vérifier l'activation de la virtualisation** dans le BIOS/UEFI avant l'installation :
> - Intel : VT-x (Virtualization Technology)
> - AMD : AMD-V / SVM

---

## 1. Télécharger l'ISO

Site officiel : https://www.proxmox.com/en/downloads

Fichier : `proxmox-ve_9.1-X.iso`

> L'ISO est déjà présente dans le dépôt à titre d'exemple — ne pas la committer dans Git (voir `.gitignore`).

---

## 2. Créer la clé USB bootable

**Sous Windows — avec Rufus :**

1. Télécharger Rufus : https://rufus.ie/
2. Brancher une clé USB (4 Go minimum, les données seront effacées)
3. Sélectionner l'ISO Proxmox
4. Mode : `DD Image`
5. Cliquer `Start`

**Sous Linux :**

```bash
# Identifier la clé USB (/dev/sdX)
lsblk

# Écrire l'ISO (ATTENTION : remplacer sdX par le bon périphérique)
dd if=proxmox-ve_9.1-X.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

---

## 3. Installer Proxmox VE

1. Booter sur la clé USB (F12 ou F2 selon le BIOS)
2. Choisir **Install Proxmox VE (Graphical)**
3. Accepter les conditions
4. Sélectionner le disque cible (SSD recommandé)
5. Paramètres de localisation :
   - Country : `France`
   - Timezone : `Europe/Paris`
   - Keyboard : `French`
6. Définir le mot de passe root et l'adresse email
7. **Configuration réseau** :

| Paramètre   | Valeur                                  |
|-------------|-----------------------------------------|
| Interface   | L'interface réseau principale du PC     |
| Hostname    | `pve-01.homelab.matoto.local`           |
| IP Address  | Choisir une IP fixe sur 192.168.1.0/24 (ex: 192.168.1.10) ou DHCP |
| Gateway     | `192.168.1.1`                           |
| DNS Server  | `192.168.1.1` ou `1.1.1.1`             |

8. Vérifier le récapitulatif et cliquer **Install**
9. Retirer la clé USB après l'installation

---

## 4. Premier accès à l'interface web

Depuis le PC principal (réseau 192.168.1.0/24) :

```
https://192.168.1.X:8006
```

Remplacer `192.168.1.X` par l'IP définie à l'installation.

- Identifiant : `root`
- Mot de passe : celui défini pendant l'installation

> Ignorer l'avertissement certificat SSL (auto-signé).

---

## 5. Configuration post-installation

### 5.1 Désactiver le dépôt Enterprise (si pas d'abonnement)

```bash
# Sur pve-01, en SSH ou dans le shell Proxmox
# Désactiver le dépôt Enterprise
echo "# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise" \
  > /etc/apt/sources.list.d/pve-enterprise.list

# Ajouter le dépôt no-subscription
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" \
  > /etc/apt/sources.list.d/pve-no-subscription.list

# Mise à jour
apt update && apt full-upgrade -y
```

### 5.2 Supprimer l'alerte d'abonnement (optionnel)

```bash
# Patch de l'interface web (à refaire après chaque mise à jour Proxmox)
sed -i.bak "s/data.status !== 'Active'/false/g" \
  /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

systemctl restart pveproxy
```

### 5.3 Vérifier la date et l'heure

```bash
timedatectl status
# Si nécessaire :
timedatectl set-timezone Europe/Paris
```

### 5.4 Script automatisé

Le script `proxmox/snippets/proxmox-post-install.sh` automatise ces étapes.

---

## 6. Vérifications

```bash
# Version Proxmox
pveversion

# État du cluster
pvecm status

# Ressources disponibles
pvesh get /nodes/pve-01/status
```

Depuis l'interface web :
- Nœud `pve-01` visible dans l'arbre de gauche
- Onglet **Summary** : CPU, RAM, stockage affichés
- Pas d'erreur rouge dans le tableau de bord

---

## Étape suivante

Créer le bridge `vmbr1` : voir [network-bridges.md](network-bridges.md)
