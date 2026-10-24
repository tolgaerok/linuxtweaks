<a id="top"></a>

<div align="center">

# 📚 Sources and references

**Everything I read, borrowed ideas from and kept open in a tab while building LinuxTweaks.**

[⬅ Back to the README](README.md)

</div>

---

LinuxTweaks comes in three builds now, one for Fedora, one for Solus and one for AerynOS. They share most of the app, but they install, update and package things very differently, and each distro has its own rules I stick to. So the sources live on three pages:

<div align="center">

| | | |
|:---:|:---:|:---:|
| [**🎩 Fedora sources**](SOURCES-FEDORA.md) | [**🌀 Solus sources**](SOURCES-SOLUS.md) | [**🪨 AerynOS sources**](SOURCES-AERYNOS.md) |
| RPM packaging, dnf5, Negativo17 and RPM Fusion, the GPU tab, SELinux, grubby, my own repo, and what's shared: the offline check, restarting services, usage sharing | eopkg, solbuild and `package.yml`, Solus's own NVIDIA packages, AppArmor, clr-boot-manager, offline the eopkg way, MEGAsync in a box, signed eopkgs on GitHub | moss and boulder, `stone.yaml`, moss states and why old ones stop reading, the new 0.26.10 commands, my own moss repo on your pc, blsforme and the boot menu, signed stones on GitHub |

</div>

Both pages are grouped by what each source helped with, show a small piece of the app next to it, and have **Try it yourself** boxes: short, safe commands you can paste into a terminal to see the same thing LinuxTweaks looks at. Most only read. The few that change something say so, and say how to put it back.

What's the same on all three, the tray and window (Python and Qt), systemd timers, polkit, the desktop standards, Bash and the Health tab's report, is written up once on the [Fedora page](SOURCES-FEDORA.md) and linked from the Solus and AerynOS ones.

## The rules I follow

- **Fedora:** the [Fedora Packaging Guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/). NVIDIA drivers and full codecs aren't part of Fedora, they come from a third party repo, and I only ever use **one**: [Negativo17](https://negativo17.org/nvidia-driver/) or [RPM Fusion](https://rpmfusion.org/Configuration), never both. They ship the same things under different names. Never NVIDIA's `.run` installer.
- **Solus:** the [Solus packaging docs](https://help.getsol.us/docs/packaging/) and [packaging practices](https://help.getsol.us/docs/packaging/packaging-practices). Drivers come from the Solus repo, the way the [Solus NVIDIA guide](https://help.getsol.us/docs/user/hardware/nvidia-gpu-drivers) says. Apps from outside go through Flatpak, as [Solus recommends](https://help.getsol.us/docs/user/software/third-party/). No Fedora repos, no extra package managers.
- **AerynOS:** the [AerynOS packaging docs](https://aerynos.com/packaging/), `release` up by 1 on every build that goes out. `/usr` is the OS and `/etc` is yours, the [stateless way](https://aerynos.com/aerynos/philosophy/). Every change goes through moss so it's a [state you can go back to](https://aerynos.com/users/system-management/moss-state-management/), and every remove does a dry run first. It stays my own signed stone, the [AerynOS recipes repo](https://github.com/AerynOS/recipes/blob/main/PACKAGING_POLICY.md) doesn't take anything made with AI tools.

If something here helped you too, the people who wrote it deserve the thanks.

---

<div align="center">

[⬅ Back to the README](README.md) · [⬆ Back to top](#top)

</div>
