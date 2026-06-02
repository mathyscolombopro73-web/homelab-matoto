# Sauvegardes et Restauration — Homelab MATOTO

---

## Stratégie de sauvegarde

| Quoi                   | Comment               | Fréquence   | Rétention  |
|------------------------|-----------------------|-------------|------------|
| VMs Proxmox (fw-01)    | Snapshot Proxmox      | Hebdomadaire | 2 copies   |
| VMs Proxmox (srv-02)   | Snapshot Proxmox      | Hebdomadaire | 2 copies   |
| Config pfSense         | Export XML manuel     | Après chaque modif | Toujours |
| Volumes Docker         | Tar + compression     | Hebdomadaire | 2 copies   |
| Données TrueNAS        | Snapshots ZFS auto    | Quotidien   | 7 jours    |
| Documentation Git      | Push sur GitHub       | Après chaque modif | Infini  |

---

## Sauvegardes Proxmox (VMs)

### Configurer les sauvegardes automatiques

Dans Proxmox : `Datacenter → Backup → Add`

| Paramètre          | Valeur recommandée   |
|--------------------|----------------------|
| Schedule           | Dimanche 02:00       |
| Storage            | local (ou NAS si disponible) |
| VMs               | fw-01, srv-02, nas-01 |
| Mode               | Snapshot             |
| Compression        | ZSTD                 |
| Max Backups        | 2                    |
| Email notification | (facultatif)         |

### Sauvegarde manuelle

```bash
# Sur pve-01, via l'interface web : sélectionner la VM → Backup → Backup Now
# Ou via l'API :
vzdump 100 --storage local --mode snapshot --compress zstd
```

---

## Sauvegardes volumes Docker (srv-02)

```bash
#!/bin/bash
# Script de sauvegarde des volumes Docker
BACKUP_DIR="/opt/homelab/backups"
DATE=$(date +%Y%m%d_%H%M)

mkdir -p "$BACKUP_DIR"

# Arrêter les conteneurs pour cohérence (optionnel)
# docker compose -f /chemin/vers/docker-compose.yml stop

# Sauvegarder chaque répertoire de données
for service in portainer uptime-kuma homepage grafana prometheus gitea nginx-proxy-manager; do
    if [ -d "/opt/homelab/$service" ]; then
        tar czf "$BACKUP_DIR/${service}_${DATE}.tar.gz" \
            -C "/opt/homelab" "$service"
        echo "Sauvegardé : $service"
    fi
done

# Supprimer les sauvegardes de plus de 14 jours
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +14 -delete
echo "Nettoyage des anciennes sauvegardes terminé"
```

---

## Export config pfSense

Dans l'interface web pfSense :

```
Diagnostics → Backup & Restore → Download configuration as XML
```

> **Ne jamais commiter ce fichier dans Git** — il contient les mots de passe et clés.  
> Le stocker dans un endroit sécurisé (NAS chiffré, gestionnaire de mots de passe).

---

## Snapshots ZFS TrueNAS

Dans TrueNAS : `Data Protection → Periodic Snapshot Tasks → Add`

| Paramètre  | Valeur          |
|------------|-----------------|
| Dataset    | data-test       |
| Schedule   | Daily           |
| Keep       | 7 (7 jours)     |
| Recursive  | Oui             |

---

## Restauration depuis une sauvegarde Proxmox

1. Dans Proxmox : `local → Backup`
2. Sélectionner la sauvegarde à restaurer
3. `Restore`
4. Choisir le stockage de destination
5. Cliquer `Restore`

---

## Restauration des volumes Docker

```bash
# Arrêter le service
docker compose down

# Restaurer le volume
tar xzf /opt/homelab/backups/grafana_20260101_0200.tar.gz -C /opt/homelab/

# Redémarrer le service
docker compose up -d
```
