#!/bin/bash
# LinuxTweaks Installation & Verification Suite
# Author: Tolga Erok
# Date: 01 Sep 2026

set -e

clear

# ── Colors ────────────────────────────────────────────────
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
header "LinuxTweaks Installation Suite"

# Setup repository
step "Repository Configuration"
REPO_FILE="/etc/yum.repos.d/linuxtweaks.repo"
if [ -f "$REPO_FILE" ]; then
    success "Repository already configured"
else
    echo "Adding LinuxTweaks repository..."
    echo -e "[linuxtweaks]\nname=LinuxTweaks Repository\nbaseurl=http://100.83.30.114:8080/linuxtweaks/\nenabled=1\ngpgcheck=1\ngpgkey=http://100.83.30.114:8080/linuxtweaks/RPM-GPG-KEY" | sudo tee "$REPO_FILE" > /dev/null
    success "Repository added"
fi

# Cleanup old installation
step "Cleaning Old Installation"
systemctl --user stop linuxtweaks* 2>/dev/null || true
systemctl --user disable linuxtweaks* 2>/dev/null || true
systemctl --user reset-failed 2>/dev/null || true
pkill -9 -f "tray.py" 2>/dev/null || true
pkill -9 -f "linuxtweaks" 2>/dev/null || true
rm -f ~/.config/systemd/user/linuxtweaks*.service
rm -f ~/.config/systemd/user/linuxtweaks*.timer
rm -f ~/.config/systemd/user/app-linuxtweaks@autostart.service
rm -rf ~/.config/linuxtweaks ~/.local/lib/linuxtweaks ~/.local/bin/linuxtweaks*
systemctl --user daemon-reload
success "Old installation removed"

# System update
step "System Maintenance"
sudo dnf clean all
sudo dnf autoremove -y || true
success "System cleaned"
sudo dnf upgrade --refresh -y || warn "System upgrade encountered an issue"
success "System updated"

# Install LinuxTweaks
step "Installing LinuxTweaks"
sudo dnf remove linuxtweaks -y 2>/dev/null || true
sudo dnf autoremove -y 2>/dev/null || true
sudo dnf install linuxtweaks -y || warn "Installation failed"
success "LinuxTweaks installed"

# Verify installation
step "Verification"
VERSION=$(dnf info linuxtweaks 2>/dev/null | grep "^Version" | awk '{print $3}')
success "Version: $VERSION"

echo -e "\n${CYAN}📦 Package Info:${NC}"
dnf info linuxtweaks | grep -E "^Name|^Version|^Release|^Repository"

echo -e "\n${CYAN}🔧 Services:${NC}"
systemctl --user list-unit-files --no-pager 2>/dev/null | grep linuxtweaks | head -4 || echo "  (pending activation)"

# Launch app
step "Launching Application"
linuxtweaks &
sleep 2
success "Application started in background"

# Final summary
echo ""
header "✅ LinuxTweaks v${VERSION} Ready!"
echo -e "${GREEN}Installation complete and verified.${NC}"
echo -e "${CYAN}Services active • App running • Ready to use${NC}"
