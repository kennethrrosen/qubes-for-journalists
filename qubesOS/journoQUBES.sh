# THIS CODE IS A WORK IN PROCESS AND NOT IN PRODUCTION
#    name: journoQUBES Qube installer for journalists
#    date: 20 February 2023
#    see: https://github.com/kennethrrosen/ for license and contact.
#
# a simple script for installing Qubes configurations for journalists in a raw QubesOS 4.1 install. The following script installs several
# Qubes through a simple command 'sudo install ./journoQubes.sh' in a dom0 terminal. A Salt version and GUI is in development
# THIS CODE IS A WORK IN PROCESS AND NOT IN PRODUCTION

#!/bin/bash

set - euo pipefail
#Check if running as root
  if["$(id -u)" != "0"];
then echo "This script must be run as root." > &2 exit 1 fi
#Define variables
  templates = ("fedora-36" "fedora-36-minimal" "debian-11" "debian-11-minimal")
  MIRAGE_FIREWALL_REPO_URL = "https://github.com/mirage/qubes-mirage-firewall/releases/download/v0.8.4/mirage-firewall.tar.bz2"
  writ_vm = "writ" 
  writ_vm_template = "debian-11" 
  template_browser_name = "t-browser" 
  appvm_browser_name = "browser" 
  browsers = "chromium torbrowser-launcher firefox-esr" 
  template_vault_name = "t-vault" 
  appvm_vault_name = "source" 
  vm_comms_name = "comms" 
  template_comms_name = "debian-11-minimal"
  comms_apt_packages =
  "whatsdesk curl signal-desktop telegram-desktop"
  vpn_config_file = "/home/user/vpn_config.ovpn" #TODO replace with RPM file destination
  appvm_VPN_name = "fedora-vpn"
  appvm_VPN_template = "fedora-36-minimal" 
  qubes_networking_packages = ("qubes-core-agent-networking" "qubes-core-agent-network-manager" #TODO check for all required packages
   "qubes-network-manager") 
  required_packages = ("openvpn" "qubes-core-agent-networking" "qubes-core-agent-network-manager" "qubes-network-manager") #TODO check for all required packages
   
#Defines a function to display error message and provide options to the user for troubleshooting
  display_error ()
{
  echo "Options:"
    echo "1. Retry the script (may lead to duplicates)" #TODO fix error-handling
    echo "2. Continue anyway (not recommended)."
    echo "3. Contact author."
    read - p "Enter your choice (1-3): " choice
    case $choice in
    1) echo "Re-trying journoQUBES script..."
    && bash / path / to / script.sh;;
  2) echo "Continuing with script execution" && return;;
  3) echo "Please send an email to kennethrrosen@proton.me" && exit 1;;
  *)echo "Invalid option. Please try again." && display_error;;
esac}

#Install pv for error checking if not already installed
type pv > /dev / null || (echo "Installing pv..."
			  && sudo qubes - dom0 - update pv
			  && echo "pv installation complete.")
  || display_error "Failed to install pv"
#Define a function to run a command in the writ VM
  run_in_writ_vm ()
{
echo "Running command in writ VM: $1"
    qvm - run - v - a "$writ_vm" "$1" | pv - p - t - e - b > /dev / null
    || display_error "Error: Failed to run command in writ VM"}

#Install templates and default appVMs
for template
  in "${templates[@]}";
do
  echo "Installing $template template..."
    qubesctl-- skip - dom0-- targets =
    "$template"-- show - output state.sls qvm.present | pv - p - t - e - b >
    /dev / null
    || display_error "Failed to install $template template" done echo
    "Installing the default templates and appVMs..." qubesctl state.sls qvm.
    template qvm.app | pv - p - t - e - b > /dev / null
    || display_error "Failed to install default templates and appVMs"

#Download the Mirage Firewall repository
    echo "Downloading Mirage Firewall repository..."
    curl - L - o mirage - firewall.tar.bz2 $REPO_URL
    || display_error "Failed to download Mirage Firewall repository"
#Extract the kernel image and initramfs
    echo "Extracting kernel image and initramfs..."
    mkdir - p / var / lib / qubes / vm - kernels / mirage - firewall
    || display_error "Failed to make mirage firewall directory" tar -
    xjf mirage - firewall.tar.bz2 - C / var / lib / qubes / vm -
    kernels / mirage -
    firewall / ||display_error "Failed to extract kernel image and initramfs"
#Create the Mirage Firewall VM
    echo "Creating sys-mirage-firewall..."
    qvm - create-- property kernel = mirage - firewall-- property kernelopts =
    ''-- property memory = 32-- property maxmem = 32-- property netvm =
    sys - net-- property provides_network = True-- property vcpus =
    1-- property virt_mode = pvh-- label =
    green-- class StandaloneVM sys - mirage - firewall
    || display_error "Failed to create sys-mirage-firewall"
