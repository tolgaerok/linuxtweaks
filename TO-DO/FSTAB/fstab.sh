#!/bin/bash

# Script to automate Samba mount creation, permissions, and fstab updates
# Tolga Erok - 19/03/2025

LOG_FILE="/var/log/tolga-auto-samba-mount.log"

# Ensure log file exists and has correct permissions
sudo touch "$LOG_FILE"
sudo chmod 666 "$LOG_FILE"

echo "Starting Samba mount setup at $(date)" | tee -a "$LOG_FILE"

# credential file paths
QNAP_CREDENTIALS="/etc/samba/QNAP_credentials.conf"
WINDOWS_CREDENTIALS="/etc/samba/Windows_credentials.conf"

# QNAP credentials
echo -e "username=admin\npassword=ibm450" | sudo tee "$QNAP_CREDENTIALS" >/dev/null

# Windows credentials
echo -e "username=tolga\npassword=ibm450" | sudo tee "$WINDOWS_CREDENTIALS" >/dev/null

# Set permissions
sudo chmod 600 "$QNAP_CREDENTIALS" "$WINDOWS_CREDENTIALS"
sudo chown root:root "$QNAP_CREDENTIALS" "$WINDOWS_CREDENTIALS"

echo "Credential files have been created and secured."

# List of directories to create
directories=(
    "/mnt/Mint"
    "/mnt/Public"
    "/mnt/QNAP"
    "/mnt/Relationships"
    "/mnt/Optus"
)

# Create directories and set permissions
for dir in "${directories[@]}"; do
    echo "Creating directory: $dir" | tee -a "$LOG_FILE"
    sudo mkdir -p "$dir"
    sudo chmod 777 "$dir"
    echo "Permissions set to 777 for $dir" | tee -a "$LOG_FILE"
done

# Samba mount entries for /etc/fstab
fstab_entries=(
    ""
    "# --------------------------  NETWORK SHARES  ------------------------------------ #"
    "//192.168.0.1/tolga                        /mnt/Optus cifs credentials=/etc/samba/Windows_credentials.conf,vers=1.0,uid=1000,gid=1000,file_mode=0777,dir_mode=0777,iocharset=utf8,cache=loose,noserverino,actimeo=60,nofail 0 0"
    "//192.168.0.17/Public/RELATIONSHIPS        /mnt/Relationships cifs credentials=/etc/samba/QNAP_credentials.conf,vers=3.0,uid=1000,gid=1000,file_mode=0777,dir_mode=0777,iocharset=utf8,cache=loose,noserverino,actimeo=60,nofail 0 0"
    "//192.168.0.18/Documents                   /mnt/Mint cifs credentials=/etc/samba/Windows_credentials.conf,vers=3.0,uid=1000,gid=1000,file_mode=0777,dir_mode=0777,iocharset=utf8,cache=loose,noserverino,actimeo=60,nofail 0 0"
    "//jack-sparrow.local/Public                /mnt/Public cifs credentials=/etc/samba/QNAP_credentials.conf,vers=3.0,uid=1000,gid=1000,file_mode=0777,dir_mode=0777,iocharset=utf8,cache=loose,noserverino,actimeo=60,nofail 0 0"
    "//jack-sparrow.local/Public/PC-PORTAL      /mnt/QNAP cifs credentials=/etc/samba/QNAP_credentials.conf,vers=3.0,uid=1000,gid=1000,file_mode=0777,dir_mode=0777,iocharset=utf8,cache=loose,noserverino,actimeo=60,nofail 0 0"
    ""
    "# --------------------------      TOOLS     ------------------------------------ #"
    "#     To Reload FSTB"
    "#      sudo systemctl daemon-reload && sudo mount -a"
    "#"
    "#     To KILL mounts"
    "#      sudo fuser -km /media/WPS"
    "#      sudo lsof +D /media/WPS"
    "#      sudo umount -l /media/WPS"
)

# Backup /etc/fstab before making changes
sudo cp /etc/fstab /etc/fstab.bak
echo "Backup of /etc/fstab created at $(date)" | tee -a "$LOG_FILE"

# Add Samba mount entries to /etc/fstab
for entry in "${fstab_entries[@]}"; do
    echo "Adding entry to /etc/fstab: $entry" | tee -a "$LOG_FILE"
    echo "$entry" | sudo tee -a /etc/fstab
done

# Mount all entries from /etc/fstab
echo "Mounting all entries from /etc/fstab..." | tee -a "$LOG_FILE"
sudo systemctl disable systemd-networkd-wait-online
sudo systemctl mask systemd-networkd-wait-online
sudo systemctl daemon-reload && sudo mount -a

# Verify if mounts are successful
echo "Verifying mounts..." | tee -a "$LOG_FILE"
mount | tee -a "$LOG_FILE"

echo "Samba mount setup completed at $(date)" | tee -a "$LOG_FILE"

sleep 1
