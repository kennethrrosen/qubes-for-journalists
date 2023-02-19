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

# Array of templates and minimal templates to install
templates=("fedora-36" "fedora-36-minimal" "debian-11" "debian-11-minimal")

# Loop through templates array and install them
for template in "${templates[@]}"; do
    echo "Installing $template template..."
    if ! qubesctl --skip-dom0 --targets="$template" --show-output state.sls qvm.present | pv -p -t -e -b > /dev/null; then
        echo "Failed to install $template template. Aborting." >&2
        exit 1
    fi
done

# Install the default templates and appVMs
echo "Installing the default templates and appVMs..."
if ! qubesctl state.sls qvm.template qvm.app | pv -p -t -e -b > /dev/null; then
    echo "Failed to install the default templates and appVMs. Aborting." >&2
    exit 1
fi

echo "Configuration of base QubesOS templates and sys- VMs complete."

# Define a function to run a command in the writ VM
run_in_writ_vm() {
    echo "Running command in writ VM: $1"
    if ! qvm-run -v -a writ "$1" | pv -p -t -e -b > /dev/null; then
        echo "Command failed: $1" >&2
        exit 1
    fi
}

# Create a standalone writer offline VM
echo "Creating the writ VM..."
if ! qvm-create -v --class Standalone --template debian-11 --label blue writ --standalone --no-netvm | pv -p -t -e -b > /dev/null; then
    echo "Failed to create the writ VM. Aborting." >&2
    exit 1
fi

# Install Crossover using PlayOnLinux
run_in_writ_vm 'echo "deb http://deb.playonlinux.com/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/playonlinux.list'
run_in_writ_vm 'wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -'
run_in_writ_vm 'sudo apt-get update && sudo apt-get install -y playonlinux'

# Install Scrivener within Crossover
run_in_writ_vm 'POL_WINEVERSION="5.22" playonlinux --run "Scrivener" /silent /sp- /no-desktop'

# Install LibreOffice
run_in_writ_vm 'sudo apt-get update && sudo apt-get install -y libreoffice'

# Clean up package cache
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

# Install browsers in the t-browser template
for browser in "chromium" "torbrowser-launcher" "firefox-esr"; do
    echo "Installing $browser in the t-browser template..."
    if ! qvm-run -v -a t-browser "sudo dnf install -y $browser" | pv -p -t -e -b > /dev/null; then
        echo "Failed to install $browser in the t-browser template. Aborting." >&2
        exit 1
    fi
done

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

echo "Configuration of browser VM and template complete...."

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

# Create and attach private storage volume to the sources VM
echo "Creating and attaching a private storage volume to the sources VM..."
if ! qvm-run -v -a -p sources 'qvm-volume create --label red private; qvm-block attach private dom0:/dev/mapper/dm-root; mkdir -p /mnt/private; mount /dev/dm-3 /mnt/private; chown user:user /mnt/private; chmod 700 /mnt/private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to create and attach the private storage volume to the sources VM. Aborting." >&2
    exit 1
fi

# Unmount and detach the private storage volume from the sources VM, then remove it
echo "Unmounting, detaching, and removing the private storage volume from the sources VM..."
if ! qvm-run -v -a -p sources 'umount /mnt/private; qvm-block detach private; qvm-volume remove private' | pv -p -t -e -b > /dev/null; then
    echo "Failed to unmount, detach, and remove the private storage volume from the sources VM. Aborting." >&2
    exit 1
fi

# Set the max RAM for the sources VM to 128MB
if ! qvm-prefs -v --set sources memory 128 | pv -p -t -e -b > /dev/null; then
    echo "Failed to set the max RAM for the sources VM to 128MB. Aborting." >&2
    exit 1
fi

echo "The sources VM has been created and configured successfully."

# Create the comms VM
echo "Creating the new AppVM 'comms'..."
if ! qvm-create --label red --template debian-11-minimal comms | pv -p -t -e -b > /dev/null && \
     qvm-service --enable --all comms | qvm-run --auto --pass-io comms 'sudo apt-get update; \
     sudo apt-get install -y whatsdesk; \
     sudo apt-get install -y curl; \
     curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -; \
     echo \"deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main\" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list; \
     sudo apt-get update; sudo apt-get install -y signal-desktop; \
     sudo apt-get install -y telegram-desktop' | pv -p -t -e -b > /dev/null; then
    echo "Failed to create and configure the new AppVM 'comms'. Aborting." >&2
    exit 1
fi

echo "The new AppVM 'comms' has been created and configured successfully."
echo "All VMs created successfully!"
echo "journoQUBES install complete."
