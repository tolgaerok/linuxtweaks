#!/bin/bash
# tolga erok
# 14-4-25

# URL for the Makulu Lindoz-D packages
base_url="https://sourceforge.net/projects/makulu/files/lindoz-d/packages"

# get list of available packages on his site
echo "Fetching package list from Makulu Lindoz-D repository..."
package_list=$(curl -s "$base_url/" | grep -oP 'href="\K.*?(?=")' | grep -E '\.deb$' | grep -E 'nvidia|kernel|suspend' | sort -u)

# are these packages available?
if [ -z "$package_list" ]; then
    echo "No relevant packages found. Please check the repository URL or your internet connection."
    exit 1
fi

# show available NVIDIA driver versions from his site
echo "Available NVIDIA driver packages:"
nvidia_list=$(echo "$package_list" | grep 'nvidia')
echo "$nvidia_list" | nl

# choose driver
read -p "Enter the number corresponding to the NVIDIA driver you wish to install: " driver_selection

# get total count for validation
total_drivers=$(echo "$nvidia_list" | wc -l)
if ! [[ "$driver_selection" =~ ^[0-9]+$ ]] || [ "$driver_selection" -lt 1 ] || [ "$driver_selection" -gt "$total_drivers" ]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

selected_driver=$(echo "$nvidia_list" | sed -n "${driver_selection}p")

# get version or keyword to match kernel/suspend
version_hint=$(basename "$selected_driver" | cut -d'-' -f2)

# sort the corresponding kernel and suspend packages
kernel_package=$(echo "$package_list" | grep 'kernel' | grep "$version_hint" | head -n 1)
suspend_package=$(echo "$package_list" | grep 'suspend' | grep "$version_hint" | head -n 1)

# show what packages to be downloaded from his site
echo "The following packages will be downloaded and installed:"
echo "NVIDIA Driver: $selected_driver"
echo "Kernel Package: $kernel_package"
echo "Suspend Package: $suspend_package"

# make temp directory for download
temp_dir=$(mktemp -d)
cd "$temp_dir" || exit 1

# download the selected packages from his site
echo "Downloading packages..."
wget "$base_url/$selected_driver/download" -O "$(basename "$selected_driver")"
wget "$base_url/$kernel_package/download" -O "$(basename "$kernel_package")"
wget "$base_url/$suspend_package/download" -O "$(basename "$suspend_package")"

# install packages
echo "Installing packages..."
sudo dpkg -i *.deb

# clean up
cd ~
rm -rf "$temp_dir"

echo "Installation complete. Please reboot your system to apply the changes."
