# Homelab MATOTO

Infrastructure personnelle de laboratoire — apprentissage, expérimentation et documentation.

> **Avertissement sécurité** : Ce dépôt ne contient **aucun secret réel** (mot de passe, clé privée, token, fichier .env de production). Tous les secrets sont remplacés par des placeholders comme `CHANGE_ME` ou `YOUR_IP_HERE`.

---

## Informations générales

| Élément            | Valeur                        |
|--------------------|-------------------------------|
| Nom du projet      | `homelab-matoto`              |
| Domaine local      | `homelab.matoto.local`        |
| Hyperviseur        | Proxmox VE 9.1                |
| Hôte Proxmox       | `pve-01`                      |
| Réseau maison      | `192.168.1.0/24`              |
| Réseau lab interne | `10.20.0.0/24`                |
| Statut             | En cours de déploiement       |
| Dernière mise à jour | 2026-06-02                  |

---

## Architecture globale

```text
PC principal (192.168.1.X)
        |
Réseau maison : 192.168.1.0/24 (Box Internet)
        |
Proxmox VE 9.1 — pve-01
        |
        +-- vmbr0 : pont réseau maison (accès Internet)
        |
        +-- vmbr1 : réseau interne lab (10.20.0.0/24)
               |
               +-- VM fw-01     pfSense      WAN: 192.168.1.50 / LAN: 10.20.0.1
               +-- VM srv-02    Debian+Docker              10.20.0.20
               +-- VM nas-01    TrueNAS                    10.20.0.30
               +-- LXC dns-01   Pi-hole                    10.20.0.40
```

---

## Plan IP résumé

| Machine   | Type | Rôle              | IP             | Réseau    |
|-----------|------|-------------------|----------------|-----------|
| `pve-01`  | Hôte | Hyperviseur        | DHCP 192.168.1.X | Maison  |
| `fw-01`   | VM   | Firewall pfSense   | WAN: 192.168.1.50 / LAN: 10.20.0.1 | Les deux |
| `srv-02`  | VM   | Debian + Docker    | 10.20.0.20     | Lab       |
| `nas-01`  | VM   | TrueNAS            | 10.20.0.30     | Lab       |
| `dns-01`  | LXC  | Pi-hole            | 10.20.0.40     | Lab       |
| DHCP pool | —    | Clients dynamiques | 10.20.0.100–200 | Lab      |

---

## Services prévus

| Service             | Machine  | Port   | Rôle                        |
|---------------------|----------|--------|-----------------------------|
| Proxmox WebUI       | pve-01   | 8006   | Gestion des VMs             |
| pfSense WebUI       | fw-01    | 80/443 | Gestion firewall/réseau     |
| Portainer           | srv-02   | 9000   | Gestion Docker via interface |
| Uptime Kuma         | srv-02   | 3001   | Supervision des services    |
| Homepage            | srv-02   | 3000   | Dashboard du homelab        |
| Grafana             | srv-02   | 3002   | Dashboards de monitoring    |
| Prometheus          | srv-02   | 9090   | Collecte de métriques       |
| Gitea               | srv-02   | 3003   | Forge Git locale            |
| Nginx Proxy Manager | srv-02   | 81     | Reverse proxy               |
| Pi-hole             | dns-01   | 80     | DNS local et filtrage       |
| TrueNAS WebUI       | nas-01   | 80     | Gestion stockage ZFS        |

---

## Route Windows à configurer

Pour accéder au réseau `10.20.0.0/24` depuis le PC principal :

```powershell
# À exécuter en administrateur
route add 10.20.0.0 mask 255.255.255.0 192.168.1.50 -p
```

Voir : [network/windows-route.md](network/windows-route.md)

---

## Documentation importante

| Sujet                   | Lien                                          |
|-------------------------|-----------------------------------------------|
| Projet et objectifs     | [PROJECT.md](PROJECT.md)                      |
| Feuille de route        | [ROADMAP.md](ROADMAP.md)                      |
| Plan d'adressage IP     | [network/addressing.md](network/addressing.md) |
| Installation Proxmox    | [proxmox/install-proxmox.md](proxmox/install-proxmox.md) |
| Configuration pfSense   | [network/pfsense-setup.md](network/pfsense-setup.md) |
| Services Docker         | [docker/README.md](docker/README.md)          |
| Checklist de validation | [operations/test-plan.md](operations/test-plan.md) |
| Dépannage               | [operations/troubleshooting.md](operations/troubleshooting.md) |

---

## Statut du projet

| Phase | Titre                      | Statut       |
|-------|----------------------------|--------------|
| 1     | Installation Proxmox       | 🔲 À faire   |
| 2     | Réseau interne vmbr1       | 🔲 À faire   |
| 3     | VM pfSense                 | 🔲 À faire   |
| 4     | VM Debian Docker           | 🔲 À faire   |
| 5     | LXC Pi-hole                | 🔲 À faire   |
| 6     | VM TrueNAS                 | 🔲 À faire   |
| 7     | Services Docker            | 🔲 À faire   |
| 8     | Monitoring                 | 🔲 À faire   |
| 9     | Sécurité                   | 🔲 À faire   |
| 10    | Sauvegardes et docs finale | 🔲 À faire   |
