echo "Hack Club Regis Server Configurator version 1.0.3"
echo "This is intended for SERVER USE ONLY. Running this on your laptop is NOT advised."
echo "This application expects sudo permissions. If you didn't already, run this with 'sudo curl' instead."
echo "The installation will begin in 10 seconds. Press Ctrl + C NOW to abort."
sleep 10

echo ""
echo "Activating GNOME remote desktop, please wait."
echo "Keep an eye out for a sudo permissions prompt."
sudo grdctl --system rdp enable
sudo grdctl --system rdp disable-view-only
read -r -p "Enter username to set for RDP: " username
read -r -p "Enter password to set for RDP: " password
sudo grdctl --system rdp set-credentials $username $password
sudo systemctl enable --now gnome-remote-desktop.service
sudo ufw allow 3389/tcp
echo "GNOME Remote Desktop configuration was a success! See IP details at end of install."


curl -O https://repo.anaconda.com/archive/Anaconda3-2026.07-1-Linux-x86_64.sh
bash ./Anaconda3-2026.07-1-MacOSX-arm64.sh -b -p $HOME/anaconda3
source ~/anaconda3/bin/activate
conda init --all

conda create --name $(hostname) python=3.14
conda activate $(hostname)

python_packages = (
    "tkinter",
    "flask",
    "ollama",
    "openai",
    "PyGithub",
    "python-dotenv",
    "requests",
    "cryptography",
    "PyJWT"
)
for package in python_packages
do 
    pip install $package
done

echo "Installation successful."
echo "IP details: "
echo $(ip a)