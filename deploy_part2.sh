#!/bin/bash
# Part 2: Install Oxide, plugins, and configuration
# This script runs after Part 1

echo "🚀 Part 2: Installation d'Oxide, plugins et configuration..."

# Check if Rust server is installed
if [ ! -f ~/rust-server/RustServer.x86_64 ]; then
    echo "⚠️  Serveur Rust non installé - installation des fichiers de configuration seulement"
fi

# Download Oxide
echo "🔧 Téléchargement d'Oxide/uMod..."
cd ~/rust-server
if [ -f ~/rust-server/RustServer.x86_64 ] && [ ! -f "oxide/oxide.dll" ]; then
    wget -q https://github.com/uMod/Oxide/releases/latest/download/Oxide.Rust.zip
    unzip -o Oxide.Rust.zip > /dev/null
    echo "  ✅ Oxide installé"
else
    echo "  ⚠️  Oxide sera installé au premier démarrage"
fi

# Download plugins
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
    curl -sL -A 'Mozilla/5.0' "https://umod.org/plugins/$plugin" -o "$plugin.cs" 2>/dev/null || echo "  ⚠️  $plugin non téléchargé"
done
echo "  ✅ Plugins téléchargés"

# Create start.sh
echo "📝 Création du script de démarrage..."
cat > ~/rust-server/start.sh << 'STARTEOF'
#!/bin/bash
cd ~/rust-server
./RustServer.x86_64 \
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

# Create autoexec.cfg
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

# Check status
echo ""
if [ -f ~/rust-server/RustServer.x86_64 ]; then
    echo "✅ Déploiement terminé ! Le serveur Rust est installé."
    echo "▶️  cd ~/rust-server && ./start.sh"
else
    echo "⚠️  Déploiement partiel terminé."
    echo "⚠️  Installez le serveur Rust manuellement avec un compte Steam."
    echo "▶️  cd ~/rust-server && ./start.sh"
fi