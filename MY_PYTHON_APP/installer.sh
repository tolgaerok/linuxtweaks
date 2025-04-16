#!/usr/bin/env bash
# Tolga Erok
# 27-3-2025
# Version: 4.0

# BUG FIX: 16/4/25 kill and then re run app after install to ensure proper execution

# Dependency Checker, autostarter, and installer with symlink for my LinuxTweakTray App
# curl -sL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/installer.sh | sudo bash

# Config
app_dir="/usr/local/bin/LinuxTweaks"
app_executable="$app_dir/LinuxTweaks.py"
desktop_file="$HOME/.config/autostart/linuxtweaks.desktop"
linuxtweaks_repo="https://github.com/tolgaerok/linuxtweaks.git"
sysmlink="/usr/local/bin/linuxtweaks"

# Clone into /tmp
tmp_clone_dir="/tmp/linuxtweaks"

install_dependencies() {
    if command -v dnf &>/dev/null; then
        packages=("python3" "git")
        install_cmd="sudo dnf install -y"
        check_cmd="dnf list installed"
    elif command -v pacman &>/dev/null; then
        packages=("python" "git" "python-pyqt6")
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

    # see if PyQt6 is installed, if not, install using pip3 (beta)
    if ! python3 -c "import PyQt6" &>/dev/null; then
        echo "PyQt6 not found. Installing via pip3..."

        # Install as the current user as my installer script is run as sudo
        if [ "$(id -u)" -eq 0 ]; then
            echo "Running as root. Installing PyQt6 for the current user..."
            # Install for the user using pip3
            su -c "python3 -m pip install --user PyQt6" $SUDO_USER
        else
            # Install as normal user
            python3 -m pip install --user PyQt6
        fi
    else
        echo "PyQt6 is already installed."
    fi
}

# clone and or update the repo
setup_repo() {
    # make sure the temp dir exists and is accessible
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

# copy LinuxTweaks folder from my repo to local machine
deploy_app() {
    echo "Copying LinuxTweaks contents to $app_dir..."
    sudo mkdir -p "$app_dir"
    sudo cp -r "$tmp_clone_dir/MY_PYTHON_APP/"* "$app_dir/"
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

# setup autostart
setup_autostart() {
    mkdir -p "$(dirname "$desktop_file")"

    cat <<EOL >"$desktop_file"
[Desktop Entry]
Type=Application
Exec=python3 $app_executable
Name=LinuxTweaks
Comment=LinuxTweaks Service Monitor by Tolga Erok
Icon=$app_dir/images/LinuxTweak.png
Terminal=false
X-GNOME-Autostart-enabled=true
EOL
    chmod +x "$desktop_file"

    # get the actual non-root user
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

run_app() {
    echo "🚀 Running LinuxTweaks..."

    # start the app in the background
    nohup python3 "$app_executable" >/dev/null 2>&1 &
    sleep 5

    # kill it
    pkill -f "$app_executable"
    sleep 1

    # restart the app
    # nohup python3 "$app_executable" >/dev/null 2>&1 &
    python3 "$app_executable" &
}

# Main menu
install_dependencies
setup_repo
deploy_app
setup_sysmlink
setup_autostart

# run the app after installation
run_app

echo "✅ LinuxTweaks installed, symlinked, added to autostart, and is now running."