#Set sys-mirage-firewall as the default firewall for all VMs
    echo "Setting Mirage Firewall as the default firewall for all VMs..."
    for vm
    in $ (qvm - ls-- raw);
do
  if["$(qvm-prefs $vm netvm)" = "sys-firewall"];
then
  qvm - prefs $vm netvm = mirage - firewall
  || display_error "Failed to set sys-mirage-firewall as default firewall" fi
  done
#Enable the Qubes Firewall service in the Mirage Firewall VM
  echo "Enabling the Qubes Firewall service in the Mirage Firewall VM..."
  qvm - features mirage - firewall qubes - firewall 1
  || display_error
  "Failed to enable Qubes Firewall service in Mirage Firewall VM"
#Disable the default kernel options in the Mirage Firewall VM
  echo "Disabling the default kernel options in the Mirage Firewall VM..."
  qvm - features mirage - firewall no - default -kernelopts 1
  || display_error
  "Failed to disable default kernel options in Mirage Firewall VM" echo
  "Mirage Firewall setup complete!"

#Create a simple personal AppVM
  echo "Creating Personal qube..."
  qvm - create - v-- class AppVM-- template fedora -
  36-- label green-- mem 2048-- maxmem 4096-- netvm sys -
  firewall-- name personal | pv - p - t - e - b
  || display_error "Failed to create Personal qube"
#Add personal qube menu items
  echo "Adding Personal qube menu items..."
  qvm - run -
  a personal
  'echo -e "[Desktop Entry]\nName=Firefox\nExec=/usr/bin/firefox\nIcon=/usr/share/icons/hicolor/32x32/apps/firefox.png\nType=Application\nCategories=Network;" > ~/.local/share/applications/firefox.desktop'
  | pv - p - t - e - b
  || display_error "Failed to add Firefox menu item" qvm - run -
  a personal
  'echo -e "[Desktop Entry]\nName=File Viewer\nExec=/usr/bin/nautilus\nIcon=/usr/share/icons/hicolor/32x32/apps/system-file-manager.png\nType=Application\nCategories=Utility;" > ~/.local/share/applications/file_viewer.desktop'
  | pv - p - t - e - b
  || display_error "Failed to add File Viewer menu item" qvm - run -
  a personal
  'echo -e "[Desktop Entry]\nName=LibreOffice\nExec=/usr/bin/libreoffice\nIcon=/usr/share/icons/hicolor/32x32/apps/libreoffice-main.png\nType=Application\nCategories=Office;" > ~/.local/share/applications/libreoffice.desktop'
  | pv - p - t - e - b
  || display_error "Failed to add LibreOffice menu item" echo
  "Creation of Personal qube complete."
#Create a standalone writer offline VM and install applications
  echo "Creating the writ VM..."
  qvm - create -
  v-- class Standalone-- template "$writ_vm_template"-- label blue
  "$writ_vm"-- standalone-- no - netvm | pv - p - t - e - b > /dev / null
  || display_error "Failed to create writ VM" echo
  "Adding software and packages items..." run_in_writ_vm
  'echo "deb http://deb.playonlinux.com/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/playonlinux.list'
  || display_error "Failed to add PlayOnLinux repository to writ VM"
  run_in_writ_vm
  'wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -'
  || display_error "Failed to add PlayOnLinux key to writ VM" run_in_writ_vm
  'sudo apt-get update && sudo apt-get install -y playonlinux'
  || display_error "Failed to install PlayOnLinux in writ VM" run_in_writ_vm
  'POL_WINEVERSION="5.22" playonlinux --run "Scrivener" /silent /sp- /no-desktop'
  || display_error "Failed to install Scrivener in writ VM" run_in_writ_vm
  'sudo apt-get update && sudo apt-get install -y libreoffice'
  || display_error "Failed to install LibreOffice in writ VM" run_in_writ_vm
  'sudo apt-get clean'
  || display_error "Failed to clean apt cache in writ VM" echo
  "Configuration of writ VM complete."
#Create template for AV
  echo "Creating template for AV..."
  qvm - create - v-- class Template-- label red-- template fedora - 36 -
  minimal-- property virt_mode = pvh-- property kernelopts = console =
  ttyS0, 115200 n8 t - av | pv - p - t - e - b > /dev / null
  || display_error "Failed to create the t-av template. Aborting."
#Install required Qubes services for networking
  echo "Installing required Qubes services for networking..."
  qvm - run - v - a t -
  av
  'sudo dnf install -y qubes-core-agent-networking qubes-core-agent-dom0-updates qubes-core-agent-passwordless-root'
  | pv - p - t - e - b > /dev / null
  || display_error
  "Failed to install required Qubes services for networking. Aborting."
