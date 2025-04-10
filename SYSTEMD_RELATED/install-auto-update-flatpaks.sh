#!/bin/bash
# Author: Tolga Erok
# Date: 21/3/2025
# Version: 6.1

# BUG FIX:
# ✅ Fixed notify-send command

# SCOPE: (for testing purposes its set to 3secs)
# Run 15 seconds after boot.
# Run at 00:00, 06:00, 12:00, 18:00.
# Run every 6 hours after it last ran.
# Check for updates after waking from suspend.

# service and timer file locations
service_file="/etc/systemd/system/tolga-flatpak-update.service"
timer_file="/etc/systemd/system/tolga-flatpak-update.timer"

# Run as root check
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

# who is the logged-in user?
if [ -n "$SUDO_USER" ]; then
    user="$SUDO_USER" # When run with sudo, get the original user
else
    user=$(who | awk '{print $1}' | head -n 1) # Get the first user from 'who' command if run as root
fi

# download LinuxTweaks icon
sudo mkdir -p /usr/local/bin/LinuxTweaks/images
sudo wget -O /usr/local/bin/LinuxTweaks/images/LinuxTweak.png https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/images/LinuxTweak.png
sudo chmod 644 /usr/local/bin/LinuxTweaks/images/LinuxTweak.png

# is Flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "Error: Flatpak is not installed. Please install Flatpak to proceed."
    exit 1
fi

# create my systemd tolga-flatpak-update.service file
cat >"$service_file" <<EOF
[Unit]
Description=Tolga's Flatpak Automatic Update V6.1
Documentation=man:flatpak(1)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c ' \
export DISPLAY=:0; \
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; \
for i in {1..3}; do \
    /usr/bin/flatpak --system uninstall --unused -y --noninteractive && \
    notify-send --app-name="🔧 Checking Flatpaks cruft" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png "Flatpak cruft Status" "✅ Cruft maintained" && \
    /usr/bin/flatpak --system update -y --noninteractive && \
    notify-send --app-name="📡 Checking Flatpaks Updates" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png "Flatpak Update Status" "✅ Updates checked" && \
    /usr/bin/flatpak --system repair -y --noninteractive && \
    notify-send --app-name="🔧 Repairing Flatpaks" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png "Flatpak Repair Status" "✅ Repairs done" && \
    break || (echo "Retrying Flatpak update..." && sleep 10); \
done | tee /tmp/flatpak_update.log; \
if grep -q "Nothing unused to uninstall" /tmp/flatpak_update.log && ! grep -q "update complete" /tmp/flatpak_update.log; then \
    sudo -u $SUDO_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send --app-name="📡 Checking Flatpaks for updates" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png "Flatpak Update Status" "✅ No updates available or no packages to clean."; \
elif grep -q "Nothing to do" /tmp/flatpak_update.log; then \
    sudo -u $SUDO_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send --app-name="🌐 Checking Flatpaks for updates" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png "Flatpak Update Status" "✅ No updates available"; \
else \
    sudo -u $SUDO_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send --app-name="💻 Installing Flatpaks" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png "Flatpak Update Status" "✅ Updates installed successfully"; \
fi'

TimeoutStopFailureMode=abort
Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=0

[Install]
WantedBy=multi-user.target
EOF

# create my tolga-flatpak-update.timer file
cat >"$timer_file" <<EOF
[Unit]
Description=Tolga's Flatpak Automatic Update Trigger V6.1
Documentation=man:flatpak(1)
Wants=network-online.target
After=network-online.target suspend.target

[Timer]
OnBootSec=15s
# OnCalendar=*-*-* 00,06,12,18:00:00
# OnUnitActiveSec=6h
OnUnitActiveSec=3s
Persistent=true
Unit=tolga-flatpak-update.service

[Install]
WantedBy=timers.target suspend.target default.target
EOF

# load up the service && timer
echo -e "\n\033[1;33mFlatpak service && timer being initiated, standby\033[0m\n"
echo ""

systemctl daemon-reload
systemctl start tolga-flatpak-update.service
systemctl enable --now tolga-flatpak-update.timer
systemctl restart tolga-flatpak-update.timer

# show status
echo -e "\nFlatpak update service status:"
systemctl status tolga-flatpak-update.service --no-pager

echo -e "\nFlatpak update timer status:"
systemctl status tolga-flatpak-update.timer --no-pager

echo -e "\nNext scheduled Flatpak update timer:"
systemctl list-timers --no-pager | grep "tolga-flatpak-update"
