\# Projet Homelab MATOTO



\## Présentation du projet



Le projet Homelab MATOTO consiste à concevoir, déployer et documenter une infrastructure informatique personnelle inspirée d’un environnement professionnel.



Ce laboratoire permet de tester des technologies liées au réseau, à la virtualisation, au stockage, à la sécurité, à la supervision et aux sauvegardes.



L’objectif principal est d’apprendre en pratiquant : tester, casser, réparer, sécuriser et documenter.



\## Nom du projet



`homelab.matoto.local`



\## Version



\- Topologie : v3.2

\- Dernier déploiement prévu : 2026-04-22



\## Objectifs principaux



\- Mettre en place une architecture réseau segmentée avec VLAN.

\- Déployer un firewall pfSense.

\- Créer une infrastructure de virtualisation avec Proxmox VE.

\- Héberger des services avec Docker.

\- Mettre en place un stockage centralisé avec TrueNAS et ZFS.

\- Configurer un DNS local avec Pi-hole.

\- Mettre en place un accès distant sécurisé avec WireGuard.

\- Superviser l’infrastructure avec Grafana.

\- Versionner la documentation et les configurations avec Gitea/GitHub.

\- Mettre en place une stratégie de sauvegarde avec restic.



\## Périmètre du projet



Le projet couvre :



\- le réseau local ;

\- les VLAN ;

\- le firewall ;

\- les machines virtuelles ;

\- les conteneurs ;

\- le stockage ;

\- le monitoring ;

\- les sauvegardes ;

\- la documentation technique.



Le projet ne couvre pas :



\- l’hébergement de services critiques pour une entreprise réelle ;

\- l’exposition publique de données sensibles ;

\- la mise en production commerciale ;

\- le stockage de secrets dans le dépôt Git.



\## Architecture cible



L’infrastructure sera composée de :



| Élément | Rôle |

|---|---|

| Internet | Accès externe |

| pfSense | Firewall, NAT, routage, VPN |

| Switch L2 managé | Segmentation VLAN 802.1Q |

| Proxmox VE | Virtualisation |

| Debian Docker | Services applicatifs |

| TrueNAS | Stockage centralisé |

| Pi-hole | DNS local |

| WireGuard | VPN |

| Grafana | Supervision |

| Gitea | Forge Git |

| restic | Sauvegardes |



\## Topologie simplifiée



```text

Internet

&#x20;  |

\[ pfSense Firewall ]

&#x20;  |

\[ Switch L2 managé 802.1Q ]

&#x20;  |

&#x20;  +-- VLAN 10 LAN

&#x20;  +-- VLAN 20 SRV

&#x20;  +-- VLAN 30 IOT

&#x20;  +-- VLAN 99 DMZ

&#x20;  |

&#x20;  +-- pve-01   Proxmox VE

&#x20;  +-- srv-02   Debian + Docker

&#x20;  +-- nas-01   TrueNAS





