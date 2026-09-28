#!/bin/bash
# ======================================================================
#   LinuxTweaks Updater - Installation & Verification Suite
#   Author : Tolga Erok
#   Date   : 28 Sep 2026
#   Purpose: Install LinuxTweaks Updater from my repo, with verification.
#            Replaces the old LinuxTweaks 6.x app (package "linuxtweaks")
#            automatically.
# ======================================================================
set -e
clear 2>/dev/null || true  # no TERM (e.g. over ssh) must not stop the install

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

PACKAGE="linuxtweaks-updater"
REPO_URL="http://100.83.30.114:8080/linuxtweaks"
REPO_FILE="/etc/yum.repos.d/linuxtweaks.repo"

# ── Start ──────────────────────────────────────────────────
header "  🫟   LinuxTweaks Updater Installation Suite "

# My Repository Configuration - always rewritten, so older copies (some had
# gpgcheck=0) get the signature check and the hourly refresh
step "Repository Configuration"
echo -e "[linuxtweaks]\nname=LinuxTweaks Repository\nbaseurl=${REPO_URL}/\nenabled=1\ngpgcheck=1\ngpgkey=${REPO_URL}/RPM-GPG-KEY\n# check for new uploads at least hourly\nmetadata_expire=1h" | sudo tee "$REPO_FILE" > /dev/null
success "Repository configured (signed packages, checked hourly)"

# The old LinuxTweaks 6.x app - the new package replaces it (dnf removes it
# in the same step), this just stops it running first. Exact names only: a
# linuxtweaks* pattern would also hit the new linuxtweaks-updater.
step "Stopping the old LinuxTweaks 6.x app (if you have it)"
systemctl --user stop linuxtweaks.timer linuxtweaks.service linuxtweaks-autostart.service 2>/dev/null || true
systemctl --user disable linuxtweaks.timer linuxtweaks-autostart.service 2>/dev/null || true
pkill -9 -f "/usr/lib/linuxtweaks/tray" 2>/dev/null || true
pkill -9 -f "python3 -m tray" 2>/dev/null || true
systemctl --user reset-failed 2>/dev/null || true
success "Done"

# Leftovers of older LinuxTweaks versions (pre-RPM copies in ~/.local, their
# user timers/autostart that keep starting the old app, unowned /usr files)
step "Cleaning up old LinuxTweaks leftovers"
curl -fsSL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/LINUXTWEAKS/POST-INSTALL/cleanup-old-linuxtweaks.sh | bash -s -- --apply ||
    warn "Couldn't run the old-version cleanup - you can run it later (see README)"

# System Maintenance
step "System Maintenance"
sudo dnf clean all
sudo dnf upgrade --refresh -y || warn "System upgrade encountered an issue"

# Install - dnf asks once to import my signing key
step "Installing ${PACKAGE}"
sudo dnf install --refresh -y "$PACKAGE" || { warn "Installation failed - check repo connectivity to 100.83.30.114:8080"; exit 1; }
VERSION=$(rpm -q --qf '%{VERSION}' "$PACKAGE")
success "${PACKAGE} ${VERSION} installed"

# Verification
step "Verification"
success "Package installed: $(rpm -q "$PACKAGE")"
if rpm -q --qf '%{NAME}\n' linuxtweaks 2>/dev/null | grep -qx linuxtweaks; then
    warn "old linuxtweaks 6.x still installed - remove it with: sudo dnf remove linuxtweaks"
else
    success "Old LinuxTweaks 6.x app not present"
fi

echo -e "\n${CYAN}Starting the tray app...${NC}"
linuxtweaks-updater
sleep 3

echo -e "\n${CYAN}Background timers:${NC}"
echo "  Update check:       $(systemctl --user is-enabled linuxtweaks-updater-check.timer 2>/dev/null || echo 'enables on first start')"
echo "  Weekly maintenance: $(systemctl --user is-enabled linuxtweaks-updater-maintenance.timer 2>/dev/null || echo 'enables on first start')"
if pgrep -u "$(id -u)" -f '^python3 /usr/lib/linuxtweaks-updater/tray/tray.py' >/dev/null; then
    success "Tray app running"
else
    warn "Tray app not running - start it with: linuxtweaks-updater"
fi

echo -e "\n${CYAN}Repository Status:${NC}"
sudo dnf repolist | grep linuxtweaks || warn "Repository not found >> check connectivity to 100.83.30.114:8080"

echo -e "\n${CYAN}Recent Changelog:${NC}"
rpm -q --changelog "$PACKAGE" | head -10

# Bye
echo ""
header "✅ LinuxTweaks Updater v${VERSION} - Installation Complete!"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. ${CYAN}Look for the icon${NC} in your system tray - right-click it for the menu"
echo -e "  2. ${CYAN}Help:${NC} tray menu > About > Help"
echo -e "  3. ${CYAN}Checks for updates${NC} every 30 minutes by default (tray menu > Check interval)"
echo -e "  4. ${CYAN}Starts by itself${NC} at every login"
echo -e "  5. ${CYAN}New versions${NC} arrive with a normal: sudo dnf upgrade"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
