# Services Docker — srv-02

Services déployés via Docker Compose sur `srv-02` (10.20.0.20).

---

## Pré-requis

- Docker et Docker Compose installés (voir [proxmox/create-debian-vm.md](../proxmox/create-debian-vm.md))
- srv-02 avec IP statique 10.20.0.20, gateway 10.20.0.1
- Accès Internet depuis srv-02

---

## Services disponibles

| Service             | Répertoire           | Port exposé | URL locale                  |
|---------------------|----------------------|-------------|-----------------------------|
| Portainer           | portainer/           | 9000        | http://10.20.0.20:9000      |
| Uptime Kuma         | uptime-kuma/         | 3001        | http://10.20.0.20:3001      |
| Homepage            | homepage/            | 3000        | http://10.20.0.20:3000      |
| Grafana + Prometheus | grafana-prometheus/ | 3002, 9090  | http://10.20.0.20:3002      |
| Gitea               | gitea/               | 3003        | http://10.20.0.20:3003      |
| Nginx Proxy Manager | nginx-proxy-manager/ | 80, 81, 443 | http://10.20.0.20:81        |

---

## Démarrage rapide

```bash
# Se connecter à srv-02
ssh admin@10.20.0.20

# Cloner le dépôt (ou copier les fichiers)
git clone https://github.com/TON_COMPTE/homelab-matoto.git
cd homelab-matoto/docker

# Démarrer un service
cd portainer
docker compose up -d

# Vérifier
docker compose ps
docker compose logs -f
```

---

## Structure des volumes

Tous les volumes sont persistants et stockés dans `/opt/homelab/` sur srv-02.

```bash
# Créer les répertoires de volumes (une seule fois)
mkdir -p /opt/homelab/{portainer,uptime-kuma,homepage,grafana,prometheus,gitea,nginx-proxy-manager}
```

---

## Commandes utiles

```bash
# Lister tous les conteneurs
docker ps -a

# Voir les logs d'un service
docker compose logs -f nom_service

# Arrêter un service
docker compose down

# Mettre à jour les images
docker compose pull
docker compose up -d

# Vérifier l'espace disque
docker system df
```

---

## Ordre de déploiement recommandé

1. **Portainer** — pour gérer Docker visuellement
2. **Uptime Kuma** — pour surveiller les services
3. **Nginx Proxy Manager** — pour le reverse proxy
4. **Homepage** — dashboard après avoir les autres services
5. **Gitea** — forge Git locale
6. **Grafana + Prometheus** — monitoring avancé
