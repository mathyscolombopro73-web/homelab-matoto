# Projet Homelab MATOTO

## Présentation

Le projet **Homelab MATOTO** consiste à concevoir, déployer et documenter une infrastructure informatique personnelle inspirée d'un environnement professionnel.

Ce laboratoire tourne entièrement sur une seule machine physique via **Proxmox VE 9.1**. L'objectif est d'apprendre en pratiquant : tester, casser, réparer, sécuriser et documenter.

---

## Objectifs principaux

- Maîtriser la **virtualisation** avec Proxmox VE
- Configurer un **firewall/routeur** pfSense en VM
- Créer un **réseau interne isolé** (vmbr1 / 10.20.0.0/24)
- Déployer des **services Docker** sur Debian
- Apprendre **TrueNAS et ZFS** pour le stockage
- Mettre en place un **DNS local** avec Pi-hole
- Superviser l'infrastructure avec **Grafana + Prometheus**
- Versionner les configs avec **Gitea**
- Documenter toutes les étapes dans ce dépôt

---

## Périmètre du projet

### Ce que le projet couvre

- Infrastructure Proxmox sur PC personnel
- Réseau interne virtualisé (vmbr1)
- Firewall pfSense en VM
- Services Docker sur VM Debian
- Stockage de test avec TrueNAS
- DNS local filtré (Pi-hole)
- Monitoring basique (Grafana/Prometheus)
- Documentation technique complète

### Ce que le projet ne couvre pas

- Hébergement de services d'entreprise réels
- Exposition publique de données sensibles
- Mise en production commerciale
- Stockage de secrets ou mots de passe dans Git

---

## Contraintes

| Contrainte           | Détail                                      |
|----------------------|---------------------------------------------|
| Infrastructure       | Une seule machine physique (Proxmox)        |
| Réseau maison        | 192.168.1.0/24 — box opérateur non maîtrisée |
| WAN pfSense          | Réseau privé 192.168.1.0/24 (pas l'Internet direct) |
| Sécurité dépôt       | Aucun secret réel dans Git                  |
| Objectif             | Apprentissage, pas production               |

---

## Architecture technique

| Composant | Rôle                  | Système        | IP              |
|-----------|-----------------------|----------------|-----------------|
| `pve-01`  | Hyperviseur           | Proxmox VE 9.1 | DHCP 192.168.1.X |
| `fw-01`   | Firewall / routeur    | pfSense        | WAN: 192.168.1.50 / LAN: 10.20.0.1 |
| `srv-02`  | Services applicatifs  | Debian + Docker | 10.20.0.20     |
| `nas-01`  | Stockage de test      | TrueNAS        | 10.20.0.30      |
| `dns-01`  | DNS local             | Pi-hole (LXC)  | 10.20.0.40      |

---

## Critères de réussite

- [ ] Proxmox VE 9.1 installé et accessible via l'interface web (port 8006)
- [ ] Bridge `vmbr1` créé et fonctionnel sur Proxmox
- [ ] pfSense accessible depuis le réseau maison (WAN) et le réseau lab (LAN)
- [ ] DHCP pfSense distribue des IP dans 10.20.0.100–200
- [ ] srv-02 pinge pfSense et a accès à Internet
- [ ] DNS local (Pi-hole) fonctionne sur dns-01
- [ ] Docker opérationnel sur srv-02 avec au moins Portainer et Uptime Kuma
- [ ] TrueNAS accessible et pool ZFS de test créé
- [ ] PC principal accède à 10.20.0.0/24 via la route Windows
- [ ] Toute la documentation est à jour dans ce dépôt

---

## Livrables

- Documentation technique complète dans ce dépôt
- Scripts d'installation automatisés (idempotents)
- Fichiers `docker-compose.yml` prêts à l'emploi
- Procédures pas à pas pour chaque composant
- Checklists de validation
- Guide de dépannage
