

# **Flatpak Auto-Update SystemD Script**  

> Tolga Erok

> 21/3/2025





<p align="center">
  <img src="images/flatpak-autoupdate/flatpak-auto-update.png" alt="alt text">
</p>

<p align="center">
  <img src="images/flatpak-autoupdate/notification-working.png" alt="alt text">
</p>

<p align="center">
  <i>For those who just want their apps to stay fresh without the extra effort, this script does the job.</i>
</p>

## Simplifying Updates for You

From my experience, manually checking for Flatpak updates can be tedious, especially if you forget or don’t feel like dealing with it. This script automates the process, saving you time and ensuring your Flatpak apps are always up to date without any `hassle`.
Why Use It?

I believe this script could really help users who prefer a `set-and-forget` method to keep their apps updated. Instead of manually running flatpak update, it handles everything through a simple `systemd service` and `timer`. It checks for updates as soon as your *system boots, every six hours, and when your PC wakes from suspend.*

If you’re like me and appreciate automating routine tasks, you’ll likely find this useful. The script also ensures that updates occur even if your machine was asleep, keeping everything current.
How It Works

-    Checks if Flatpak is installed: Before running anything, the script checks if Flatpak is installed on your system.
-    Creates a `systemd service`: This runs the `flatpak update -y` command to update all your Flatpak apps without asking for confirmation.
-    Sets up a timer: The update process is scheduled to run right after boot, every `six` hours, and after waking up from `suspend`. This means you don’t have to worry about forgetting to check.
-    Enables and starts the timer: It sets everything in motion right away, making sure the updates happen automatically.
-    Displays status: At the end of the process, it shows you the status of both the service and timer, so you know when the next update is coming.

## Who Should Use This?

If you use Flatpak often and like the idea of keeping your apps up to date automatically, this script is a perfect fit. It’s especially helpful if you don’t want to think about updating and prefer using `systemd` over `cron` jobs. 

I feel it’s a solid choice for people who keep their system on all the `time` or use `suspend`.

*However, if you’re someone who prefers reviewing updates before installation or doesn’t use Flatpak much, this may not be necessary for you.*




### 🔗 *To view source code:*

```bash
https://github.com/tolgaerok/linuxtweaks/blob/main/modules/tolgas-tweaks/SYSTEMD_RELATED/auto-update-flatpaks.sh
```

### 🔗 *To `run` from the remote location:*

```bash
curl -sL https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/modules/tolgas-tweaks/SYSTEMD_RELATED/auto-update-flatpaks.sh
```

#
[📚 Back to Main Menu](https://github.com/tolgaerok/linuxtweaks/blob/main/README.md)

## *Other repositories in my git hub:*

<div align="center">
  <table style="border-collapse: collapse; width: 100%; border: none;">
    <tr>
     <td align="center" style="border: none;">
        <a href="https://github.com/tolgaerok/fedora-tolga">
          <img src="https://flathub.org/img/distro/fedora.svg" alt="Fedora" style="width: 100%;">
          <br>Fedora
        </a>
      </td>
      <td align="center" style="border: none;">
        <a href="https://github.com/tolgaerok/NixOS-tolga">
          <img src="https://flathub.org/img/distro/nixos.svg" alt="NixOs" style="width: 100%;">
          <br>NixOs 23.05
        </a>
      </td>
    </tr>
  </table>
</div>

## *My Stats:*

<div align="center">

<div style="text-align: center;">
  <a href="https://git.io/streak-stats" target="_blank">
    <img src="http://github-readme-streak-stats.herokuapp.com?user=tolgaerok&theme=dark&background=000000" alt="GitHub Streak" style="display: block; margin: 0 auto;">
  </a>
  <div style="text-align: center;">
    <a href="https://github.com/anuraghazra/github-readme-stats" target="_blank">
      <img src="https://github-readme-stats.vercel.app/api/top-langs/?username=tolgaerok&layout=compact&theme=vision-friendly-dark" alt="Top Languages" style="display: block; margin: 0 auto;">
    </a>
  </div>
</div>
</div>
