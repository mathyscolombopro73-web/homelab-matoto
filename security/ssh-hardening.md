# Durcissement SSH — Homelab MATOTO

Procédure de configuration SSH sécurisée pour toutes les machines Linux du lab.

---

## 1. Générer une paire de clés SSH (sur le PC principal)

```powershell
# Windows — PowerShell ou Git Bash
ssh-keygen -t ed25519 -C "homelab-matoto" -f "$env:USERPROFILE\.ssh\homelab_ed25519"
```

Cela crée :
- `~/.ssh/homelab_ed25519` — clé privée (ne jamais partager)
- `~/.ssh/homelab_ed25519.pub` — clé publique (à copier sur les serveurs)

---

## 2. Copier la clé publique sur les serveurs

```bash
# Depuis le PC principal vers srv-02
ssh-copy-id -i ~/.ssh/homelab_ed25519.pub admin@10.20.0.20

# Depuis le PC principal vers dns-01
ssh-copy-id -i ~/.ssh/homelab_ed25519.pub root@10.20.0.40
```

Ou manuellement :

```bash
# Sur le serveur cible
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "COLLER_LA_CLE_PUBLIQUE_ICI" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

---

## 3. Configurer sshd_config

Sur chaque machine Linux (`/etc/ssh/sshd_config`) :

```bash
nano /etc/ssh/sshd_config
```

```text
# Désactiver l'accès root par SSH
PermitRootLogin no

# Désactiver l'authentification par mot de passe (après avoir copié la clé !)
PasswordAuthentication no

# Autoriser uniquement les clés publiques
PubkeyAuthentication yes

# Désactiver l'authentification par challenge
ChallengeResponseAuthentication no

# Désactiver le forwarding X11 (inutile en serveur)
X11Forwarding no

# Timeout de session
ClientAliveInterval 300
ClientAliveCountMax 2

# Limiter les tentatives de connexion
MaxAuthTries 3

# Changer le port SSH (optionnel, obscurity mais utile)
# Port 2222
```

Appliquer :

```bash
sshd -t          # vérifier la syntaxe
systemctl restart sshd
```

> **Tester la connexion par clé AVANT de fermer la session courante** pour éviter de se bloquer.

---

## 4. Configurer fail2ban

```bash
apt install -y fail2ban

# Configurer pour SSH
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime  = 3600
findtime  = 600
maxretry = 5

[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
EOF

systemctl enable fail2ban
systemctl restart fail2ban
```

Vérifier les IP bannies :

```bash
fail2ban-client status sshd
```

---

## 5. Configurer le client SSH sur le PC Windows

Éditer `~/.ssh/config` :

```text
# Accès aux machines du lab
Host pve-01
    HostName 192.168.1.10
    User root
    IdentityFile ~/.ssh/homelab_ed25519

Host fw-01
    HostName 10.20.0.1
    User admin
    IdentityFile ~/.ssh/homelab_ed25519

Host srv-02
    HostName 10.20.0.20
    User admin
    IdentityFile ~/.ssh/homelab_ed25519

Host nas-01
    HostName 10.20.0.30
    User admin
    IdentityFile ~/.ssh/homelab_ed25519

Host dns-01
    HostName 10.20.0.40
    User root
    IdentityFile ~/.ssh/homelab_ed25519
```

Usage :

```powershell
ssh srv-02   # au lieu de ssh admin@10.20.0.20 -i ~/.ssh/homelab_ed25519
```
