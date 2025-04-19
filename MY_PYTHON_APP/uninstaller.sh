#!/usr/bin/env bash

# Tolga Erok
# 27-3-2025
# Version: 1.0

# Uninstaller for LinuxTweaks
# curl -sL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/uninstaller.sh | sudo bash

# Config
app_dir="/usr/local/bin/LinuxTweaks"
app_executable="$app_dir/LinuxTweaks.py"
desktop_file="$HOME/.config/autostart/linuxtweaks.desktop"
sysmlink="/usr/local/bin/linuxtweaks"
tmp_clone_dir="$HOME/linuxtweaks"

# Move to a safe directory before deleting anything
cd ~ || exit 1

# kill process
echo "Stopping LinuxTweaks if running..."
pkill -f "$app_executable" 2>/dev/null && echo "✅ Process stopped." || echo "ℹ No running process found."

# remove system-wide files
echo "Removing application files..."
sudo rm -rf "$app_dir"

# remove symlink
if [ -L "$sysmlink" ] || [ -f "$sysmlink" ]; then
    echo "Removing symlink: $sysmlink"
    sudo rm -f "$sysmlink"
fi

# remove autostart entry
if [ -f "$desktop_file" ]; then
    echo "Removing autostart entry: $desktop_file"
    rm -f "$desktop_file"
fi

# remove cloned repo (if exists)
if [ -d "$tmp_clone_dir" ]; then
    echo "Removing temporary cloned repo: $tmp_clone_dir"
    rm -rf "$tmp_clone_dir"
fi

# remove desktop shortcut (if exists)
logged_in_user=$(logname 2>/dev/null || echo $SUDO_USER)
desktop_shortcut="/home/$logged_in_user/Desktop/linuxtweaks.desktop"
if [ -f "$desktop_shortcut" ]; then
    echo "Removing desktop shortcut: $desktop_shortcut"
    rm -f "$desktop_shortcut"
fi

echo "✅ LinuxTweaks successfully uninstalled."
