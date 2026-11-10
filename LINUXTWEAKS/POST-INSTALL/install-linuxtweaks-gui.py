#!/usr/bin/env python3
# 👁️‍🗨️ Created by: Tolga Erok
# 📧 Email:      kingtolga@gmail.com
# 📡 GitHub:     https://github.com/tolgaerok/linuxtweaks
# SPDX-License-Identifier: GPL-3.0-or-later
#
# the window for install-linuxtweaks.sh, Nord like my release windows. it
# does nothing itself, it runs the script and shows what it says.
# install-linuxtweaks.sh opens me, you never run me by hand.

import sys
from pathlib import Path

try:
    from PyQt6.QtCore import QProcess, Qt
    from PyQt6.QtGui import QIcon, QPixmap
    from PyQt6.QtWidgets import (QApplication, QCheckBox, QFrame, QHBoxLayout, QLabel, QMessageBox,
                                 QPlainTextEdit, QPushButton, QVBoxLayout, QWidget)
    YES, NO = QMessageBox.StandardButton.Yes, QMessageBox.StandardButton.No
except ImportError:
    from PyQt5.QtCore import QProcess, Qt
    from PyQt5.QtGui import QIcon, QPixmap
    from PyQt5.QtWidgets import (QApplication, QCheckBox, QFrame, QHBoxLayout, QLabel, QMessageBox,
                                 QPlainTextEdit, QPushButton, QVBoxLayout, QWidget)
    YES, NO = QMessageBox.Yes, QMessageBox.No

SCRIPT = sys.argv[1] if len(sys.argv) > 1 else "install-linuxtweaks.sh"
# my LinuxTweaks icon, the script puts it next to me
ICON = Path(__file__).resolve().parent / "install-linuxtweaks-icon.png"
TAGS = {"fedora": ("Fedora", "#51a2da"), "solus": ("Solus", "#5294e2"), "aerynos": ("AerynOS", "#b48ead")}
HOW = {"fedora": ("RPM", "my key, checked with rpmkeys before anything installs", "dnf"),
       "solus": ("eopkg", "its .asc and my key, gpgv says good or it stops", "eopkg"),
       "aerynos": ("stone", "its .asc and my key, then my moss repo on GitHub", "moss")}
STYLE = """
QWidget { background: #2e3440; color: #eceff4; font-size: 14px; }
#head { font-size: 20px; font-weight: bold; }
#sub { color: #88c0d0; font-size: 13px; }
#logo { background: #b5e61d; color: #2e3440; border-radius: 24px; font-size: 18px; font-weight: bold; }
#card { background: #3b4252; border: 1px solid #4c566a; border-radius: 10px; }
#card QLabel, #card QCheckBox { background: transparent; }
#cardTitle { color: #88c0d0; font-size: 15px; font-weight: bold; }
#info { color: #d8dee9; font-size: 13px; }
#note { color: #81a1c1; font-size: 12px; }
QPushButton { background: #434c5e; border: 2px solid #88c0d0; border-radius: 4px; padding: 5px 14px; font-size: 13px; }
QPushButton:hover { background: #4c566a; }
QPushButton:disabled { color: #4c566a; border-color: #4c566a; }
QPushButton#go { background: #a3be8c; color: #2e3440; border-color: #a3be8c; font-weight: bold; }
QPushButton#red { border-color: #bf616a; }
QPlainTextEdit { background: #272c36; color: #d8dee9; border: 1px solid #4c566a; border-radius: 8px;
                 font-family: "Fira Code", monospace; font-size: 12px; }
QCheckBox { color: #eceff4; font-size: 13px; spacing: 8px; }
QCheckBox::indicator { width: 16px; height: 16px; border: 2px solid #88c0d0; border-radius: 4px; background: #2e3440; }
QCheckBox::indicator:checked { background: #a3be8c; border-color: #a3be8c; }
"""
EDGE = {"green": "#a3be8c", "orange": "#d08770", "red": "#bf616a"}


def kb(size):
    try:
        return f"{int(size) // 1024} KB"
    except ValueError:
        return "?"


def newer(have, new):
    def key(v):
        return [int(n) for n in v.split(".") if n.isdigit()]
    return bool(new) and key(new) > key(have)


