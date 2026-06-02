# Guide de dépannage — Homelab MATOTO

Problèmes fréquents et leurs solutions.

---

## Proxmox

### Proxmox inaccessible après modification réseau

**Symptôme** : L'interface web Proxmox ne répond plus sur `https://192.168.1.X:8006`

**Causes et solutions** :

| Cause                             | Solution                                             |
|-----------------------------------|------------------------------------------------------|
| Mauvaise IP dans vmbr0            | Accès physique au serveur, modifier `/etc/network/interfaces`, `ifreload -a` |
| Gateway incorrecte                | Vérifier la route par défaut : `ip route show`       |
| Bridge mal configuré              | Vérifier `brctl show`, vérifier que vmbr0 a un bridge-port sur la carte physique |
| Service pveproxy arrêté           | `systemctl restart pveproxy` (accès physique ou IPMI) |

**Diagnostic en console physique** :

```bash
ip addr show vmbr0        # vérifier l'IP
ip route show             # vérifier la route par défaut
ping 192.168.1.1          # vérifier la gateway
systemctl status pveproxy # vérifier le service
```

---

### pfSense bloque le trafic depuis le réseau maison (WAN)

**Symptôme** : Impossible d'accéder à `https://192.168.1.50`, les VMs du lab n'ont pas Internet

**Cause** : Options "Block private networks" et/ou "Block bogon networks" activées sur l'interface WAN.

**Solution** :

1. Accéder à pfSense depuis la console Proxmox (pas besoin de réseau)
2. `Interfaces → WAN`
3. Décocher **Block private networks and loopback addresses**
4. Décocher **Block bogon networks**
5. `Save` → `Apply Changes`

---

### Debian srv-02 n'a pas Internet

**Diagnostic** :

```bash
# Sur srv-02
ping 10.20.0.1      # Gateway pfSense — doit répondre
ping 1.1.1.1        # Internet — si fail, problème routage pfSense
nslookup google.com # DNS — si fail, problème DNS
ip route show       # Vérifier la route par défaut
cat /etc/resolv.conf # Vérifier le DNS configuré
```

**Solutions** :

| Problème                  | Solution                                          |
|---------------------------|---------------------------------------------------|
| Gateway incorrecte        | Corriger dans `/etc/network/interfaces` : `gateway 10.20.0.1` |
| pfSense LAN pas démarré   | Vérifier que fw-01 est allumé et la LAN 10.20.0.1 active |
| Règle LAN bloquante       | Vérifier `Firewall → Rules → LAN` dans pfSense    |
| NAT outbound manquant     | `Firewall → NAT → Outbound` : mode Automatic      |

---

### DNS ne fonctionne pas

**Diagnostic** :

```bash
# Tester avec un DNS public
nslookup google.com 1.1.1.1     # contourne Pi-hole

# Tester Pi-hole directement
nslookup google.com 10.20.0.40

# Vérifier Pi-hole
# Sur dns-01 :
systemctl status pihole-FTL
ss -tlnp | grep :53
```

**Solutions** :

| Problème                    | Solution                                        |
|-----------------------------|-------------------------------------------------|
| Pi-hole arrêté              | `pihole restartdns` ou `systemctl restart pihole-FTL` |
| Pi-hole ne répond pas sur 53 | Vérifier que le LXC dns-01 est démarré         |
| DNS configuré sur 127.0.0.1 | Modifier `/etc/resolv.conf` : `nameserver 10.20.0.40` |
| pfSense utilise mauvais DNS | `System → General Setup` → corriger DNS         |

---

### Route Windows ne fonctionne pas

**Symptôme** : Ping vers 10.20.0.X échoue depuis le PC principal

**Diagnostic** :

```powershell
# Vérifier la route
route print 10.20.0.0

# Vérifier si pfSense répond
ping 192.168.1.50

# Vérifier la route par défaut
netstat -rn
```

**Solutions** :

| Problème                       | Solution                                             |
|--------------------------------|------------------------------------------------------|
| Route pas dans la table        | `route add 10.20.0.0 mask 255.255.255.0 192.168.1.50 -p` en admin |
| pfSense ne répond pas au ping  | Vérifier règle WAN ICMP dans pfSense                 |
| pfSense WAN pas sur 192.168.1.50 | Vérifier l'IP WAN de pfSense (console)             |
| Règle firewall WAN bloquante   | Vérifier `Firewall → Rules → WAN` dans pfSense       |
| PowerShell pas en admin        | Clic droit → Exécuter en tant qu'administrateur      |

---

### Impossible d'accéder au réseau 10.20.0.0/24 depuis le PC

**Diagnostic complet** :

1. Vérifier que pfSense est démarré et que l'IP WAN est 192.168.1.50
2. Vérifier la route Windows : `route print 10.20.0.0`
3. Vérifier les règles firewall pfSense WAN
4. Tester depuis une VM du lab (ping entre VMs fonctionne ?)

---

### Conflit IP

**Symptôme** : Deux machines ont la même IP, comportement aléatoire réseau

**Diagnostic** :

```bash
# Sur pfSense (shell ou console)
arp -a | grep 10.20.0.XX

# Sur Linux
arping -I eth0 10.20.0.XX
```

**Solution** :

1. Identifier quelle machine utilise l'IP dupliquée
2. Modifier l'IP statique de la machine mal configurée
3. Vérifier le bail DHCP dans pfSense : `Services → DHCP Server → Leases`

---

### Mauvais bridge sur une VM

**Symptôme** : Une VM n'a pas de connectivité réseau du tout, ou est sur le mauvais réseau

**Solution** :

1. Éteindre la VM
2. `VM → Hardware → Network Device`
3. Vérifier quel bridge est assigné (`vmbr0` ou `vmbr1`)
4. Modifier si nécessaire
5. Redémarrer la VM

---

### DHCP pfSense désactivé

**Symptôme** : Les VMs ne reçoivent pas d'IP automatiquement

**Solution** :

1. Dans pfSense : `Services → DHCP Server → LAN`
2. Vérifier que **Enable DHCP server on LAN interface** est coché
3. Vérifier la plage : 10.20.0.100 → 10.20.0.200
4. `Save` → `Apply Changes`

---

### Docker ne démarre pas

**Diagnostic** :

```bash
systemctl status docker
journalctl -u docker --no-pager -n 50
docker info
```

**Solution courante** :

```bash
systemctl restart docker
# Si erreur de socket :
chmod 660 /var/run/docker.sock
usermod -aG docker $USER
```

---

## Commandes de diagnostic rapide

```bash
# État réseau général (sur n'importe quelle VM Linux)
ip addr show
ip route show
ping -c 3 10.20.0.1
ping -c 3 1.1.1.1
nslookup google.com

# Ports ouverts
ss -tlnp

# Logs système
journalctl -xe --no-pager | tail -50

# Docker
docker ps -a
docker compose logs -f
```
