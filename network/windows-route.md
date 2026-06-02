# Route Windows vers le réseau lab — Homelab MATOTO

Pour accéder au réseau lab `10.20.0.0/24` depuis le PC principal Windows, une route statique doit être ajoutée. Elle passe par pfSense (192.168.1.50) qui fait le relais.

---

## Pré-requis

- pfSense déployé avec WAN : `192.168.1.50`
- PC principal sur le réseau `192.168.1.0/24`
- PowerShell lancé **en administrateur**

---

## Ajout de la route (méthode recommandée)

```powershell
# Ajouter la route persistante (survit aux redémarrages Windows)
route add 10.20.0.0 mask 255.255.255.0 192.168.1.50 -p
```

Le paramètre `-p` rend la route **permanente**.

---

## Vérification

```powershell
# Afficher toutes les routes
route print

# Filtrer sur le réseau du lab
route print 10.20.0.0
```

Résultat attendu :

```text
IPv4 Route Table
===========================================================================
Active Routes:
Network Destination    Netmask          Gateway         Interface   Metric
       10.20.0.0    255.255.255.0     192.168.1.50    192.168.1.X    ...
```

---

## Test de connectivité

```powershell
# Ping pfSense LAN
ping 10.20.0.1

# Ping srv-02
ping 10.20.0.20

# Ping Pi-hole
ping 10.20.0.40
```

---

## Suppression de la route

```powershell
# Supprimer la route persistante
route delete 10.20.0.0
```

---

## Script automatisé

Un script PowerShell est disponible dans `scripts/windows-add-lab-route.ps1`.

```powershell
# Exécuter le script (PowerShell en administrateur)
.\scripts\windows-add-lab-route.ps1
```

---

## Dépannage

| Problème                          | Solution                                                  |
|-----------------------------------|-----------------------------------------------------------|
| `route add` échoue                | Vérifier que PowerShell est lancé **en administrateur**   |
| Ping 10.20.0.1 ne répond pas      | Vérifier que pfSense est démarré et que l'IP WAN est 192.168.1.50 |
| La route disparaît au redémarrage | Vérifier que le flag `-p` a été utilisé                   |
| Ping fonctionne mais pas le web   | Vérifier les règles firewall de pfSense (WAN allow)       |

---

## Note technique

pfSense doit avoir une règle firewall WAN autorisant le trafic depuis `192.168.1.0/24` vers le réseau LAN `10.20.0.0/24`.

Par défaut pfSense bloque tout depuis le WAN. Voir [pfsense-setup.md](pfsense-setup.md) pour les règles à créer.
