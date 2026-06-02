# Nginx Proxy Manager — Reverse proxy

Reverse proxy avec interface web pour gérer facilement les hôtes proxy, redirections et certificats SSL.

| Info        | Valeur                     |
|-------------|----------------------------|
| URL Admin   | http://10.20.0.20:81       |
| Machine     | srv-02                     |
| Image       | jc21/nginx-proxy-manager:latest |
| Compose     | docker/nginx-proxy-manager/docker-compose.yml |

## Déploiement

```bash
cd homelab-matoto/docker/nginx-proxy-manager
docker compose up -d
```

## Identifiants par défaut (à changer immédiatement)

| Champ       | Valeur par défaut      |
|-------------|------------------------|
| Email       | admin@example.com      |
| Mot de passe | changeme              |

## Usages dans le lab

- Créer des entrées proxy vers les services internes
- Permettre l'accès via nom de domaine plutôt que par IP:port
- Gérer les certificats SSL (Let's Encrypt si domaine public disponible, ou auto-signé)

## Exemple de proxy host (lab)

Pour accéder à Grafana via `grafana.homelab.matoto.local` :

1. `Hosts → Proxy Hosts → Add Proxy Host`
2. Domain Names : `grafana.homelab.matoto.local`
3. Forward Host : `10.20.0.20`
4. Forward Port : `3002`
5. Save

Ajouter l'entrée DNS dans Pi-hole pour que ça fonctionne localement.
