#!/bin/bash

set -euo pipefail

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Install pv if not already installed
if ! type pv > /dev/null; then
    echo "Installing pv..."
    if ! sudo qubes-dom0-update pv | pv -p -t -e -b > /dev/null; then
        echo "Failed to install pv. Aborting." >&2
        exit 1
    fi
    echo "pv installation complete."
fi

# Install the default templates
echo "Installing the default templates..."
if ! qubesctl state.sls qvm.template | pv -p -t -e -b > /dev/null; then
    echo "Failed to install the default templates. Aborting." >&2
    exit 1
fi

# Install the fedora-36 template
echo "Installing the fedora-36 template..."
if ! qubesctl --skip-dom0 --targets=fedora-36 --show-output state.sls qvm.present | pv -p -t -e -b > /dev/null; then
    echo "Failed to install the fedora-36 template. Aborting." >&2
    exit 1
fi

# Install the fedora-36-minimal template
echo "Installing the fedora-36-minimal template..."
if ! qubesctl --skip-dom0 --targets=fedora-36-minimal --show-output state.sls qvm.present | pv -p -t -e -b > /dev/null; then
    echo "Failed to install the fedora-36-minimal template. Aborting." >&2
    exit 1
fi

# Install the debian-11 template
echo "Installing the debian-11 template..."
if ! qubesctl --skip-dom0 --targets=debian-11 --show-output state.sls qvm.present | pv -p -t -e -b > /dev/null; then
    echo "Failed to install the debian-11 template. Aborting." >&2
    exit 1
fi

# Install the debian-11-minimal template
echo "Installing the debian-11-minimal template..."
if ! qubesctl --skip-dom0 --targets=debian-11-minimal --show-output state.sls qvm.present | pv -p -t -e -b > /dev/null; then
    echo "Failed to install the debian-11-minimal template. Aborting." >&2
    exit 1
fi

# Install the default appVMs
echo "Installing the default appVMs..."
if ! qubesctl state.sls qvm.app | pv -p -t -e -b > /dev/null; then
    echo "Failed to install the default appVMs. Aborting." >&2
    exit 1
fi

echo "Configuration of base QubesOS templates and sys- VMs complete."

# Create a standalone writer offline VM
echo "Creating the writ VM..."
if ! qvm-create -v --class Standalone --template debian-11 --label blue writ --standalone --no-netvm | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the writ VM. Aborting." >&2
    exit 1
fi

# Install Crossover using PlayOnLinux
echo "Installing Crossover using PlayOnLinux..."
if ! qvm-run -v -a writ 'echo "deb http://deb.playonlinux.com/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/playonlinux.list' | pv -p -t -e -b > /dev/null; then
    echo "Failed to add PlayOnLinux repository. Aborting." >&2
    exit 1
fi
if ! qvm-run -v -a writ 'wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -' | pv -p -t -e -b > /dev/null; then
    echo "Failed to add PlayOnLinux repository key. Aborting." >&2
    exit 1
fi
if ! qvm-run -v -a writ 'sudo apt-get update && sudo apt-get install -y playonlinux' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Crossover. Aborting." >&2
    exit 1
fi

# Install Scrivener within Crossover
echo "Installing Scrivener within Crossover..."
if ! qvm-run -v -a writ 'POL_WINEVERSION="5.22" playonlinux --run "Scrivener" /silent /sp- /no-desktop' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Scrivener within Crossover. Aborting." >&2
    exit 1
fi

# Install LibreOffice
echo "Installing LibreOffice..."
if ! qvm-run -v -a writ 'sudo apt-get update && sudo apt-get install -y libreoffice' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install LibreOffice. Aborting." >&2
    exit 1
fi

# Clean up package cache
echo "Cleaning up package cache..."
if ! qvm-run -v -a writ 'sudo apt-get clean' | pv -p -t -e -b > /dev/null; then
    echo "Failed to clean up package cache. Aborting." >&2
    exit 1
fi

echo "Configuration of writ VM complete."

# Create template for AV
echo "Creating template for AV..."
if ! qvm-create -v --class Template --label red --template fedora-36-minimal --property virt_mode=appvm --property kernelopts=console=ttyS0,115200n8 --property virt_mode=appvm t-av | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the t-av template. Aborting." >&2
    exit 1
fi

# Install required Qubes services for networking
echo "Installing required Qubes services for networking..."
if ! qvm-run -v -a t-av 'sudo dnf install -y qubes-core-agent-networking qubes-core-agent-dom0-updates qubes-core-agent-passwordless-root' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install required Qubes services for networking. Aborting." >&2
    exit 1
fi

# Install Zoom in the t-av template
echo "Installing Zoom in the t-av template..."
if ! qvm-run -v -a t-av 'sudo dnf install -y https://dl.zoom.us/linux/client/zoom_x86_64.rpm' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Zoom in the t-av template. Aborting." >&2
    exit 1
fi

