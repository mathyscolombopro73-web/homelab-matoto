# Règles Firewall — Homelab MATOTO

Règles pfSense pour l'infrastructure de base du lab.

---

## Principe de sécurité

```
Politique par défaut : BLOQUER tout ce qui n'est pas explicitement autorisé
Documenter chaque exception
Partir de règles larges, puis affiner
```

---

## Interface WAN (vmbr0 — 192.168.1.50)

> Le WAN est sur un réseau **privé** (réseau maison). Les options "Block private networks" et "Block bogon networks" doivent être **désactivées**.

| Priorité | Action  | Protocol | Source            | Destination          | Port dest.   | Description                          |
|----------|---------|----------|-------------------|----------------------|--------------|--------------------------------------|
| 1        | Pass    | TCP      | 192.168.1.0/24    | WAN address          | 443 (HTTPS)  | Accès WebUI pfSense depuis PC        |
| 2        | Pass    | TCP      | 192.168.1.0/24    | WAN address          | 80 (HTTP)    | Accès WebUI pfSense HTTP (optionnel) |
| 3        | Pass    | ICMP     | 192.168.1.0/24    | WAN address          | any          | Ping pfSense depuis réseau maison    |
| 4        | Pass    | TCP      | 192.168.1.0/24    | 10.20.0.0/24         | any          | Accès PC principal vers réseau lab   |
| 99       | Block   | any      | any               | any                  | any          | Bloquer tout le reste (implicit)     |

---

## Interface LAN (vmbr1 — 10.20.0.1)

| Priorité | Action  | Protocol | Source            | Destination          | Port dest.  | Description                       |
|----------|---------|----------|-------------------|----------------------|-------------|-----------------------------------|
| 1        | Pass    | any      | LAN net           | any                  | any         | Tout autoriser depuis le LAN (défaut pfSense) |
| 2        | Pass    | UDP/TCP  | LAN net           | 10.20.0.40           | 53          | DNS vers Pi-hole                  |
| 99       | Block   | any      | any               | any                  | any         | Implicit deny                     |

---

## NAT Outbound (sortie Internet)

pfSense configure automatiquement le NAT outbound en mode **Automatic**.

Toutes les machines du réseau `10.20.0.0/24` sortent sur Internet via l'IP WAN `192.168.1.50`.

Pour vérifier :

```
Firewall → NAT → Outbound
```

Mode recommandé : **Automatic** ou **Hybrid**.

---

## Règles à ajouter progressivement

### Phase 5 — Après déploiement Pi-hole

Forcer le DNS du LAN vers Pi-hole (éviter le contournement DNS) :

```
Firewall → Rules → LAN → Add
Action : Pass
Protocol : UDP/TCP
Source : LAN net
Destination : 10.20.0.40
Port : 53
Description : DNS LAN vers Pi-hole uniquement
```

Bloquer le DNS direct vers Internet depuis le LAN :

```
Action : Block
Protocol : UDP/TCP
Source : LAN net
Destination : any
Port : 53
Description : Bloquer DNS direct non-Pi-hole
Exception : 10.20.0.40 n'est pas concernée par ce blocage
```

### Phase 9 — Durcissement

- Restreindre l'accès SSH à certaines IPs seulement
- Bloquer les accès inter-VMs non nécessaires
- Activer les logs sur les règles de blocage

---

## Commandes de diagnostic utiles (depuis pfSense)

```text
Menu console → 7 (Ping host)
Menu console → 8 (Shell)

# Dans le shell pfSense
pfctl -sr                  # afficher toutes les règles actives
pfctl -ss                  # afficher les sessions actives
tcpdump -i vtnet0 -n       # capturer le trafic WAN
tcpdump -i vtnet1 -n       # capturer le trafic LAN
```
