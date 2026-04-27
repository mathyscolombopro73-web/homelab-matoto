\# Règles Firewall - Homelab MATOTO



\## Objectif



Ce document décrit les règles firewall prévues pour le homelab.



Le firewall principal est pfSense. Il assure :



\- le filtrage réseau ;

\- le routage inter-VLAN ;

\- le NAT vers Internet ;

\- la protection des zones internes ;

\- l’accès VPN avec WireGuard ;

\- l’isolation de la DMZ et du réseau IOT.



\## Principe général



La politique de sécurité utilisée est :



```text

Bloquer par défaut

Autoriser uniquement ce qui est nécessaire

Documenter chaque exception