# Install Teams in the t-av template
echo "Installing Teams in the t-av template..."
if ! qvm-run -v -a t-av 'sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && sudo curl -o /etc/yum.repos.d/teams.repo https://packages.microsoft.com/yumrepos/ms-teams.repo && sudo dnf install -y teams' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Teams in the t-av template. Aborting." >&2
    exit 1
fi

# Install Google Chat in the t-av template
echo "Installing Google Chat in the t-av template..."
if ! qvm-run -v -a t-av 'sudo dnf install -y google-chrome-stable' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Google Chat in the t-av template. Aborting." >&2
    exit 1
fi

# Create Qube for AV
echo "Creating the AV Qube..."
if ! qvm-create -v --label red --template t-av --property virt_mode=appvm --property kernelopts=console=ttyS0,115200n8 AV | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the AV Qube. Aborting." >&2
    exit 1
fi

echo "Configuration of AV VM and template complete...."

# Create template for browser
echo "Creating template for browser..."
if ! qvm-create -v --class Template --label grey --template fedora-36-minimal --property netvm=sys-vpn --property kernelopts=console=ttyS0,115200n8 t-browser | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the t-browser template. Aborting." >&2
    exit 1
fi

# Install required Qubes services for networking in the t-browser template
echo "Installing required Qubes services for networking in the t-browser template..."
if ! qvm-run -v -a t-browser 'sudo dnf install -y qubes-core-agent-networking qubes-core-agent-network-manager qubes-network-manager' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install the required Qubes services for networking in the t-browser template. Aborting." >&2
    exit 1
fi

# Install Chromium in the t-browser template
echo "Installing Chromium in the t-browser template..."
if ! qvm-run -v -a t-browser 'sudo dnf install -y chromium' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Chromium in the t-browser template. Aborting." >&2
    exit 1
fi

# Install Tor Browser in the t-browser template
echo "Installing Tor Browser in the t-browser template..."
if ! qvm-run -v -a t-browser 'sudo dnf install -y torbrowser-launcher' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Tor Browser in the t-browser template. Aborting." >&2
    exit 1
fi

# Install Firefox-ESR in the t-browser template
echo "Installing Firefox-ESR in the t-browser template..."
if ! qvm-run -v -a t-browser 'sudo dnf install -y firefox-esr' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Firefox-ESR in the t-browser template. Aborting." >&2
    exit 1
fi
# Create a new Qube for the browser AppVM based on the t-browser template
echo "Creating a new Qube for the browser AppVM based on the t-browser template..."
if ! qvm-create -v --label grey --template t-browser --property netvm=sys-vpn browser | pv -p -t -e -b > /dev/null; then
    echo "Failed to create a new Qube for the browser AppVM based on the t-browser template. Aborting." >&2
    exit 1
fi

# Add arkenfox user.js file to the browser AppVM
echo "Adding arkenfox user.js file to the browser AppVM..."
if ! qvm-run -v -a browser 'mkdir -p ~/.mozilla/firefox/*.default-release && curl -sL https://raw.githubusercontent.com/arkenfox/user.js/master/user.js > ~/.mozilla/firefox/*.default-release/user.js' | pv -p -t -e -b > /dev/null; then
    echo "Failed to add the arkenfox user.js file to the browser AppVM. Aborting." >&2
    exit 1
fi

# Rename Firefox .desktop file to Arkenfox in the browser AppVM
echo "Renaming Firefox .desktop file to Arkenfox in the browser AppVM..."
if ! qvm-run -v -a browser 'mv ~/.local/share/applications/firefox-esr.desktop ~/.local/share/applications/arkenfox.desktop' | pv -p -t -e -b > /dev/null; then
    echo "Failed to rename the Firefox .desktop file to Arkenfox in the browser AppVM. Aborting." >&2
    exit 1
fi

# Create the sources VM based on the fedora-36-minimal template
echo "Creating the sources VM based on the fedora-36-minimal template..."
if ! qvm-create -v --label red --class StandaloneVM --property virt_mode=linux --property kernelopts=console=ttyS0,115200n8 --template fedora-36-minimal sources | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the sources VM based on the fedora-36-minimal template. Aborting." >&2
    exit 1
fi

# Install qubes-core-agent-passwordless-root in the sources VM
echo "Installing qubes-core-agent-passwordless-root in the sources VM..."
if ! qvm-run -v -a -p -u root sources 'dnf install -y qubes-core-agent-passwordless-root' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install qubes-core-agent-passwordless-root in the sources VM. Aborting." >&2
    exit 1
fi

# Create a private storage volume in the sources VM
echo "Creating a private storage volume in the sources VM..."
if ! qvm-run -v -a -p sources 'qvm-volume create --label red private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to create a private storage volume in the sources VM. Aborting." >&2
    exit 1
fi

