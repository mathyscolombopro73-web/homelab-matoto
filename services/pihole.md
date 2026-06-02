# Pi-hole — dns-01

DNS local avec filtrage publicitaire et de tracking, déployé dans un LXC Debian sur Proxmox.

| Info        | Valeur                        |
|-------------|-------------------------------|
| Machine     | dns-01 (LXC Debian)           |
| IP          | 10.20.0.40/24                 |
| Gateway     | 10.20.0.1                     |
| URL Admin   | http://10.20.0.40/admin       |
| Port DNS    | 53 (UDP/TCP)                  |

## Installation

Voir [proxmox/create-pihole-lxc.md](../proxmox/create-pihole-lxc.md) ou utiliser le script :

```bash
bash scripts/pihole-lxc-install.sh
```

## Configuration DNS dans pfSense

Après installation de Pi-hole, configurer pfSense pour l'utiliser :

- `System → General Setup → DNS Server 1` : `10.20.0.40`
- `Services → DHCP Server → LAN → DNS Server 1` : `10.20.0.40`

## Commandes Pi-hole

```bash
pihole status          # état du service
pihole -up             # mettre à jour Pi-hole
pihole -g              # mettre à jour les listes de blocage
pihole -a -p           # changer le mot de passe admin
pihole restartdns      # redémarrer le DNS
pihole -t              # afficher les logs en temps réel
```
