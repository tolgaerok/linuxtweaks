#!/bin/bash
# Tolga Erok
# 19/12/2024
# CHANGE_LOG: 18/3/2025 : ADD MULTIPLE REPOS

# Setup Git Repository and GitHub SSH Authentication

### --- > Configuration
repo_name1="tolga-scripts"
repo_name2="linuxtweaks"
git_user_name="Tolga Erok"
git_user_email="kingtolga@gmail.com"
github_username="tolgaerok"
local_repo_dir="/home/tolga/MyGit"
ssh_key_comment="${git_user_email}"

# check Git is installed
if ! command -v git &>/dev/null; then
    echo "Git is not installed. Installing Git..."
    sudo apt-get install git -y  # Change for your distro
    if ! command -v git &>/dev/null; then
        echo "Git installation failed. Exiting."
        exit 1
    fi
else
    echo "Git is already installed."
fi

# check that SSH is configured
if ! ssh-add -l &>/dev/null; then
    echo "SSH agent is not running, starting it..."
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
else
    echo "SSH agent is already running."
fi

### --- > Create Dir and Clone Repository
echo "Creating directory for Git repository..."
mkdir -p "${local_repo_dir}"
cd "${local_repo_dir}" || exit 1

# lone repositories if they do not exist
if [ ! -d "${local_repo_dir}/${repo_name1}" ]; then
    echo "Cloning repository: ${repo_name1}..."
    git clone git@github.com:${github_username}/${repo_name1}.git
fi

if [ ! -d "${local_repo_dir}/${repo_name2}" ]; then
    echo "Cloning repository: ${repo_name2}..."
    git clone git@github.com:${github_username}/${repo_name2}.git
fi

### --- > Set Global Git Configuration
echo "Configuring global Git settings..."
git config --global user.email "${git_user_email}"
git config --global user.name "${git_user_name}"
git config --global init.defaultBranch main
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=25000'
git config --global push.default simple

### --- > Setup SSH Key for GitHub Authentication
echo "Generating SSH key for GitHub authentication..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "${ssh_key_comment}" -f ~/.ssh/id_rsa -N ""
fi

### --- > Display and Configure SSH
echo "Displaying SSH public key (add to GitHub settings):"
cat ~/.ssh/id_rsa.pub

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

### --- > Configure Local Repositories for SSH
echo "Configuring local repositories for SSH..."

# Set remote for repo_name1
cd "${local_repo_dir}/${repo_name1}" || exit 1
git remote set-url origin "git@github.com:${github_username}/${repo_name1}.git"
git remote -v

# Set remote for repo_name2
cd "${local_repo_dir}/${repo_name2}" || exit 1
git remote set-url origin "git@github.com:${github_username}/${repo_name2}.git"
git remote -v

### --- > Test SSH Connection
echo "Testing SSH connection with GitHub..."
ssh -T git@github.com

### --- > Secure SSH Files
echo "Securing SSH file permissions..."
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

### --- > Ensure Correct Ownership
echo "Ensuring correct ownership of SSH files..."
chown tolga:tolga ~/.ssh/config
chown tolga:tolga ~/.ssh/id_rsa
chown tolga:tolga ~/.ssh/id_rsa.pub

### --- > Final Check
echo "Final repository setup check..."
git remote -v
ssh -T git@github.com
