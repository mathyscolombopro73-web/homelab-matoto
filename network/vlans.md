# VLANs — Homelab MATOTO

## Statut actuel

> Le lab actuel (Phase 1 à 6) **n'utilise pas de VLANs**. La segmentation est assurée par le bridge `vmbr1` de Proxmox et le firewall pfSense.

Cette page documente les VLANs qui pourront être ajoutés en phase avancée du projet.

---

## Architecture actuelle (sans VLAN)

```text
vmbr0  →  Réseau maison 192.168.1.0/24
vmbr1  →  Réseau lab 10.20.0.0/24 (toutes les VMs)
```

Toutes les VMs du lab partagent le même segment `10.20.0.0/24` via `vmbr1`.

---

## Extension future : segmentation par VLAN

Si le lab évolue avec un switch managé, des VLANs pourront être créés :

| VLAN | Nom   | Réseau           | Rôle                        |
|------|-------|------------------|-----------------------------|
| 10   | LAN   | 10.20.10.0/24    | Administration, PC perso    |
| 20   | SRV   | 10.20.20.0/24    | Serveurs (srv-02, nas-01)   |
| 30   | IOT   | 10.20.30.0/24    | Objets connectés isolés     |
| 99   | DMZ   | 10.20.99.0/24    | Services exposés (web, etc) |

---

## Règles inter-VLAN prévues

| Source | Destination | Action           | Raison                        |
|--------|-------------|------------------|-------------------------------|
| LAN    | SRV         | Autoriser        | Administration des serveurs   |
| LAN    | IOT         | Limiter          | Gestion ponctuelle seulement  |
| LAN    | DMZ         | Partiel          | Administration                |
| SRV    | Internet    | Autoriser        | Updates, images Docker        |
| SRV    | LAN         | Bloquer          | Sécurité                      |
| IOT    | Internet    | Autoriser limité | Fonctionnement appareils      |
| IOT    | LAN/SRV     | Bloquer          | Isolation IOT                 |
| DMZ    | Internet    | Autoriser        | Services exposés              |
| DMZ    | LAN/SRV     | Bloquer          | Protection interne            |

---

## Prérequis pour implémenter des VLANs

- Switch L2/L3 compatible 802.1Q (ex : TP-Link TL-SG108E ou similaire)
- pfSense configuré avec interfaces VLAN (sous-interfaces)
- VMs/LXC reconnectées aux bons VLANs dans Proxmox

---

## Références

- [proxmox/network-bridges.md](../proxmox/network-bridges.md) — Configuration des bridges
- [network/firewall-rules.md](firewall-rules.md) — Règles inter-VLAN
