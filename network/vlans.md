\# Plan VLAN - Homelab MATOTO



\## Objectif



Ce document décrit la segmentation réseau du homelab.



Les VLAN permettent de séparer les usages du réseau afin d’améliorer :



\- la sécurité ;

\- l’organisation ;

\- le contrôle des flux ;

\- l’isolation des équipements ;

\- la lisibilité de l’infrastructure.



\## Domaine local



`homelab.matoto.local`



\## Vue d’ensemble des VLAN



| VLAN | Nom | Réseau | Usage |

|---:|---|---|---|

| 10 | LAN | `192.168.10.0/24` | Postes personnels et administration |

| 20 | SRV | `192.168.20.0/24` | Serveurs, VMs, LXC et services internes |

| 30 | IOT | `192.168.30.0/24` | Objets connectés |

| 99 | DMZ | `192.168.99.0/24` | Services isolés ou exposés |



\## VLAN 10 - LAN



\### Rôle



Le VLAN 10 est le réseau principal utilisé pour les postes personnels et l’administration du homelab.



\### Équipements concernés



\- PC personnel ;

\- laptop d’administration ;

\- accès à Proxmox ;

\- accès à TrueNAS ;

\- accès à pfSense ;

\- accès aux interfaces web internes.



\### Réseau



| Élément | Valeur |

|---|---|

| VLAN ID | `10` |

| Nom | `LAN` |

| Réseau | `192.168.10.0/24` |

| Passerelle | `192.168.10.1` |

| DHCP | Oui |

| DNS | Pi-hole / pfSense |



\### Politique de sécurité



Le VLAN LAN peut accéder aux services internes nécessaires à l’administration.



Accès autorisés :



\- interface pfSense ;

\- interface Proxmox ;

\- interface TrueNAS ;

\- services Docker internes ;

\- Grafana ;

\- Gitea ;

\- Pi-hole.



\## VLAN 20 - SRV



\### Rôle



Le VLAN 20 héberge les serveurs, les machines virtuelles, les conteneurs et les services internes.



\### Équipements concernés



\- `pve-01` ;

\- `srv-02` ;

\- `nas-01` ;

\- Pi-hole ;

\- Grafana ;

\- Gitea ;

\- services Docker ;

\- services de sauvegarde.



\### Réseau



| Élément | Valeur |

|---|---|

| VLAN ID | `20` |

| Nom | `SRV` |

| Réseau | `192.168.20.0/24` |

| Passerelle | `192.168.20.1` |

| DHCP | Optionnel |

| DNS | Pi-hole |



\### Adressage recommandé



| Hôte | Adresse IP | Rôle |

|---|---|---|

| `pve-01` | `192.168.20.10` | Proxmox VE |

| `srv-02` | `192.168.20.20` | Debian Docker |

| `nas-01` | `192.168.20.30` | TrueNAS |

| `dns-01` | `192.168.20.40` | Pi-hole |

| `mon-01` | `192.168.20.50` | Grafana / monitoring |

| `git-01` | `192.168.20.60` | Gitea |

| `backup-01` | `192.168.20.70` | restic |



\### Politique de sécurité



Le VLAN SRV peut accéder à Internet pour :



\- mises à jour système ;

\- téléchargement d’images Docker ;

\- synchronisation de dépôts Git ;

\- sauvegardes externes si nécessaire.



Les accès depuis SRV vers LAN doivent être limités.



\## VLAN 30 - IOT



\### Rôle



Le VLAN 30 isole les objets connectés et les équipements considérés comme moins fiables.



\### Équipements concernés



\- caméras ;

\- prises connectées ;

\- assistants vocaux ;

\- téléviseurs ;

\- imprimantes ;

\- appareils domotiques.



\### Réseau



| Élément | Valeur |

|---|---|

| VLAN ID | `30` |

| Nom | `IOT` |

| Réseau | `192.168.30.0/24` |

| Passerelle | `192.168.30.1` |

| DHCP | Oui |

| DNS | Pi-hole ou pfSense |



\### Politique de sécurité



Le VLAN IOT doit être fortement limité.



Accès autorisés :



\- Internet ;

\- DNS ;

\- NTP ;

\- services précis si nécessaire.



Accès bloqués :



\- VLAN 10 LAN ;

\- VLAN 20 SRV ;

\- interface pfSense ;

\- interface Proxmox ;

\- interface TrueNAS.



\## VLAN 99 - DMZ



\### Rôle



Le VLAN 99 est utilisé pour les services isolés ou potentiellement exposés.



\### Équipements concernés



\- serveur web de test ;

\- reverse proxy ;

\- services publics contrôlés ;

\- machines de laboratoire exposées temporairement.



\### Réseau



| Élément | Valeur |

|---|---|

| VLAN ID | `99` |

| Nom | `DMZ` |

| Réseau | `192.168.99.0/24` |

| Passerelle | `192.168.99.1` |

| DHCP | Optionnel |

| DNS | Pi-hole ou pfSense |



\### Politique de sécurité



La DMZ ne doit pas pouvoir initier de connexion vers les réseaux internes.



Accès autorisés :



\- DMZ vers Internet ;

\- LAN vers DMZ pour administration ;

\- Internet vers DMZ uniquement si une règle explicite existe.



Accès bloqués :



\- DMZ vers LAN ;

\- DMZ vers SRV ;

\- DMZ vers IOT ;

\- DMZ vers interfaces d’administration.



\## Résumé des règles inter-VLAN



| Source | Destination | Action | Raison |

|---|---|---|---|

| LAN | SRV | Autoriser | Administration |

| LAN | IOT | Limiter | Gestion ponctuelle |

| LAN | DMZ | Autoriser partiellement | Administration |

| SRV | Internet | Autoriser | Updates et services |

| SRV | LAN | Bloquer par défaut | Sécurité |

| IOT | Internet | Autoriser limité | Fonctionnement appareils |

| IOT | LAN | Bloquer | Isolation |

| IOT | SRV | Bloquer | Isolation |

| DMZ | Internet | Autoriser | Services exposés |

| DMZ | LAN | Bloquer | Protection interne |

| DMZ | SRV | Bloquer | Protection interne |



\## Services réseau communs



| Service | Port | Usage |

|---|---:|---|

| DNS | 53 | Résolution de noms |

| DHCP | 67/68 | Attribution IP |

| HTTP | 80 | Interface web ou proxy |

| HTTPS | 443 | Interface web sécurisée |

| SSH | 22 | Administration |

| NTP | 123 | Synchronisation horaire |

| WireGuard | 51820 | VPN |



\## Bonnes pratiques



\- Utiliser des IP fixes pour les serveurs.

\- Utiliser DHCP pour les postes clients et objets connectés.

\- Bloquer les flux inter-VLAN par défaut.

\- Autoriser uniquement les flux nécessaires.

\- Documenter chaque exception firewall.

\- Ne jamais placer les objets connectés dans le LAN principal.

\- Ne jamais exposer directement Proxmox, TrueNAS ou pfSense à Internet.



\## Statut



Plan VLAN en phase de conception.

