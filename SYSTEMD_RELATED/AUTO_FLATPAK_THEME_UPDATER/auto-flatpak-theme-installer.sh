#!/usr/bin/env bash
# Tolga Erok
# 18/4/2025

# my personal script to set up Flatpak theme installer and auto updater with systemd
# Tested on: Makulu (debian)
#            BigLinux (arch)

# BUG FIX: some flathub org.gtk.Gtk3theme with stable are not avaiable like Yaru-dark

set -e

echo "Creating systemd service and timer for Tolga's Flatpak Theme Installer..."

# create Flatpak Theme Installer service
sudo tee /etc/systemd/system/tolga-install-flatpak-themes.service >/dev/null <<'EOF'
[Unit]
Description=Tolga's Flatpak Theme Installer
Wants=network-online.target flatpak.service
After=network-online.target flatpak.service

[Service]
Type=oneshot
RemainAfterExit=true
ExecStartPre=/usr/bin/bash -c "if ! command -v flatpak &> /dev/null; then echo 'Flatpak is not installed!'; exit 1; fi"
ExecStartPre=/usr/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
ExecStart=/usr/bin/bash -c '\
  flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3//stable || echo "⚠️ Failed to install adw-gtk3"; \
  flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3-dark//stable || echo "⚠️ Failed to install adw-gtk3-dark"; \
  flatpak install -y flathub org.gtk.Gtk3theme.Yaru || echo "⚠️ Failed to install Yaru"; \
  flatpak install -y flathub org.gtk.Gtk3theme.Yaru-dark || echo "⚠️ Failed to install Yaru-dark"; \
  flatpak install -y flathub org.gtk.Gtk3theme.Yaru-olive-dark || echo "⚠️ Failed to install Yaru-olive-dark"; \
  flatpak install -y flathub org.gtk.Gtk3theme.Yaru-Deepblue//stable || echo "⚠️ Failed to install Yaru-Deepblue"; \
  flatpak install -y flathub org.gtk.Gtk3theme.Yaru-Deepblue-dark//stable || echo "⚠️ Failed to install Yaru-Deepblue-dark"; \
  flatpak override --user --env=GTK_THEME=adw-gtk3; \
  flatpak override --user --env=USE_POINTER_VIEWPORT=1; \
  flatpak override --user --filesystem=xdg-config/gtk-4.0:ro; \
  flatpak override --user --unset-env=QT_QPA_PLATFORMTHEME; \
'
EOF

# create the timer for tolga's theme installer
sudo tee /etc/systemd/system/tolga-install-flatpak-themes.timer >/dev/null <<'EOF'
[Unit]
Description=Tolga's Flatpak Theme Installer Timer

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "Creating systemd service and timer for Tolga's Flatpak Auto Updater..."

# set permissions
sudo chmod 644 /etc/systemd/system/tolga-install-flatpak-themes.{service,timer}
sudo chown root:root /etc/systemd/system/tolga-install-flatpak-themes.{service,timer}

# reload systemd and enable my timers
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now tolga-install-flatpak-themes.timer

# start my services once immediately
sudo systemctl restart tolga-install-flatpak-themes.service

# show my services status
systemctl status tolga-install-flatpak-themes.service --no-pager

echo "✅ Tolga's Flatpak services and timers installed and running."
systemctl list-timers | grep tolga-install-flatpak-themes.timer

# optional GTK3 theme lister
read -rp $'\n❓ Do you want to list available GTK3 themes from Flathub? [y/N]: ' reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
    echo -e "\n🔍 Searching for available GTK3 themes...\n"
    flatpak search Gtk3theme
fi
