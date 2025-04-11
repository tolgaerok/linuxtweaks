#!/usr/bin/env python3
# Tolga Erok
# 26-3-2025
# Version:                  5.0

import sys
import subprocess
from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QLabel, QPushButton,
    QSystemTrayIcon, QMenu, QListWidget, QMessageBox
)
from PyQt6.QtGui import QAction, QIcon
from PyQt6.QtCore import Qt, QTimer

app_icon = "/usr/local/bin/LinuxTweaks/images/LinuxTweak.png"
icon_amber = "🛠️"
icon_green = "✔️"
icon_red = "❌️"

def get_tolga_services():
    """Fetch all active system and user-level services containing 'tolga'."""
    services = set()

    # System-wide services
    system_output = subprocess.run(
        ["systemctl", "list-units", "--type=service", "--all", "--no-pager", "--no-legend"],
        capture_output=True, text=True
    ).stdout
    services.update(
        line.split()[0] for line in system_output.splitlines()
        if "tolga" in line
    )

    # User-level services
    user_output = subprocess.run(
        ["systemctl", "--user", "list-units", "--type=service", "--all", "--no-pager", "--no-legend"],
        capture_output=True, text=True
    ).stdout
    services.update(
        line.split()[0] for line in user_output.splitlines()
        if "tolga" in line
    )

    return sorted(services)

def check_service_status(service):
    """Returns status icon and string for each service."""
    try:
        cmd = ["systemctl", "show", service, "--no-pager"]
        if subprocess.run(["systemctl", "--user", "status", service], capture_output=True).returncode == 0:
            cmd.insert(1, "--user")
        output = subprocess.run(cmd, capture_output=True, text=True).stdout

        active_state = next((l.split("=")[1] for l in output.splitlines() if l.startswith("ActiveState=")), "unknown")
        result = next((l.split("=")[1] for l in output.splitlines() if l.startswith("Result=")), "unknown")

        if active_state == "active" or (active_state == "inactive" and result == "success"):
            return icon_green, " Active   "
        elif active_state == "inactive":
            return icon_red, " Inactive"
        else:
            return icon_amber, " Unknown "
    except Exception:
        return icon_red, " Error"

class LinuxTweakMonitor(QWidget):
    def __init__(self, tray_icon):
        super().__init__()
        self.tray_icon = tray_icon
        self.setWindowTitle("LinuxTweak Service Monitor")
        self.setGeometry(100, 100, 350, 300)
        self.layout = QVBoxLayout()

        self.service_list = QListWidget()
        self.layout.addWidget(self.service_list)

        self.start_button = QPushButton("Start Service")
        self.stop_button = QPushButton("Stop Service")
        self.restart_button = QPushButton("Restart Service")
        self.layout.addWidget(self.start_button)
        self.layout.addWidget(self.stop_button)
        self.layout.addWidget(self.restart_button)

        self.start_button.clicked.connect(lambda: self.manage_service("start"))
        self.stop_button.clicked.connect(lambda: self.manage_service("stop"))
        self.restart_button.clicked.connect(lambda: self.manage_service("restart"))

        self.setLayout(self.layout)
        self.refresh_status()

    def refresh_status(self):
        self.service_list.clear()
        self.services = get_tolga_services()

        service_statuses = [
            (svc, *check_service_status(svc)) for svc in self.services
        ]
        service_statuses.sort(key=lambda x: ("Active" not in x[2], "Inactive" in x[2]))

        for svc, icon, status in service_statuses:
            self.service_list.addItem(f"{icon}{status} :  {svc}")

        self.tray_icon.update_status()

    def manage_service(self, action):
        selected_item = self.service_list.currentItem()
        if not selected_item:
            QMessageBox.warning(self, "No Service Selected", "Please select a service.")
            return

        service = selected_item.text().split(":")[-1].strip()
        is_user_service = subprocess.run(
            ["systemctl", "--user", "status", service], capture_output=True
        ).returncode == 0

        cmd = ["systemctl"]
        if is_user_service:
            cmd.append("--user")

        subprocess.run(cmd + ["daemon-reexec"], check=True)
        subprocess.run(cmd + [action, service], capture_output=True)
        self.refresh_status()
        QTimer.singleShot(100, self.tray_icon.update_status)

class LinuxTweakTray:
    def __init__(self):
        self.app = QApplication(sys.argv)
        self.tray = QSystemTrayIcon(QIcon(app_icon))
        self.tray.setToolTip("LinuxTweak Service Monitor")

        self.menu = QMenu()
        self.show_app_action = QAction("Open Service Monitor")
        self.show_app_action.triggered.connect(self.open_app)
        self.refresh_action = QAction("Refresh")
        self.refresh_action.triggered.connect(self.update_status)
        self.exit_action = QAction("Exit")
        self.exit_action.triggered.connect(self.app.quit)

        self.menu.addAction(self.show_app_action)
        self.menu.addAction(self.refresh_action)
        self.menu.addSeparator()
        self.menu.addAction(self.exit_action)

        self.tray.setContextMenu(self.menu)
        self.tray.activated.connect(self.tray_clicked)

        self.window = LinuxTweakMonitor(self)
        self.update_status()
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_status)
        self.timer.start(5000)

        self.tray.show()

    def update_status(self):
        statuses = [(svc, *check_service_status(svc)) for svc in get_tolga_services()]

        tooltip = ""
        for svc, icon, status in statuses:
            tooltip += f"{icon}{status} : {svc}\n"

        self.tray.setToolTip(tooltip.strip())
        self.tray.setIcon(QIcon(app_icon))

    def tray_clicked(self, reason):
        if reason == QSystemTrayIcon.ActivationReason.Trigger:
            self.open_app()

    def open_app(self):
        self.window.refresh_status()
        self.window.show()

    def run(self):
        self.app.exec()

if __name__ == "__main__":
    tray = LinuxTweakTray()
    tray.run()
