#!/bin/bash

set -e

echo "🔧 Starting Arch development environment setup..."

# ----------------------------------------
# 1. Check and install yay
# ----------------------------------------

sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    echo "📦 yay is not installed. Installing..."
    sudo pacman -S --needed --noconfirm git base-devel

    tempdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tempdir/yay"
    (cd "$tempdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tempdir"
else
    echo "✅ yay is already installed."
fi

yay -Syu --noconfirm

# ----------------------------------------
# 2. Read package lists
# ----------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PACMAN_PACKAGES=()
AUR_PACKAGES=()

if [ -f ./pacman.txt ]; then
    mapfile -t PACMAN_PACKAGES < ./pacman.txt
fi

if [ -f ./aur.txt ]; then
    mapfile -t AUR_PACKAGES < ./aur.txt
fi

# ----------------------------------------
# 3. Install pacman packages
# ----------------------------------------
echo "📦 Installing pacman packages..."
for pkg in "${PACMAN_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        sudo pacman -S --noconfirm "$pkg"
    else
        echo "✅ $pkg is already installed."
    fi
done

# ----------------------------------------
# 4. Install AUR packages
# ----------------------------------------
echo "📦 Installing AUR packages..."
for pkg in "${AUR_PACKAGES[@]}"; do
    if ! yay -Qq "$pkg" &>/dev/null; then
        yay -S --noconfirm "$pkg"
    else
        echo "✅ $pkg is already installed."
    fi
done

# ----------------------------------------
# 5. Remove old configs
# ----------------------------------------
echo "🧹 Removing existing config files..."

TARGETS=(
    "$HOME/.bashrc"
    "$HOME/.config"
)

for target in "${TARGETS[@]}"; do
    if [ -e "$target" ]; then
        echo "⚠️  Deleting: $target"
        rm -rf "$target"
    fi
done

# mkdir -p "$HOME/.config"

# ----------------------------------------
# 6. Apply dotfiles with stow
# ----------------------------------------
echo "🔗 Setting up symbolic links for dotfiles..."
cd "$SCRIPT_DIR/dotfiles"

for dir in */; do
    stow -v --restow -t "$HOME" "${dir%/}"
done
cd

# ----------------------------------------
# Setup ufw
# ----------------------------------------
echo "Setting up ufw..."
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# ----------------------------------------
# Setup ly
# ----------------------------------------
echo "Setting up ly..."
sudo systemctl enable ly.service
sudo systemctl start ly.service

echo "✅ Setup complete!"
cd
