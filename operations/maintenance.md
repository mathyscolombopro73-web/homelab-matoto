# Maintenance — Homelab MATOTO

Procédures de maintenance régulière de l'infrastructure.

---

## Mises à jour hebdomadaires

### Proxmox (pve-01)

```bash
# SSH sur pve-01
apt update && apt full-upgrade -y
pveversion
```

### Debian srv-02

```bash
apt update && apt upgrade -y
```

### Pi-hole (dns-01)

```bash
pihole -up
pihole -g  # mettre à jour les listes de blocage
```

### Docker (srv-02)

```bash
# Mettre à jour toutes les images
docker compose pull

# Redémarrer les services avec les nouvelles images
docker compose up -d

# Nettoyer les images inutilisées
docker image prune -f
```

---

## Vérification mensuelle

- [ ] Vérifier l'espace disque sur tous les hôtes
- [ ] Vérifier les logs Proxmox pour des erreurs
- [ ] Vérifier les sauvegardes (elles se sont bien exécutées ?)
- [ ] Tester une restauration de test
- [ ] Vérifier la liste de blocage Pi-hole (à jour ?)
- [ ] Vérifier les certificats SSL (s'ils sont utilisés)

```bash
# Espace disque
df -h

# Logs Proxmox
journalctl -p err --no-pager -n 50

# Conteneurs Docker (état)
docker ps -a
docker system df
```

---

## Redémarrage propre du lab

Ordre d'arrêt recommandé :

1. Arrêter les VMs/LXC (srv-02, nas-01, dns-01)
2. Arrêter pfSense (fw-01) en dernier

Ordre de démarrage :

1. Démarrer pfSense (fw-01) en premier
2. Attendre 30 secondes
3. Démarrer srv-02, dns-01, nas-01

---

## Commandes utiles Proxmox

```bash
# État des VMs
qm list

# Démarrer une VM
qm start 100   # fw-01

# Arrêter une VM
qm shutdown 100

# État des LXC
pct list

# Démarrer un LXC
pct start 104   # dns-01
```
