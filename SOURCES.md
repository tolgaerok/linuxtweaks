<a id="top"></a>

<div align="center">

# 📚 Sources and references

**Everything I read, borrowed ideas from and kept open in a tab while building LinuxTweaks.**

[⬅ Back to the README](README.md)

</div>

---

LinuxTweaks comes in two builds now, one for Fedora and one for Solus. They share most of the app, but they install, update and package things very differently, and each distro has its own rules I stick to. So the sources live on two pages:

<div align="center">

| | |
|:---:|:---:|
| [**🎩 Fedora sources**](SOURCES-FEDORA.md) | [**🌀 Solus sources**](SOURCES-SOLUS.md) |
| RPM packaging, dnf5, Negativo17 and RPM Fusion, the GPU tab, SELinux, grubby, my own repo | eopkg, solbuild and `package.yml`, Solus's own NVIDIA packages, AppArmor, clr-boot-manager, signed eopkgs on GitHub |

</div>

Both pages are grouped by what each source helped with, show a small piece of the app next to it, and have **Try it yourself** boxes: short, safe commands you can paste into a terminal to see the same thing LinuxTweaks looks at. Most only read. The few that change something say so, and say how to put it back.

What's the same on both, the tray and window (Python and Qt), systemd timers, polkit, the desktop standards, Bash and the Health tab's report, is written up once on the [Fedora page](SOURCES-FEDORA.md) and linked from the Solus one.

## The rules I follow

- **Fedora:** the [Fedora Packaging Guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/). NVIDIA drivers and full codecs aren't part of Fedora, they come from a third party repo, and I only ever use **one**: [Negativo17](https://negativo17.org/nvidia-driver/) or [RPM Fusion](https://rpmfusion.org/Configuration), never both. They ship the same things under different names. Never NVIDIA's `.run` installer.
- **Solus:** the [Solus packaging docs](https://help.getsol.us/docs/packaging/) and [packaging practices](https://help.getsol.us/docs/packaging/packaging-practices). Drivers come from the Solus repo, the way the [Solus NVIDIA guide](https://help.getsol.us/docs/user/hardware/nvidia-gpu-drivers) says. Apps from outside go through Flatpak, as [Solus recommends](https://help.getsol.us/docs/user/software/third-party/). No Fedora repos, no extra package managers.

If something here helped you too, the people who wrote it deserve the thanks.

---

<div align="center">

[⬅ Back to the README](README.md) · [⬆ Back to top](#top)

</div>
