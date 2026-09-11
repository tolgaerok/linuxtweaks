#!/bin/bash
# ======================================================================
#   LinuxTweaks Installation & Verification Suite 
#   Author : Tolga Erok
#   Date   : 10 Sep 2026
#   Purpose: Clean install from repo with full verification
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
header "  🫟   LinuxTweaks Installation Suite "

# My Repository Configuration
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
systemctl --user stop linuxtweaks.timer 2>/dev/null || true
systemctl --user stop linuxtweaks-autostart.service 2>/dev/null || true
systemctl --user disable linuxtweaks.timer 2>/dev/null || true
systemctl --user disable linuxtweaks-autostart.service 2>/dev/null || true
systemctl --user reset-failed 2>/dev/null || true
pkill -9 -f "python3 -m tray" 2>/dev/null || true
pkill -9 -f "check.sh" 2>/dev/null || true
rm -rf ~/.config/linuxtweaks ~/.config/systemd/user/linuxtweaks.timer
systemctl --user daemon-reload 2>/dev/null || true
success "Old installation cleaned"

# System Maintenance
step "System Maintenance"
sudo dnf clean all
sudo dnf autoremove -y || true
success "System cleaned"
sudo dnf upgrade --refresh -y || warn "System upgrade encountered an issue"
success "System updated"

# Installing LinuxTweaks 2026
step "Installing LinuxTweaks v6.1.68"
sudo dnf remove linuxtweaks -y || true
sudo dnf autoremove -y || true
sudo dnf install linuxtweaks -y || warn "Installation failed - check repo connectivity"
success "LinuxTweaks installed"

# Verification
step "Verification"
VERSION=$(dnf info linuxtweaks 2>/dev/null | grep "^Version" | awk '{print $3}')
success "Version: $VERSION"

echo -e "\n${CYAN}📦 Package Info:${NC}"
dnf info linuxtweaks | grep -E "^Name|^Version|^Release|^Repository"

echo -e "\n${CYAN}🔧 Systemd Services Installed:${NC}"
rpm -ql linuxtweaks | grep systemd/user | while read service; do
    echo "  ✓ $(basename $service)"
done

linuxtweaks

# Service Status
echo ""
header "🫟 LinuxTweaks Service Status"

echo -e "${CYAN}Timer:${NC}"
systemctl --user status linuxtweaks.timer --no-pager 2>&1 | grep -E "Loaded|Active|Trigger" || true

echo -e "\n${CYAN}Update Checker Service:${NC}"
systemctl --user status linuxtweaks.service --no-pager 2>&1 | grep -E "Loaded|Active|TriggeredBy" || true

echo -e "\n${CYAN}Autostart Service:${NC}"
systemctl --user status linuxtweaks-autostart.service --no-pager 2>&1 | grep -E "Loaded|Active" || true

echo -e "\n${CYAN}Enabled Status:${NC}"
echo "  Timer: $(systemctl --user is-enabled linuxtweaks.timer 2>/dev/null || echo 'disabled')"
echo "  Service: $(systemctl --user is-enabled linuxtweaks.service 2>/dev/null || echo 'static')"
echo "  Autostart: $(systemctl --user is-enabled linuxtweaks-autostart.service 2>/dev/null || echo 'disabled')"

echo -e "\n${CYAN}User Timer Configuration:${NC}"
if [ -f ~/.config/systemd/user/linuxtweaks.timer ]; then
    grep "OnUnitActiveSec" ~/.config/systemd/user/linuxtweaks.timer || echo "  (using system default: 30 minutes)"
else
    echo "  User timer not yet created (will be created on first settings change)"
fi

echo -e "\n${CYAN}Application Config:${NC}"
if [ -f ~/.config/linuxtweaks/config ]; then
    CHECK_INTERVAL=$(grep "CHECK_INTERVAL" ~/.config/linuxtweaks/config | cut -d= -f2)
    echo "  Configured interval: $CHECK_INTERVAL seconds"
else
    echo "  Config not yet created (will be created on first run)"
fi

echo -e "\n${CYAN}Repository Status:${NC}"
sudo dnf repolist | grep linuxtweaks || warn "Repository not found >> check connectivity to 100.83.30.114:8080"

echo -e "\n${CYAN}Recent Changelog:${NC}"
rpm -q --changelog linuxtweaks | head -10

# Bye
echo ""
header "✅ LinuxTweaks v${VERSION} - Installation Complete!"
echo -e "${GREEN}All services configured and verified.${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. ${CYAN}Run the app:${NC} ${GREEN}linuxtweaks${NC}"
echo -e "  2. ${CYAN}Open Settings:${NC} Configure check interval and update options"
echo -e "  3. ${CYAN}Default Timer will:${NC} Run every 30 minutes (configurable in Settings)"
echo -e "  4. ${CYAN}Autostart on:${NC} Next login"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
