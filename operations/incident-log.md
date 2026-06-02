# Journal des incidents — Homelab MATOTO

Historique des incidents et problèmes rencontrés pendant la mise en place du lab.

---

## Format d'entrée

```
## [DATE] Titre de l'incident

**Symptôme** : Description du problème observé
**Cause** : Cause identifiée
**Solution** : Ce qui a résolu le problème
**Durée** : Temps de résolution
**Leçon** : Ce qu'on en retient
```

---

## Incidents

*(Aucun incident enregistré pour l'instant — en cours de déploiement)*

---

## Exemple d'entrée

```
## [2026-06-01] pfSense bloque le trafic WAN

**Symptôme** : Impossible d'accéder à 192.168.1.50 depuis le PC principal,
les VMs du lab n'ont pas Internet.

**Cause** : Options "Block private networks" et "Block bogon networks" activées
sur l'interface WAN. Le WAN pfSense est sur le réseau privé 192.168.1.0/24,
donc pfSense bloquait son propre trafic.

**Solution** : Désactivé les deux options dans Interfaces → WAN.
Voir network/pfsense-setup.md étape 6.

**Durée** : 20 minutes

**Leçon** : Toujours désactiver ces options quand le WAN est sur un réseau privé.
```
