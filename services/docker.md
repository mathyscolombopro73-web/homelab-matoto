# Docker — srv-02

Docker est le moteur de conteneurisation déployé sur la VM Debian `srv-02`.

| Info        | Valeur              |
|-------------|---------------------|
| Machine     | srv-02              |
| IP          | 10.20.0.20          |
| OS          | Debian 12 Bookworm  |
| Version     | Docker CE (latest)  |

## Installation

Voir [proxmox/create-debian-vm.md](../proxmox/create-debian-vm.md) ou utiliser le script :

```bash
bash scripts/debian-docker-install.sh
```

## Services déployés

Voir [docker/README.md](../docker/README.md) pour la liste complète et les `docker-compose.yml`.

## Commandes de base

```bash
docker ps -a                    # lister tous les conteneurs
docker compose up -d            # démarrer un service
docker compose down             # arrêter un service
docker compose logs -f          # suivre les logs
docker compose pull && docker compose up -d  # mettre à jour
docker system prune -f          # nettoyer les ressources inutilisées
```
