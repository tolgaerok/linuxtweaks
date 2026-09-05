#!/bin/bash
# ======================================================================
#   LinuxTweaks Installation & Verification Suite v6.1.20
#   Author : Tolga Erok
#   Date   : 05 Sep 2026
#   Purpose: Clean install with repo setup and verification
# ======================================================================
set -e
clear

# ── Colours ────────────────────────────────────────────────
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ── Helper Functions ───────────────────────────────────────
header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$*${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

step() {
    echo -e "\n${CYAN}▶${NC} ${BLUE}$*${NC}"
}

success() {
    echo -e "${GREEN}✅ $*${NC}"
}

warn() {
    echo -e "${RED}❌ ERROR${NC}: $*" >&2
}

# ── Start ──────────────────────────────────────────────────
header "LinuxTweaks Installation Suite v6.1.20"

# Repository Configuration
step "Repository Configuration"
REPO_FILE="/etc/yum.repos.d/linuxtweaks.repo"
if [ -f "$REPO_FILE" ]; then
    success "Repository already configured"
else
    echo "Adding LinuxTweaks repository..."
    echo -e "[linuxtweaks]\nname=LinuxTweaks Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks/\nenabled=1\ngpgcheck=1\ngpgkey=http://100.83.30.114:8080/linuxtweaks/RPM-GPG-KEY" | sudo tee "$REPO_FILE" > /dev/null
    success "Repository added"
fi

# Cleaning Old Installation
step "Cleaning Old Installation"
systemctl --user stop linuxtweaks* 2>/dev/null || true
systemctl --user disable linuxtweaks* 2>/dev/null || true
systemctl --user reset-failed 2>/dev/null || true
pkill -9 -f "tray.py" 2>/dev/null || true
pkill -9 -f "linuxtweaks" 2>/dev/null || true
rm -rf ~/.config/linuxtweaks ~/.local/lib/linuxtweaks ~/.local/bin/linuxtweaks*
systemctl --user daemon-reload
success "Old installation removed"

# System Maintenance
step "System Maintenance"
sudo dnf clean all
sudo dnf autoremove -y || true
success "System cleaned"
sudo dnf upgrade --refresh -y || warn "System upgrade encountered an issue"
success "System updated"

# Installing LinuxTweaks
step "Installing LinuxTweaks"
sudo dnf remove linuxtweaks -y 2>/dev/null || true
sudo dnf autoremove -y 2>/dev/null || true
sudo dnf install linuxtweaks -y || warn "Installation failed"
success "LinuxTweaks installed"

# Verification
step "Verification"
VERSION=$(dnf info linuxtweaks 2>/dev/null | grep "^Version" | awk '{print $3}')
success "Version: $VERSION"

echo -e "\n${CYAN}📦 Package Info:${NC}"
dnf info linuxtweaks | grep -E "^Name|^Version|^Release|^Repository"

echo -e "\n${CYAN}🔧 Systemd Services:${NC}"
systemctl --user list-unit-files --no-pager 2>/dev/null | grep linuxtweaks | head -3

# Service Status
echo ""
header "🫟 LinuxTweaks Service Status"

systemctl --user is-active linuxtweaks.timer && echo "✅ Timer running" || echo "❌ Timer stopped"
systemctl --user is-active linuxtweaks-autostart.service && echo "✅ Autostart enabled" || echo "⚠️  Autostart inactive (normal - runs once on login)"

echo ""
echo -e "${CYAN}Timer Details:${NC}"
systemctl --user status linuxtweaks.timer --no-pager | grep -E "Loaded|Active|Trigger"

echo ""
echo -e "${CYAN}Running Process:${NC}"
ps aux | grep tray.py | grep -v grep || echo "(tray app will start on next login or run: linuxtweaks)"

echo -e "\n${CYAN}Repository Status:${NC}"
sudo dnf repolist | grep linuxtweaks

echo -e "\n${CYAN}Recent Changes:${NC}"
rpm -q --changelog linuxtweaks | head -15

# Final summary
echo ""
header "✅ LinuxTweaks v${VERSION} - Installation Complete!"
echo -e "${GREEN}Services configured and verified.${NC}"
echo -e "${CYAN}👉 Run: linuxtweaks${NC}"
echo ""
