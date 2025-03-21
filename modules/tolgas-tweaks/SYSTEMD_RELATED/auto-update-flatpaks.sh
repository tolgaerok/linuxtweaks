#!/bin/bash
# Author: Tolga Erok
# Date: 21/3/2025
# Version: 3.0

# SCOPE:
# Run 15 seconds after boot.
# Run at 00:00, 06:00, 12:00, 18:00.
# Run every 6 hours after it last ran.
# Check for updates after waking from suspend.

# Configs
SERVICE_FILE="/etc/systemd/system/tolga-flatpak-update.service"
TIMER_FILE="/etc/systemd/system/tolga-flatpak-update.timer"

# run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

# Check if flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "Error: Flatpak is not installed."
    exit 1
fi

# systemd service file
echo "[Unit]
Description=Tolga's Flatpak Automatic Update V3.0
Documentation=man:flatpak(1)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr//bin/flatpak update -y
" | tee "$SERVICE_FILE" >/dev/null

# systemd timer file
echo "[Unit]
Description=Tolga's Flatpak Automatic Update Trigger V3.0
Documentation=man:flatpak(1)
Wants=network-online.target
After=network-online.target suspend.target

[Timer]
OnBootSec=15s
OnCalendar=*-*-* 00,06,12,18:00:00
OnUnitActiveSec=6h
Persistent=true

[Install]
WantedBy=timers.target suspend.target" | tee "$TIMER_FILE" >/dev/null

# Reload systemd
systemctl daemon-reload
systemctl enable --now tolga-flatpak-update.timer
systemctl restart tolga-flatpak-update.timer  # Ensure changes apply

# status of both with no pager!
echo -e "\nFlatpak update service status:"
systemctl status tolga-flatpak-update.service --no-pager

echo -e "\nFlatpak update timer status:"
systemctl status tolga-flatpak-update.timer --no-pager

echo -e "\nNext scheduled Flatpak update:"
systemctl list-timers --no-pager | grep tolga-flatpak-update
