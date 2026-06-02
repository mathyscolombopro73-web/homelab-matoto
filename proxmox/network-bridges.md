# Bridges réseau Proxmox — pve-01

Configuration des bridges `vmbr0` et `vmbr1` sur Proxmox VE 9.1.

---

## Rôle des bridges

| Bridge  | Rôle                               | IP sur Proxmox  | Réseau           |
|---------|------------------------------------|-----------------|------------------|
| `vmbr0` | Réseau maison — accès Internet     | IP de pve-01    | 192.168.1.0/24   |
| `vmbr1` | Réseau interne lab — isolé         | **Aucune IP**   | 10.20.0.0/24 (géré par pfSense) |

> `vmbr0` est créé automatiquement lors de l'installation de Proxmox.
> `vmbr1` doit être créé manuellement.

---

## Créer vmbr1 via l'interface web Proxmox

> **Avertissement** : toute modification réseau sur Proxmox peut entraîner une perte d'accès temporaire. Travailler de préférence avec un accès physique au serveur ou via l'écran.

1. Dans l'interface web : `pve-01 → Network`
2. Cliquer **Create → Linux Bridge**
3. Remplir les champs :

| Paramètre          | Valeur          |
|--------------------|-----------------|
| Name               | `vmbr1`         |
| IPv4/CIDR          | *Laisser vide*  |
| IPv6/CIDR          | *Laisser vide*  |
| Bridge ports       | *Laisser vide*  |
| Autostart          | Coché           |
| VLAN aware         | Non (pour l'instant) |
| Comment            | `Réseau interne lab` |

4. Cliquer **Create**
5. Cliquer **Apply Configuration**

---

## Configuration résultante dans /etc/network/interfaces

Après création via l'interface web, le fichier `/etc/network/interfaces` devrait ressembler à :

```text
auto lo
iface lo inet loopback

iface enp3s0 inet manual

auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports enp3s0
    bridge-stp off
    bridge-fd 0
    # Bridge réseau maison — accès Internet

auto vmbr1
iface vmbr1 inet manual
    bridge-ports none
    bridge-stp off
    bridge-fd 0
    # Bridge réseau interne lab — sans IP sur Proxmox
```

> Le fichier exemple est disponible dans [snippets/vmbr1-example.interfaces](snippets/vmbr1-example.interfaces)

---

## Appliquer sans redémarrer

```bash
# Sur pve-01 (SSH ou shell Proxmox)
ifreload -a
```

Si `ifreload` n'est pas disponible :

```bash
# Méthode alternative (peut couper la connexion brièvement)
ifdown vmbr1; ifup vmbr1
```

---

## Vérification

```bash
# Lister les bridges
brctl show

# Vérifier l'état des interfaces
ip addr show vmbr1

# Vérifier que vmbr1 n'a pas d'IP
ip route
```

Résultat attendu pour `vmbr1` :

```text
vmbr1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    link/ether ...
    # Pas d'adresse inet → correct
```

---

## Vérification via l'interface web

Dans `pve-01 → Network` :
- `vmbr0` : active, IP 192.168.1.X/24
- `vmbr1` : active, pas d'IP

---

## Étape suivante

Créer la VM pfSense : voir [create-pfsense-vm.md](create-pfsense-vm.md)