class Window(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("LinuxTweaks installer")
        self.setStyleSheet(STYLE)
        self.resize(640, 520)
        self.info = {}
        self.proc = None
        self.steps = []
        lay = QVBoxLayout(self)
        lay.setContentsMargins(18, 18, 18, 18)
        lay.setSpacing(12)
        top = QHBoxLayout()
        logo = QLabel()
        logo.setFixedSize(48, 48)
        pix = QPixmap(str(ICON))
        if pix.isNull():
            # no icon, GitHub didn't hand it over: my green circle with LT
            logo.setText("LT")
            logo.setObjectName("logo")
            logo.setAlignment(Qt.AlignmentFlag.AlignCenter if hasattr(Qt, "AlignmentFlag") else Qt.AlignCenter)
        else:
            logo.setPixmap(pix.scaled(48, 48, Qt.AspectRatioMode.KeepAspectRatio if hasattr(Qt, "AspectRatioMode")
                                      else Qt.KeepAspectRatio,
                                      Qt.TransformationMode.SmoothTransformation if hasattr(Qt, "TransformationMode")
                                      else Qt.SmoothTransformation))
            self.setWindowIcon(QIcon(str(ICON)))
        top.addWidget(logo)
        words = QVBoxLayout()
        words.setSpacing(0)
        heading = QHBoxLayout()
        head = QLabel("LinuxTweaks installer")
        head.setObjectName("head")
        self.tag = QLabel()
        heading.addWidget(head)
        heading.addSpacing(8)
        heading.addWidget(self.tag)
        heading.addStretch()
        words.addLayout(heading)
        self.sub = QLabel("looking at your pc…")
        self.sub.setObjectName("sub")
        words.addWidget(self.sub)
        top.addLayout(words, 1)
        lay.addLayout(top)
        self.body = QVBoxLayout()
        self.body.setSpacing(12)
        lay.addLayout(self.body)
        lay.addStretch()
        self.buttons = QHBoxLayout()
        lay.addLayout(self.buttons)
        self.note = QLabel()
        self.note.setObjectName("note")
        self.note.setWordWrap(True)
        lay.addWidget(self.note)
        self.run(["--info"], self.got_info)

    # ---- bits ----

    def clear(self):
        """empties the cards and buttons"""
        for box in (self.body, self.buttons):
            while box.count():
                item = box.takeAt(0)
                if item.widget():
                    item.widget().hide()
                    item.widget().deleteLater()

    def card(self, title, right="", edge=None):
        frame = QFrame()
        frame.setObjectName("card")
        if edge:
            frame.setStyleSheet(f"#card {{ border-left: 5px solid {EDGE[edge]}; }}")
        cl = QVBoxLayout(frame)
        cl.setContentsMargins(14, 10, 14, 12)
        row = QHBoxLayout()
        t = QLabel(title)
        t.setObjectName("cardTitle")
        row.addWidget(t)
        row.addStretch()
        if right:
            r = QLabel(right)
            r.setObjectName("note")
            row.addWidget(r)
        cl.addLayout(row)
        self.body.addWidget(frame)
        return cl

    def text(self, layout, words, name="info"):
        label = QLabel(words)
        label.setObjectName(name)
        label.setWordWrap(True)
        layout.addWidget(label)
        return label

    def button(self, words, then, name=""):
        b = QPushButton(words)
        if name:
            b.setObjectName(name)
        b.clicked.connect(then)
        self.buttons.addWidget(b)
        return b

    def run(self, args, then, lines=None):
        """runs the script and passes on what it says"""
        self.proc = QProcess(self)
        self.proc.setProcessChannelMode(QProcess.ProcessChannelMode.MergedChannels
                                        if hasattr(QProcess, "ProcessChannelMode") else QProcess.MergedChannels)
        out = []

        def read():
            data = bytes(self.proc.readAllStandardOutput()).decode(errors="replace")
            for line in data.splitlines():
                out.append(line)
                if lines:
                    kind, _, words = line.partition(": ")
                    lines(kind, words)

        self.proc.readyReadStandardOutput.connect(read)
        self.proc.finished.connect(lambda code, _s: (read(), self._done(then, code, out)))
        self.proc.start("bash", [SCRIPT, "--plain", *args])

    def _done(self, then, code, out):
        self.proc = None
        then(code, out)

    # ---- what's on the box ----

    def got_info(self, _code, out):
        self.info = dict(line.split("=", 1) for line in out if "=" in line)
        distro = self.info.get("distro", "unknown")
        name, colour = TAGS.get(distro, (self.info.get("name", "?"), "#4c566a"))
        self.tag.setText(name)
        self.tag.setStyleSheet(f"background: {colour}; color: #2e3440; border-radius: 9px; "
                               "padding: 1px 10px; font-size: 12px; font-weight: bold;")
        self.clear()
        have, new = self.info.get("installed", ""), self.info.get("newest", "")
        if distro == "unknown":
            self.sub.setText(f"found {self.info.get('name', 'something')}")
            cl = self.card("Not a distro I know", self.info.get("name", ""), "red")
            self.text(cl, "LinuxTweaks is for Fedora, Solus and AerynOS. The Mint one isn't out yet.")
            self.button("Close", self.close)
            self.buttons.addStretch()
        elif not new:
            self.sub.setText(f"found {self.info.get('name')}")
            cl = self.card("Can't reach my GitHub", "", "red")
            self.text(cl, "Check your internet and try again. Nothing changed.")
            self.button("⟳ Try again", lambda: self.run(["--info"], self.got_info), "go")
            self.button("Close", self.close)
            self.buttons.addStretch()
        elif not have:
            self.fresh(distro, new)
        else:
            self.installed(have, new)

    def fresh(self, distro, new):
        kind, check, pm = HOW[distro]
        self.sub.setText(f"found {self.info.get('name')}, LinuxTweaks isn't on here yet")
        cl = self.card("What gets installed", "from my GitHub")
        self.text(cl, f"<b>linuxtweaks-updater {new}</b> ({kind}, {kb(self.info.get('size', ''))})<br>"
                      f"Checked with {check}<br>{pm} brings in what it needs, nothing else gets updated")
        self.extra = None
        if distro == "fedora":
            cl = self.card("Extras", "off unless you tick it")
            self.extra = QCheckBox("Get bandwhich for the Traffic tab (not in Fedora, from Terra by Fyra Labs)")
            cl.addWidget(self.extra)
        elif distro == "aerynos":
            cl = self.card("Extras", "off unless you tick it", "orange")
            self.extra = QCheckBox("Add the volatile repo too, newer packages sooner, can break now and then")
            cl.addWidget(self.extra)
        self.button("Install", self.install, "go")
        self.button("Close", self.close)
        self.buttons.addStretch()
        self.note.setText("One password, then it's all done in one go.")

    def installed(self, have, new):
        self.sub.setText(f"LinuxTweaks {have} is on here" + (f", {new} is up" if newer(have, new) else ""))
        cl = self.card("What do you want", "")
        if newer(have, new):
            self.text(cl, "You've got it already. Update it, or take it off.")
            self.button(f"Update to {new}", lambda: self.work(["--update"]), "go")
        else:
            self.text(cl, "You're on the newest. New versions come from About → Check for LinuxTweaks updates.")
        self.button("Remove LinuxTweaks", self.remove, "red")
        self.button("Close", self.close)
        self.buttons.addStretch()
        self.note.setText("Remove asks before it deletes your settings.")

    # ---- doing it ----

    def install(self):
        extras = ""
        if self.extra is not None and self.extra.isChecked():
            extras = "bandwhich" if self.info.get("distro") == "fedora" else "volatile"
        self.work(["--install", extras] if extras else ["--install"])

    def remove(self):
        self.run(["--remove-list"], self._remove_ask)

    def _remove_ask(self, _code, out):
        goes = "\n".join(f"   {line}" for line in out if line.strip()) or "   linuxtweaks-updater"
        if QMessageBox.question(self, "Remove LinuxTweaks",
                                f"This comes off your pc:\n\n{goes}\n\nGo ahead?", YES | NO, NO) == YES:
            self.work(["--remove"])

    def work(self, args):
        self.clear()
        self.sub.setText("working, don't close me")
        cl = self.card("Working", "")
        self.step_box = QVBoxLayout()
        cl.addLayout(self.step_box)
        self.log = QPlainTextEdit()
        self.log.setReadOnly(True)
        self.log.setMinimumHeight(140)
        cl.addWidget(self.log)
        self.steps = []
        self.result = ("", "")
        self.note.setText("A password box pops up once.")
        self.run(args, lambda code, _out: self.finished(code, args), self.line)

    def line(self, kind, words):
        if kind == "step":
            self._tick()
            row = QLabel(f"● {words}")
            row.setStyleSheet("color: #ebcb8b; background: transparent;")
            self.step_box.addWidget(row)
            self.steps.append(row)
        elif kind == "ok":
            self._tick(words)
        elif kind in ("done", "fail"):
            self._tick()
            self.result = (kind, words)
        else:
            self.log.appendPlainText(words)

    def _tick(self, words=None):
        if self.steps and self.steps[-1].text().startswith("●"):
            row = self.steps[-1]
            row.setText("✓ " + (words or row.text()[2:]))
            row.setStyleSheet("color: #a3be8c; background: transparent;")

    def finished(self, code, args):
        kind, words = self.result
        self.clear()
        if code == 0 and kind == "done":
            self.sub.setText("all done")
            cl = self.card("Done", "", "green")
            self.text(cl, words)
            if args[0] == "--remove":
                self.button("Close", self.close)
                self.buttons.addStretch()
                if QMessageBox.question(self, "Your settings", "Delete your LinuxTweaks settings too?\n\n"
                                        "~/.local/state, ~/.cache and ~/.config/linuxtweaks-updater",
                                        YES | NO, NO) == YES:
                    self.run(["--wipe"], lambda *_: self.note.setText("Your settings are gone too."))
                return
            self.text(cl, "It starts by itself when you log in. New versions come from "
                          "About → Check for LinuxTweaks updates, you won't need me again.")
            self.button("Close", self.close, "go")
            self.buttons.addStretch()
            self.note.setText("")
        else:
            self.sub.setText("that didn't work")
            cl = self.card("Didn't go through", "nothing changed", "red")
            said = self.log.toPlainText() if hasattr(self, "log") else ""
            self.text(cl, words or "Something went wrong, the log below says what.")
            if said.strip():
                log = QPlainTextEdit(said)
                log.setReadOnly(True)
                log.setMinimumHeight(120)
                cl.addWidget(log)
            self.button("⟳ Try again", lambda: self.run(["--info"], self.got_info), "go")
            self.button("Close", self.close)
            self.buttons.addStretch()
            self.note.setText("")

    def closeEvent(self, event):
        if self.proc is not None:
            event.ignore()
            self.note.setText("Still working, give it a sec.")
            return
        event.accept()


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("LinuxTweaks installer")
    w = Window()
    w.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
