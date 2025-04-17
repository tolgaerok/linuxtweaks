#!/bin/bash
# Tolga Erok
# 11/4/25

VERSION="4.9"
VERSION_URL="https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/SYSTEMD_RELATED/AUTO_FLATPAK_UPDATER/version.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 🔥 fetch the latest version from my GitHub
get_latest_version() {
    curl -sL "$VERSION_URL" | tr -d '\r'
}

# 🎯 compare versions 🔥
is_outdated() {
    local current=$1
    local latest=$2
    [[ "$(printf '%s\n' "$current" "$latest" | sort -V | head -n1)" != "$latest" ]]
}

# 🎯 skip version check if told to 🔥
if [ "$1" == "--skip-version" ]; then
    shift
    SKIP_VERSION_CHECK="yes"
fi

if [ "$1" == "--version" ] && [ "$SKIP_VERSION_CHECK" != "yes" ]; then
    latest_version=$(get_latest_version)

    if is_outdated "$VERSION" "$latest_version"; then
        echo -e "${YELLOW}[ ❌ ] Your version ($VERSION) is outdated. Latest is $latest_version.${NC}"
        echo -ne "${YELLOW}\nWould you like to download and run the latest installer script now? (y/n): ${NC}"
        read -r answer
        if [[ "$answer" == [Yy]* ]]; then
            TMP_SCRIPT="/tmp/tolga-flatpak-updater-installer.sh"
            echo -e "${GREEN}[+] Downloading the latest installer to $TMP_SCRIPT...${NC}"
            curl -sL "https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/SYSTEMD_RELATED/AUTO_FLATPAK_UPDATER/tolga-flatpak-updater-installer.sh" -o "$TMP_SCRIPT"
            chmod +x "$TMP_SCRIPT"
            echo -e "${GREEN}[+] Running the installer...${NC}"
            bash "$TMP_SCRIPT"
            rm -f "$TMP_SCRIPT"
            exit 0
        else
            echo -e "${YELLOW}[!] Update skipped by user.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}[ ✔ ] You are using the latest version ($VERSION).${NC}"
        exit 0
    fi
fi

# varibles
unit_dir="$HOME/.config/systemd/user"
unit_dir_root="/etc/systemd/system"
service_file="$unit_dir/tolga-flatpak.service"
timer_file="$unit_dir/tolga-flatpak.timer"
wake_file="$unit_dir_root/tolga-flatpak-wake.service"
failed_service_file="$unit_dir/tolga-flatpak-failed-notify.service"
help_URL="https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/SYSTEMD_RELATED/AUTO_FLATPAK_UPDATER/help.txt"
help_dir="$unit_dir"
icon_URL="https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/images/LinuxTweak.png"
icon_dir="/usr/local/bin/LinuxTweaks/images"
icon_path="$icon_dir/LinuxTweak.png"
current_user=$(whoami)

# ---- Flatpak Theming Tweaks - LinuxTweaks (Tolga)  ----
flatpak override --user --env=USE_POINTER_VIEWPORT=1
flatpak override --user --filesystem=xdg-config/gtk-4.0:ro
flatpak override --user --unset-env=QT_QPA_PLATFORMTHEME
sudo timedatectl set-ntp true

# === show Usage (BETA) ===
# i.e     ./example-installer.sh install
# i.e     ./example-installer.sh remove
usage() {
    echo "Usage: $0 {install|remove}"
    exit 1
}

