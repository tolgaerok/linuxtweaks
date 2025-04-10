#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="V6.2"
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
service_name="tolga-apply-cake-qdisc.service"
service_file="/etc/systemd/system/$service_name"
service_name2="tolga-apply-cake-qdisc-wake.service"
service_file2="/etc/systemd/system/$service_name2"

# Create systemd service for CAKE at boot
echo -e "${BLUE}Creating systemd service file at ${service_file}...${NC}"
sudo bash -c "cat > $service_file" <<EOF
[Unit]
Description=Tolga's V6.2 CAKE qdisc for $interface at boot
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
echo -e "${BLUE}Creating systemd service file at ${service_file2}...${NC}"
sudo bash -c "cat > $service_file2" <<EOF
[Unit]
Description=Re-apply Tolga's V6.2 CAKE qdisc to $interface after suspend/wake
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
sudo systemctl enable --now "$service_name"
sudo systemctl enable --now "$service_name2"

echo -e "${BLUE}Verifying qdisc configuration for ${interface}:${NC}"
sudo tc qdisc show dev "$interface"

# Add function & alias to .bashrc only if not already present in user bashrc
BASHRC="$HOME/.bashrc"

# Add cake-restart function if not present
if ! grep -q "function cake-restart()" "$BASHRC"; then
    echo -e "${BLUE}Adding 'cake-restart' function to .bashrc...${NC}"
    cat >>"$BASHRC" <<EOF

# Apply CAKE qdisc easily - Tolga Erok
function cake-restart() {
    service_name="tolga-apply-cake-qdisc.service"
    service_name2="tolga-apply-cake-qdisc-wake.service"

    # Detect active network interface
    interface=\$(ip -o link show | awk -F': ' '
    \$2 ~ /wlp|wlo|wlx|eth|eno/ && /UP/ && !/NO-CARRIER/ {print \$2; exit}')
    
    if [[ -z "\$interface" ]]; then
        echo -e "${RED}Error: No active network interface detected!${NC}"
        return 1
    fi

    echo -e "${BLUE}Restarting CAKE qdisc for interface: \$interface${NC}"

    sudo systemctl daemon-reload
    sudo systemctl restart "$service_name"
    sudo systemctl restart "$service_name2"

    echo -e "${BLUE}Verifying qdisc configuration for \$interface:${NC}"
    sudo tc -s qdisc show dev "\$interface"

    echo -e "${BLUE}Systemd service statuses:${NC}"
    sudo systemctl status "$service_name" --no-pager
    sudo systemctl status "$service_name2" --no-pager
}

EOF
fi

# Add aliases if not present
if ! grep -q 'alias cake-status=' "$BASHRC"; then
    echo -e "${BLUE}Adding 'cake-status' alias to .bashrc...${NC}"
    echo "alias cake-status=\"sudo systemctl status $service_name --no-pager && sudo systemctl status $service_name2 --no-pager\"" >>"$BASHRC"
fi

if ! grep -q 'alias cake-restart=' "$BASHRC"; then
    echo -e "${BLUE}Adding 'cake-restart' alias to .bashrc...${NC}"
    echo "alias cake-restart=\"cake-restart\"" >>"$BASHRC"
fi

echo -e "${YELLOW}Reloading .bashrc...${NC}"
source "$BASHRC"