#Install Zoom, Teams, and Google Chat in the t-av template
  echo "Installing Zoom, Teams, and Google Chat in the t-av template..."
  qvm - run - v - a t -
  av 'sudo dnf install -y https://dl.zoom.us/linux/client/zoom_x86_64.rpm' |
  pv - p - t - e - b > /dev / null
  || display_error "Failed to install Zoom in the t-av template. Aborting."
  qvm - run - v - a t -
  av
  'sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && sudo curl -o /etc/yum.repos.d/teams.repo https://packages.microsoft.com/yumrepos/ms-teams.repo && sudo dnf install -y teams'
  | pv - p - t - e - b > /dev / null
  || display_error "Failed to install Teams in the t-av template. Aborting."
  qvm - run - v - a t - av 'sudo dnf install -y google-chrome-stable' | pv -
  p - t - e - b > /dev / null
  || display_error
  "Failed to install Google Chat in the t-av template. Aborting."
#Create Qube for AV
  echo "Creating the AV Qube..."
  qvm - create - v-- label red-- template t - av-- property virt_mode =
  pvh-- property kernelopts = console =
  ttyS0, 115200 n8 AV | pv - p - t - e - b > /dev / null
  || display_error "Failed to create the AV Qube. Aborting." echo
  "Configuration of AV VM and template complete...."
#Create template for browser
  echo "Creating template for browser..."
  qvm - create - v-- class Template-- label grey-- template fedora - 36 -
  minimal-- property netvm = sys - vpn-- property kernelopts = console =
  ttyS0, 115200 n8 "$TEMPLATE_BROWSER_NAME" | pv - p - t - e - b > /dev / null
  || display_error "Failed to create the $TEMPLATE_BROWSER_NAME template."
#Install required Qubes services for networking and browsers in the t-browser template
  echo
  "Installing required Qubes services for networking and browsers in the $TEMPLATE_BROWSER_NAME template..."
  qvm - run - v -
  a "$TEMPLATE_BROWSER_NAME"
  "sudo dnf install -y qubes-core-agent-networking qubes-core-agent-network-manager qubes-network-manager $BROWSERS"
  | pv - p - t - e - b > /dev / null
  || display_error
  "Failed to install the required Qubes services for networking and browsers in the $TEMPLATE_BROWSER_NAME template."
#Create a new Qube for the browser AppVM based on the t-browser template, add arkenfox user.js file and rename Firefox .desktop file
  echo
  "Creating a new Qube for the $APPVM_BROWSER_NAME AppVM based on the $TEMPLATE_BROWSER_NAME template, adding arkenfox user.js file and renaming Firefox .desktop file..."
  qvm - create -
  v-- label grey-- template "$TEMPLATE_BROWSER_NAME"-- property netvm =
  sys - vpn "$APPVM_BROWSER_NAME"
  || display_error
  "Failed to create the browser AppVM based on the $TEMPLATE_BROWSER_NAME template."
  qvm - run - v -
  a "$APPVM_BROWSER_NAME"
  'mkdir -p ~/.mozilla/firefox/*.default-release && curl -sL https://raw.githubusercontent.com/arkenfox/user.js/master/user.js > ~/.mozilla/firefox/*.default-release/user.js'
  || display_error
  "Failed to add arkenfox user.js file to the $APPVM_BROWSER_NAME AppVM." qvm
  - run - v -
  a "$APPVM_BROWSER_NAME"
  'mv ~/.local/share/applications/firefox-esr.desktop ~/.local/share/applications/arkenfox.desktop'
  | pv - p - t - e - b > /dev / null
  || display_error
  "Failed to rename Firefox .desktop file in the $APPVM_BROWSER_NAME AppVM."
  echo "Configuration of browser AppVM and template complete."
#Create the sources VM based on the fedora-36-minimal template
  echo
  "Creating the $APPVM_VAULT_NAME VM based on the $TEMPLATE_VAULT_NAME template..."
  qvm - create - v-- label red-- class StandaloneVM-- property virt_mode =
  pvh-- property kernelopts = console = ttyS0, 115200 n8-- property memory =
  128-- template fedora - 36 - minimal "$APPVM_VAULT_NAME"
  || display_error
  "Failed to create the $APPVM_VAULT_NAME VM based on the $TEMPLATE_VAULT_NAME template."
  echo
  "The $APPVM_VAULT_NAME VM has been created and configured successfully."
