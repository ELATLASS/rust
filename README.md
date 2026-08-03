# Maghribi Chill - Serveur Rust Maroc

Serveur Rust RP/MMO pour la communauté marocaine, hébergé sur **GitHub Codespaces**.

## 🚀 Démarrage rapide

1. Ouvre le codespace : https://github.com/ELATLASS/maghribi-chill-rust
2. Clique sur **"Code" → "Codespaces" → "New codespace"**
3. Le `deploy.sh` s'exécute automatiquement via `postCreateCommand`

## 📋 Configuration

- **Hostname** : Maghribi Chill - Maroc
- **Port** : 28015 (game), 28016 (RCON)
- **Max players** : 50
- **PvP** : Activé
- **RCON password** : `maghribi_rcon_2024`

## 🔧 Architecture du projet

```
maghribi-chill-rust/
├── .devcontainer/
│   └── devcontainer.json       # Configuration Codespaces (4 CPU, 16GB RAM, 32GB storage)
├── deploy.sh                   # Script de déploiement automatisé
├── deploy_part1.sh             # Partie 1: SteamCMD + serveur Rust
├── deploy_part2.sh             # Partie 2: Oxide + plugins + configuration
└── README.md
```

## 📦 Déploiement

Le `deploy.sh` effectue les opérations suivantes :

1. **Installation des dépendances** (lib32gcc-s1, wget, unzip, curl, screen)
2. **SteamCMD** : Téléchargement et installation
3. **Serveur Rust** : Téléchargement via SteamCMD (app 258100)
   - ⚠️ Nécessite un compte Steam avec licence Rust
   - Login anonyme échoue avec "No subscription"
4. **Oxide/uMod** : Téléchargement depuis [OxideMod/Oxide.Rust](https://github.com/OxideMod/Oxide.Rust)
5. **Plugins core** : ZoneManager, ImageLibrary, Teleport, StackSize
6. **Configuration** : start.sh, autoexec.cfg

## 🎮 Démarrage du serveur

```bash
cd ~/rust-server
./start.sh
```

## 🔧 Installation manuelle (si SteamCMD échoue)

```bash
# 1. Connecte-toi à Steam avec un compte possédant Rust
steamcmd +login <steam_user> +force_install_directory ~/rust-server +app_update 258100 validate +quit

# 2. Installe Oxide
cd ~/rust-server
wget https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip
unzip Oxide.Rust-linux.zip

# 3. Démarre le serveur
./start.sh
```

## 🌍 Ports

- **28015** : Port de jeu (TCP/UDP)
- **28016** : Port RCON (TCP)

## 🏗️ Spécifications Codespaces

- **Machine** : standardLinux32gb (4 cores, 16GB RAM, 32GB storage)
- **OS** : Ubuntu 22.04
- **Ports exposés** : 28015, 28016

## 📝 TODO

- [ ] Installer le serveur Rust avec un compte Steam
- [ ] Configurer les plugins RP (NPCTrader, Economy, Shop)
- [ ] Créer la zone safe Medina Hub
- [ ] Configurer le système économique (Dirham + Épices)
- [ ] Ajouter les items customs marocains