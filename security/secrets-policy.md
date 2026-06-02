# Politique de gestion des secrets — Homelab MATOTO

> **Règle absolue** : Aucun secret réel ne doit jamais être commité dans ce dépôt Git.

---

## Ce qui ne doit JAMAIS aller dans Git

| Type de secret        | Exemples                                    |
|-----------------------|---------------------------------------------|
| Mots de passe         | root, admin, services                       |
| Clés privées SSH      | `id_rsa`, `id_ed25519`                      |
| Certificats privés    | `*.key`, `*.pem`                            |
| Tokens API            | GitHub, Gitea, Grafana, etc.                |
| Fichiers `.env`       | Variables d'environnement de production     |
| Configs VPN           | `*.ovpn`, fichiers WireGuard                |
| Exports pfSense       | `config.xml` avec mots de passe            |
| Sauvegardes chiffrées | Clés de chiffrement restic                 |

---

## Placeholders à utiliser dans les fichiers de config

Dans tous les fichiers du dépôt, remplacer les secrets par :

| Placeholder          | Utilisation                      |
|----------------------|----------------------------------|
| `CHANGE_ME`          | Mot de passe à définir           |
| `YOUR_PASSWORD_HERE` | Mot de passe spécifique          |
| `YOUR_IP_HERE`       | Adresse IP à renseigner          |
| `YOUR_TOKEN_HERE`    | Token API à renseigner           |
| `EXAMPLE_KEY`        | Clé ou secret à remplacer        |

---

## Comment gérer les secrets en local

### Option 1 : Fichiers `.env` locaux (non commités)

Créer un fichier `.env` dans le répertoire du service :

```bash
# .env (ne jamais commiter ce fichier)
GRAFANA_ADMIN_PASSWORD=mon_vrai_mot_de_passe
GITEA_SECRET_KEY=ma_cle_secrete
```

Référencer dans `docker-compose.yml` :

```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
```

### Option 2 : Docker Secrets (production)

Pour une vraie infrastructure :

```yaml
secrets:
  db_password:
    file: ./secrets/db_password.txt
```

---

## Le .gitignore protège contre les accidents

Les fichiers suivants sont exclus par `.gitignore` :

```
.env
*.key
*.pem
secrets/
private/
*.ovpn
```

---

## En cas d'accident (commit d'un secret)

Si un secret est commité par erreur :

1. **Ne pas paniquer, mais agir vite**
2. Révoquer immédiatement le secret compromis (changer le mot de passe, régénérer le token)
3. Nettoyer l'historique Git :

```bash
# Outil recommandé : git-filter-repo
pip install git-filter-repo
git filter-repo --path fichier-secret.txt --invert-paths
git push --force origin main
```

4. Considérer que le secret est compromis même après nettoyage (il a pu être vu/indexé)
