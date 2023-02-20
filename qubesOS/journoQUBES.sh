#!/bin/bash

set -euo pipefail

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Define variables
templates=("fedora-36" "fedora-36-minimal" "debian-11" "debian-11-minimal")
writ_vm="writ"
writ_vm_template="debian-11"
template_browser_name="t-browser"
appvm_browser_name="browser"
browsers="chromium torbrowser-launcher firefox-esr"
template_vault_name="t-vault"
appvm_vault_name="source"
vm_comms_name="comms"
template_comms_name="debian-11-minimal"
comms_apt_packages="whatsdesk curl signal-desktop telegram-desktop"
vpn_config_file="/home/user/vpn_config.ovpn"
appvm_VPN_name="fedora-vpn"
appvm_VPN_template="fedora-36-minimal"
qubes_networking_packages=("qubes-core-agent-networking" "qubes-core-agent-network-manager" "qubes-network-manager")
required_packages=("openvpn" "qubes-core-agent-networking" "qubes-core-agent-network-manager" "qubes-network-manager")


# Install pv if not already installed
if ! type pv > /dev/null; then
    echo "Installing pv..."
    sudo qubes-dom0-update pv
    echo "pv installation complete."
fi

# Define a function to run a command in the writ VM
run_in_writ_vm() {
    echo "Running command in writ VM: $1"
    qvm-run -v -a "$writ_vm" "$1" | pv -p -t -e -b > /dev/null
}

# Install templates and default appVMs
for template in "${templates[@]}"; do
    echo "Installing $template template..."
    qubesctl --skip-dom0 --targets="$template" --show-output state.sls qvm.present | pv -p -t -e -b > /dev/null
done
echo "Installing the default templates and appVMs..."
qubesctl state.sls qvm.template qvm.app | pv -p -t -e -b > /dev/null

# Create a standalone writer offline VM and install applications
echo "Creating the writ VM..."
qvm-create -v --class Standalone --template "$writ_vm_template" --label blue "$writ_vm" --standalone --no-netvm | pv -p -t -e -b > /dev/null
run_in_writ_vm 'echo "deb http://deb.playonlinux.com/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/playonlinux.list'
run_in_writ_vm 'wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -'
run_in_writ_vm 'sudo apt-get update && sudo apt-get install -y playonlinux'
run_in_writ_vm 'POL_WINEVERSION="5.22" playonlinux --run "Scrivener" /silent /sp- /no-desktop'
run_in_writ_vm 'sudo apt-get update && sudo apt-get install -y libreoffice'
run_in_writ_vm 'sudo apt-get clean'
echo "Configuration of writ VM complete."

# Create template for AV
echo "Creating template for AV..."
qvm-create -v --class Template --label red --template fedora-36-minimal --property virt_mode=appvm --property kernelopts=console=ttyS0,115200n8 --property virt_mode=appvm t-av | pv -p -t -e -b > /dev/null || { echo "Failed to create the t-av template. Aborting." >&2; exit 1; }

# Install required Qubes services for networking
echo "Installing required Qubes services for networking..."
qvm-run -v -a t-av 'sudo dnf install -y qubes-core-agent-networking qubes-core-agent-dom0-updates qubes-core-agent-passwordless-root' | pv -p -t -e -b > /dev/null || { echo "Failed to install required Qubes services for networking. Aborting." >&2; exit 1; }

# Install Zoom, Teams, and Google Chat in the t-av template
echo "Installing Zoom, Teams, and Google Chat in the t-av template..."
qvm-run -v -a t-av 'sudo dnf install -y https://dl.zoom.us/linux/client/zoom_x86_64.rpm' | pv -p -t -e -b > /dev/null || { echo "Failed to install Zoom in the t-av template. Aborting." >&2; exit 1; }
qvm-run -v -a t-av 'sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && sudo curl -o /etc/yum.repos.d/teams.repo https://packages.microsoft.com/yumrepos/ms-teams.repo && sudo dnf install -y teams' | pv -p -t -e -b > /dev/null || { echo "Failed to install Teams in the t-av template. Aborting." >&2; exit 1; }
qvm-run -v -a t-av 'sudo dnf install -y google-chrome-stable' | pv -p -t -e -b > /dev/null || { echo "Failed to install Google Chat in the t-av template. Aborting." >&2; exit 1; }

