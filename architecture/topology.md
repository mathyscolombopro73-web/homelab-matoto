# Topologie — Homelab MATOTO

## Vue d'ensemble

| Élément          | Valeur                   |
|------------------|--------------------------|
| Domaine local    | `homelab.matoto.local`   |
| Hyperviseur      | Proxmox VE 9.1           |
| Réseau maison    | `192.168.1.0/24`         |
| Réseau interne   | `10.20.0.0/24`           |
| Statut           | En cours de déploiement  |

---

## Schéma logique

```text
PC principal (Windows)
192.168.1.X
      |
      | (réseau maison)
      |
  [ Box Internet ]
192.168.1.0/24
      |
      |
  [ Proxmox VE 9.1 — pve-01 ]
  192.168.1.X (DHCP depuis la box)
      |
      +-- vmbr0 (pont vers réseau maison — accès Internet)
      |
      +-- vmbr1 (pont interne lab — sans IP sur Proxmox)
             |
             +-- [ fw-01 — pfSense ]
             |     WAN : vmbr0 → 192.168.1.50/24
             |     LAN : vmbr1 → 10.20.0.1/24
             |     DHCP : 10.20.0.100 à 10.20.0.200
             |
             +-- [ srv-02 — Debian Docker ]
             |     vmbr1 → 10.20.0.20/24
             |     GW : 10.20.0.1
             |
             +-- [ nas-01 — TrueNAS ]
             |     vmbr1 → 10.20.0.30/24
             |     GW : 10.20.0.1
             |
             +-- [ dns-01 — Pi-hole LXC ]
                   vmbr1 → 10.20.0.40/24
                   GW : 10.20.0.1
```

---

## Description des bridges Proxmox

| Bridge  | Rôle                              | IP sur Proxmox | Connecté à       |
|---------|-----------------------------------|----------------|------------------|
| `vmbr0` | Pont réseau maison / Internet      | IP de pve-01   | Box 192.168.1.0/24 |
| `vmbr1` | Réseau interne lab isolé           | Aucune         | Interne uniquement |

---

## Flux principaux

| Source         | Destination      | Via        | Port/Proto  | Rôle                        |
|----------------|------------------|------------|-------------|-----------------------------|
| PC principal   | pve-01 (8006)    | vmbr0      | TCP 8006    | Accès WebUI Proxmox         |
| PC principal   | fw-01 (80/443)   | 192.168.1.50 | TCP 80/443 | Accès WebUI pfSense        |
| PC principal   | 10.20.0.0/24     | 192.168.1.50 | Route Windows | Accès réseau lab          |
| fw-01 WAN      | Internet         | vmbr0      | Tout        | Sortie Internet du lab      |
| srv-02         | fw-01            | vmbr1      | Tout        | Gateway par défaut          |
| dns-01         | fw-01            | vmbr1      | Tout        | Gateway par défaut          |
| srv-02         | dns-01 (53)      | vmbr1      | UDP 53      | Résolution DNS              |

---

## Notes importantes

- **pfSense WAN** est sur le réseau maison `192.168.1.0/24`, pas sur Internet directement. Il faut donc **désactiver** les options "Block private networks" et "Block bogon networks" sur l'interface WAN.
- **vmbr1 n'a pas d'IP** sur Proxmox. Le routage du réseau `10.20.0.0/24` passe exclusivement par pfSense.
- Pour accéder au réseau `10.20.0.0/24` depuis le PC Windows, une **route statique** doit être ajoutée (voir [network/windows-route.md](../network/windows-route.md)).
