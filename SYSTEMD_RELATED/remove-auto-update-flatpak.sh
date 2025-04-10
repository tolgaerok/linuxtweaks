#!/bin/bash
# Author: Tolga Erok
# Date: 21/3/2025
# Version: 4.1a

# SCOPE:
# Delete existing service and timer for Flatpak updates and reload systemd.

# service and timer file locations
service_file="/etc/systemd/system/tolga-flatpak-update.service"
timer_file="/etc/systemd/system/tolga-flatpak-update.timer"

# run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

# Delete my service and timer files if they exist
if [ -f "$service_file" ]; then
    echo "Removing existing service file: $service_file"
    rm -f "$service_file"
else
    echo "Service file does not exist: $service_file"
fi

if [ -f "$timer_file" ]; then
    echo "Removing existing timer file: $timer_file"
    rm -f "$timer_file"
else
    echo "Timer file does not exist: $timer_file"
fi

# Reload systemd daemon
systemctl daemon-reload

# status of the timer and service (they should be removed)
echo -e "\nFlatpak update service status (should not exist):"
systemctl status tolga-flatpak-update.service --no-pager || echo "Service is removed."

echo -e "\nFlatpak update timer status (should not exist):"
systemctl status tolga-flatpak-update.timer --no-pager || echo "Timer is removed."

echo -e "\nFlatpak update service and timer removed. You can now start fresh."
