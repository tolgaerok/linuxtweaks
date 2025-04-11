#!/usr/bin/env python3
# Tolga Erok
# Version: 3.2 - Now supports `.service` and `.timer` units from both system & user level

import sys
import subprocess
from PyQt6.QtWidgets import (
    QApplication,
    QWidget,
    QVBoxLayout,
    QPushButton,
    QListWidget,
    QMessageBox,
    QSystemTrayIcon,
    QMenu,
)
from PyQt6.QtGui import QAction, QIcon
from PyQt6.QtCore import QTimer

app_icon = "/usr/local/bin/LinuxTweaks/images/LinuxTweak.png"
icon_amber = "🛠️"
icon_green = "✔️"
icon_red = "❌️"


def list_units(unit_type):
    """Helper to fetch units of a given type (service or timer) from both scopes."""
    units = set()

    # System
    sys_cmd = [
        "systemctl",
        "list-units",
        f"--type={unit_type}",
        "--all",
        "--no-pager",
        "--no-legend",
    ]
    sys_output = subprocess.run(sys_cmd, capture_output=True, text=True).stdout
    units.update(line.split()[0] for line in sys_output.splitlines() if "tolga" in line)

    # User
    usr_cmd = [
        "systemctl",
        "--user",
        "list-units",
        f"--type={unit_type}",
        "--all",
        "--no-pager",
        "--no-legend",
    ]
    usr_output = subprocess.run(usr_cmd, capture_output=True, text=True).stdout
    units.update(line.split()[0] for line in usr_output.splitlines() if "tolga" in line)

    return sorted(units)


def get_tolga_units():
    return list_units("service") + list_units("timer")


def check_status(unit):
    """Determine if unit is system or user, and check its status."""
    try:
        # Determine scope
        is_user = (
            subprocess.run(
                ["systemctl", "--user", "status", unit], capture_output=True
            ).returncode
            == 0
        )
        base_cmd = ["systemctl", "--user"] if is_user else ["systemctl"]
        output = subprocess.run(
            base_cmd + ["show", unit, "--no-pager"], capture_output=True, text=True
        ).stdout

        active_state = next(
            (
                l.split("=")[1]
                for l in output.splitlines()
                if l.startswith("ActiveState=")
            ),
            "unknown",
        )
        result = next(
            (l.split("=")[1] for l in output.splitlines() if l.startswith("Result=")),
            "unknown",
        )

        if active_state == "active" or (
            active_state == "inactive" and result == "success"
        ):
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

        self.start_button = QPushButton("Start")
        self.stop_button = QPushButton("Stop")
        self.restart_button = QPushButton("Restart")
        self.layout.addWidget(self.start_button)
        self.layout.addWidget(self.stop_button)
        self.layout.addWidget(self.restart_button)

        self.start_button.clicked.connect(lambda: self.manage("start"))
        self.stop_button.clicked.connect(lambda: self.manage("stop"))
        self.restart_button.clicked.connect(lambda: self.manage("restart"))

        self.setLayout(self.layout)
        self.refresh_status()

    def refresh_status(self):
        self.service_list.clear()
        self.units = get_tolga_units()

        statuses = [(unit, *check_status(unit)) for unit in self.units]
        statuses.sort(key=lambda x: ("Active" not in x[2], "Inactive" in x[2]))

        for unit, icon, state in statuses:
            self.service_list.addItem(f"{icon}{state} :  {unit}")

        self.tray_icon.update_status()

    def manage(self, action):
        item = self.service_list.currentItem()
        if not item:
            QMessageBox.warning(self, "No Unit Selected", "Please select a unit.")
            return

        unit = item.text().split(":")[-1].strip()
        is_user = (
            subprocess.run(
                ["systemctl", "--user", "status", unit], capture_output=True
            ).returncode
            == 0
        )
        cmd = ["systemctl", "--user"] if is_user else ["systemctl"]
        subprocess.run(cmd + [action, unit], capture_output=True)
        self.refresh_status()


class LinuxTweakTray:
    def __init__(self):
        self.app = QApplication(sys.argv)
        self.tray = QSystemTrayIcon(QIcon(app_icon))
        self.menu = QMenu()

        self.window = LinuxTweakMonitor(self)

        self.menu.addAction("Open Service Monitor", self.open_app)
        self.menu.addAction("Refresh", self.update_status)
        self.menu.addSeparator()
        self.menu.addAction("Exit", self.app.quit)

        self.tray.setContextMenu(self.menu)
        self.tray.activated.connect(self.tray_clicked)
        self.update_status()

        self.timer = QTimer()
        self.timer.timeout.connect(self.update_status)
        self.timer.start(5000)

        self.tray.show()

    def update_status(self):
        tooltip = ""
        statuses = [(unit, *check_status(unit)) for unit in get_tolga_units()]
        for unit, icon, state in statuses:
            tooltip += f"{icon}{state} : {unit}\n"
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
