#!/bin/bash
# tolga erok
# 14-4-25

# URL for the Makulu Lindoz-D packages
base_url="https://sourceforge.net/projects/makulu/files/lindoz-d/packages"

# get list of available packages on his site
echo "Fetching package list from Makulu Lindoz-D repository..."
package_list=$(curl -s "$base_url/" | grep -oP 'href="\K.*?(?=")' | grep -E 'nvidia|kernel|suspend' | sort -u)

# are these packages available?
if [ -z "$package_list" ]; then
    echo "No relevant packages found. Please check the repository URL or your internet connection."
    exit 1
fi

# show available NVIDIA driver versions from his site
echo "Available NVIDIA driver packages:"
echo "$package_list" | grep 'nvidia' | nl

read -p "Enter the number corresponding to the NVIDIA driver you wish to install: " driver_selection

total_drivers=$(echo "$package_list" | grep 'nvidia' | wc -l)
if ! [[ "$driver_selection" =~ ^[0-9]+$ ]] || [ "$driver_selection" -lt 1 ] || [ "$driver_selection" -gt "$total_drivers" ]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

selected_driver=$(echo "$package_list" | grep 'nvidia' | sed -n "${driver_selection}p")

# sort the corresponding kernel and suspend packages
kernel_package=$(echo "$package_list" | grep 'kernel' | grep "$(basename "$selected_driver" | cut -d'-' -f2)" | head -n 1)
suspend_package=$(echo "$package_list" | grep 'suspend' | grep "$(basename "$selected_driver" | cut -d'-' -f2)" | head -n 1)

# show what packages to be downloaded from his site
echo "The following packages will be downloaded and installed:"
echo "NVIDIA Driver: $selected_driver"
echo "Kernel Package: $kernel_package"
echo "Suspend Package: $suspend_package"

temp_dir=$(mktemp -d)
cd "$temp_dir" || exit 1

# download the selected packages from his site
echo "Downloading packages..."
wget "$base_url/$selected_driver/download" -O "$(basename "$selected_driver")"
wget "$base_url/$kernel_package/download" -O "$(basename "$kernel_package")"
wget "$base_url/$suspend_package/download" -O "$(basename "$suspend_package")"

echo "Installing packages..."
sudo dpkg -i *.deb

# clean up
cd ~
rm -rf "$temp_dir"

echo "Installation complete. Please reboot your system to apply the changes."