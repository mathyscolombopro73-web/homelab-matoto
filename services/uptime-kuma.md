# Uptime Kuma — Supervision des services

Outil de monitoring de disponibilité, style UptimeRobot mais auto-hébergé.

| Info        | Valeur                     |
|-------------|----------------------------|
| URL         | http://10.20.0.20:3001     |
| Machine     | srv-02                     |
| Image       | louislam/uptime-kuma:latest |
| Compose     | docker/uptime-kuma/docker-compose.yml |

## Déploiement

```bash
cd homelab-matoto/docker/uptime-kuma
docker compose up -d
```

## Services à monitorer (exemples)

Après déploiement, ajouter ces monitors dans l'interface :

| Service          | Type  | URL / Host          | Port  |
|------------------|-------|---------------------|-------|
| pfSense          | HTTP  | http://10.20.0.1    | 443   |
| Portainer        | HTTP  | http://10.20.0.20   | 9000  |
| Pi-hole          | HTTP  | http://10.20.0.40   | 80    |
| TrueNAS          | HTTP  | http://10.20.0.30   | 80    |
| Grafana          | HTTP  | http://10.20.0.20   | 3002  |
| Gitea            | HTTP  | http://10.20.0.20   | 3003  |
| DNS Pi-hole      | DNS   | 10.20.0.40          | 53    |
