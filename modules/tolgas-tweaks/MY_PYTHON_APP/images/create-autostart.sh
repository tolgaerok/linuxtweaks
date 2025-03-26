#!/bin/bash
# Tolga Erok
# 26/3/2025

# config
local_dir="$HOME/.config/autostart"
desktop_file="$local_dir/linuxtweaks.desktop"

mkdir -p "$local_dir"

# .desktop file
cat <<EOL >"$desktop_file"
[Desktop Entry]
Type=Application
Exec=/usr/local/bin/linuxtweaks
Name=LinuxTweaks
Comment=LinuxTweaks Service Monitor by Tolga Erok
Icon=/usr/local/bin/LinuxTweaks/images/LinuxTweak.png
Terminal=false
X-GNOME-Autostart-enabled=true
EOL

# Make .desktop file executable
chmod +x "$desktop_file"
echo "LinuxTweaks has been added to autostart!"
