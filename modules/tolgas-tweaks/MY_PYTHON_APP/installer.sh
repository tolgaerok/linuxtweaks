#!/usr/bin/env bash
# Tolga Erok
# 27-3-2025
# Version: 2.0

# Dependency Checker, autostarter and installer with sysmlink for my LinuxTweakTray App

# Config
linuxtweaks_repo="https://github.com/tolgaerok/linuxtweaks.git"
tmp_clone_dir="$HOME/linuxtweaks"
app_dir="/usr/local/bin/LinuxTweaks"
app_executable="$app_dir/LinuxTweaks.py"
desktop_file="$HOME/.config/autostart/linuxtweaks.desktop"
sysmlink="/usr/local/bin/linuxtweaks"

# check dependencies are installed (DNF or Pacman)
install_dependencies() {
    local packages=("python3" "python3-pyqt6" "git")
    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            echo "Installing $pkg..."
            if command -v dnf &>/dev/null; then
                sudo dnf install -y "$pkg"
            elif command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm "$pkg"
            else
                echo "Unsupported package manager. Install $pkg manually."
                exit 1
            fi
        fi
    done
}

# clone or update the repo
setup_repo() {
    if [ -d "$tmp_clone_dir" ]; then
        echo "Updating repository..."
        git -C "$tmp_clone_dir" pull
    else
        echo "Cloning repository..."
        git clone "$linuxtweaks_repo" "$tmp_clone_dir"
    fi
}

# Copy LinuxTweaks folder from repo to local machine
deploy_app() {
    echo "Copying LinuxTweaks contents to $app_dir..."
    sudo mkdir -p "$app_dir"
    sudo cp -r "$tmp_clone_dir/modules/tolgas-tweaks/MY_PYTHON_APP/"* "$app_dir/"
    sudo chmod -R +x "$app_dir"
}

# create sysmlink (remove if one exists)
setup_sysmlink() {
    if [ -L "$sysmlink" ] || [ -f "$sysmlink" ]; then
        echo "Removing existing sysmlink: $sysmlink"
        sudo rm -f "$sysmlink"
    fi
    echo "Creating new sysmlink..."
    sudo ln -s "$app_executable" "$sysmlink"
}

# create .desktop file
setup_autostart() {
    mkdir -p "$(dirname "$desktop_file")"
    cat <<EOL >"$desktop_file"
[Desktop Entry]
Type=Application
Exec=$symlink
Name=LinuxTweaks
Comment=LinuxTweaks Service Monitor by Tolga Erok
Icon=$app_dir/images/LinuxTweak.png
Terminal=false
X-GNOME-Autostart-enabled=true
EOL
    chmod +x "$desktop_file"

    # Also copy .desktop file to the logged-in user's Desktop
    echo "📁 Copying .desktop file to Desktop..."
    cp "$desktop_file" "$desktop_shortcut"
    chmod +x "$desktop_shortcut"
}

# main menu
install_dependencies
setup_repo
deploy_app
setup_sysmlink
setup_autostart

echo "✅ LinuxTweaks installed, sysmlinked, and added to autostart."
