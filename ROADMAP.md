# Roadmap Homelab MATOTO

Feuille de route progressive du projet. Chaque phase doit être validée avant de passer à la suivante.

---

## Phase 1 — Installation Proxmox

- [ ] Télécharger l'ISO Proxmox VE 9.1
- [ ] Créer une clé USB bootable (Rufus ou Balena Etcher)
- [ ] Installer Proxmox VE sur le PC
- [ ] Configurer le réseau de management (bridge vmbr0)
- [ ] Accéder à l'interface web : `https://192.168.1.X:8006`
- [ ] Appliquer les paramètres post-installation (dépôts, mises à jour)
- [ ] Désactiver les alertes d'abonnement (non-subscription repo)

**Référence :** [proxmox/install-proxmox.md](proxmox/install-proxmox.md)

---

## Phase 2 — Réseau interne vmbr1

- [ ] Créer le bridge `vmbr1` dans Proxmox (sans IP)
- [ ] Vérifier la configuration dans `/etc/network/interfaces`
- [ ] Appliquer sans casser l'accès à Proxmox
- [ ] Documenter la configuration réseau

**Référence :** [proxmox/network-bridges.md](proxmox/network-bridges.md)

---

## Phase 3 — VM pfSense (fw-01)

- [ ] Télécharger l'ISO pfSense
- [ ] Créer la VM avec 2 cartes réseau (vmbr0 + vmbr1)
- [ ] Installer pfSense
- [ ] Assigner WAN (vmbr0) et LAN (vmbr1)
- [ ] Configurer le WAN : IP statique 192.168.1.50/24
- [ ] Désactiver "Block private networks" sur le WAN
- [ ] Configurer le LAN : 10.20.0.1/24
- [ ] Activer le DHCP LAN : 10.20.0.100–200
- [ ] Vérifier l'accès à l'interface web pfSense depuis le réseau maison
- [ ] Tester la connectivité Internet depuis le LAN

**Référence :** [network/pfsense-setup.md](network/pfsense-setup.md)

---

## Phase 4 — VM Debian Docker (srv-02)

- [ ] Télécharger l'ISO Debian 12 (Bookworm)
- [ ] Créer la VM connectée à vmbr1
- [ ] Installer Debian (mode minimal)
- [ ] Configurer l'IP statique : 10.20.0.20/24 — GW : 10.20.0.1
- [ ] Installer Docker et Docker Compose
- [ ] Vérifier la connectivité et le DNS
- [ ] Tester Docker avec `docker run hello-world`

**Référence :** [proxmox/create-debian-vm.md](proxmox/create-debian-vm.md)

---

## Phase 5 — LXC Pi-hole (dns-01)

- [ ] Télécharger le template Debian LXC dans Proxmox
- [ ] Créer le conteneur LXC connecté à vmbr1
- [ ] Configurer l'IP statique : 10.20.0.40/24 — GW : 10.20.0.1
- [ ] Installer Pi-hole
- [ ] Configurer pfSense pour utiliser Pi-hole comme DNS du LAN
- [ ] Tester la résolution DNS depuis srv-02
- [ ] Vérifier le filtrage DNS dans le dashboard Pi-hole

**Référence :** [proxmox/create-pihole-lxc.md](proxmox/create-pihole-lxc.md)

---

## Phase 6 — VM TrueNAS (nas-01)

- [ ] Télécharger l'ISO TrueNAS Scale
- [ ] Créer la VM avec disque système + disque data de test
- [ ] Installer TrueNAS
- [ ] Configurer l'IP statique : 10.20.0.30/24 — GW : 10.20.0.1
- [ ] Créer un pool ZFS de test
- [ ] Créer des datasets (données, sauvegardes)
- [ ] Configurer un partage SMB ou NFS de test
- [ ] Tester l'accès depuis srv-02

**Référence :** [proxmox/create-truenas-vm.md](proxmox/create-truenas-vm.md)

---

## Phase 7 — Services Docker

- [ ] Déployer Portainer (gestion Docker)
- [ ] Déployer Uptime Kuma (supervision)
- [ ] Déployer Homepage (dashboard)
- [ ] Déployer Nginx Proxy Manager (reverse proxy)
- [ ] Déployer Gitea (forge Git)
- [ ] Tester chaque service depuis le réseau lab

**Référence :** [docker/README.md](docker/README.md)

---

## Phase 8 — Monitoring

- [ ] Déployer Prometheus
- [ ] Déployer Grafana
- [ ] Ajouter Node Exporter sur srv-02 et nas-01
- [ ] Importer les dashboards Grafana (système, Docker)
- [ ] Configurer Uptime Kuma pour surveiller les services critiques
- [ ] Configurer les alertes (optionnel)

**Référence :** [services/grafana.md](services/grafana.md)

---

## Phase 9 — Sécurité

- [ ] Durcir SSH sur toutes les machines (clé publique, désactiver root)
- [ ] Changer les mots de passe par défaut sur pfSense, TrueNAS, Pi-hole
- [ ] Vérifier les règles firewall pfSense
- [ ] Mettre en place une politique de secrets (aucun secret dans Git)
- [ ] Documenter les services exposés

**Référence :** [security/hardening.md](security/hardening.md)

---

## Phase 10 — Sauvegardes et documentation finale

- [ ] Configurer les sauvegardes Proxmox (snapshots VM)
- [ ] Mettre en place restic pour les données importantes
- [ ] Vérifier la procédure de restauration
- [ ] Compléter toute la documentation
- [ ] Nettoyer les fichiers inutiles du dépôt
- [ ] Créer un tag Git `v1.0`

**Référence :** [operations/backup-restore.md](operations/backup-restore.md)
