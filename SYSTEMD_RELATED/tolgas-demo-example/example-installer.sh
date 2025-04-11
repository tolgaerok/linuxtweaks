#!/bin/bash
# Tolga Erok
# 11/4/25
# VERSION 3.0a

# === configuration ===
unit_dir="$HOME/.config/systemd/user"
service_file="$unit_dir/tolga.service"
timer_file="$unit_dir/tolga.timer"
icon_dir="/usr/local/bin/LinuxTweaks/images"
icon_path="$icon_dir/LinuxTweak.png"
icon_URL="https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/images/LinuxTweak.png"
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
    echo "[+] Installing Tolga's Flatpak updater..."

    mkdir -p "$unit_dir"
    sudo mkdir -p "$icon_dir"

    # create service
    cat <<EOF >"$service_file"
[Unit]
Description=Tolga's Flatpak Automatic Update and Notification VER:2.0A
Documentation=man:flatpak(1)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecCondition=/bin/bash -c '[[ "\$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Metered | cut -c 3-)" == @(2|4) ]]'
ExecStart=/bin/bash -c '
/usr/bin/notify-send "Flatpaks Uninstall" "🌐  Checking for flatpak cruft" --app-name="🔧  Flatpak Maintenance" -i $icon_path -u NORMAL
/usr/bin/flatpak --system uninstall --unused -y --noninteractive
sleep 5
/usr/bin/notify-send "Flatpaks Updates" "📡  Checking for flatpak UPDATES" --app-name="📡  Flatpak Updater" -i $icon_path -u NORMAL
/usr/bin/flatpak --system update -y --noninteractive
sleep 5
/usr/bin/notify-send "Flatpaks Repair" "💻  Checking and repairing Flatpaks" --app-name="🔧  Flatpak Repair Service" -i $icon_path -u NORMAL
/usr/bin/flatpak --system repair
sleep 5
/usr/bin/notify-send "Flatpaks Updated" "✅  Your computer is ready!" --app-name="💻  Flatpak Update Service" -i $icon_path -u NORMAL
'

TimeoutStopFailureMode=abort
Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=0
EOF

    # create timer
    cat <<EOF >"$timer_file"
[Unit]
Description=Run Tolga's Flatpak Update Script daily

[Timer]
OnBootSec=10min
OnUnitActiveSec=5min
Persistent=true
Unit=tolga.service

[Install]
WantedBy=timers.target
EOF

    chmod 644 "$service_file" "$timer_file"

    echo "[+] Downloading icon..."
    sudo wget -O "$icon_path" "$icon_URL"
    sudo chmod 644 "$icon_path"

    echo "[+] Enabling linger and reloading systemd..."
    sudo loginctl enable-linger "$current_user"
    systemctl --user daemon-reexec
    systemctl --user daemon-reload
    systemctl --user enable --now tolga.timer
    systemctl --user start tolga.service

    echo "[+] Timer status:"
    systemctl --user list-timers | grep tolga
}

# === remove Function ===
remove_service() {
    echo "[-] Removing Tolga's Flatpak updater..."

    systemctl --user disable --now tolga.timer tolga.service
    systemctl --user daemon-reload

    echo "[-] Removing systemd unit files..."
    rm -f "$service_file" "$timer_file"

    echo "[-] Optionally removing icon and directory..."
    sudo rm -f "$icon_path"
    sudo rmdir --ignore-fail-on-non-empty "$icon_dir"

    echo "[-] Tolga's updater has been fully removed."
}

# === Menu ===
while true; do
    echo ""
    echo "=== Tolga's Auto Flatpak Updater ==="
    echo "1) Install"
    echo "2) Remove"
    echo "3) Exit"
    read -rp "Choose an option [1-3]: " choice

    case "$choice" in
    1)
        install_service
        ;;
    2)
        remove_service
        ;;
    3)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid option, try again."
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