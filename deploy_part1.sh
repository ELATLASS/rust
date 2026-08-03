#!/bin/bash
# Part 1: Install SteamCMD and try to download Rust server
# This script runs in background to avoid SSH session issues

echo "🚀 Part 1: Installation de SteamCMD et téléchargement du serveur Rust..."

# Install dependencies
sudo apt-get update -qq
sudo apt-get install -y -qq lib32gcc-s1 wget unzip curl > /dev/null 2>&1
echo "  ✅ Dépendances installées"

# Create directories
mkdir -p ~/rust-server/steamcmd
mkdir -p ~/rust-server/oxide/plugins
mkdir -p ~/rust-server/oxide/config
mkdir -p ~/rust-server/cfg
echo "  ✅ Dossiers créés"

# Download SteamCMD
cd ~/rust-server/steamcmd
if [ ! -f "steamcmd.sh" ]; then
    wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xzf steamcmd_linux.tar.gz
fi
echo "  ✅ SteamCMD installé"

# Try to download Rust server (will fail without Steam license)
echo "🎮 Téléchargement du serveur Rust..."
cd ~/rust-server/steamcmd
# Run in a subshell with disown to completely detach
(
    ./steamcmd.sh +login anonymous +force_install_directory ~/rust-server +app_update 258100 validate +quit
) > /tmp/steamcmd_rust.log 2>&1
echo "  SteamCMD terminé (exit code: $?)"

# Check if Rust was installed
if [ -f ~/rust-server/RustServer.x86_64 ]; then
    echo "  ✅ Serveur Rust téléchargé"
else
    echo "  ⚠️  Serveur Rust non téléchargé (licence Steam requise)"
fi

echo "✅ Part 1 terminé"