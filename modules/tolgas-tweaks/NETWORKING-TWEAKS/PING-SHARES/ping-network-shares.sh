#!/bin/bash
# Tolga Erok - 19/03/2025
# Auto-mount Samba shares every 30s, after boot, and after suspend

LOG_FILE="/var/log/tolga-auto-ping-samba-install.log"

# Ensure log file exists with correct permissions
sudo touch "$LOG_FILE"
sudo chmod 666 "$LOG_FILE"

echo "Starting setup at $(date)" | tee -a "$LOG_FILE"

# Create Samba Auto-Ping Script
echo "Creating Samba Auto-Ping script..." | tee -a "$LOG_FILE"
cat <<EOF | sudo tee /usr/local/bin/tolga-auto-ping-samba.sh >/dev/null
#!/bin/bash
# Tolga Erok - 19/03/2025
# Auto-Mount Samba Shares Every 30s, After Boot, and After Suspend

LOG_FILE="/var/log/tolga-auto-ping-samba.log"
echo "Scanning shares started at $(date)" >> "$LOG_FILE"

# Start timer
START_TIME=$(date +%s)

# List of SMB shares
shares=(
    "//jack-sparrow.local/Public/"
    "//jack-sparrow.local/MY-QNAP/"
)

# Mount each SMB share
for share in "${shares[@]}"; do
    share_name=$(basename "$share")
    mount_point="/mnt/$share_name"

    echo "Attempting to mount $share to $mount_point" >> "$LOG_FILE"

    if mount | grep -q "$mount_point"; then
        echo "$share is already mounted at $mount_point" >> "$LOG_FILE"
    else
        sudo mkdir -p "$mount_point"
        # Attempt mounting with appropriate options
        if sudo mount -t cifs "$share" "$mount_point" -o credentials=/etc/samba/credentials,vers=3.0,readbufsize=131072,writebufsize=131072,noserverino,noatime,uid=1000,gid=1000,file_mode=0777,dir_mode=0777; then
            echo "Successfully mounted $share to $mount_point" >> "$LOG_FILE"
        else
            echo "Failed to mount $share to $mount_point" >> "$LOG_FILE"
        fi
    fi
done

END_TIME=$(date +%s)
TIME_TAKEN=$((END_TIME - START_TIME))
echo "Scan Complete: Shares scanned in $TIME_TAKEN seconds at $(date)." >> "$LOG_FILE"
EOF

# Make the script executable
sudo chmod +x /usr/local/bin/tolga-auto-ping-samba.sh

# Create Systemd Service
echo "Creating systemd service..." | tee -a "$LOG_FILE"
cat <<'EOF' | sudo tee /etc/systemd/system/tolga-auto-ping-samba.service >/dev/null
[Unit]
Description=Automatically Ping and Mount Samba Shares - Tolga Erok
After=network-online.target avahi-daemon.service
Wants=network-online.target avahi-daemon.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/tolga-auto-ping-samba.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal
EOF

# Create Systemd Timer
echo "Creating systemd timer..." | tee -a "$LOG_FILE"
cat <<'EOF' | sudo tee /etc/systemd/system/tolga-auto-ping-samba.timer >/dev/null
[Unit]
Description=Scan and ping Samba shares every 30s - Tolga Erok

[Timer]
OnBootSec=10s
OnUnitActiveSec=30s
Unit=tolga-auto-ping-samba.service

[Install]
WantedBy=timers.target
EOF

# Create Systemd Suspend Service
echo "Creating systemd suspend service..." | tee -a "$LOG_FILE"
cat <<'EOF' | sudo tee /etc/systemd/system/tolga-auto-ping-samba-suspend.service >/dev/null
[Unit]
Description=Auto-Mount Samba Shares After Suspend - Tolga Erok
After=network-online.target sleep.target suspend.target hybrid-sleep.target hibernate.target
Requires=network-online.target
# Adding a delay after suspend
ExecStartPre=/bin/sleep 2

[Service]
Type=oneshot
ExecStart=/usr/local/bin/tolga-auto-ping-samba.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=suspend.target sleep.target hybrid-sleep.target hibernate.target
EOF

# Reload systemd and enable services
echo "Reloading systemd and enabling services..." | tee -a "$LOG_FILE"
sudo systemctl daemon-reload
sudo systemctl enable --now tolga-auto-ping-samba.timer
sudo systemctl enable --now tolga-auto-ping-samba-suspend.service
sudo systemctl restart tolga-auto-ping-samba.service
sudo systemctl restart tolga-auto-ping-samba-suspend.service

# Verification
echo "Verifying setup..." | tee -a "$LOG_FILE"
sudo systemctl list-timers --all --no-pager | tee -a "$LOG_FILE"
sudo journalctl -u tolga-auto-ping-samba.timer --no-pager | tee -a "$LOG_FILE"
sudo journalctl -u tolga-auto-ping-samba.service --no-pager | tee -a "$LOG_FILE"
sudo journalctl -u tolga-auto-ping-samba-suspend.service --no-pager | tee -a "$LOG_FILE"

sudo systemctl status tolga-auto-ping-samba.service --no-pager | tee -a "$LOG_FILE"
sudo systemctl status tolga-auto-ping-samba.timer --no-pager | tee -a "$LOG_FILE"
sudo systemctl status tolga-auto-ping-samba-suspend.service --no-pager | tee -a "$LOG_FILE"

sudo systemctl list-units --type=service --state=running --no-pager | tee -a "$LOG_FILE"
sudo systemctl list-timers --no-pager | tee -a "$LOG_FILE"
sudo systemctl is-enabled tolga-auto-ping-samba.service --no-pager | tee -a "$LOG_FILE"
sudo systemctl is-enabled tolga-auto-ping-samba.timer --no-pager | tee -a "$LOG_FILE"
sudo systemctl is-enabled tolga-auto-ping-samba-suspend.service --no-pager | tee -a "$LOG_FILE"

echo "Setup complete! Samba shares will be auto-mounted after boot, every 30s, and after suspend." | tee -a "$LOG_FILE"
