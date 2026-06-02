# Créer la VM pfSense — fw-01

Procédure de création de la VM pfSense sur Proxmox VE 9.1.

---

## Pré-requis

- Proxmox VE 9.1 installé
- Bridge `vmbr0` et `vmbr1` fonctionnels
- ISO pfSense téléchargée et uploadée dans Proxmox

---

## 1. Uploader l'ISO pfSense dans Proxmox

1. Télécharger l'ISO pfSense CE depuis : https://www.pfsense.org/download/
   - Architecture : AMD64
   - Installer : DVD Image (ISO) Installer
2. Dans Proxmox : `local (pve-01) → ISO Images → Upload`
3. Sélectionner l'ISO pfSense et uploader

---

## 2. Créer la VM

Dans l'interface Proxmox : `Create VM`

### Onglet General

| Paramètre | Valeur        |
|-----------|---------------|
| Node      | `pve-01`      |
| VM ID     | `100`         |
| Name      | `fw-01`       |

### Onglet OS

| Paramètre    | Valeur                          |
|--------------|---------------------------------|
| ISO Image    | pfSense-CE-X.X.X-amd64.iso     |
| Type         | Other                           |
| Version      | Other                           |

### Onglet System

| Paramètre | Valeur    |
|-----------|-----------|
| SCSI      | VirtIO SCSI |
| BIOS      | SeaBIOS (défaut) |
| Machine   | q35       |

### Onglet Disks

| Paramètre  | Valeur     |
|------------|------------|
| Bus/Device | SATA 0     |
| Disk size  | 10 Go      |
| Storage    | local-lvm  |

### Onglet CPU

| Paramètre | Valeur |
|-----------|--------|
| Sockets   | 1      |
| Cores     | 2      |
| Type      | x86-64-v2-AES |

### Onglet Memory

| Paramètre | Valeur |
|-----------|--------|
| Memory    | 1024 Mo (1 Go) |

### Onglet Network

**Carte réseau 1 — WAN**

| Paramètre | Valeur  |
|-----------|---------|
| Bridge    | `vmbr0` |
| Model     | VirtIO (paravirt) |
| VLAN Tag  | No VLAN |

> **Après la création**, ajouter la deuxième carte réseau :

---

## 3. Ajouter la deuxième carte réseau (LAN)

Après avoir créé la VM :

1. Sélectionner `fw-01 → Hardware → Add → Network Device`

| Paramètre | Valeur  |
|-----------|---------|
| Bridge    | `vmbr1` |
| Model     | VirtIO (paravirt) |
| VLAN Tag  | No VLAN |

2. Cliquer **Add**

La VM doit maintenant avoir :
- `net0` : vmbr0 (WAN)
- `net1` : vmbr1 (LAN)

---

## 4. Vérifier les adresses MAC

Pour associer correctement WAN/LAN lors de l'installation pfSense :

1. `fw-01 → Hardware`
2. Noter l'adresse MAC de `net0` (WAN — vmbr0)
3. Noter l'adresse MAC de `net1` (LAN — vmbr1)

---

## 5. Démarrer et installer pfSense

1. Démarrer la VM : `fw-01 → Start`
2. Ouvrir la console : `fw-01 → Console`
3. Suivre la procédure d'installation dans [network/pfsense-setup.md](../network/pfsense-setup.md)

---

## Erreurs fréquentes

| Problème                                  | Solution                                        |
|-------------------------------------------|-------------------------------------------------|
| VM ne démarre pas sur l'ISO               | Vérifier que l'ISO est bien sélectionnée dans OS |
| Mauvaise assignation WAN/LAN dans pfSense | Comparer les MACs dans Proxmox et dans pfSense  |
| pfSense ne trouve pas Internet (WAN)      | Vérifier que net0 est sur vmbr0                 |
| Les VMs ne joignent pas pfSense (LAN)     | Vérifier que net1 est sur vmbr1                 |
| pfSense bloque le trafic WAN privé        | Désactiver "Block private networks" sur le WAN  |
