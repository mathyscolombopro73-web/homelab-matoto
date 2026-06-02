# Flux réseau — Homelab MATOTO

Ce document décrit les flux réseau principaux entre les composants du lab.

---

## Vue d'ensemble des zones

| Zone           | Réseau          | Composants                          |
|----------------|-----------------|-------------------------------------|
| Réseau maison  | 192.168.1.0/24  | Box, PC principal, Proxmox (pve-01) |
| Réseau lab     | 10.20.0.0/24    | fw-01 (LAN), srv-02, nas-01, dns-01 |
| pfSense WAN    | 192.168.1.50/24 | Interface WAN de fw-01              |

---

## Flux d'accès depuis le PC principal

```text
PC principal (192.168.1.X)
    │
    ├─► Proxmox WebUI       192.168.1.X:8006   (direct via réseau maison)
    │
    ├─► pfSense WebUI WAN   192.168.1.50:443   (direct via réseau maison)
    │
    └─► Réseau 10.20.0.0/24 ────────────────────────────────────────────
            │  (via route Windows : next-hop 192.168.1.50)
            │
            ├─► fw-01 LAN       10.20.0.1     (pfSense WebUI via LAN)
            ├─► srv-02          10.20.0.20    (services Docker)
            ├─► nas-01          10.20.0.30    (TrueNAS WebUI)
            └─► dns-01          10.20.0.40    (Pi-hole WebUI)
```

---

## Flux Internet depuis le lab

```text
Machine lab (ex: srv-02 : 10.20.0.20)
    │
    └─► Gateway : 10.20.0.1 (pfSense LAN)
            │
            └─► pfSense NAT ──► vmbr0 ──► Box ──► Internet
```

pfSense effectue le **NAT** (masquerade) pour toutes les machines du lab vers Internet.

---

## Flux DNS

```text
Machine lab (srv-02, nas-01...)
    │
    └─► DNS : 10.20.0.40 (Pi-hole)
            │
            ├─► Résolution locale : retourne les IPs du lab
            │
            └─► Résolution externe : forward vers 1.1.1.1 ou 8.8.8.8
                        │
                        └─► via pfSense ──► Internet
```

---

## Flux DHCP

```text
Machine lab (nouvelle VM ou LXC)
    │
    └─► Requête DHCP broadcast sur vmbr1
            │
            └─► pfSense LAN (10.20.0.1) répond
                    IP attribuée : 10.20.0.100 à 10.20.0.200
                    Gateway : 10.20.0.1
                    DNS : 10.20.0.40 (Pi-hole) ou 1.1.1.1
```

---

## Tableau des règles réseau résumées

| Source          | Destination       | Port/Proto   | Action   | Raison                        |
|-----------------|-------------------|--------------|----------|-------------------------------|
| LAN (10.20.x.x) | WAN (Internet)    | Tout         | Autoriser | Navigation, mises à jour      |
| LAN             | LAN               | Tout         | Autoriser | Communication inter-VMs       |
| WAN (192.168.1.x) | LAN pfSense     | TCP 443      | Autoriser | Accès WebUI pfSense depuis PC |
| WAN             | LAN               | ICMP         | Autoriser | Ping depuis PC principal      |
| WAN             | LAN               | Autre        | Bloquer  | Sécurité par défaut           |
| LAN             | dns-01 (53)       | UDP/TCP 53   | Autoriser | Résolution DNS interne        |

---

## Notes importantes

- Le WAN pfSense est un réseau **privé** (192.168.1.0/24), pas Internet directement.  
  Il faut donc **désactiver** "Block private networks" et "Block bogon networks" sur l'interface WAN de pfSense.

- Proxmox lui-même **n'a pas d'IP sur vmbr1**. Il n'est pas routé dans le réseau lab. Seul pfSense route le trafic entre les zones.

- La route Windows `route add 10.20.0.0 mask 255.255.255.0 192.168.1.50 -p` est indispensable pour que le PC principal puisse joindre les VMs du lab directement.
