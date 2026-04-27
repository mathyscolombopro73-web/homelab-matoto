# \# Homelab MATOTO

# 

# Bienvenue dans mon homelab personnel : un environnement conçu pour apprendre, tester, casser, réparer et documenter des technologies réseau, système, stockage, sécurité et automatisation.

# 

# \## Informations générales

# 

# | Élément | Valeur |

# |---|---|

# | Domaine local | `homelab.matoto.local` |

# | Version topologie | `v3.2` |

# | Dernier déploiement | `2026-04-22` |

# | Type de projet | Homelab personnel |

# | Objectif | Apprentissage, expérimentation et documentation |

# 

# \## Objectifs du projet

# 

# Ce homelab a pour objectif de simuler une petite infrastructure proche d’un environnement professionnel.

# 

# Il me permet de travailler sur :

# 

# \- la segmentation réseau avec VLAN ;

# \- le firewalling avec pfSense ;

# \- la virtualisation avec Proxmox VE ;

# \- la conteneurisation avec Docker ;

# \- le stockage centralisé avec TrueNAS et ZFS ;

# \- le DNS local avec Pi-hole ;

# \- l’accès distant sécurisé avec WireGuard ;

# \- la supervision avec Grafana ;

# \- la gestion de code avec Gitea ;

# \- les sauvegardes avec restic.

# 

# \## Architecture globale

# 

# ```text

# Internet

# &#x20;  |

# \[ pfSense Firewall ]

# &#x20;  | WAN / LAN / DMZ / WireGuard

# &#x20;  |

# \[ Switch L2 managé 802.1Q ]

# &#x20;  |

# &#x20;  +-- VLAN 10 LAN

# &#x20;  +-- VLAN 20 SRV

# &#x20;  +-- VLAN 30 IOT

# &#x20;  +-- VLAN 99 DMZ

# &#x20;  |

# &#x20;  +-- pve-01      Proxmox VE 8.2

# &#x20;  +-- srv-02      Debian + Docker

# &#x20;  +-- nas-01      TrueNAS + ZFS RAIDZ

