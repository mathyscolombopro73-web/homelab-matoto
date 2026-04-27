\# Topologie Homelab MATOTO



\## Informations



| Élément | Valeur |

|---|---|

| Domaine local | `homelab.matoto.local` |

| Version topologie | `v3.2` |

| Dernier déploiement | `2026-04-22` |

| Statut | En conception |



\## Vue d’ensemble



Cette topologie représente l’architecture cible du homelab.



L’infrastructure est organisée autour de quatre zones principales :



\- Internet ;

\- firewall pfSense ;

\- switch L2 managé avec VLAN ;

\- serveurs internes.



\## Schéma logique



```text

Internet

&#x20;  |

&#x20;  | WAN

&#x20;  |

\[ pfSense Firewall ]

&#x20;  |

&#x20;  | LAN Trunk 802.1Q

&#x20;  |

\[ Switch L2 managé ]

&#x20;  |

&#x20;  +-- VLAN 10 LAN

&#x20;  |      +-- PC personnel

&#x20;  |      +-- Accès administration

&#x20;  |

&#x20;  +-- VLAN 20 SRV

&#x20;  |      +-- pve-01

&#x20;  |      +-- srv-02

&#x20;  |      +-- nas-01

&#x20;  |

&#x20;  +-- VLAN 30 IOT

&#x20;  |      +-- Objets connectés

&#x20;  |      +-- Appareils non fiables

&#x20;  |

&#x20;  +-- VLAN 99 DMZ

&#x20;         +-- Services isolés

&#x20;         +-- Services exposés

