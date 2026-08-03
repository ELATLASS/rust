#!/bin/bash
# Automated Rust Server Deployment Script for GitHub Codespaces/VPS
# Serveur Rust Maroc - Communauté Marocaine
# Note: Rust Dedicated Server (app 258100) requires a Steam account with license.
# SteamCMD can kill SSH sessions on failure — using 'script' to isolate it.

echo "🚀 Démarrage du déploiement du serveur Rust Maroc..."

# 1. Installer les dépendances
echo "📦 Installation des dépendances..."
sudo apt-get update -qq
sudo apt-get install -y -qq lib32gcc-s1 wget unzip curl > /dev/null 2>&1
echo "  ✅ Dépendances installées"

# 2. Créer la structure des dossiers
echo "📁 Création de la structure des dossiers..."
mkdir -p ~/rust-server/steamcmd
mkdir -p ~/rust-server/oxide/plugins
mkdir -p ~/rust-server/oxide/config
mkdir -p ~/rust-server/cfg
echo "  ✅ Dossiers créés"

# 3. Télécharger SteamCMD
echo "⬇️  Téléchargement de SteamCMD..."
cd ~/rust-server/steamcmd
if [ ! -f "steamcmd.sh" ]; then
    wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xzf steamcmd_linux.tar.gz
fi
echo "  ✅ SteamCMD installé"

# 4. Télécharger le serveur Rust via SteamCMD
echo "🎮 Téléchargement du serveur Rust..."
cd ~/rust-server/steamcmd
RUST_INSTALLED=false

# Check if Rust is already installed
if [ -f ~/rust-server/RustServer.x86_64 ] || [ -f ~/rust-server/RustDedicated ]; then
    RUST_INSTALLED=true
    echo "  ✅ Serveur Rust déjà installé"
else
    # Use Steam credentials if available, otherwise try anonymous
    # SteamCMD can kill SSH sessions on failure — using 'script' to isolate it
    if [ -n "$STEAM_PASSWORD" ]; then
        if [ -n "$STEAM_GUARD_CODE" ]; then
            echo "  → Téléchargement via SteamCMD (compte Steam: $STEAM_USER, code SG: $STEAM_GUARD_CODE)..."
            script -qec "./steamcmd.sh +force_install_dir ~/rust-server +login $STEAM_USER $STEAM_PASSWORD +set_steam_guard_code $STEAM_GUARD_CODE +app_update 258100 validate +quit" /dev/null > /tmp/steamcmd_rust.log 2>&1 || true
        else
            echo "  → Téléchargement via SteamCMD (compte Steam: $STEAM_USER)..."
            script -qec "./steamcmd.sh +force_install_dir ~/rust-server +login $STEAM_USER $STEAM_PASSWORD +app_update 258100 validate +quit" /dev/null > /tmp/steamcmd_rust.log 2>&1 || true
        fi
    else
        echo "  → Tentative de téléchargement via SteamCMD (anonymous)..."
        script -qec './steamcmd.sh +force_install_dir ~/rust-server +login anonymous +app_update 258100 validate +quit' /dev/null > /tmp/steamcmd_rust.log 2>&1 || true
    fi
    
    if [ -f ~/rust-server/RustServer.x86_64 ] || [ -f ~/rust-server/RustDedicated ]; then
        RUST_INSTALLED=true
        echo "  ✅ Serveur Rust téléchargé"
    else
        echo "  ⚠️  SteamCMD échoué (Rust nécessite une licence Steam)"
        echo "  ⚠️  Utilise: steamcmd +login <steam_user> <steam_password> +force_install_directory ~/rust-server +app_update 258100 validate +quit"
    fi
fi

# 5. Télécharger Oxide
echo "🔧 Téléchargement d'Oxide/uMod..."
cd ~/rust-server
if [ "$RUST_INSTALLED" = true ] && [ ! -f "oxide/oxide.dll" ]; then
    curl -sL -A 'Mozilla/5.0' -o Oxide.Rust.zip 'https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip'
    if unzip -o Oxide.Rust.zip > /dev/null 2>&1; then
        echo "  ✅ Oxide installé"
    else
        echo "  ⚠️  Échec du téléchargement d'Oxide"
    fi
elif [ "$RUST_INSTALLED" = false ]; then
    echo "  ⚠️  Oxide sera installé au premier démarrage du serveur Rust"
else
    echo "  ✅ Oxide déjà installé"
fi

# 6. Télécharger les plugins core
echo "🔌 Téléchargement des plugins core..."
PLUGINS_DIR=~/rust-server/oxide/plugins
mkdir -p "$PLUGINS_DIR"
cd "$PLUGINS_DIR"

plugins=(
    "ZoneManager"
    "ImageLibrary"
    "Teleport"
    "StackSize"
)

for plugin in "${plugins[@]}"; do
    echo "  → Téléchargement de $plugin..."
    curl -sL -A 'Mozilla/5.0' "https://umod.org/plugins/$plugin" -o "$plugin.cs" 2>/dev/null || echo "  ⚠️  $plugin non téléchargé (vérifier URL)"
done
echo "  ✅ Plugins téléchargés"

# 7. Créer le script de démarrage
echo "📝 Création du script de démarrage..."
cat > ~/rust-server/start.sh << 'STARTEOF'
#!/bin/bash
cd ~/rust-server
if [ -f ./RustDedicated ]; then
    BINARY=./RustDedicated
elif [ -f ./RustServer.x86_64 ]; then
    BINARY=./RustServer.x86_64
else
    echo "ERROR: No Rust server binary found. Install via steamcmd first."
    exit 1
fi

$BINARY \
    -batchmode \
    -port 28015 \
    -rcon.port 28016 \
    -rcon.password "maghribi_rcon_2024" \
    -server.hostname "Maghribi Chill - Maroc" \
    -server.description "Serveur Rust Maroc - Communauté Marocaine" \
    -server.url "https://discord.gg/maghribi" \
    -server.maxplayers 50 \
    -autostart
STARTEOF

chmod +x ~/rust-server/start.sh
echo "  ✅ start.sh créé"

# 8. Créer le fichier de configuration
echo "⚙️  Création du fichier de configuration..."
cat > ~/rust-server/cfg/autoexec.cfg << 'CFGEOF'
server.hostname "Maghribi Chill - Maroc"
server.description "Serveur Rust Maroc - Communauté Marocaine"
server.url "https://discord.gg/maghribi"
server.maxplayers 50
server.pvp true
server.buildposessions true
CFGEOF
echo "  ✅ autoexec.cfg créé"

# 9. Vérifier si le serveur est installé
echo ""
if [ -f ~/rust-server/RustServer.x86_64 ] || [ -f ~/rust-server/RustDedicated ]; then
    echo "✅ Déploiement terminé ! Le serveur Rust est installé."
    echo ""
    echo "▶️  Pour démarrer le serveur :"
    echo "  cd ~/rust-server && ./start.sh"
else
    echo "⚠️  Déploiement partiel terminé."
    echo "⚠️  Le serveur Rust n'a pas pu être téléchargé (licence Steam requise)."
    echo "⚠️  Les fichiers de configuration, plugins et scripts sont prêts."
    echo ""
    echo "▶️  Pour installer le serveur Rust manuellement :"
    echo "  1. Connecte-toi à Steam avec un compte possédant Rust"
    echo "  2. Utilise: steamcmd +login <steam_user> +force_install_directory ~/rust-server +app_update 258100 validate +quit"
    echo "  3. Installe Oxide: wget https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip"
    echo "  4. Démarre: cd ~/rust-server && ./start.sh"
fi