#Install qubes-core-agent-passwordless-root in the vault VM
  echo
  "Installing qubes-core-agent-passwordless-root in the $APPVM_VAULT_NAME VM..."
  qvm - run - v - a - p -
  u root "$APPVM_VAULT_NAME"
  'dnf install -y qubes-core-agent-passwordless-root' | pv - p - t - e - b >
  /dev / null
  || display_error
  "Failed to install qubes-core-agent-passwordless-root in the $APPVM_VAULT_NAME VM."
#Create and attach private storage volume to the vault VM
  echo
  "Creating and attaching a private storage volume to the $APPVM_VAULT_NAME VM..."
  qvm - run - v - a -
  p "$APPVM_VAULT_NAME"
  'qvm-volume create --label red private; qvm-block attach private dom0:/dev/mapper/dm-root; mkdir -p /mnt/private; mount /dev/dm-3 /mnt/private; chown user:user /mnt/private; chmod 700 /mnt/private'
  | pv - p - t - e - b > /dev / null
  || display_error
  "Failed to create and attach the private storage volume to the $APPVM_VAULT_NAME VM."
#Unmount and detach the private storage volume from the vault VM, then remove it
  echo
  "Unmounting, detaching, and removing the private storage volume from the $APPVM_VAULT_NAME VM..."
  qvm - run - v - a -
  p "$APPVM_VAULT_NAME"
  'umount /mnt/private; qvm-block detach private; qvm-volume remove private' |
  pv - p - t - e - b > /dev / null
  || display_error
  "Failed to unmount, detach, and remove the private storage volume from the $APPVM_VAULT_NAME VM."
  echo
  "The $APPVM_VAULT_NAME VM has been created and configured successfully."
#Create the comms VM
  echo "Creating the new AppVM '$VM_COMMS_NAME'..."
  qvm -
  create-- label red-- template "$TEMPLATE_COMMS_NAME" "$VM_COMMS_NAME" | pv -
  p - t - e - b > /dev / null
  || display_error "Failed to create the new AppVM '$VM_COMMS_NAME'." qvm -
  service-- enable-- all "$VM_COMMS_NAME" | qvm - run-- auto-- pass -
  io "$VM_COMMS_NAME"
  "sudo apt-get update; sudo apt-get install -y $COMMS_APT_PACKAGES" | pv -
  p - t - e - b > /dev / null
  || display_error "Failed to configure the new AppVM '$VM_COMMS_NAME'." echo
  "The AppVM '$VM_COMMS_NAME' has been created and configured successfully."
#Check if VPN config file exists
  if[!-f "$vpn_config_file"];
then echo "Error: VPN config file $vpn_config_file not found." exit 1 fi
#Create the VPN Qube
  echo "Creating the VPN Qube"
  qvm -
  create-- label black-- template "$appvm__VPN_template" "$appvm_VPN_name"
  || display_error "Failed to create the AppVM for VPN." qvm - run-- pass -
  io $appvm_VPN_name
  "sudo dnf install -y ${qubes_networking_packages[*]} qubes-core-agent-passwordless-root"
  || display_error "Failed to install required packages in the AppVM."
#Install required packages in the AppVM
  for package
  in "${required_packages[@]}";
do
  if !qvm
    -run - a "$appvm_VPN_name" "which $package" > /dev / null;
then
  echo "Installing $package..."
  qvm - run - a "$appvm_VPN_name" "sudo dnf install -y $package"
  || display_error "Failed to install $package in the AppVM." fi done
#Copy VPN config file to the AppVM
  echo "Copying VPN config file to AppVM: $appvm_VPN_name..."
  qvm - run-- pass - io "$appvm_VPN_name" "cat > /rw/config/vpn_config.ovpn" <
  "$vpn_config_file"
  || display_error "Failed to copy VPN config file to AppVM."
#Install and set up OpenVPN in the AppVM
  echo "Setting up OpenVPN in AppVM: $appvm_VPN_name..."
  qvm - run - p "$appvm_VPN_name" "sudo dnf install -y openvpn"
  || display_error "Failed to install OpenVPN in the AppVM." qvm -
  run-- pass - io -
  p "$appvm_VPN_name" "sudo openvpn --config /rw/config/vpn_config.ovpn &"
  || display_error "Failed to set up OpenVPN in the AppVM." echo
  "VPN is now running in the AppVM: $appvm_VPN_name."
#Notes for the user to complete the setup:
  echo "Please manually configure sys-vpm to use the VPN for network traffic.
- Open NetworkManager from the system tray or in the AppVM's settings.
- In the VPN tab, click 'Add'.
- Select 'Import from file' and select the VPN config file from /rw/config/vpn_config.ovpn.
- In the General tab, make sure 'Automatically connect to VPN when using this connection' is checked.
- Save and close the VPN settings.
- Restart the network service: sudo systemctl restart NetworkManager." echo "All VMs created successfully!" echo "journoQUBES install complete."

echo "journoQUBES install complete."
