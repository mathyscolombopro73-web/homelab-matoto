# Créer le LXC Pi-hole — dns-01

Procédure de création du conteneur LXC Pi-hole sur Proxmox VE 9.1.

---

## Pré-requis

- Proxmox VE 9.1 avec `vmbr1` créé
- pfSense opérationnel avec accès Internet depuis le lab
- Template Debian 12 téléchargé dans Proxmox

---

## 1. Télécharger le template Debian LXC

Dans l'interface Proxmox :

1. `local (pve-01) → CT Templates → Templates`
2. Chercher `debian-12-standard`
3. Cliquer **Download**

---

## 2. Créer le conteneur LXC

Dans l'interface Proxmox : `Create CT`

### Onglet General

| Paramètre     | Valeur            |
|---------------|-------------------|
| CT ID         | `104`             |
| Hostname      | `dns-01`          |
| Password      | Mot de passe fort (ne pas mettre dans Git) |
| SSH Public Key | (optionnel, recommandé) |
| Unprivileged  | Coché             |

### Onglet Template

| Paramètre | Valeur                         |
|-----------|--------------------------------|
| Storage   | local                          |
| Template  | `debian-12-standard_XX_amd64.tar.zst` |

### Onglet Disks

| Paramètre | Valeur    |
|-----------|-----------|
| Storage   | local-lvm |
| Disk size | 8 Go      |

### Onglet CPU

| Paramètre | Valeur |
|-----------|--------|
| Cores     | 1      |

### Onglet Memory

| Paramètre | Valeur    |
|-----------|-----------|
| Memory    | 512 Mo    |
| Swap      | 256 Mo    |

### Onglet Network

| Paramètre | Valeur          |
|-----------|-----------------|
| Bridge    | `vmbr1`         |
| IPv4      | Static          |
| IPv4/CIDR | `10.20.0.40/24` |
| Gateway   | `10.20.0.1`     |

### Onglet DNS

| Paramètre  | Valeur  |
|------------|---------|
| DNS domain | `homelab.matoto.local` |
| DNS servers | `1.1.1.1` |

---

## 3. Démarrer le conteneur

1. Cliquer **Finish**
2. Démarrer le conteneur : `dns-01 → Start`
3. Ouvrir la console : `dns-01 → Console`

---

## 4. Mettre à jour et préparer le système

```bash
apt update && apt upgrade -y
apt install -y curl
```

---

## 5. Installer Pi-hole

```bash
curl -sSL https://install.pi-hole.net | bash
```

Pendant l'installation interactive :

| Étape                    | Choix recommandé                |
|--------------------------|---------------------------------|
| Interface réseau         | `eth0` (ou l'interface disponible) |
| DNS upstream             | Cloudflare (1.1.1.1) ou Google  |
| Listes de blocage        | Garder les listes par défaut    |
| IPv4 statique            | Confirmer 10.20.0.40/24         |
| IPv6                     | Non (pas nécessaire pour le lab) |
| Web admin interface      | Oui                             |
| Web server (lighttpd)    | Oui                             |
| Log queries              | Oui                             |
| Privacy mode             | Mode 0 (tout loguer) ou Mode 3  |

À la fin de l'installation, Pi-hole affiche le mot de passe admin auto-généré.

> **Changer immédiatement le mot de passe :**

```bash
pihole -a -p
# Entrer un nouveau mot de passe fort
```

---

## 6. Accéder à l'interface web Pi-hole

```
http://10.20.0.40/admin
```

---

## 7. Configurer pfSense pour utiliser Pi-hole comme DNS

Dans l'interface web pfSense :

```
System → General Setup
```

| Paramètre    | Valeur         |
|--------------|----------------|
| DNS Server 1 | `10.20.0.40`   |
| DNS Server 2 | `1.1.1.1`      |

Puis dans le DHCP LAN :

```
Services → DHCP Server → LAN
```

| Paramètre         | Valeur       |
|-------------------|--------------|
| DNS Server 1      | `10.20.0.40` |
| DNS Server 2      | `1.1.1.1`    |

---

## 8. Tester la résolution DNS depuis srv-02

```bash
# Tester avec Pi-hole comme DNS
nslookup google.com 10.20.0.40

# Vérifier que la requête apparaît dans le dashboard Pi-hole
```

---

## 9. Script automatisé

Le script `scripts/pihole-lxc-install.sh` automatise les mises à jour et l'installation.

---

## Dépannage

| Problème                        | Solution                                             |
|---------------------------------|------------------------------------------------------|
| Pi-hole ne démarre pas          | Vérifier les ports 80 et 53 (`ss -tlnp`)             |
| DNS ne fonctionne pas           | Vérifier que Pi-hole écoute sur 10.20.0.40:53        |
| Interface web inaccessible      | Vérifier lighttpd (`systemctl status lighttpd`)      |
| LXC n'a pas Internet            | Vérifier la route pfSense et le DNS 1.1.1.1 au démarrage |
