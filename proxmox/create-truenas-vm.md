# Créer la VM TrueNAS — nas-01

Procédure de création de la VM TrueNAS Scale sur Proxmox VE 9.1.

---

## Pré-requis

- Proxmox VE 9.1 avec `vmbr1` créé
- pfSense opérationnel
- ISO TrueNAS Scale téléchargée et uploadée dans Proxmox

---

## 1. Uploader l'ISO TrueNAS Scale

1. Télécharger depuis : https://www.truenas.com/download-truenas-scale/
2. Dans Proxmox : `local (pve-01) → ISO Images → Upload`

---

## 2. Créer la VM

### Onglet General

| Paramètre | Valeur    |
|-----------|-----------|
| VM ID     | `103`     |
| Name      | `nas-01`  |

### Onglet OS

| Paramètre | Valeur                         |
|-----------|--------------------------------|
| ISO Image | TrueNAS-SCALE-XX.X.X.X.iso    |
| Type      | Linux                          |
| Version   | 6.x - 2.6 Kernel               |

### Onglet System

| Paramètre | Valeur       |
|-----------|--------------|
| SCSI      | VirtIO SCSI  |
| Machine   | q35          |
| BIOS      | OVMF (UEFI)  |

> TrueNAS Scale fonctionne mieux avec UEFI (OVMF).

### Onglet Disks

**Disque système (OS TrueNAS) :**

| Paramètre  | Valeur     |
|------------|------------|
| Bus/Device | SATA 0     |
| Disk size  | 32 Go      |
| Storage    | local-lvm  |

**Disque data (pool ZFS de test) — à ajouter après la création :**

| Paramètre  | Valeur     |
|------------|------------|
| Bus/Device | SATA 1     |
| Disk size  | 50–100 Go  |
| Storage    | local-lvm  |

> Ajouter le disque data via `nas-01 → Hardware → Add → Hard Disk`

### Onglet CPU

| Paramètre | Valeur |
|-----------|--------|
| Sockets   | 1      |
| Cores     | 2      |
| Type      | host   |

### Onglet Memory

| Paramètre  | Valeur                            |
|------------|-----------------------------------|
| Memory     | 8192 Mo (8 Go) **minimum**        |

> **ZFS est très gourmand en RAM.** 8 Go est le minimum absolu pour TrueNAS.
> Règle de base ZFS : 1 Go de RAM par To de stockage (minimum 8 Go).

### Onglet Network

| Paramètre | Valeur  |
|-----------|---------|
| Bridge    | `vmbr1` |
| Model     | VirtIO  |

---

## 3. Installer TrueNAS Scale

1. Démarrer la VM et ouvrir la console
2. Sélectionner `1. Install/Upgrade`
3. Choisir le disque système (SATA 0 — 32 Go)
4. **Ne pas sélectionner** le disque data (SATA 1)
5. Définir le mot de passe root (ne pas mettre dans Git)
6. Attendre la fin de l'installation
7. Redémarrer

---

## 4. Configurer l'IP statique

Depuis la console TrueNAS, menu `1. Configure Network Interfaces` :

| Paramètre      | Valeur       |
|----------------|--------------|
| Interface      | vtnet0 (ou ens18) |
| DHCP           | Non          |
| IP Address     | 10.20.0.30   |
| Subnet mask    | /24          |
| IPv4 Default Gateway | 10.20.0.1 |
| DNS Nameserver 1 | 1.1.1.1    |

---

## 5. Accéder à l'interface web

```
http://10.20.0.30
```

Identifiant : `root`  
Mot de passe : défini à l'installation

---

## 6. Créer un pool ZFS de test

Dans l'interface web TrueNAS :

1. `Storage → Create Pool`
2. Nom du pool : `data-test`
3. Sélectionner le disque data (SATA 1)
4. Layout : `Stripe` (pas de redondance, c'est un test)
5. Confirmer la création

---

## 7. Créer des datasets

Dans `Storage → data-test → Add Dataset` :

| Dataset  | Usage                     |
|----------|---------------------------|
| `docker` | Volumes Docker (si besoin) |
| `backup` | Sauvegardes de test        |
| `media`  | Données diverses           |

---

## 8. Configurer un partage SMB (test)

1. `Sharing → Windows Shares (SMB) → Add`
2. Sélectionner le dataset souhaité
3. Activer le service SMB si demandé
4. Tester depuis srv-02 :

```bash
# Tester l'accès SMB depuis srv-02
smbclient -L 10.20.0.30 -U guest
```

---

## Limites de TrueNAS en VM

> TrueNAS est prévu pour une utilisation sur matériel dédié. En VM :

| Limitation               | Détail                                        |
|--------------------------|-----------------------------------------------|
| Passthrough disque physique | Préférable pour la production (pas du test) |
| RAM partagée              | ZFS peut en consommer beaucoup                |
| Performances              | Réduites par rapport au bare metal            |
| Objectif ici              | **Apprentissage uniquement**                  |

Pour le lab, les disques virtuels (fichiers qcow2/raw dans Proxmox) sont suffisants pour apprendre ZFS et TrueNAS.
