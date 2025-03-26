#!/bin/bash
# Tolga Erok
# 19/12/2024
# CHANGE_LOG: 18/3/2025 : ADD MULTIPLE REPOS

# Setup Git Repository and GitHub SSH Authentication

### --- > Configuration
REPO_NAME1="tolga-scripts"
REPO_NAME2="linuxtweaks"
GIT_USER_NAME="Tolga Erok"
GIT_USER_EMAIL="kingtolga@gmail.com"
GITHUB_USERNAME="tolgaerok"
LOCAL_REPO_DIR="/home/tolga/MyGit"
SSH_KEY_COMMENT="${GIT_USER_EMAIL}"

# Ensure Git is installed
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

# Ensure SSH is configured
if ! ssh-add -l &>/dev/null; then
    echo "SSH agent is not running, starting it..."
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
else
    echo "SSH agent is already running."
fi

### --- > Create Directory and Clone Repository (if needed)
echo "Creating directory for Git repository..."
mkdir -p "${LOCAL_REPO_DIR}"
cd "${LOCAL_REPO_DIR}" || exit 1

# Clone repositories if they do not exist
if [ ! -d "${LOCAL_REPO_DIR}/${REPO_NAME1}" ]; then
    echo "Cloning repository: ${REPO_NAME1}..."
    git clone git@github.com:${GITHUB_USERNAME}/${REPO_NAME1}.git
fi

if [ ! -d "${LOCAL_REPO_DIR}/${REPO_NAME2}" ]; then
    echo "Cloning repository: ${REPO_NAME2}..."
    git clone git@github.com:${GITHUB_USERNAME}/${REPO_NAME2}.git
fi

### --- > Set Global Git Configuration
echo "Configuring global Git settings..."
git config --global user.email "${GIT_USER_EMAIL}"
git config --global user.name "${GIT_USER_NAME}"
git config --global init.defaultBranch main
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=25000'
git config --global push.default simple

### --- > Setup SSH Key for GitHub Authentication
echo "Generating SSH key for GitHub authentication..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "${SSH_KEY_COMMENT}" -f ~/.ssh/id_rsa -N ""
fi

### --- > Display and Configure SSH
echo "Displaying SSH public key (add to GitHub settings):"
cat ~/.ssh/id_rsa.pub

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

### --- > Configure Local Repositories for SSH
echo "Configuring local repositories for SSH..."

# Set remote for REPO_NAME1
cd "${LOCAL_REPO_DIR}/${REPO_NAME1}" || exit 1
git remote set-url origin "git@github.com:${GITHUB_USERNAME}/${REPO_NAME1}.git"
git remote -v

# Set remote for REPO_NAME2
cd "${LOCAL_REPO_DIR}/${REPO_NAME2}" || exit 1
git remote set-url origin "git@github.com:${GITHUB_USERNAME}/${REPO_NAME2}.git"
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
