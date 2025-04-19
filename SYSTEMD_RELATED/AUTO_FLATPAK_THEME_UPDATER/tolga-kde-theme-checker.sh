#!/bin/bash
# tolga erok
# 19/4/25

# detect current KDE theme info
kde_theme=$(lookandfeeltool -l | grep -i "current" | cut -d ':' -f2 | xargs)

echo "🖼️  Your current KDE theme: ${kde_theme:-unknown}"

# list of Flatpak GTK themes from my systemD install
themes=(
    "adw-gtk3"
    "adw-gtk3-dark"
    "Yaru"
    "Yaru-dark"
    "Yaru-olive-dark"
    "Yaru-Deepblue"
    "Yaru-Deepblue-dark"
)

echo "Select a GTK theme for Flatpak apps:"
select theme in "${themes[@]}"; do
    if [[ -n "$theme" ]]; then
        echo "🎨 Applying GTK_THEME=$theme to Flatpak apps..."
        flatpak override --user --env=GTK_THEME="$theme"
        flatpak override --user --unset-env=QT_QPA_PLATFORMTHEME
        echo "✅ Done! Restart your Flatpak apps to see the change."
        break
    else
        echo "❌ Invalid choice, try again."
    fi
done
