# Portainer — Gestion Docker

Interface web de gestion Docker déployée sur srv-02.

| Info        | Valeur                     |
|-------------|----------------------------|
| URL         | http://10.20.0.20:9000     |
| Machine     | srv-02                     |
| Image       | portainer/portainer-ce:latest |
| Compose     | docker/portainer/docker-compose.yml |

## Déploiement

```bash
cd homelab-matoto/docker/portainer
docker compose up -d
```

## Premier démarrage

Accéder à `http://10.20.0.20:9000` dans les **5 minutes** après le démarrage pour créer le compte admin. Passé ce délai, Portainer se verrouille pour des raisons de sécurité (redémarrer le conteneur si nécessaire).

## Usages principaux

- Voir l'état de tous les conteneurs Docker
- Démarrer/arrêter/redémarrer des conteneurs
- Accéder aux logs des conteneurs
- Gérer les volumes et les réseaux Docker
- Déployer des stacks depuis l'interface