# Attach the private storage volume to the sources VM
echo "Attaching the private storage volume to the sources VM..."
if ! qvm-run -v -a -p sources 'qvm-block attach private dom0:/dev/mapper/dm-root' | pv -p -t -e -b > /dev/null; then
    echo "Failed to attach the private storage volume to the sources VM. Aborting." >&2
    exit 1
fi

# Make the private storage volume available in the sources VM
echo "Making the private storage volume available in the sources VM..."
if ! qvm-run -v -a -p sources 'mkdir -p /mnt/private; mount /dev/dm-3 /mnt/private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to make the private storage volume available in the sources VM. Aborting." >&2
    exit 1
fi

# Create the sources VM based on the fedora-36-minimal template
echo "Creating the sources VM based on the fedora-36-minimal template..."
if ! qvm-create -v --label red --class StandaloneVM --property virt_mode=linux --property kernelopts=console=ttyS0,115200n8 --template fedora-36-minimal sources | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the sources VM based on the fedora-36-minimal template. Aborting." >&2
    exit 1
fi

# Install qubes-core-agent-passwordless-root in the sources VM
echo "Installing qubes-core-agent-passwordless-root in the sources VM..."
if ! qvm-run -v -a -p -u root sources 'dnf install -y qubes-core-agent-passwordless-root' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install qubes-core-agent-passwordless-root in the sources VM. Aborting." >&2
    exit 1
fi

# Create a private storage volume in the sources VM
echo "Creating a private storage volume in the sources VM..."
if ! qvm-run -v -a -p sources 'qvm-volume create --label red private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to create a private storage volume in the sources VM. Aborting." >&2
    exit 1
fi

# Attach the private storage volume to the sources VM
echo "Attaching the private storage volume to the sources VM..."
if ! qvm-run -v -a -p sources 'qvm-block attach private dom0:/dev/mapper/dm-root' | pv -p -t -e -b > /dev/null; then
    echo "Failed to attach the private storage volume to the sources VM. Aborting." >&2
    exit 1
fi

# Make the private storage volume available in the sources VM
echo "Making the private storage volume available in the sources VM..."
if ! qvm-run -v -a -p sources 'mkdir -p /mnt/private; mount /dev/dm-3 /mnt/private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to make the private storage volume available in the sources VM. Aborting." >&2
    exit 1
fi

# Set the ownership and permissions for the private storage volume
if ! qvm-run -v -a -p sources 'chown user:user /mnt/private; chmod 700 /mnt/private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to set the ownership and permissions for the private storage volume. Aborting." >&2
    exit 1
fi

# Unmount the private storage volume in the sources VM
if ! qvm-run -v -a -p sources 'umount /mnt/private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to unmount the private storage volume in the sources VM. Aborting." >&2
    exit 1
fi

# Detach the private storage volume from the sources VM
if ! qvm-run -v -a -p sources 'qvm-block detach private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to detach the private storage volume from the sources VM. Aborting." >&2
    exit 1
fi

# Remove the private storage volume from the sources VM
if ! qvm-run -v -a -p sources 'qvm-volume remove private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to remove the private storage volume from the sources VM. Aborting." >&2
    exit 1
fi

# Set the max RAM for the sources VM to 128MB
if ! qvm-prefs -v --set sources memory 128 | pv -p -t -e -b > /dev/null; then
    echo "Failed to set the max RAM for the sources VM to 128MB. Aborting." >&2
    exit 1
fi

echo "The sources VM has been created and configured successfully."

#!/bin/bash

# Create the new AppVM
echo "Creating the new AppVM 'comms'..."
if ! qvm-create --label red --template debian-11-minimal comms | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the new AppVM. Aborting." >&2
    exit 1
fi

# Enable networking services for the AppVM
echo "Enabling networking services for the new AppVM..."
if ! qvm-service --enable --all comms | pv -p -t -e -b > /dev/null; then
    echo "Failed to enable networking services for the new AppVM. Aborting." >&2
    exit 1
fi

# Install Whatsdesk
echo "Installing Whatsdesk..."
if ! qvm-run --auto --pass-io comms 'sudo apt-get update; sudo apt-get install -y whatsdesk' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Whatsdesk. Aborting." >&2
    exit 1
fi

# Install Signal Desktop
echo "Installing Signal Desktop..."
if ! qvm-run --auto --pass-io comms 'sudo apt-get update; sudo apt-get install -y curl; curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -; echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list; sudo apt-get update; sudo apt-get install -y signal-desktop' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Signal Desktop. Aborting." >&2
    exit 1
fi

# Install Telegram
echo "Installing Telegram..."
if ! qvm-run --auto --pass-io comms 'sudo apt-get update; sudo apt-get install -y telegram-desktop' | pv -p -t -e -b > /dev/null; then
    echo "Failed to install Telegram. Aborting." >&2
    exit 1
fi

echo "The new AppVM 'comms' has been created and configured successfully."

echo "All VMs created successfully!"

echo "journoQUBES install complete."
