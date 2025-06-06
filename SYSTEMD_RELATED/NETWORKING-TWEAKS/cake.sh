#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="V8"
# DATE_CREATED="18/3/2025"
# BUG_FIX="15/4/2025" : Typo error on creating wake service
# BUG_FIX="16/4/2025" : fixed detecting package manager more rebust

# Description: Systemd script to force CAKE onto any active network interface.

YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

# which package manager and set install command for `tc`
if command -v dnf &>/dev/null; then
    INSTALL_CMD="sudo dnf install -y iproute-tc"
elif command -v pacman &>/dev/null; then
    INSTALL_CMD="sudo pacman -Sy --needed iproute2"
else
    echo -e "${RED}❌ Unsupported distribution. Exiting...${NC}"
    exit 1
fi

# check for `tc` command - install if itsmissing
if ! command -v tc &>/dev/null; then
    echo -e "${YELLOW}⚠️  'tc' command not found. Installing required package...${NC}"
    if $INSTALL_CMD; then
        echo -e "${GREEN}✅ 'tc' installed successfully.${NC}"
        hash -r
    else
        echo -e "${RED}❌ Failed to install 'tc'. Please install it manually.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ 'tc' is already installed.${NC}"
fi

# detect tc path
TC_PATH=$(command -v tc)
if [ -z "$TC_PATH" ]; then
    echo -e "${RED}Failed to find tc after installation. Exiting.${NC}"
    exit 1
fi

# detect active network interface
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
Description=Tolga's V8.0 CAKE qdisc for $interface at boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
# ExecStart=$TC_PATH qdisc replace dev $interface root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18
ExecStart=/bin/bash -c 'interface=\$(ip link show | awk -F: '\''\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \t]+|[ \t]+$/, \"\", \$2); print \$2; exit}'\''); if [ -n \"\$interface\" ]; then sudo tc qdisc replace dev \$interface root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18; fi'
RemainAfterExit=yes

Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=0

# Watchdog & safety
TimeoutStartSec=10min
TimeoutStopSec=10s
TimeoutStopFailureMode=kill

StandardError=journal
StandardOutput=journal
SuccessExitStatus=0 3

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for suspend/wake
echo -e "${BLUE}Creating systemd service file at ${service_file2}...${NC}"
sudo tee "$service_file2" >/dev/null <<'EOF'
[Unit]
Description=Re-apply Tolga's V8.0 CAKE qdisc to $interface after suspend/wake
After=network-online.target suspend.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'iface=$(ip -o link show | awk -F: '\''/wlp|wlo|wlx/ && $2 !~ /NO-CARRIER/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}'\''); \
if [ -n "$iface" ]; then \
  /usr/sbin/tc qdisc replace dev "$iface" root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18; \
fi'

RemainAfterExit=yes
Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=0

# Watchdog & safety
TimeoutStartSec=10min
TimeoutStopSec=10s
TimeoutStopFailureMode=kill

StandardError=journal
StandardOutput=journal
SuccessExitStatus=0 3

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
