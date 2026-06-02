# Plan de test — Checklist de validation du homelab

Checklist à compléter progressivement au fur et à mesure du déploiement.  
Cocher chaque point une fois vérifié réellement.

---

## Phase 1 — Proxmox VE

- [ ] Proxmox VE 9.1 installé sur pve-01
- [ ] Interface web accessible : `https://192.168.1.X:8006`
- [ ] Connexion en `root` fonctionnelle
- [ ] Dépôt no-subscription configuré
- [ ] `apt full-upgrade` exécuté sans erreur
- [ ] Stockage local visible (local-lvm)

---

## Phase 2 — Bridge vmbr1

- [ ] Bridge `vmbr1` créé dans Proxmox (sans IP)
- [ ] `vmbr0` et `vmbr1` visibles dans `pve-01 → Network`
- [ ] `ip addr show vmbr1` : pas d'adresse inet
- [ ] `brctl show` : vmbr1 apparaît

---

## Phase 3 — pfSense (fw-01)

- [ ] VM fw-01 créée avec 2 cartes réseau (vmbr0 + vmbr1)
- [ ] pfSense installé et démarré
- [ ] Interface WAN assignée sur vtnet0 (vmbr0)
- [ ] Interface LAN assignée sur vtnet1 (vmbr1)
- [ ] IP WAN : 192.168.1.50/24 — gateway 192.168.1.1
- [ ] IP LAN : 10.20.0.1/24
- [ ] DHCP LAN actif : plage 10.20.0.100–200
- [ ] "Block private networks" **désactivé** sur WAN
- [ ] "Block bogon networks" **désactivé** sur WAN
- [ ] Interface web pfSense accessible : `https://192.168.1.50`
- [ ] Mot de passe admin pfSense changé
- [ ] Ping pfSense → 1.1.1.1 : OK (menu console → 7)
- [ ] Ping pfSense → 192.168.1.1 : OK

---

## Phase 4 — VM Debian Docker (srv-02)

- [ ] VM srv-02 créée et connectée à vmbr1
- [ ] Debian 12 installé
- [ ] IP statique configurée : 10.20.0.20/24 — GW 10.20.0.1
- [ ] `ping 10.20.0.1` depuis srv-02 : OK
- [ ] `ping 1.1.1.1` depuis srv-02 : OK
- [ ] `nslookup google.com` depuis srv-02 : OK
- [ ] Docker installé et fonctionnel
- [ ] `docker run --rm hello-world` : OK
- [ ] `docker compose version` : OK
- [ ] Répertoires `/opt/homelab/` créés

---

## Phase 5 — LXC Pi-hole (dns-01)

- [ ] LXC dns-01 créé et connecté à vmbr1
- [ ] IP statique : 10.20.0.40/24 — GW 10.20.0.1
- [ ] Pi-hole installé
- [ ] Mot de passe Pi-hole changé
- [ ] Interface web Pi-hole accessible : `http://10.20.0.40/admin`
- [ ] DNS Pi-hole répond : `nslookup google.com 10.20.0.40` depuis srv-02 : OK
- [ ] pfSense configuré pour utiliser 10.20.0.40 comme DNS LAN
- [ ] Requêtes DNS visibles dans le dashboard Pi-hole

---

## Phase 6 — VM TrueNAS (nas-01)

- [ ] VM nas-01 créée avec disque système + disque data
- [ ] TrueNAS Scale installé
- [ ] IP statique : 10.20.0.30/24 — GW 10.20.0.1
- [ ] Interface web TrueNAS accessible : `http://10.20.0.30`
- [ ] Mot de passe root changé
- [ ] Pool ZFS `data-test` créé
- [ ] Dataset créé dans le pool
- [ ] Partage SMB ou NFS de test accessible depuis srv-02

---

## Phase 7 — Services Docker

- [ ] Portainer déployé — `http://10.20.0.20:9000`
- [ ] Compte Portainer créé dans les 5 minutes
- [ ] Uptime Kuma déployé — `http://10.20.0.20:3001`
- [ ] Homepage déployée — `http://10.20.0.20:3000`
- [ ] Nginx Proxy Manager déployé — `http://10.20.0.20:81`
- [ ] Identifiants NPM changés
- [ ] Gitea déployé — `http://10.20.0.20:3003`
- [ ] Compte admin Gitea créé

---

## Phase 8 — Monitoring

- [ ] Prometheus déployé — `http://10.20.0.20:9090`
- [ ] Grafana déployé — `http://10.20.0.20:3002`
- [ ] Mot de passe Grafana changé
- [ ] Prometheus ajouté comme datasource dans Grafana
- [ ] Dashboard "Node Exporter" importé dans Grafana
- [ ] Métriques srv-02 visibles dans Grafana

---

## Accès depuis le PC principal Windows

- [ ] Route Windows ajoutée : `route add 10.20.0.0 mask 255.255.255.0 192.168.1.50 -p`
- [ ] `ping 10.20.0.1` depuis le PC : OK
- [ ] `ping 10.20.0.20` depuis le PC : OK
- [ ] `ping 10.20.0.30` depuis le PC : OK
- [ ] `ping 10.20.0.40` depuis le PC : OK
- [ ] Accès à http://10.20.0.20:9000 (Portainer) depuis le navigateur PC : OK

---

## Script de vérification automatique

```bash
# Sur srv-02
bash /chemin/homelab-matoto/scripts/check-lab-connectivity.sh
```
