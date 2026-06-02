# Inventaire — Homelab MATOTO

Recensement de toutes les machines et services du lab.

---

## Machines virtuelles et conteneurs

| Hôte     | Type | Rôle                | Système         | IP Réseau lab    | Gateway      | Statut   |
|----------|------|---------------------|-----------------|------------------|--------------|----------|
| `pve-01` | Hôte | Hyperviseur         | Proxmox VE 9.1  | DHCP 192.168.1.X | 192.168.1.1  | Prévu    |
| `fw-01`  | VM   | Firewall / Routeur  | pfSense         | WAN: 192.168.1.50 / LAN: 10.20.0.1 | — | Prévu |
| `srv-02` | VM   | Services Docker     | Debian 12       | 10.20.0.20/24    | 10.20.0.1    | Prévu    |
| `nas-01` | VM   | Stockage ZFS        | TrueNAS Scale   | 10.20.0.30/24    | 10.20.0.1    | Prévu    |
| `dns-01` | LXC  | DNS local           | Debian + Pi-hole | 10.20.0.40/24   | 10.20.0.1    | Prévu    |

---

## Services hébergés sur srv-02 (Docker)

| Service             | Port interne | Port exposé | URL locale                          |
|---------------------|--------------|-------------|-------------------------------------|
| Portainer           | 9000         | 9000        | http://10.20.0.20:9000              |
| Uptime Kuma         | 3001         | 3001        | http://10.20.0.20:3001              |
| Homepage            | 3000         | 3000        | http://10.20.0.20:3000              |
| Grafana             | 3000         | 3002        | http://10.20.0.20:3002              |
| Prometheus          | 9090         | 9090        | http://10.20.0.20:9090              |
| Gitea               | 3000         | 3003        | http://10.20.0.20:3003              |
| Nginx Proxy Manager | 80/81/443    | 80/81/443   | http://10.20.0.20:81 (admin)        |

---

## Détail des machines

### pve-01 — Proxmox VE

| Élément       | Valeur                        |
|---------------|-------------------------------|
| Rôle          | Hyperviseur                   |
| OS            | Proxmox VE 9.1                |
| IP management | DHCP depuis la box (192.168.1.X) |
| WebUI         | https://192.168.1.X:8006      |
| Bridges       | vmbr0 (maison), vmbr1 (lab)   |
| RAM conseillée | 16 Go minimum                |
| Stockage      | SSD recommandé pour les VMs   |

---

### fw-01 — pfSense

| Élément       | Valeur                        |
|---------------|-------------------------------|
| Rôle          | Firewall, NAT, routeur, DHCP  |
| OS            | pfSense CE ou Plus            |
| WAN           | vmbr0 — IP: 192.168.1.50/24   |
| LAN           | vmbr1 — IP: 10.20.0.1/24      |
| DHCP LAN      | 10.20.0.100 à 10.20.0.200     |
| DNS LAN       | 10.20.0.40 (Pi-hole) puis 1.1.1.1 |
| WebUI         | http://192.168.1.50 ou https://10.20.0.1 |
| RAM VM        | 1 Go                          |
| CPU VM        | 2 vCPU                        |
| Disque VM     | 10 Go                         |

---

### srv-02 — Debian Docker

| Élément       | Valeur                        |
|---------------|-------------------------------|
| Rôle          | Serveur applicatif Docker     |
| OS            | Debian 12 Bookworm            |
| IP            | 10.20.0.20/24                 |
| Gateway       | 10.20.0.1                     |
| DNS           | 10.20.0.40 (Pi-hole)          |
| RAM VM        | 4 Go (8 Go conseillés)        |
| CPU VM        | 2–4 vCPU                      |
| Disque VM     | 50 Go minimum                 |

---

### nas-01 — TrueNAS

| Élément       | Valeur                        |
|---------------|-------------------------------|
| Rôle          | Stockage ZFS de test          |
| OS            | TrueNAS Scale                 |
| IP            | 10.20.0.30/24                 |
| Gateway       | 10.20.0.1                     |
| WebUI         | http://10.20.0.30             |
| RAM VM        | 8 Go minimum (ZFS exigeant)   |
| CPU VM        | 2 vCPU                        |
| Disque système | 32 Go                        |
| Disque data   | 1 disque de test (ex: 50 Go)  |

---

### dns-01 — Pi-hole (LXC)

| Élément       | Valeur                        |
|---------------|-------------------------------|
| Rôle          | DNS local et filtrage         |
| OS            | Debian 12 (LXC)               |
| IP            | 10.20.0.40/24                 |
| Gateway       | 10.20.0.1                     |
| WebUI         | http://10.20.0.40/admin       |
| RAM LXC       | 512 Mo                        |
| CPU LXC       | 1 vCPU                        |
| Disque LXC    | 8 Go                          |
