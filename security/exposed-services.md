# Services exposés — Homelab MATOTO

Inventaire des services accessibles depuis le réseau maison et depuis le réseau lab.

---

## Services accessibles depuis le réseau maison (192.168.1.0/24)

Ces services sont joignables sans passer par pfSense :

| Service          | URL                            | Port  | Accessible à            |
|------------------|--------------------------------|-------|-------------------------|
| Proxmox WebUI    | https://192.168.1.X:8006       | 8006  | PC principal uniquement |
| pfSense WebUI WAN | https://192.168.1.50          | 443   | PC principal (règle firewall) |

> **Bonne pratique** : limiter l'accès Proxmox au seul PC d'administration (par IP ou par règle firewall sur la box).

---

## Services accessibles depuis le réseau lab (10.20.0.0/24)

Accessibles depuis le PC principal via la route Windows :

| Service             | URL                          | Port  | Authentification     |
|---------------------|------------------------------|-------|----------------------|
| pfSense WebUI LAN   | https://10.20.0.1            | 443   | admin / CHANGE_ME    |
| Pi-hole Admin       | http://10.20.0.40/admin      | 80    | Mot de passe Pi-hole |
| TrueNAS WebUI       | http://10.20.0.30            | 80    | root / CHANGE_ME     |
| Portainer           | http://10.20.0.20:9000       | 9000  | admin / CHANGE_ME    |
| Uptime Kuma         | http://10.20.0.20:3001       | 3001  | admin / CHANGE_ME    |
| Homepage            | http://10.20.0.20:3000       | 3000  | Aucune (dashboard)   |
| Grafana             | http://10.20.0.20:3002       | 3002  | admin / CHANGE_ME    |
| Prometheus          | http://10.20.0.20:9090       | 9090  | Aucune (interne)     |
| Gitea               | http://10.20.0.20:3003       | 3003  | admin / CHANGE_ME    |
| Nginx Proxy Mgr     | http://10.20.0.20:81         | 81    | admin@example.com    |

---

## Services NON exposés sur Internet

Ce homelab ne doit **pas** exposer de services directement sur Internet.

- Pas de port-forwarding sur la box vers Proxmox
- Pas de port-forwarding vers les services Docker
- Pas d'IP publique sur pfSense WAN (le WAN est sur le réseau maison)

Si une exposition externe est souhaitée à l'avenir, utiliser un VPN (WireGuard) plutôt que du port-forwarding.

---

## Rappels sécurité

- Changer tous les mots de passe par défaut (marqués `CHANGE_ME`)
- Prometheus n'a pas d'authentification par défaut : l'exposer uniquement en interne
- Gitea : désactiver les inscriptions ouvertes après création du compte admin
- Nginx Proxy Manager : changer les identifiants par défaut immédiatement