# Create Qube for AV
echo "Creating the AV Qube..."
qvm-create -v --label red --template t-av --property virt_mode=appvm --property kernelopts=console=ttyS0,115200n8 AV | pv -p -t -e -b > /dev/null || { echo "Failed to create the AV Qube. Aborting." >&2; exit 1; }

echo "Configuration of AV VM and template complete...."

# Create template for browser
echo "Creating template for browser..."
if ! qvm-create -v --class Template --label grey --template fedora-36-minimal --property netvm=sys-vpn --property kernelopts=console=ttyS0,115200n8 "$TEMPLATE_BROWSER_NAME" | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the $TEMPLATE_BROWSER_NAME template. Aborting." >&2
    exit 1
fi

# Install required Qubes services for networking and browsers in the t-browser template
echo "Installing required Qubes services for networking and browsers in the $TEMPLATE_BROWSER_NAME template..."
if ! qvm-run -v -a "$TEMPLATE_BROWSER_NAME" "sudo dnf install -y qubes-core-agent-networking qubes-core-agent-network-manager qubes-network-manager $BROWSERS" | pv -p -t -e -b > /dev/null; then
    echo "Failed to install the required Qubes services for networking and browsers in the $TEMPLATE_BROWSER_NAME template. Aborting." >&2
    exit 1
fi

# Create a new Qube for the browser AppVM based on the t-browser template, add arkenfox user.js file and rename Firefox .desktop file
echo "Creating a new Qube for the $APPVM_BROWSER_NAME AppVM based on the $TEMPLATE_BROWSER_NAME template, adding arkenfox user.js file and renaming Firefox .desktop file..."
if qvm-create -v --label grey --template "$TEMPLATE_BROWSER_NAME" --property netvm=sys-vpn "$APPVM_BROWSER_NAME" \
&& qvm-run -v -a "$APPVM_BROWSER_NAME" 'mkdir -p ~/.mozilla/firefox/*.default-release && curl -sL https://raw.githubusercontent.com/arkenfox/user.js/master/user.js > ~/.mozilla/firefox/*.default-release/user.js' \
&& qvm-run -v -a "$APPVM_BROWSER_NAME" 'mv ~/.local/share/applications/firefox-esr.desktop ~/.local/share/applications/arkenfox.desktop' | pv -p -t -e -b > /dev/null; then
    echo "Configuration of browser AppVM and template complete." 
else
    echo "Failed to configure the browser AppVM and template. Aborting." >&2
    exit 1
fi

echo "Configuration of browser VM and template complete...."
fi

# Create the vault VM based on the fedora-36-minimal template
echo "Creating the $APPVM_VAULT_NAME VM based on the $TEMPLATE_VAULT_NAME template..."
if ! qvm-create -v --label red --class StandaloneVM --property virt_mode=linux --property kernelopts=console=ttyS0,115200n8 --template fedora-36-minimal "$APPVM_VAULT_NAME" | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the $APPVM_VAULT_NAME VM based on the $TEMPLATE_VAULT_NAME template. Aborting." >&2
    exit 1
fi

# Install qubes-core-agent-passwordless-root in the vault VM
echo "Installing qubes-core-agent-passwordless-root in the $APPVM_VAULT_NAME VM..."
if ! qvm-run -v -a -p -u root "$APPVM_VAULT_NAME" 'dnf install -y qubes-core-agent-passwordless-root' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install qubes-core-agent-passwordless-root in the $APPVM_VAULT_NAME VM. Aborting." >&2
    exit 1
fi

# Create and attach private storage volume to the vault VM
echo "Creating and attaching a private storage volume to the $APPVM_VAULT_NAME VM..."
if ! qvm-run -v -a -p "$APPVM_VAULT_NAME" 'qvm-volume create --label red private; qvm-block attach private dom0:/dev/mapper/dm-root; mkdir -p /mnt/private; mount /dev/dm-3 /mnt/private; chown user:user /mnt/private; chmod 700 /mnt/private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to create and attach the private storage volume to the $APPVM_VAULT_NAME VM. Aborting." >&2
    exit 1
