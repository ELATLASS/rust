#!/bin/bash
# Build + run the Maghribi API (Rust/Axum) in a GitHub Codespace
set -e

echo "🦀 Installing Rust toolchain..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

echo "🔨 Building release binary..."
cd "$(dirname "$0")"
cargo build --release

echo "🚀 Starting API on :3000 (Codespace forwards this port)..."
exec ./target/release/maghribi-api
