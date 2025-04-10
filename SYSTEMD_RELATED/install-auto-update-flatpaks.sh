#!/bin/bash
# Author: Tolga Erok
# Date: 21/3/2025
# Version: 5.1

# BUG FIX:
# ✅ Fixed notify-send command syntax (missing space in -i argument)
# ✅ Corrected ExecStart escaping issues
# ✅ Ensured systemd unit files have proper formatting
# ✅ Fixed systemctl commands to avoid redundant restarts

# SCOPE:
# Run 15 seconds after boot.
# Run at 00:00, 06:00, 12:00, 18:00.
# Run every 6 hours after it last ran.
# Check for updates after waking from suspend.

# service and timer files and their locations
service_file="/etc/systemd/system/tolga-flatpak-update.service"
timer_file="/etc/systemd/system/tolga-flatpak-update.timer"

# Run as root check
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

# find-out the logged-in user
if [ -n "$SUDO_USER" ]; then
    user="$SUDO_USER" # when run with sudo get the original user
else
    user=$(who | awk '{print $1}' | head -n 1) # get the first user from who command if run as root
fi

# download LinuxTweaks icon
sudo mkdir -p /usr/local/bin/LinuxTweaks/images
sudo wget -O /usr/local/bin/LinuxTweaks/images/LinuxTweak.png https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/images/LinuxTweak.png
sudo chmod 644 /usr/local/bin/LinuxTweaks/images/LinuxTweak.png

# is Flatpak is installed?
if ! command -v flatpak &>/dev/null; then
    echo "Error: Flatpak is not installed. Please install Flatpak to proceed."
    exit 1
fi

# create my systemd tolga-flatpak-update.service file
cat >"$service_file" <<EOF
[Unit]
Description=Tolga's Flatpak Automatic Update V5.1
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
    /usr/bin/flatpak --system update -y --noninteractive && \
    /usr/bin/flatpak --system repair && break || (echo "Retrying Flatpak update..." && sleep 10); \
done | tee /tmp/flatpak_update.log; \
if grep -q "Nothing to do" /tmp/flatpak_update.log; then \
    sudo -u $user DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send --app-name="Checking Flatpaks for updates" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png "Flatpak Update Status" "No updates available"; \
else \
    sudo -u $user DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send --app-name="Installing Flatpaks" -i /usr/local/bin/LinuxTweaks/images/LinuxTweak.png "Flatpak Update Status:" "Updates installed successfully"; \
fi'

# if the service doesnt stop correctly, abort
TimeoutStopFailureMode=abort

# do not interrupt the service during sleep mode
Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=0

#   NOTES:
#   systemctl daemon-reload && systemctl start tolga-flatpak-update.service && systemctl enable --now tolga-flatpak-update.timer && systemctl restart tolga-flatpak-update.timer && echo -e "\nFlatpak update service status:" && systemctl status tolga-flatpak-update.service --no-pager && echo -e "\nFlatpak update timer status:" && systemctl status tolga-flatpak-update.timer --no-pager && echo -e "\nNext scheduled Flatpak update timer:" && systemctl list-timers --no-pager | grep "tolga-flatpak-update"
EOF

# create my tolga-flatpak-update.timer file
cat >"$timer_file" <<EOF
[Unit]
Description=Tolga's Flatpak Automatic Update Trigger V5.1
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
WantedBy=timers.target suspend.target
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
