#!/usr/bin/env bash
# Tolga Erok - 27-3-2025
# Dependency Checker for my LinuxTweakTray App

# dependencies
needed_packages=("python3" "python3-pyqt6" "systemd")

# detect OS
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# check if a package is installed
is_installed() {
    case "$DISTRO" in
    fedora | rhel | rocky | almalinux)
        rpm -q "$1" &>/dev/null
        ;;
    arch | manjaro | Biglinux) 
        pacman -Q "$1" &>/dev/null
        ;;
    debian | ubuntu | pop | linuxmint)
        dpkg -l "$1" &>/dev/null
        ;;
    *)
        return 1
        ;;
    esac
}

# install missing packages
install_packages() {
    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo "✔️ All dependencies are installed."
        exit 0
    fi

    echo -e "\n⚠️ Missing dependencies: ${missing_packages[*]}"

    case "$DISTRO" in
    fedora | rhel | rocky | almalinux)
        install_command="sudo dnf install -y ${missing_packages[*]}"
        ;;
    arch | manjaro | Biglinux) # BigLinux is now supported under the Arch case
        install_command="sudo pacman -S --noconfirm ${missing_packages[*]}"
        ;;
    debian | ubuntu | pop | linuxmint)
        install_command="sudo apt install -y ${missing_packages[*]}"
        ;;
    *)
        echo "❌ Unsupported distro. Install manually: ${missing_packages[*]}"
        exit 1
        ;;
    esac

    read -rp "Do you want to install missing packages? (y/N): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        eval "$install_command"
    else
        echo "❌ Dependencies not installed. Exiting."
        exit 1
    fi
}

# main
DISTRO=$(detect_distro)
echo "🔍 Detected system: ${DISTRO^}"

# check if systemctl is available
if ! command -v systemctl &>/dev/null; then
    echo "❌ systemctl is missing! Ensure you are running a systemd-based system."
    exit 1
fi

# check missing packages
missing_packages=()
for pkg in "${needed_packages[@]}"; do
    if ! is_installed "$pkg"; then
        missing_packages+=("$pkg")
    fi
done

install_packages
echo -e "\n✅ All dependencies are now installed."
