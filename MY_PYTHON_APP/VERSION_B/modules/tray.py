# Tolga Erok
# 26-3-2025

# APP IMAGE LOCATION:      /usr/local/bin/LinuxTweaks/images/LinuxTweak.png
# APP LOCATION:            /usr/local/bin/LinuxTweaks/LinuxTweaks.py
# PYTHON ONLINE FORMATTER: https://codebeautify.org/python-formatter-beautifier#
# SYMLINK:                 sudo ln -s /usr/local/bin/LinuxTweaks/LinuxTweaks.py /usr/local/bin/linuxtweaks
# Installer:               curl -sL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/installer.sh | sudo bash

from PyQt6.QtWidgets import QSystemTrayIcon, QMenu
from PyQt6.QtGui import QIcon
from modules.monitor import LinuxTweakMonitor


class SystemTray(QSystemTrayIcon):
    def __init__(self, app, services):
        super().__init__()
        self.setIcon(QIcon("icon.png"))
        self.setToolTip("LinuxTweaks")

        menu = QMenu()
        open_monitor = menu.addAction("Open Monitor")
        exit_action = menu.addAction("Exit")

        open_monitor.triggered.connect(self.open_monitor)
        exit_action.triggered.connect(app.quit)

        self.setContextMenu(menu)
        self.monitor_window = LinuxTweakMonitor(self, services)

    def open_monitor(self):
        self.monitor_window.show()

    def update_status(self):
        pass  # Implement status update logic if needed