# === install Function ===
install_service() {
    echo -e "${GREEN}[+] Installing Tolga's Flatpak updater...\n ${NC}"

    mkdir -p "$unit_dir"
    mkdir -p "$icon_dir"

    echo -e "${GREEN}[+] Downloading help file...\n${NC}"
    wget -O "$help_dir/help.txt" "$help_URL"
    chmod 644 "$help_dir/help.txt"
    sudo chown "$USER:$USER" "$icon_path" "$help_dir/help.txt"

    echo -e "${GREEN}[+] Downloading icon...\n ${NC}"
    wget -O "$icon_path" "$icon_URL"
    sudo chmod 644 "$icon_path"

    # create service
    cat <<EOF >"$service_file"
[Unit]
Description=Tolga's Flatpak Automatic Update and Notification VER: 5.0
Documentation=file:///home/tolga/.config/systemd/user/help.txt
OnFailure=tolga-flatpak-failed-notify.service
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecCondition=/bin/bash -c '[[ "$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Metered | cut -c 3-)" == @(2|4) ]]'
ExecStart=/bin/bash -c '/usr/bin/notify-send "" "🌐  Checking for flatpak cruft" --app-name="🔧  Flatpak Maintenance" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png -u NORMAL && /usr/bin/flatpak --system uninstall --unused -y --noninteractive && sleep 5 && /usr/bin/notify-send "" "📡  Checking for flatpak UPDATES" --app-name="📡  Flatpak Updater" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png -u NORMAL && /usr/bin/flatpak --system update -y --noninteractive && sleep 5 && /usr/bin/notify-send "" "💻  Checking and repairing Flatpaks" --app-name="🔧  Flatpak Repair Service" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png -u NORMAL && /usr/bin/flatpak --system repair && sleep 5 && /usr/bin/notify-send "Flatpaks checked, fixed and updated" "✅  Your computer is ready!" --app-name="💻  Flatpak Update Service" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png -u NORMAL'


Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=0

# Watchdog & safety
TimeoutStartSec=15min
TimeoutStopSec=30s
TimeoutStopFailureMode=kill
EOF

    # create failed service
    cat <<EOF >"$failed_service_file"
[Unit]
Description=Flatpak Update Failure Notification VER: 5.0

[Service]
Type=oneshot
ExecStart=/usr/bin/notify-send "❌ Flatpak Autoupdate Failed" "Please check your flatpak service logs." --app-name="Flatpak Fail" -i dialog-error -u CRITICAL
EOF

    # create timer
    cat <<EOF >"$timer_file"
[Unit]
Description=Run Tolga's Flatpak Update Script daily VER: 5.0

[Timer]
# OnCalendar=daily
OnBootSec=5min
RandomizedDelaySec=10min
Persistent=true
Unit=tolga-flatpak.service

[Install]
WantedBy=timers.target
EOF

    # create wake
    cat <<EOF >"$wake_file"
[Unit]
Description=Trigger user flatpak update after resume VER: 5.0
After=suspend.target

[Service]
Type=oneshot
# ExecStart=/bin/bash -c 'su - "$current_user" -c "systemctl --user start tolga-flatpak.service"'
ExecStart=/bin/bash -c 'su - "$USER" -c "systemctl --user start tolga-flatpak.service"'


[Install]
WantedBy=suspend.target
EOF

    chmod 755 "$service_file" "$timer_file"
    chmod 644 "$failed_service_file"

    echo -en "${YELLOW}[+] Enabling linger and reloading systemd...standby....\n ${NC}"

    sudo loginctl enable-linger "$current_user"

    # systemctl --user daemon-reexec
    systemctl --user daemon-reload
    systemctl --user enable --now tolga-flatpak.timer

    sudo systemctl enable tolga-flatpak-wake.service
    sudo systemctl start tolga-flatpak-wake.service

    systemctl --user start tolga-flatpak.timer
    # systemctl --user start tolga-flatpak-failed-notify.service
    systemctl --user start tolga-flatpak.service
    systemctl --user status tolga-flatpak-failed-notify.service --no-pager
    systemctl --user status tolga-flatpak.service --no-pager
    # systemctl --user daemon-reload

    echo -en "${YELLOW}[+] Timer status:\n ${NC}"
    # systemctl --user list-timers | grep tolga
    systemctl --user list-timers tolga-flatpak.timer
    echo -e "${GREEN}=== Tolga's Auto Flatpak Updater installed ===${NC}"
    sleep 5
}

# === remove Function ===
remove_service() {
    echo -e "${RED}\n[-] Removing Tolga's Flatpak updater...\n${NC}"

    # Stop and disable user-level services
    systemctl --user disable --now \
        tolga-flatpak.timer \
        tolga-flatpak.service \
        tolga-flatpak-failed-notify.service

    # Stop and disable the wake service (system-level)
    sudo systemctl disable --now tolga-flatpak-wake.service

    # Reload systemd
    systemctl --user daemon-reload
    sudo systemctl daemon-reexec

    echo -e "${RED}\n[-] Removing systemd unit files...\n${NC}"
    rm -f "$service_file" "$timer_file" "$failed_service_file"
    sudo rm -f "$wake_file"

    # Optionally remove icon and help file
    # sudo rm -f "$icon_path"
    # rm -f "$help_dir/help.txt"
    # sudo rmdir --ignore-fail-on-non-empty "$icon_dir"

    echo -e "${RED}\n[-] Tolga's updater has been fully removed.\n${NC}"

    sleep 5
}

# === Entry Point ===
# i.e     ./example-installer.sh install
# i.e     ./example-installer.sh remove
case "$1" in
install)
    install_service
    ;;
remove)
    remove_service
    ;;
*)
    usage
    ;;
esac

# === Menu ===
while true; do
    clear
    echo -e ""
    echo -e "${GREEN}=== Tolga's Auto Flatpak Updater v$VERSION ===${NC}"
    echo -e "${GREEN}1)${YELLOW} Install${NC}"
    echo -e "${GREEN}2)${YELLOW} Remove${NC}"
    echo -e "${RED}3) Exit${NC}"
    echo -en "${YELLOW}Choose an option [1-3]: ${NC}"
    read -r choice

    case "$choice" in
    1)
        install_service
        ;;
    2)
        remove_service
        ;;
    3)
        clear
        echo -e "${RED}\n[+] ===============      TIMERS    ======================= [+]\n${NC}"
        systemctl --user list-timers tolga-flatpak.timer
        echo -e "${RED}\n[+] =============== SERVICE STATUS ======================= [+]\n${NC}"
        systemctl --user status tolga-flatpak.service --no-pager
        echo -e "${RED}\n[+] ============================================== [+]\n${NC}"
        systemctl --user status tolga-flatpak-failed-notify.service --no-pager
        echo -e "${RED}\n[+] ============================================== [+]\n${NC}"
        echo -e "${RED}\nGoodbye and thankyou for using Tolga's LinuxTweaks flatpak autoupdater\n${NC}"

        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option, try again.${NC}"
        ;;
    esac
done
