#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="V8-REMOVE"
# DATE_CREATED="15/4/2025"
# Description: Removes Tolga's CAKE systemd setup and bashrc entries.

YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

service_name="tolga-apply-cake-qdisc.service"
service_file="/etc/systemd/system/$service_name"
service_name2="tolga-apply-cake-qdisc-wake.service"
service_file2="/etc/systemd/system/$service_name2"
BASHRC="$HOME/.bashrc"

echo -e "${BLUE}Disabling and stopping systemd services...${NC}"
sudo systemctl disable --now "$service_name"
sudo systemctl disable --now "$service_name2"

echo -e "${BLUE}Removing service files...${NC}"
sudo rm -f "$service_file" "$service_file2"

echo -e "${BLUE}Reloading systemd daemon...${NC}"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo -e "${BLUE}Removing bashrc additions...${NC}"

# remove cake-restart function
sed -i '/# Apply CAKE qdisc easily - Tolga Erok/,/^}/d' "$BASHRC"

# remove aliases
# sed -i '/alias cake-status=/d' "$BASHRC"
# sed -i '/alias cake
