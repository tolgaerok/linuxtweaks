# Tolga Erok
# 26-3-2025

# APP IMAGE LOCATION:      /usr/local/bin/LinuxTweaks/images/LinuxTweak.png
# APP LOCATION:            /usr/local/bin/LinuxTweaks/LinuxTweaks.py
# PYTHON ONLINE FORMATTER: https://codebeautify.org/python-formatter-beautifier#
# SYMLINK:                 sudo ln -s /usr/local/bin/LinuxTweaks/LinuxTweaks.py /usr/local/bin/linuxtweaks
# Installer:               curl -sL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/installer.sh | sudo bash

import os
import subprocess
from PyQt6.QtWidgets import QSystemTrayIcon, QMenu, QMessageBox
from PyQt6.QtGui import QIcon
from PyQt6.QtCore import QTimer, QUrl
from PyQt6.QtGui import QDesktopServices
from modules.monitor import LinuxTweakMonitor


class SystemTray(QSystemTrayIcon):
    def __init__(self, app, services):
        super().__init__()

        # Ensure correct icon path
        icon_path = os.path.join(os.path.dirname(__file__), "../images/LinuxTweak.png")
        self.setIcon(QIcon(icon_path))
        self.setToolTip("LinuxTweaks")

        # Set up the menu
        menu = QMenu()
        open_monitor = menu.addAction("Open Monitor")
        exit_action = menu.addAction("Exit")
        check_updates_action = menu.addAction("Check for Updates")

        # connecting actions to menu options
        open_monitor.triggered.connect(self.open_monitor)
        exit_action.triggered.connect(app.quit)
        check_updates_action.triggered.connect(self.check_for_updates)

        self.setContextMenu(menu)
        self.monitor_window = LinuxTweakMonitor(self, services)

    def open_monitor(self):
        """Show the monitoring window"""
        self.monitor_window.show()

    def update_status(self):
        """Implement status update"""
        pass

    def check_for_updates(self):
        """Check if there's any updates available on my repo and update accordingly"""
        tmp_clone_dir = os.path.join(os.path.expanduser("~"), "linuxtweaks")
        linuxtweaks_repo = "https://github.com/tolgaerok/linuxtweaks.git"

        # Check if the repo already exists
        if os.path.isdir(tmp_clone_dir):
            # Update linuxtweaks repo
            print("Updating repository...")
            subprocess.run(["git", "-C", tmp_clone_dir, "pull"], check=True)
            self.show_update_notification(
                "Update Available", "The app has been updated successfully!"
            )
        else:
            # clone my repo if not exists
            print("Cloning repository...")
            subprocess.run(
                ["git", "clone", linuxtweaks_repo, tmp_clone_dir], check=True
            )
            self.show_update_notification(
                "Repo Cloned", "The app was cloned successfully! All hail KingTolga!"
            )

    def show_update_notification(self, title, message):
        """Show a notification with the app icon"""
        icon_path = os.path.join(os.path.dirname(__file__), "../images/LinuxTweak.png")
        self.showMessage(
            title, message, QSystemTrayIcon.Information, 5000, QIcon(icon_path)
        )
