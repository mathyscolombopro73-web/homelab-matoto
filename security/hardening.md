# Durcissement — Homelab MATOTO

Bonnes pratiques de sécurité pour l'infrastructure du lab.

---

## Principes généraux

- **Moindre privilège** : chaque service n'a accès qu'à ce dont il a besoin
- **Défense en profondeur** : plusieurs couches de sécurité
- **Aucun secret dans Git** : voir [secrets-policy.md](secrets-policy.md)
- **Mots de passe forts** sur tous les services

---

## Checklist de durcissement

### Proxmox (pve-01)

- [ ] Changer le mot de passe root par défaut
- [ ] Accès WebUI limité au réseau maison (192.168.1.0/24)
- [ ] Désactiver le dépôt Enterprise si pas d'abonnement
- [ ] Mettre à jour régulièrement (`apt full-upgrade`)
- [ ] Créer un utilisateur non-root pour les opérations courantes
- [ ] Activer les sauvegardes régulières dans Proxmox

### pfSense (fw-01)

- [ ] Changer le mot de passe admin par défaut (pfsense → votre mot de passe)
- [ ] Désactiver l'accès WebUI depuis le WAN si possible (ou le restreindre)
- [ ] Activer HTTPS sur l'interface web
- [ ] Vérifier les règles firewall (pas de "allow any any" non documentée)
- [ ] Désactiver les services inutilisés
- [ ] Mettre à jour pfSense régulièrement

### srv-02 — Debian Docker

- [ ] Connexion SSH par clé publique uniquement (désactiver le mot de passe SSH)
- [ ] Désactiver l'accès SSH root
- [ ] Installer et configurer `fail2ban`
- [ ] Firewall local (`ufw` ou `iptables`)
- [ ] Mettre à jour régulièrement (`apt upgrade`)
- [ ] Volumes Docker non exposés publiquement
- [ ] Pas de secrets dans les `docker-compose.yml` (utiliser `.env`)

### dns-01 — Pi-hole

- [ ] Changer le mot de passe admin Pi-hole après installation
- [ ] Accès limité au réseau lab (10.20.0.0/24)
- [ ] Mettre à jour Pi-hole régulièrement (`pihole -up`)

### nas-01 — TrueNAS

- [ ] Changer le mot de passe root
- [ ] Désactiver les partages non nécessaires
- [ ] Accès SMB/NFS limité aux IPs du lab
- [ ] Activer les snapshots ZFS
- [ ] Mettre à jour TrueNAS

---

## Durcissement SSH (global)

Voir [ssh-hardening.md](ssh-hardening.md) pour la procédure détaillée.

```bash
# Résumé rapide : modifier /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
Port 22  # changer si souhaité (ex: 2222)
```

---

## Politique de gestion des secrets

Ne jamais stocker dans Git :
- Mots de passe
- Clés SSH/TLS privées
- Tokens API
- Fichiers `.env` de production

Voir [secrets-policy.md](secrets-policy.md) pour les règles complètes.

---

## Mises à jour régulières

```bash
# Debian (srv-02, dns-01)
apt update && apt upgrade -y

# Proxmox (pve-01)
apt update && apt full-upgrade -y

# Docker (srv-02)
docker compose pull
docker compose up -d

# Pi-hole (dns-01)
pihole -up
```
