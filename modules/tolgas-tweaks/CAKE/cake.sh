#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="V6.1"
# DATE_CREATED="18/3/2025"
# BUG_FIX="18/3/2025"
# Description: Systemd script to force CAKE onto any active network interface.

YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

# Detect package manager
if command -v dnf &>/dev/null; then
    PM="dnf"
    INSTALL_CMD="sudo dnf install -y iproute-tc"
    elif command -v pacman &>/dev/null; then
    PM="pacman"
    INSTALL_CMD="sudo pacman -Sy --needed iproute2"
else
    echo -e "${RED}Unsupported distribution. Exiting...${NC}"
    exit 1
fi

# Check and install `tc`
if ! command -v tc &>/dev/null; then
    echo -e "${YELLOW}tc command not found, installing required package...${NC}"
    $INSTALL_CMD
    hash -r
fi

# detect tc path
TC_PATH=$(command -v tc)
if [ -z "$TC_PATH" ]; then
    echo -e "${RED}Failed to find tc after installation. Exiting.${NC}"
    exit 1
fi

# Detect active network interface
interface=$(ip -o link show | awk -F': ' '
$2 ~ /wlp|wlo|wlx|eth|eno/ && /UP/ && !/NO-CARRIER/ {print $2; exit}')

if [ -z "$interface" ]; then
    echo -e "${RED}No active network interface found. Exiting.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected active network interface: ${interface}${NC}"

# Systemd service names
SERVICE_NAME="tolga-apply-cake-qdisc.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
SERVICE_NAME2="tolga-apply-cake-qdisc-wake.service"
SERVICE_FILE2="/etc/systemd/system/$SERVICE_NAME2"

# Create systemd service for CAKE at boot
echo -e "${BLUE}Creating systemd service file at ${SERVICE_FILE}...${NC}"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Tolga's V6.1 CAKE qdisc for $interface at boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$TC_PATH qdisc replace dev $interface root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for suspend/wake
echo -e "${BLUE}Creating systemd service file at ${SERVICE_FILE2}...${NC}"
sudo bash -c "cat > $SERVICE_FILE2" <<EOF
[Unit]
Description=Re-apply Tolga's V6.1 CAKE qdisc to $interface after suspend/wake
After=suspend.target

[Service]
Type=oneshot
ExecStart=$TC_PATH qdisc replace dev $interface root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18

[Install]
WantedBy=suspend.target
EOF

# Reload systemd and enable services
echo -e "${BLUE}Reloading systemd daemon and enabling services...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable --now "$SERVICE_NAME"
sudo systemctl enable --now "$SERVICE_NAME2"

echo -e "${BLUE}Verifying qdisc configuration for ${interface}:${NC}"
sudo tc qdisc show dev "$interface"

# Add function & alias to .bashrc only if not already present in user bashrc
BASHRC="$HOME/.bashrc"

if ! grep -q "function cake()" "$BASHRC"; then
    echo -e "${BLUE}Adding 'cake' function to .bashrc...${NC}"
    cat >>"$BASHRC" <<EOF

# Apply CAKE qdisc easily - Tolga Erok
function cake() {
  interface=\$(ip link show | awk -F': ' '/wlp|wlo|wlx|eth|eno/ && /UP/ && !/NO-CARRIER/ {print \$2; exit}')
  sudo systemctl daemon-reload
  sudo systemctl restart $SERVICE_NAME
  sudo tc -s qdisc show dev \$interface
  sudo systemctl status $SERVICE_NAME --no-pager
  sudo systemctl status $SERVICE_NAME2 --no-pager
}
EOF
else
    echo -e "${YELLOW}'cake' function already exists in .bashrc, skipping...${NC}"
fi

if ! grep -q 'alias cake-status=' "$BASHRC"; then
    echo -e "${BLUE}Adding 'cake-status' alias to .bashrc...${NC}"
    echo "alias cake-status=\"sudo systemctl status $SERVICE_NAME --no-pager && sudo systemctl status $SERVICE_NAME2 --no-pager\"" >> "$BASHRC"
else
    echo -e "${YELLOW}'cake-status' alias already exists in .bashrc, skipping...${NC}"
fi

echo -e "${YELLOW}Reloading .bashrc...${NC}"
source "$BASHRC"