\# Inventaire - Homelab MATOTO



\## Objectif



Ce document recense les machines principales du homelab.



Il permet de garder une vision claire de l’infrastructure :



\- noms des machines ;

\- rôles ;

\- systèmes installés ;

\- adresses IP ;

\- services hébergés ;

\- état actuel.



\## Domaine local



`homelab.matoto.local`



\## Vue d’ensemble



| Hôte | Rôle | Système | VLAN | Adresse IP | Statut |

|---|---|---|---:|---|---|

| `pfSense` | Firewall / routeur | pfSense | 10 / 20 / 30 / 99 | `192.168.x.1` | Prévu |

| `pve-01` | Hyperviseur | Proxmox VE 8.2 | 20 | `192.168.20.10` | Prévu |

| `srv-02` | Serveur applicatif | Debian + Docker | 20 | `192.168.20.20` | Prévu |

| `nas-01` | Stockage centralisé | TrueNAS | 20 | `192.168.20.30` | Prévu |

| `dns-01` | DNS local | Pi-hole | 20 | `192.168.20.40` | Prévu |

| `mon-01` | Monitoring | Grafana / Prometheus | 20 | `192.168.20.50` | Prévu |

| `git-01` | Forge Git | Gitea | 20 | `192.168.20.60` | Prévu |

| `backup-01` | Sauvegardes | restic | 20 | `192.168.20.70` | Prévu |



\## Machines principales



\## pfSense



\### Rôle



`pfSense` est le routeur et firewall principal du homelab.



Il gère :



\- l’accès Internet ;

\- le NAT ;

\- les VLAN ;

\- le routage inter-VLAN ;

\- les règles firewall ;

\- le VPN WireGuard ;

\- le DHCP selon les VLAN ;

\- éventuellement le DNS de secours.



\### Interfaces prévues



| Interface | Rôle | Réseau |

|---|---|---|

| WAN | Accès Internet | Fourni par l’opérateur |

| LAN | Administration | `192.168.10.0/24` |

| VLAN 20 | Serveurs | `192.168.20.0/24` |

| VLAN 30 | IOT | `192.168.30.0/24` |

| VLAN 99 | DMZ | `192.168.99.0/24` |

| WireGuard | VPN | `10.10.10.0/24` |



\### Adresse IP prévue



| Interface | Adresse |

|---|---|

| LAN | `192.168.10.1` |

| SRV | `192.168.20.1` |

| IOT | `192.168.30.1` |

| DMZ | `192.168.99.1` |



\---



\## pve-01



\### Rôle



`pve-01` est l’hyperviseur principal du homelab.



Il héberge les machines virtuelles et les conteneurs LXC.



\### Informations



| Élément | Valeur |

|---|---|

| Nom | `pve-01` |

| Système | Proxmox VE 8.2 |

| VLAN | 20 SRV |

| Adresse IP | `192.168.20.10` |

| Rôle | Virtualisation |

| Charge prévue | 9 VMs / 6 LXC |

| Statut | Prévu |



\### Services hébergés possibles



| Service | Type | Rôle |

|---|---|---|

| `dns-01` | LXC | Pi-hole |

| `mon-01` | VM | Grafana / Prometheus |

| `backup-01` | LXC | restic |

| `lab-linux-01` | VM | Tests Linux |

| `web-dmz-01` | VM | Service web isolé |

| `docker-test-01` | VM | Tests Docker |



\### Notes



L’accès à l’interface Proxmox doit être autorisé uniquement depuis :



\- VLAN 10 LAN ;

\- VPN WireGuard ;

\- éventuellement un poste d’administration dédié.



L’interface Web Proxmox utilise le port :



```text

8006/TCP

