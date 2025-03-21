#!/bin/bash
# Author: Tolga Erok
# Date: 21/3/2025
# Version: 3.2

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

# download my icon and move to /usr/local/bin/tolga-profile-5.png
sudo wget -O /usr/local/bin/tolga-profile-5.png https://github.com/tolgaerok/linuxtweaks/raw/main/modules/docs/images/md-pics/tolga-profile-5.png
sudo chmod 644 /usr/local/bin/tolga-profile-5.png

# Check if flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "Error: Flatpak is not installed. Please install Flatpak to proceed."
    exit 1
fi

# systemd service file
echo "[Unit]
Description=Tolga's Flatpak Automatic Update V3.2
Documentation=man:flatpak(1)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c ' \
export DISPLAY=:0; \
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; \
for i in {1..3}; do \
    /usr/bin/flatpak update -y && break || (echo "Retrying Flatpak update..." && sleep 10); \
done | tee /tmp/flatpak_update.log; \
if grep -q "Nothing to do" /tmp/flatpak_update.log; then \
    sudo -u tolga DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send --app-name="Checking Flatpaks for updates" -i /usr/local/bin/tolga-profile-5.png "Flatpak Update Status:" "No updates available"; \
else \
    sudo -u tolga DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send --app-name="Installing Flatpaks" -i /usr/local/bin/tolga-profile-5.png"Flatpak Update Status:" "Updates installed successfully"; \
fi

# systemctl daemon-reload && systemctl start tolga-flatpak-update.service && systemctl enable --now tolga-flatpak-update.timer && systemctl restart tolga-flatpak-update.timer && echo -e "\nFlatpak update service status:" && systemctl status tolga-flatpak-update.service --no-pager && echo -e "\nFlatpak update timer status:" && systemctl status tolga-flatpak-update.timer --no-pager && echo -e "\nNext scheduled Flatpak update timer:" && systemctl list-timers --no-pager | grep "tolga-flatpak-update"'" | tee "$SERVICE_FILE" >/dev/null

# systemd timer file
echo "[Unit]
Description=Tolga's Flatpak Automatic Update Trigger V3.2
Documentation=man:flatpak(1)
Wants=network-online.target
After=network-online.target suspend.target

[Timer]
OnBootSec=15s
# OnCalendar=*-*-* 00,06,12,18:00:00
# OnUnitActiveSec=6h
OnUnitActiveSec=3s
Persistent=true

[Install]
WantedBy=timers.target suspend.target" | tee "$TIMER_FILE" >/dev/null

# Reload systemd
systemctl daemon-reload
systemctl start tolga-flatpak-update.service
systemctl enable --now tolga-flatpak-update.timer
systemctl restart tolga-flatpak-update.timer

# status of both with no pager!
echo -e "\nFlatpak update service status:"
systemctl status tolga-flatpak-update.service --no-pager

echo -e "\nFlatpak update timer status:"
systemctl status tolga-flatpak-update.timer --no-pager

echo -e "\nNext scheduled Flatpak update timer:"
systemctl list-timers --no-pager | grep "tolga-flatpak-update"
