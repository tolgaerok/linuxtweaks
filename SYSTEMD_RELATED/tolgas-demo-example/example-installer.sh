#!/bin/bash
# Tolga Erok
# 11/4/25
# VERSION 3.0a

# exit if script is run as root or with sudo
if [ "$(id -u)" -eq 0 ]; then
    echo -e "\033[0;31m[!] Do NOT run this script as root or with sudo.\033[0m"
    echo -e "\033[0;33m[!] Please run as a regular user. Sudo will be used internally only when needed.\033[0m"
    exit 1
fi

# === configuration ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
unit_dir="$HOME/.config/systemd/user"
service_file="$unit_dir/tolga-flatpak.service"
failed_service_file="$unit_dir/tolga-flatpak-failed-notify.service"
timer_file="$unit_dir/tolga-flatpak.timer"
icon_dir="/usr/local/bin/LinuxTweaks/images"
help_dir="$unit_dir"
help_file="$help_dir/help.txt"
icon_path="$icon_dir/LinuxTweak.png"
icon_URL="https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/images/LinuxTweak.png"
help_URL="https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/SYSTEMD_RELATED/tolgas-demo-example/help.txt"
current_user=$(whoami)

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
    sudo wget -O "$unit_dir" "$icon_URL"
    sudo mkdir -p "$icon_dir"

    # Download help file
    echo -e "${GREEN}[+] Downloading help file...\n${NC}"
    wget -O "$help_dir/help.txt" "$help_URL"
    chmod 644 "$help_dir/help.txt"

    # create service
    cat <<EOF >"$service_file"
[Unit]
Description=Tolga's Flatpak Automatic Update and Notification VER:2.0A
Documentation=file://$unit_dir/help.txt
OnFailure=tolga-flatpak-failed-notify.service
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecCondition=/bin/bash -c '[[ "\$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Metered | cut -c 3-)" == @(2|4) ]]'
ExecStart=/bin/bash -c "/usr/bin/notify-send \"\" \"🌐  Checking for flatpak cruft\" --app-name=\"🔧  Flatpak Maintenance\" -i $icon_path -u NORMAL && /usr/bin/flatpak --system uninstall --unused -y --noninteractive && sleep 5 && /usr/bin/notify-send \"\" \"📡  Checking for flatpak UPDATES\" --app-name=\"📡  Flatpak Updater\" -i $icon_path -u NORMAL && /usr/bin/flatpak --system update -y --noninteractive && sleep 5 && /usr/bin/notify-send \"\" \"💻  Checking and repairing Flatpaks\" --app-name=\"🔧  Flatpak Repair Service\" -i $icon_path -u NORMAL && /usr/bin/flatpak --system repair && sleep 5 && /usr/bin/notify-send \"Flatpaks checked, fixed and updated\" \"✅  Your computer is ready!\" --app-name=\"💻  Flatpak Update Service\" -i $icon_path -u NORMAL"

Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=0

# Watchdog & safety
TimeoutStartSec=15min
TimeoutStopSec=30s
TimeoutStopFailureMode=kill

StandardError=journal
StandardOutput=journal
SuccessExitStatus=0 3
EOF

    # create failed service
    cat <<EOF >"$failed_service_file"
[Unit]
Description=Flatpak Update Failure Notification

[Service]
Type=oneshot
ExecStart=/usr/bin/notify-send "❌ Flatpak Autoupdate Failed" "Please check your flatpak service logs." --app-name="Flatpak Fail" -i dialog-error -u CRITICAL
EOF

    # create timer
    cat <<EOF >"$timer_file"
[Unit]
Description=Run Tolga's Flatpak Update Script daily

[Timer]
OnCalendar=daily
RandomizedDelaySec=10min
Persistent=true
Unit=tolga-flatpak.service

[Install]
WantedBy=timers.target
EOF

    chmod 644 "$service_file" "$timer_file"

    echo -e "${GREEN}[+] Downloading icon...\n ${NC}"
    sudo wget -O "$icon_path" "$icon_URL"

    sudo chmod 644 "$icon_path"

    echo -en "${YELLOW}[+] Enabling linger and reloading systemd...standby....\n ${NC}"
    sudo loginctl enable-linger "$current_user"
    systemctl --user daemon-reexec
    systemctl --user daemon-reload
    systemctl --user enable --now tolga-flatpak.timer
    systemctl --user start tolga-flatpak-failed-notify.service
    systemctl --user start tolga-flatpak.service
    systemctl --user status tolga-flatpak-failed-notify.service --no-pager
    systemctl --user status tolga-flatpak.service --no-pager

    echo -en "${YELLOW}[+] Timer status:\n ${NC}"
    # systemctl --user list-timers | grep tolga
    systemctl --user list-timers tolga-flatpak.timer
    echo -e "${GREEN}=== Tolga's Auto Flatpak Updater installed ===${NC}"
    sleep 5
}

# === remove Function ===
remove_service() {
    echo -e "${RED}\n[-] Removing Tolga's Flatpak updater...\n ${NC}"

    systemctl --user disable --now tolga-flatpak.timer tolga-flatpak.service tolga-flatpak-failed-notify.service
    systemctl --user daemon-reload

    echo -e "${RED}\n[-] Removing systemd unit files...\n ${NC}"
    rm -f "$service_file" "$timer_file"

    # echo "[-] Optionally removing icon and directory..."
    # sudo rm -f "$icon_path"
    # sudo rmdir --ignore-fail-on-non-empty "$icon_dir"

    echo -e "${RED}\n[-] Tolga's updater has been fully removed.\n ${NC}"
    sleep 5
}

# === Menu ===
while true; do
    clear
    echo -e ""
    echo -e "${GREEN}=== Tolga's Auto Flatpak Updater ===${NC}"
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
