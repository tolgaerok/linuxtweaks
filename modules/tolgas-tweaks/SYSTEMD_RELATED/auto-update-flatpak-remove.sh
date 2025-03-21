#!/bin/bash
# Author: Tolga Erok
# Date: 21/3/2025
# Version: 3.1

# SCOPE:
# Delete existing service and timer for Flatpak updates and reload systemd.

# Configs
SERVICE_FILE="/etc/systemd/system/tolga-flatpak-update.service"
TIMER_FILE="/etc/systemd/system/tolga-flatpak-update.timer"

# run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

# Delete the systemd service and timer files if they exist
if [ -f "$SERVICE_FILE" ]; then
    echo "Removing existing service file: $SERVICE_FILE"
    rm -f "$SERVICE_FILE"
else
    echo "Service file does not exist: $SERVICE_FILE"
fi

if [ -f "$TIMER_FILE" ]; then
    echo "Removing existing timer file: $TIMER_FILE"
    rm -f "$TIMER_FILE"
else
    echo "Timer file does not exist: $TIMER_FILE"
fi

# Reload systemd daemon to apply changes
systemctl daemon-reload

# Status of the timer and service (they should be removed)
echo -e "\nFlatpak update service status (should not exist):"
systemctl status tolga-flatpak-update.service --no-pager || echo "Service is removed."

echo -e "\nFlatpak update timer status (should not exist):"
systemctl status tolga-flatpak-update.timer --no-pager || echo "Timer is removed."

# Confirm removal and reset
echo -e "\nFlatpak update service and timer removed. You can now start fresh."
