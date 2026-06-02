# Plan d'adressage IP — Homelab MATOTO

---

## Réseaux

| Réseau          | CIDR              | Rôle                              |
|-----------------|-------------------|-----------------------------------|
| Réseau maison   | 192.168.1.0/24    | Réseau de la box opérateur        |
| Réseau lab      | 10.20.0.0/24      | Réseau interne virtualisé (vmbr1) |

---

## Adresses IP fixes

| Machine   | Nom FQDN                         | Interface     | Adresse IP        | Rôle                      |
|-----------|----------------------------------|---------------|-------------------|---------------------------|
| `pve-01`  | pve-01.homelab.matoto.local      | vmbr0         | DHCP 192.168.1.X  | Hyperviseur Proxmox       |
| `fw-01`   | fw-01.homelab.matoto.local       | WAN (vmbr0)   | 192.168.1.50/24   | pfSense WAN               |
| `fw-01`   | fw-01.homelab.matoto.local       | LAN (vmbr1)   | 10.20.0.1/24      | pfSense LAN / Gateway     |
| `srv-02`  | srv-02.homelab.matoto.local      | vmbr1         | 10.20.0.20/24     | Debian Docker             |
| `nas-01`  | nas-01.homelab.matoto.local      | vmbr1         | 10.20.0.30/24     | TrueNAS                   |
| `dns-01`  | dns-01.homelab.matoto.local      | vmbr1         | 10.20.0.40/24     | Pi-hole (LXC)             |

---

## Plage DHCP

| Paramètre     | Valeur                |
|---------------|-----------------------|
| Serveur DHCP  | pfSense (fw-01)       |
| Plage         | 10.20.0.100 — 10.20.0.200 |
| Gateway       | 10.20.0.1             |
| DNS primaire  | 10.20.0.40 (Pi-hole)  |
| DNS secondaire | 1.1.1.1              |
| Durée du bail | 24h (86400 s)         |

---

## Gateways

| Machine  | Gateway par défaut |
|----------|--------------------|
| `fw-01`  | 192.168.1.1 (box)  |
| `srv-02` | 10.20.0.1          |
| `nas-01` | 10.20.0.1          |
| `dns-01` | 10.20.0.1          |

---

## Serveurs DNS

| Étape          | DNS utilisé            | Raison                                |
|----------------|------------------------|---------------------------------------|
| Phase initiale | 1.1.1.1 (Cloudflare)   | Avant que Pi-hole soit opérationnel   |
| Phase normale  | 10.20.0.40 (Pi-hole)   | DNS local avec filtrage               |
| Fallback       | 1.1.1.1 / 8.8.8.8      | Si Pi-hole inaccessible               |

---

## Ports importants

| Service             | Machine  | Port(s)       | Protocole  |
|---------------------|----------|---------------|------------|
| Proxmox WebUI       | pve-01   | 8006          | TCP (HTTPS) |
| pfSense WebUI       | fw-01    | 80, 443       | TCP         |
| Pi-hole Admin       | dns-01   | 80            | TCP (HTTP)  |
| DNS                 | dns-01   | 53            | UDP/TCP     |
| TrueNAS WebUI       | nas-01   | 80            | TCP         |
| Portainer           | srv-02   | 9000          | TCP         |
| Uptime Kuma         | srv-02   | 3001          | TCP         |
| Homepage            | srv-02   | 3000          | TCP         |
| Grafana             | srv-02   | 3002          | TCP         |
| Prometheus          | srv-02   | 9090          | TCP         |
| Gitea               | srv-02   | 3003          | TCP         |
| Nginx Proxy Manager | srv-02   | 80, 443, 81   | TCP         |
| SSH                 | Toutes   | 22            | TCP         |
| SMB (TrueNAS)       | nas-01   | 445           | TCP         |
| NFS (TrueNAS)       | nas-01   | 2049          | TCP/UDP     |

---

## Route Windows

Pour accéder au réseau `10.20.0.0/24` depuis le PC principal sous Windows :

```powershell
# Ajouter la route (persistante, survivra aux redémarrages)
route add 10.20.0.0 mask 255.255.255.0 192.168.1.50 -p

# Vérifier
route print 10.20.0.0

# Supprimer si besoin
route delete 10.20.0.0
```

Voir la procédure complète : [windows-route.md](windows-route.md)
