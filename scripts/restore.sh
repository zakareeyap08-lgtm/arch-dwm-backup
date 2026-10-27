
#!/usr/bin/env bash

set -euo pipefail

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "===================================="
echo " Arch Linux + dwm Restoration"
echo "===================================="

if [[ $EUID -eq 0 ]]; then
    echo "Do not run this script as root."
    exit 1
fi

echo
echo "This script will:"
echo "1. Install official Arch packages"
echo "2. Rebuild dwm, dmenu, st and slstatus"
echo "3. Restore selected desktop configurations"
echo "4. Restore your wallpaper and autostart script"
echo
echo "It will NOT automatically restore AUR packages,"
echo "enable system services or restore personal data."
echo

read -r -p "Continue? [y/N] " answer

if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Restoration cancelled."
    exit 0
fi

# Install official packages
echo
echo "[1/4] Installing official packages..."

if [[ -s "$BACKUP_DIR/packages/official-explicit.txt" ]]; then
    sudo pacman -Syu --needed
    sudo pacman -S --needed - \
        < "$BACKUP_DIR/packages/official-explicit.txt"
else
    echo "No official package list found."
    exit 1
fi

# Rebuild suckless programs
echo
echo "[2/4] Rebuilding suckless programs..."

for program in dwm dmenu st slstatus; do
    SOURCE_DIR="$BACKUP_DIR/suckless/$program"

    if [[ ! -f "$SOURCE_DIR/Makefile" ]]; then
        echo "Missing Makefile for $program"
        exit 1
    fi

    echo "Building $program..."

    (
        cd "$SOURCE_DIR"
        make clean
        make
        sudo make install
    )
done

# Restore desktop configurations
echo
echo "[3/4] Restoring desktop configurations..."

mkdir -p "$HOME/.config"

if [[ -d "$BACKUP_DIR/dotfiles/config" ]]; then
    rsync -av \
        "$BACKUP_DIR/dotfiles/config/" \
        "$HOME/.config/"
fi

if [[ -d "$BACKUP_DIR/dotfiles/home" ]]; then
    rsync -av \
        "$BACKUP_DIR/dotfiles/home/" \
        "$HOME/"
fi

# Restore wallpaper
echo
echo "[4/4] Restoring wallpaper..."

mkdir -p "$HOME/wallpapers"

if [[ -f "$BACKUP_DIR/assets/wallpapers/abstract-dark.png" ]]; then
    cp -a \
        "$BACKUP_DIR/assets/wallpapers/abstract-dark.png" \
        "$HOME/wallpapers/"
fi

echo
echo "===================================="
echo " Restoration steps completed"
echo "===================================="
echo
echo "Still to do:"
echo "- Review and reinstall AUR packages"
echo "- Enable required systemd services"
echo "- Restore personal files from separate backup"
echo "- Configure and start your X11 session"
echo "- Check hardware-specific settings"
echo
echo "You may need to log out and back in."
