#!/bin/bash
# tolga erok
# 14-4-25

# URL for the Makulu Lindoz-D packages
base_url="https://sourceforge.net/projects/makulu/files/lindoz-d/packages"

# get list of available packages on his site
echo "Fetching package list from Makulu Lindoz-D repository..."
package_list=$(curl -s "$base_url/" | grep -oP 'href="\K[^"]+' | grep -E '\.deb$' | grep -E 'nvidia|kernel|suspend' | sort -u)

# are these packages available?
if [ -z "$package_list" ]; then
    echo "No relevant packages found. Please check the repository URL or your internet connection."
    exit 1
fi

# show available NVIDIA driver versions from his site
echo "Available NVIDIA driver packages:"
driver_list=$(echo "$package_list" | grep 'nvidia')
echo "$driver_list" | nl

read -p "Enter the number corresponding to the NVIDIA driver you wish to install: " driver_selection

# user input
total_drivers=$(echo "$driver_list" | wc -l)
if ! [[ "$driver_selection" =~ ^[0-9]+$ ]] || [ "$driver_selection" -lt 1 ] || [ "$driver_selection" -gt "$total_drivers" ]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

# get selected driver package
selected_driver=$(echo "$driver_list" | sed -n "${driver_selection}p")

# match related kernel/suspend packages
driver_version=$(basename "$selected_driver" | cut -d'-' -f2)

# match kernel and suspend packages
kernel_package=$(echo "$package_list" | grep 'kernel' | grep "$driver_version" | head -n 1)
suspend_package=$(echo "$package_list" | grep 'suspend' | grep "$driver_version" | head -n 1)

# show what packages to be downloaded from his site
echo "The following packages will be downloaded and installed:"
echo "NVIDIA Driver: $selected_driver"
echo "Kernel Package: $kernel_package"
echo "Suspend Package: $suspend_package"

# create temp dir
temp_dir=$(mktemp -d)
cd "$temp_dir" || exit 1

# download the selected packages from his site
echo "Downloading packages..."
wget -q --show-progress "https://downloads.sourceforge.net/project/makulu/files/lindoz-d/packages/$selected_driver" -O "$(basename "$selected_driver")"
[ -n "$kernel_package" ] && wget -q --show-progress "https://downloads.sourceforge.net/project/makulu/files/lindoz-d/packages/$kernel_package" -O "$(basename "$kernel_package")"
[ -n "$suspend_package" ] && wget -q --show-progress "https://downloads.sourceforge.net/project/makulu/files/lindoz-d/packages/$suspend_package" -O "$(basename "$suspend_package")"

# install packages
echo "Installing packages..."
sudo dpkg -i *.deb

# clean up
cd ~
rm -rf "$temp_dir"

echo "Installation complete. Please reboot your system to apply the changes."
