#!/bin/bash
# tolga erok
# 16/4/2025

#=================================================
# LinuxTweaks - Startup System Health Check
#=================================================

clear

# Config
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Timestamp
timestamp=$(date +"%Y-%m-%d %H:%M:%S %Z")

#=================================================
# Basic System Information
#=================================================
kernel=$(uname -r)
distribution=$(lsb_release -d 2>/dev/null | awk -F"\t" '{print $2}' || echo "Unknown")
architecture=$(uname -m)
cpu_model=$(lscpu | grep "Model name" | awk -F": " '{print $2}')
total_ram=$(free -h | awk '/Mem:/ {print $2}')
session_type=$(loginctl show-session $(loginctl | grep -m1 "$(whoami)" | awk '{print $1}') -p Type | cut -d= -f2)
desktop_environment=${XDG_CURRENT_DESKTOP:-"Unknown"}
uptime=$(uptime -p)
load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')

#=================================================
# Boot Analysis
#=================================================
startup_time=$(systemd-analyze | grep "Startup finished" | cut -d '=' -f2 | sed 's/^ //')
graphical_target_time=$(systemd-analyze critical-chain graphical.target | grep 'graphical.target' | awk '{print $NF}')
startup_time=${startup_time:-"Startup time data not available"}
if [[ -z "$graphical_target_time" || "$graphical_target_time" == "@0ms" ]]; then
    graphical_target_time="Graphical target time data not available"
fi

#=================================================
# System Logs
#=================================================
systemd_errors=$(journalctl -p 3 -n 20 --no-pager)

#=================================================
# Network Details
#=================================================
network_routes=$(ip route)
dns_config=$(cat /etc/resolv.conf)
dns_servers=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}')
ping_results=""
for dns in $dns_servers; do
    if ping -c 1 -W 1 "$dns" &>/dev/null; then
        ping_results+="✔️  Successfully pinged $dns\n"
    else
        ping_results+="❌  Failed to ping $dns\n"
    fi
done

#=================================================
# SMART Status
#=================================================
smart_status=$(sudo smartctl -H /dev/sda 2>/dev/null | grep "SMART overall-health self-assessment test result")

#=================================================
# USB Devices
#=================================================
usb_info=$(lsusb)

#=================================================
# Disk Info
#=================================================
disk_info=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE)

#=================================================
# Memory Details
#=================================================
mem_details=$(sudo dmidecode --type 17 2>/dev/null | grep -E "Size:|Speed:|Type:" | grep -v "No Module Installed")

#=================================================
# Systemd Timers
#=================================================
timers_info=$(systemctl list-timers --all --no-pager)

#=================================================
# Systemd Services
#=================================================
services_info=$(systemctl list-units --type=service --state=running --no-pager)

#=================================================
# Report Output
#=================================================

section() {
    echo ""
    echo -e " 🛠️${GREEN} (ツ)_/¯"
    echo -e "${GREEN}================================================="
    echo -e "${BLUE} $1${GREEN}"
    echo -e "=================================================${RESET}"
}

field() {
    echo -e "${BLUE}- $1:${RESET} ${YELLOW}$2${RESET}"
}

section "LinuxTweaks - Startup System Health Check Report"
field "Generated" "$timestamp"

section "Basic System Information"
field "Timestamp" "$timestamp"
field "Kernel Version" "$kernel"
field "Distribution" "$distribution"
field "Architecture" "$architecture"
field "CPU Model" "$cpu_model"
field "Total RAM" "$total_ram"
field "Session Type" "$session_type"
field "Desktop Environment" "$desktop_environment"
field "Uptime & Load" "$uptime, Load average: $load_avg"

section "Boot Analysis"
field "Startup finished in" "$startup_time"
field "Graphical target reached after" "$graphical_target_time"

section "Systemd Journal Errors (Last 20)"
echo -e "${YELLOW}$systemd_errors${RESET}"

section "Connectivity Test (Ping DNS Servers)"
echo -e "${YELLOW}$ping_results${RESET}"

section "Network Configuration"
field "Routing Table" ""
echo -e "${YELLOW}$network_routes${RESET}"

section "DNS Configuration (/etc/resolv.conf)"
echo -e "${YELLOW}$dns_config${RESET}"

section "SMART Status (/dev/sda)"
echo -e "${YELLOW}$smart_status${RESET}"

section "USB Devices"
echo -e "${YELLOW}$usb_info${RESET}"

section "Disk Information"
echo -e "${YELLOW}$disk_info${RESET}"

section "Swap Information"
swap_info=$(sudo swapon --show)
echo -e "${YELLOW}$swap_info${RESET}"

section "Memory Module Details"
echo -e "${YELLOW}$mem_details${RESET}"

section "TCP Congestion Control"
congestion_control=$(sysctl net.ipv4.tcp_congestion_control)
echo -e "${YELLOW}$congestion_control${RESET}"

section "Systemd Timers"
echo -e "${YELLOW}$timers_info${RESET}"

section "Systemd Services"
echo -e "${YELLOW}$services_info${RESET}"
