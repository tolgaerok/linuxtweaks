#!/usr/bin/env python3
# Tolga Erok
# 26-3-2025

# APP IMAGE LOCATION:      /usr/local/bin/LinuxTweaks/images/LinuxTweak.png
# APP LOCATION:            /usr/local/bin/LinuxTweaks/LinuxTweaks.py
# PYTHON ONLINE FORMATTER: https://codebeautify.org/python-formatter-beautifier#
# SYMLINK:                 sudo ln -s /usr/local/bin/LinuxTweaks/LinuxTweaks.py /usr/local/bin/linuxtweaks
# Installer:               curl -sL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/installer.sh | sudo bash

import sys
from PyQt6.QtWidgets import QApplication
from modules.tray import SystemTray

# Define services to monitor
services = ["ssh", "cron", "NetworkManager"]


def main():
    app = QApplication(sys.argv)
    tray_icon = SystemTray(app, services)
    tray_icon.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
