# Configuration pfSense — Homelab MATOTO

Guide complet d'installation et de configuration de pfSense en VM sur Proxmox.

---

## Prérequis

- VM créée dans Proxmox avec 2 cartes réseau :
  - **Carte 1** : connectée à `vmbr0` (WAN — réseau maison)
  - **Carte 2** : connectée à `vmbr1` (LAN — réseau lab)
- ISO pfSense téléchargée (voir [proxmox/create-pfsense-vm.md](../proxmox/create-pfsense-vm.md))

---

## 1. Installation de pfSense

1. Démarrer la VM depuis l'ISO pfSense
2. Accepter les conditions de licence
3. Choisir **Install pfSense**
4. Sélectionner le disque (le seul disponible)
5. Choisir le mode de partitionnement : **Auto (UFS)**
6. Confirmer et lancer l'installation
7. Une fois terminé : retirer l'ISO et redémarrer

---

## 2. Assignation des interfaces (console)

Au premier démarrage, pfSense demande d'assigner les interfaces.

```text
Do you want to set up VLANs now? → n (non pour l'instant)

Enter the WAN interface name → vtnet0  (ou em0 selon le driver)
Enter the LAN interface name → vtnet1
```

> **Important** : identifie les interfaces par leur adresse MAC visible dans Proxmox (onglet Matériel de la VM).

Confirmer l'assignation → `y`

---

## 3. Configuration du WAN

Dans le menu console pfSense :

```text
2) Set interface(s) IP address
Choisir 1 (WAN)
```

| Paramètre              | Valeur            |
|------------------------|-------------------|
| Type d'adresse         | Statique          |
| Adresse IP WAN         | 192.168.1.50      |
| Masque de sous-réseau  | 24                |
| Gateway WAN            | 192.168.1.1       |
| IPv6                   | Non (entrée vide) |
| Activer DHCP sur WAN   | Non               |
| Revenir HTTP (port 80) | Non               |

---

## 4. Configuration du LAN

```text
2) Set interface(s) IP address
Choisir 2 (LAN)
```

| Paramètre              | Valeur         |
|------------------------|----------------|
| Type d'adresse         | Statique       |
| Adresse IP LAN         | 10.20.0.1      |
| Masque de sous-réseau  | 24             |
| IPv6                   | Non            |
| Activer DHCP sur LAN   | Oui            |
| Début plage DHCP       | 10.20.0.100    |
| Fin plage DHCP         | 10.20.0.200    |

Après cette étape, pfSense affiche :

```text
The WEBGUI can be accessed at http://10.20.0.1
```

---

## 5. Accès à l'interface web

Depuis le réseau maison (PC principal), pfSense WAN est accessible sur :

```
https://192.168.1.50
```

Identifiants par défaut :

| Champ       | Valeur par défaut |
|-------------|-------------------|
| Utilisateur | `admin`           |
| Mot de passe | `pfsense`        |

> **Changer le mot de passe immédiatement** après la première connexion.

---

## 6. Désactiver "Block private networks" sur le WAN

> **Obligatoire** car le WAN de pfSense est sur le réseau privé 192.168.1.0/24.

Dans l'interface web :

```
Interfaces → WAN
```

Décocher :
- **Block private networks and loopback addresses**
- **Block bogon networks**

Cliquer **Save** puis **Apply Changes**.

---

## 7. Configurer le DNS du LAN

```
System → General Setup
```

| Paramètre        | Valeur                           |
|------------------|----------------------------------|
| DNS Server 1     | 10.20.0.40 (Pi-hole, phase 5)    |
| DNS Server 1 alt | 1.1.1.1 (au début, avant Pi-hole) |
| DNS Server 2     | 8.8.8.8                          |

---

## 8. Règle WAN — accès WebUI pfSense depuis le PC principal

Par défaut, l'accès à l'interface web est bloqué depuis le WAN.

Pour autoriser l'accès depuis le PC principal :

```
Firewall → Rules → WAN → Add
```

| Paramètre   | Valeur                           |
|-------------|----------------------------------|
| Action      | Pass                             |
| Interface   | WAN                              |
| Protocol    | TCP                              |
| Source      | 192.168.1.0/24 (réseau maison)   |
| Destination | This firewall (WAN address)      |
| Port dest.  | HTTPS (443) ou HTTP (80)         |
| Description | Accès WebUI pfSense depuis LAN maison |

Cliquer **Save** puis **Apply Changes**.

---

## 9. Règle WAN — accès ICMP (ping) depuis le PC principal

```
Firewall → Rules → WAN → Add
```

| Paramètre   | Valeur                      |
|-------------|------------------------------|
| Action      | Pass                         |
| Interface   | WAN                          |
| Protocol    | ICMP                         |
| ICMP type   | any                          |
| Source      | 192.168.1.0/24               |
| Destination | This firewall                |
| Description | Ping pfSense depuis PC       |

---

## 10. Règle LAN — autoriser tout le trafic sortant (défaut)

pfSense crée automatiquement une règle LAN "allow all" au premier démarrage.

Vérifier dans `Firewall → Rules → LAN` qu'il y a une règle :

```
Protocol: any | Source: LAN net | Destination: any | Action: Pass
```

---

## 11. Tests de connectivité

### Depuis la console pfSense (menu `7 - Ping host`)

```text
Ping 1.1.1.1          → vérifie Internet depuis pfSense
Ping 192.168.1.1      → vérifie l'accès à la box
Ping 10.20.0.20       → vérifie srv-02 (si déjà déployée)
```

### Depuis srv-02 (après déploiement)

```bash
ping 10.20.0.1    # gateway pfSense
ping 1.1.1.1      # Internet
nslookup google.com 1.1.1.1   # DNS externe
```

---

## Erreurs fréquentes

| Problème                                | Solution                                               |
|-----------------------------------------|--------------------------------------------------------|
| WebUI inaccessible depuis 192.168.1.50  | Vérifier la règle WAN ou l'IP WAN de pfSense          |
| Les VMs du lab n'ont pas Internet       | Vérifier NAT outbound et règle LAN allow all          |
| pfSense bloque le réseau maison sur WAN | Désactiver "Block private networks" sur l'interface WAN |
| Mauvaise assignation WAN/LAN            | Revérifier les MACs dans Proxmox et réassigner        |
