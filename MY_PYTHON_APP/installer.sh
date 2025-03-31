#!/usr/bin/env bash
# Tolga Erok
# 27-3-2025
# Version: 2.0

# Dependency Checker, autostarter and installer with symlink for my LinuxTweakTray App
# curl -sL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/installer.sh | sudo bash

# Config
app_dir="/usr/local/bin/LinuxTweaks"
app_executable="$app_dir/LinuxTweaks.py"
desktop_file="$HOME/.config/autostart/linuxtweaks.desktop"
linuxtweaks_repo="https://github.com/tolgaerok/linuxtweaks.git"
sysmlink="/usr/local/bin/linuxtweaks"
tmp_clone_dir="/tmp/linuxtweaks" # Clone into /tmp

# check dependencies are installed (DNF or Pacman)
install_dependencies() {
    if command -v dnf &>/dev/null; then
        packages=("python3" "python3-qt6" "git")
        install_cmd="sudo dnf install -y"
        check_cmd="dnf list installed"
    elif command -v pacman &>/dev/null; then
        packages=("python" "python-pyqt6" "git")
        install_cmd="sudo pacman -S --noconfirm"
        check_cmd="pacman -Q"
    else
        echo "Unsupported package manager. Install dependencies manually."
        exit 1
    fi

    for pkg in "${packages[@]}"; do
        if ! $check_cmd "$pkg" &>/dev/null; then
            echo "Installing $pkg..."
            $install_cmd "$pkg"
        else
            echo "$pkg is already installed."
        fi
    done
}

# clone or update the repo
setup_repo() {
    # Ensure the temp directory exists and is accessible
    sudo mkdir -p "$tmp_clone_dir"
    sudo chown -R "$USER:$USER" "$tmp_clone_dir"
    cd "$tmp_clone_dir" || {
        echo "❌ Failed to enter $tmp_clone_dir"
        exit 1
    }

    if [ -d "$tmp_clone_dir/.git" ]; then
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
    sudo cp -r "$tmp_clone_dir/MY_PYTHON_APP/"* "$app_dir/"
    sudo chmod -R +x "$app_dir"
}

# create sysmlink (remove if one exists)
setup_sysmlink() {
    if [ -L "$sysmlink" ] || [ -f "$sysmlink" ]; then
        echo "Removing existing symlink: $sysmlink"
        sudo rm -f "$sysmlink"
    fi
    echo "Creating new symlink..."
    sudo ln -s "$app_executable" "$sysmlink"
}

# setup autostart
setup_autostart() {
    mkdir -p "$(dirname "$desktop_file")"

    cat <<EOL >"$desktop_file"
[Desktop Entry]
Type=Application
Exec=$sysmlink
Name=LinuxTweaks
Comment=LinuxTweaks Service Monitor by Tolga Erok
Icon=$app_dir/images/LinuxTweak.png
Terminal=false
X-GNOME-Autostart-enabled=true
EOL
    chmod +x "$desktop_file"

    # Get the actual non-root user
    logged_in_user=$(logname 2>/dev/null || echo $SUDO_USER)
    logged_in_user_desktop="/home/$logged_in_user/Desktop"

    if [ -d "$logged_in_user_desktop" ]; then
        desktop_shortcut="$logged_in_user_desktop/linuxtweaks.desktop"
        echo "📁 Copying .desktop file to $logged_in_user_desktop..."
        sudo cp "$desktop_file" "$desktop_shortcut"
        sudo chmod +x "$desktop_shortcut"
        sudo chown "$logged_in_user:$logged_in_user" "$desktop_shortcut"
    else
        echo "⚠ Desktop directory ($logged_in_user_desktop) does not exist. Skipping desktop shortcut creation."
    fi
}

# run the app automatically after installation
run_app() {
    echo "🚀 Running LinuxTweaks..."
    # Ensure the app is run correctly in the background
    nohup python3 "$app_executable" >"$app_dir/linuxtweaks.log" 2>&1 &
}

# main menu
install_dependencies
setup_repo
deploy_app
setup_sysmlink
setup_autostart

# run my app after installation
run_app

echo "✅ LinuxTweaks installed, symlinked, and added to autostart."
