# Tolga Erok
# 26-3-2025

# APP IMAGE LOCATION:      /usr/local/bin/LinuxTweaks/images/LinuxTweak.png
# APP LOCATION:            /usr/local/bin/LinuxTweaks/LinuxTweaks.py
# PYTHON ONLINE FORMATTER: https://codebeautify.org/python-formatter-beautifier#
# SYMLINK:                 sudo ln -s /usr/local/bin/LinuxTweaks/LinuxTweaks.py /usr/local/bin/linuxtweaks
# Installer:               curl -sL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/installer.sh | sudo bash

from PyQt6.QtWidgets import QWidget, QVBoxLayout, QListWidget, QPushButton, QMessageBox
from PyQt6.QtCore import QTimer
from modules.services import check_service_status, manage_service


class LinuxTweakMonitor(QWidget):
    def __init__(self, tray_icon, services):
        super().__init__()
        self.tray_icon = tray_icon
        self.setWindowTitle("LinuxTweak Service Monitor")
        self.setGeometry(100, 100, 350, 300)
        self.layout = QVBoxLayout()

        # Service list
        self.service_list = QListWidget()
        self.layout.addWidget(self.service_list)

        # Buttons
        self.start_button = QPushButton("Start Service")
        self.stop_button = QPushButton("Stop Service")
        self.restart_button = QPushButton("Restart Service")
        self.layout.addWidget(self.start_button)
        self.layout.addWidget(self.stop_button)
        self.layout.addWidget(self.restart_button)

        # Button actions
        self.start_button.clicked.connect(lambda: self.handle_service("start"))
        self.stop_button.clicked.connect(lambda: self.handle_service("stop"))
        self.restart_button.clicked.connect(lambda: self.handle_service("restart"))

        self.setLayout(self.layout)
        self.services = services  # Service list passed from main.py
        self.refresh_status()

    def refresh_status(self):
        """Update service status in the list box"""
        self.service_list.clear()

        service_statuses = []
        for service in self.services:
            icon, status = check_service_status(service)
            service_statuses.append((service, icon, status))

        # Sort services: Active → Inactive → Disabled
        service_statuses.sort(key=lambda x: ("Active" not in x[2], "Disabled" in x[2]))

        for service, icon, status in service_statuses:
            self.service_list.addItem(f"{icon}{status} :  {service}")

        self.tray_icon.update_status()

    def handle_service(self, action):
        """Start/Stop/Restart selected service"""
        selected_item = self.service_list.currentItem()
        if not selected_item:
            QMessageBox.warning(self, "No Service Selected", "Please select a service.")
            return

        service_name = selected_item.text().split(":")[-1].strip()
        manage_service(action, service_name)

        self.refresh_status()
        QTimer.singleShot(100, self.tray_icon.update_status)