fi

# Unmount and detach the private storage volume from the vault VM, then remove it
echo "Unmounting, detaching, and removing the private storage volume from the $APPVM_VAULT_NAME VM..."
if ! qvm-run -v -a -p "$APPVM_VAULT_NAME" 'umount /mnt/private; qvm-block detach private; qvm-volume remove private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to unmount, detach, and remove the private storage volume from the $APPVM_VAULT_NAME VM. Aborting." >&2
    exit 1
fi

# Set the max RAM for the vault VM to 128MB
if ! qvm-prefs -v --set "$APPVM_VAULT_NAME" memory 128 | pv -p -t -e -b > /dev/null; then
    echo "Failed to set the max RAM for the $APPVM_VAULT_NAME VM to 128MB. Aborting." >&2
    exit 1
fi

echo "The $APPVM_VAULT_NAME VM has been created and configured successfully."

# Create the comms VM
echo "Creating the new AppVM '$VM_COMMS_NAME'..."
if ! qvm-create --label red --template "$TEMPLATE_COMMS_NAME" "$VM_COMMS_NAME" | pv -p -t -e -b > /dev/null && \
     qvm-service --enable --all "$VM_COMMS_NAME" | qvm-run --auto --pass-io "$VM_COMMS_NAME" "sudo apt-get update; \
     sudo apt-get install -y $COMMS_APT_PACKAGES" | pv -p -t -e -b > /dev/null; then
    echo "Failed to create and configure the new AppVM '$VM_COMMS_NAME'. Aborting." >&2
    exit 1
fi
echo "The new AppVM '$VM_COMMS_NAME' has been created and configured successfully."

#!/bin/bash

set -euo pipefail

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Check if VPN config file exists
if [ ! -f "$vpn_config_file" ]; then
  echo "Error: VPN config file $vpn_config_file not found."
  exit 1
fi

# Create the AppVM for VPN
echo "Creating the AppVM for VPN: $appvm_name..."
qvm-create --label black --template "$appvm__VPN_template" "$appvm_VPN_name" \
  && qvm-run --pass-io $appvm_VPN_name "sudo dnf install -y ${qubes_networking_packages[*]} qubes-core-agent-passwordless-root" \
  || { echo "Error: Failed to create the AppVM for VPN." >&2; exit 1; }

# Install required packages in the AppVM
for package in "${required_packages[@]}"; do
  if ! qvm-run -a "$appvm_VPN_name" "which $package" > /dev/null; then
    echo "Installing $package..."
    qvm-run -a "$appvm_VPN_name" "sudo dnf install -y $package" \
      || { echo "Error: Failed to install $package in the AppVM." >&2; exit 1; }
  fi
done

# Copy VPN config file to the AppVM
echo "Copying VPN config file to AppVM: $appvm_VPN_name..."
qvm-run --pass-io "$appvm_VPN_name" "cat > /rw/config/vpn_config.ovpn" < "$vpn_config_file"

# Install and set up OpenVPN in the AppVM
echo "Setting up OpenVPN in AppVM: $appvm_VPN_name..."
qvm-run -p "$appvm_VPN_name" "sudo dnf install -y openvpn" \
  && qvm-run --pass-io -p "$appvm_VPN_name" "sudo openvpn --config /rw/config/vpn_config.ovpn &" \
  || { echo "Error: Failed to set up OpenVPN in the AppVM." >&2; exit 1; }

echo "VPN is now running in AppVM: $appvm_VPN_name."

# Notes for the user to complete the setup:
echo "Please manually configure the AppVM to use the VPN for network traffic.
- Open NetworkManager from the system tray or in the AppVM's settings.
- In the VPN tab, click 'Add'.
- Select 'Import from file' and select the VPN config file from /rw/config/vpn_config.ovpn.
- In the General tab, make sure 'Automatically connect to VPN when using this connection' is checked.
- Save and close the VPN settings.
- Restart the network service: sudo systemctl restart NetworkManager."

echo "All VMs created successfully!"
echo "journoQUBES install complete."
