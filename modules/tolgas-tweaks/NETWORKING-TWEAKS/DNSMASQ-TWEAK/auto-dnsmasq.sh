#!/usr/bin/env bash

# DNS Speed Optimization Script for Fedora & Arch-based ( Continuation from my old RHEL script )
# Tolga Erok
# 24/3/2025
# Scope:
# Automates dnsmasq setup for speed, with an option to restore previous settings.
# Ver: 3.8a

DNSMASQ_CONF="/etc/dnsmasq.conf"
RESOLV_CONF="/etc/resolv.conf"
BACKUP_RESOLV="/etc/resolv.conf.backup"

setup_dnsmasq() {
    echo "Setting up dnsmasq for maximum speed..."

    # Install dnsmasq
    if command -v dnf &>/dev/null; then
        dnf install -y dnsmasq
    elif command -v pacman &>/dev/null; then
        pacman -S --noconfirm dnsmasq
    else
        echo "Unsupported package manager. Exiting..."
        exit 1
    fi
}

get_active_interface() {
    # Detect the first UP interface, prefer Wi-Fi (mines wlp4s0)
    local interface=$(ip -o link show up | awk '!/lo/ {print $2}' | sed 's/://')
    if [[ "$interface" == "wlp4s0" ]]; then
        echo "wlp4s0"
    else
        echo "$interface"
    fi
}

set_dnsmasq() {
    echo "🚀 Setting up dnsmasq for maximum speed..."

    setup_dnsmasq

    # Backup /etc/resolv.conf
    [ ! -f "$BACKUP_RESOLV" ] && sudo cp "$RESOLV_CONF" "$BACKUP_RESOLV"

    # Stop systemd-resolved
    sudo systemctl disable --now systemd-resolved

    # Get the active network interface
    local interface=$(get_active_interface)

    if [ -z "$interface" ]; then
        echo "❌ No active network interface found. Please check your connection!"
        return 1
    fi

    echo "Using network interface: $interface"

    # Configure dnsmasq with what I think is the optimal settings
    sudo tee "$DNSMASQ_CONF" >/dev/null <<EOF
# DNS servers to use
server=1.1.1.1                  # Use Cloudflare DNS server (fast and privacy-focused)
server=1.0.0.1                  # Use Cloudflare secondary DNS server
server=8.8.8.8                  # Use Google DNS server (reliable and widely used)
server=8.8.4.4                  # Use Google secondary DNS server

# Do not use system's /etc/resolv.conf for DNS resolution (beta)
no-resolv                       # Do not use /etc/resolv.conf to get nameservers - old RHEL script

# DNS cache settings
cache-size=10000                # Set the DNS cache size to 10,000 entries
no-negcache                     # Don't cache negative (failed) lookups, improves error handling - old RHEL script

# Network interface to use
interface=$interface            # Use the specified network interface

# Privacy and security settings
bogus-priv                      # Block local IP address leaks (prevents resolving of private IPs like 192.168.x.x) - old RHEL script
domain-needed                   # Only send DNS queries for valid TLDs (prevents unnecessary queries) - old RHEL script

# DNS server query behavior
strict-order                    # Query DNS servers in strict order, prioritizing Cloudflare DNS first (1.1.1.1) - old RHEL script
EOF

    # Restart dnsmasq
    sudo systemctl enable --now dnsmasq

    # Set resolv.conf to use dnsmasq - old RHEL script
    echo "nameserver 127.0.0.1" | sudo tee "$RESOLV_CONF" >/dev/null

    echo "✅ dnsmasq setup completed! Your system now uses a fast DNS cache."
}

restore_dns() {
    echo "🔄 Restoring previous DNS settings..."
    sudo systemctl disable --now dnsmasq
    sudo systemctl enable --now systemd-resolved
    [ -f "$BACKUP_RESOLV" ] && sudo cp "$BACKUP_RESOLV" "$RESOLV_CONF"
    echo "✅ DNS settings restored to previous state."
}

check_status() {
    echo "🔍 Checking DNS configuration..."

    # Check if dnsmasq is running
    if systemctl is-active --quiet dnsmasq; then
        echo "✅ dnsmasq is active"
    else
        echo "❌ dnsmasq is NOT running"
    fi

    # Check if systemd-resolved is running
    if systemctl is-active --quiet systemd-resolved; then
        echo "✅ systemd-resolved is running"
    else
        echo "❌ systemd-resolved is NOT running"
    fi

    # Show current resolv.conf
    echo "📄 Current /etc/resolv.conf:"
    cat "$RESOLV_CONF"

    # Test DNS resolution through dnsmasq (127.0.0.1) - old RHEL script
    echo "🔍 Testing DNS resolution via dnsmasq (127.0.0.1)..."
    if nslookup google.com 127.0.0.1 &>/dev/null; then
        echo "✅ dnsmasq is resolving DNS successfully."
    else
        echo "❌ dnsmasq is NOT resolving DNS. Please check your setup."
    fi

    # Test DNS resolution through an external nameserver (8.8.8.8) - old RHEL script
    echo "🔍 Testing DNS resolution via external nameserver (8.8.8.8)..."
    if nslookup google.com 8.8.8.8 &>/dev/null; then
        echo "✅ External DNS (8.8.8.8) is resolving DNS successfully."
    else
        echo "❌ External DNS (8.8.8.8) is NOT resolving DNS. Check external DNS connectivity."
    fi

    # Test DNS resolution through an external nameserver (1.1.1.1) - old RHEL script
    echo "🔍 Testing DNS resolution via external nameserver (1.1.1.1)..."
    if nslookup google.com 1.1.1.1 &>/dev/null; then
        echo "✅ External DNS (1.1.1.1) is resolving DNS successfully."
    else
        echo "❌ External DNS (1.1.1.1) is NOT resolving DNS. Check external DNS connectivity."
    fi

    # Use dig for a more detailed DNS test - old RHEL script
    echo "🔍 Using dig for more details on DNS resolution..."
    dig google.com +short

    # Check dnsmasq logs
    sudo journalctl -u dnsmasq --no-pager --lines=20
}

while true; do
    echo ""
    echo "Tolga's 2025 DNSMASQ tweak"
    echo "--------------------------------------------"
    echo "Choose an option:"
    echo "1) Set up fast dnsmasq"
    echo "2) Restore previous DNS settings"
    echo "3) Check current DNS status"
    echo "4) Exit"
    echo "--------------------------------------------"
    read -p "Enter your choice (1/2/3/4): " choice

    case "$choice" in
    1) set_dnsmasq ;;
    2) restore_dns ;;
    3) check_status ;;
    4)
        echo "🚪 Exiting..."
        exit 0
        ;;
    *) echo "❌ Invalid choice! Please select a valid option." ;;
    esac
done
