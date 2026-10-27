#!/usr/bin/env bash
set -euo pipefail

echo "Hack Club Regis Server Configurator version 1.0.5"
echo "This is intended for SERVER USE ONLY. Running this on your laptop is NOT advised."
echo "Run this script as your normal user. It will request sudo when necessary."
echo "The installation will begin in 10 seconds. Press Ctrl + C NOW to abort."
sleep 10

echo ""
echo "Activating GNOME remote desktop, please wait."

sudo grdctl --system rdp enable
sudo grdctl --system rdp disable-view-only

read -r -p "Enter username to set for RDP: " username
read -r -s -p "Enter password to set for RDP: " password
echo ""

sudo grdctl --system rdp set-credentials "$username" "$password"
unset password username

sudo systemctl enable --now gnome-remote-desktop.service
sudo ufw allow 3389/tcp

echo "GNOME Remote Desktop configuration was a success!"

echo ""
echo "Downloading Anaconda..."

INSTALLER="Anaconda3-2026.07-1-Linux-x86_64.sh"
INSTALL_DIR="$HOME/anaconda3"

curl -fL "https://repo.anaconda.com/archive/$INSTALLER" -o "$INSTALLER"

bash "./$INSTALLER" -b -p "$INSTALL_DIR"

rm -f "./$INSTALLER"

source "$INSTALL_DIR/etc/profile.d/conda.sh"

conda tos accept --override-channels \
    --channel https://repo.anaconda.com/pkgs/main

conda tos accept --override-channels \
    --channel https://repo.anaconda.com/pkgs/r

ENV_NAME="$(hostname -s | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9_-.' '-')"

echo "Creating Conda environment: $ENV_NAME"

conda create \
    --name "$ENV_NAME" \
    python=3.14 \
    tk \
    pip \
    --yes -q

PYTHON_PACKAGES=(
    flask
    ollama
    openai
    PyGithub
    python-dotenv
    requests
    cryptography
    PyJWT
)

echo "Installing Python packages..."

conda run -n "$ENV_NAME" python -m pip install "${PYTHON_PACKAGES[@]}"

echo ""
echo "Installation successful!"
echo "Conda environment: $ENV_NAME"
echo "To activate it in a future terminal, run:"
echo "  conda activate \"$ENV_NAME\""
echo ""
echo "IP details:"
ip -brief address