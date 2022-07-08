# journoQUBES
Steps taken to harden Qubes (4.1.0) on a Librem 14 (750G-LUKS encrypted drives, 64G RAM). Despite the security of the Purism laptop, I took additional steps (hardware, software) to add enhanced security. This is a working list as I go through the intitialization of the OS, a running tab of work done to it for future reference and backup purposes; also, for future project on journalist digital security.

NOTE: Qubes is as the hardest possible OS for journalists as a daily driver. (TAILS is the preferred choice for in-a-pinch necessity, emergencies, and use under opressive regimes with active net-monitoring.) Nevertheless, the steps below consider a threat model in the grey area between levels 2 - 3 (of 4) of the Cupwire standard (https://www.cupwire.com/threat-modeling/). I've found this middle ground idylic for most foreign correspondents who are often already operating (or seeking to operate) with this level of anonymity. Much of this repository was created from various sources in an attempt to centralize tools for journalists. If credit is not cited where credit is do, please let me know and I will rectify.

### best practices
- LUKS encrypt all harddrives in installation configuration
- too many levels of complexity leads to user error; eliminate attack surface, but make your security measures convenient and practical
- set the Qubes, Debian and Whonix package updates to Tor onion service repositories
- move files downloaded by Tor Browser from the ~/Downloads folder to another specially created one
- set power button to shutdown, don't leave computer unattended in public; store in hotel safes
- use Diceware passphrases
- download files securely using scurl
- files received or downloaded fromthe internet, via email, and PDFs, etc. should be opened in a DVM
- use split-GPG for email to reduce the risk of key theft used for encryption / decryption and signing
- only open untrusted email attachments in a DisposableVM to prevent possible infection
- for anonymous PGP-encrypted email over Tor, use Mozilla Thunderbird.
- physically move all mobiles devices to a distant physical location or faraday bag

### pre-installation configurations
- disabled Intel ME (Librem standard)
- anti-evil-maid (not necessary with Librem)
- coreboot & seaBIOS firmware, Yubikey login and killswitch
- physical hardware disconnect for microphone, wifi, bluetooth, webcam
- removed speakers
- removed beeper
- tamper-evident screws
- waxed external ports

### post-installation configurations
- disable previews of files from untrusted sources in File Manager
- swap networking (sys-net and sys-firewall) templates to customized Kicksure Templates (based on Debian 11 over tor, DVMs), making sure not to configure as a Standalone VM
- confirm Microcode Package Check (in dom0):
```dnf list | grep microcode```
- confirm AppArmor active (in Debian & Kicksure VMs):
```sudo aa-status```
- sudo systemctl mask systemcheck
- enable all available apparmor profiles in the Whonix-Workstation and Whonix-Gateway Templates
```sudo aa-status```
- configure each ServiceVM as a static DisposableVM to mitigate the threat from persistent malware accross VM reboots.

## swap PureBoot to Coreboot/SeaBIOS
```
mkdir ~/updates 
cd ~/updates 
wget https://source.puri.sm/coreboot/utility/raw/master/coreboot_util.sh -O coreboot_util.sh 
sudo bash ./coreboot_util.sh

(follow prompts:)
1. 
(Default) 
Standard 
1. 
Select desired boot device 
Y 

```

## enable Yubikey for mandatory login removal lockswitch
```
https://www.qubes-os.org/doc/yubikey/
```

## testing buskill dead-person's switch (would prefer password-entry dead-person's switch)
```
https://www.buskill.in/qubes-os/
```

## enlarged dom0
```
sudo lvresize --size 50G /dev/mapper/qubes_dom0-root
sudo resize2fs /dev/mapper/qubes_dom0-root
```

## anonymize MAC address and hostname
https://github.com/Qubes-Community/Contents/blob/master/docs/privacy/anonymizing-your-mac-address.md
These steps should be done inside a template to be used to create a NetVM as it relies on creating a config file that would otherwise be deleted after a reboot due to the nature of AppVMs.

Write the settings to a new file in the `/etc/NetworkManager/conf.d/` directory, such as `00-macrandomize.conf`.
The following example enables Wifi and Ethernet MAC address randomization while scanning (not connected), and uses a randomly generated but persistent MAC address for each individual Wifi and Ethernet connection profile.

~~~
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=stable
ethernet.cloned-mac-address=stable
connection.stable-id=${CONNECTION}/${BOOT}
#use random IPv6 addresses per session / don't leak MAC via IPv6 (cf. RFC 4941):
ipv6.ip6-privacy=2
~~~

* `stable` in combination with `${CONNECTION}/${BOOT}` generates a random address that persists until reboot.
* `random` generates a random address each time a link goes up.

To see all the available configuration options, refer to the man page: `man nm-settings`

Next, create a new NetVM using the edited template and assign network devices to it.

Finally, shutdown all VMs and change the settings of sys-firewall, etc. to use the new NetVM.

You can check the MAC address currently in use by looking at the status pages of your router device(s), or inside the NetVM with the command `sudo ip link show`.

DHCP requests also leak your hostname to your LAN. Since your hostname is usually `sys-net`, other network users can easily spot that you're using Qubes OS.

Unfortunately `NetworkManager` currently doesn't provide an option to disable that leak globally ([Gnome Bug 768076](https://bugzilla.gnome.org/show_bug.cgi?id=768076)). However the below alternatives exist.

`NetworkManager` can be configured to use `dhclient` for DHCP requests. `dhclient` has options to prevent the hostname from being sent. To do that, add a file to your `sys-net` template (usually the Fedora or Debian base template) named e.g. `/etc/NetworkManager/conf.d/dhclient.conf` with the following content:  
```
[main]
dhcp=dhclient
```
Afterwards edit `/etc/dhcp/dhclient.conf` and remove or comment out the line starting with `send host-name`.

If you want to decide per connection, `NetworkManager` also provides an option to not send the hostname:  
Edit the saved connection files at `/rw/config/NM-system-connections/*.nmconnection` and add the `dhcp-send-hostname=false` line to both the `[ipv4]` and the `[ipv6]` section.

Alternatively you may use the following code to assign a random hostname to a VM during each of its startup. Please follow the instructions mentioned in the beginning to properly install it.

```.bash
#!/bin/bash
set -e -o pipefail
#
# Set a random hostname for a VM session.
#
# Instructions:
# 1. This file must be placed and made executable (owner: root) inside the template VM of your network VM such that it will be run before your hostname is sent over a network.
# In a Fedora template, use `/etc/NetworkManager/dispatcher.d/pre-up.d/00_hostname`.
# In a Debian template, use `/etc/network/if-pre-up.d/00_hostname`.
# 2. Execute `sudo touch /etc/hosts.lock` inside the template VM of your network VM.
# 3. Execute inside your network VM:
#  `sudo bash -c 'mkdir -p /rw/config/protected-files.d/ && echo -e "/etc/hosts\n/etc/hostname" > /rw/config/protected-files.d/protect_hostname.txt'`


#NOTE: mv is atomic on most systems
if [ -f "/rw/config/protected-files.d/protect_hostname.txt" ] && rand="$RANDOM" && mv "/etc/hosts.lock" "/etc/hosts.lock.$rand" ; then
	name="PC-$rand"
	echo "$name" > /etc/hostname
	hostname "$name"
	#NOTE: NetworkManager may set it again after us based on DHCP or /etc/hostname, cf. `man NetworkManager.conf` @hostname-mode
	
	#from /usr/lib/qubes/init/qubes-early-vm-config.sh
	if [ -e /etc/debian_version ]; then
            ipv4_localhost_re="127\.0\.1\.1"
        else
            ipv4_localhost_re="127\.0\.0\.1"
        fi
        sed -i "s/^\($ipv4_localhost_re\(\s.*\)*\s\).*$/\1${name}/" /etc/hosts
        sed -i "s/^\(::1\(\s.*\)*\s\).*$/\1${name}/" /etc/hosts
fi
exit 0
```
Assuming that you're using `sys-net` as your network VM, your `sys-net` hostname should now be `PC-[number]` with a different `[number]` each time your `sys-net` is started.

## Qubes compartmentalization
I've compartmentalized my digital personal and work lives thusly:

## configure offline write & research Qube vault
https://www.dropbox.com/s/bnsysjubsyq45ud/Scrivener-1.9.0.1beta-x86_64_language_pack.AppImage.tar.gz
Into a Fedora-xx template clone
```
cd ./Downloads/Scrivener*AppImage
chmod a+x Scrivener*AppImage
./Scrivener*AppImage --appimage-extract
Move squashfs-root folder to appVM
refresh applications
Launch AppRun

```

## configure ProtonVPN Qube
```
qvm-clone fedora-35-minimal fedora-35-minimal-sys-vpn

mkdir ~/temp && cd ~/temp
curl --remote-name --remote-header-name --proxy http://127.0.0.1:8082 https://protonvpn.com/download/protonvpn-stable-release-1.0.0-1.noarch.rpm
rpm2cpio protonvpn-stable-release-1.0.0-1.noarch.rpm | cpio --extract --make-directories --preserve-modification-time --verbose --quiet
mv ~/temp/etc/yum.repos.d/protonvpn-stable-f33.repo /etc/yum.repos.d/

dnf upgrade
dnf install protonvpn qubes-core-agent-networking qubes-core-agent-network-manager network-manager-applet notification-daemon  NetworkManager-openvpn-gnome gnome-keyring

qvm-create --template fedora-35-minimal-sys-vpn --label green sys-vpn
qvm-prefs sys-vpn autostart false
qvm-prefs sys-vpn netvm sys-firewall
qvm-prefs sys-vpn provides_network true
qvm-service sys-vpn network-manager true
qvm-create --template fedora-35-minimal-sys-vpn --label red sys-vpn-tor
qvm-prefs sys-vpn-tor autostart false
qvm-prefs sys-vpn-tor netvm sys-firewall
qvm-prefs sys-vpn-tor provides_network true
qvm-service sys-vpn-tor network-manager true

protonvpn init
```

## configure Comms Qube (Signal, WhatsApp, Zoom)
- tk

## configure email (Thunderbird with Proton Bridge) Qube 
- tk

## configure multimedia Qube
- tk

## configure Windows Qube
Legacy and more personal software live here. Also home to much of my multimedia accounts: Spotify, Netflix, Spotify, Netflix, Amazon Prime (via Chromium), etc. Still having difficulties getting windows tools to work.
(https://github.com/Qubes-Community/Contents/blob/master/docs/os/windows/windows-vm.md)
```
qvm-create --class StandaloneVM --label red --property virt_mode=hvm win7new
qvm-prefs win7new memory 4096
qvm-prefs win7new maxmem 4096
qvm-prefs win7new kernel ''
qvm-volume extend win7new:root 25g
qvm-prefs win7new debug true
qvm-features win7new video-model cirrus
qvm-start --cdrom=untrusted:/home/user/windows_install.iso win7new
# restart after the first part of the windows installation process ends
qvm-start win7new
# once Windows is installed and working
qvm-prefs win7new memory 2048
qvm-prefs win7new maxmem 2048
qvm-features --unset win7new video-model
qvm-prefs win7new qrexec_timeout 300
# with Qubes Windows Tools installed:
qvm-prefs win7new debug false
```
To install Qubes Windows Tools, follow instructions in Qubes Windows Tools (https://www.qubes-os.org/doc/windows-tools/).

## add split browser personal "surfer" qube
https://github.com/rustybird/qubes-app-split-browser

Combination      | Function
-----------------|--------------------------------------------------------------
**Alt-b**        | Open bookmarks
**Ctrl-d**       | Bookmark current page
Ctrl-Shift-Enter | Log into current page
Ctrl-Shift-s     | Move downloads to a VM of your choice
**Ctrl-Shift-u** | `New Identity` on steroids: Quit and restart the browser in a new DisposableVM, with fresh Tor circuits.

Create a new persistent VM or take an existing one, and configure it to launch the right DisposableVMs and (optionally, for safety against user error) to have no network access itself:

1. Create a new persistent VM or take an existing one, and configure it to launch the right DisposableVMs and (optionally, for safety against user error) to have no network access itself:

        qvm-create --label=purple surfer
        qvm-prefs surfer default_dispvm whonix-ws-XX-dvm
        qvm-prefs surfer netvm ''

   The DisposableVMs will know which persistent VM launched them, so don't name it "rumplestiltskin" if an exploited browser mustn't find out.

2. Install the `qubes-split-browser` package from [qubes-repo-contrib](https://www.qubes-os.org/doc/installing-contributed-packages/) in your persistent VM's TemplateVM (e.g. fedora-XX).

   _Or install manually:_ Copy `vm/` into your persistent VM or its TemplateVM (e.g. fedora-XX) and run `sudo make install-persist`; then install the `dmenu pwgen oathtool` packages in the TemplateVM.

3. Install the `qubes-split-browser-disp` package from qubes-repo-contrib in your persistent VM's default DisposableVM Template's TemplateVM (e.g. whonix-ws-XX).

   _Or install manually:_ Copy `vm/` into your persistent VM's default DisposableVM Template (e.g. whonix-ws-XX-dvm) or the latter's TemplateVM (e.g. whonix-ws-XX) and run `sudo make install-disp`; then install the `xdotool` package in the TemplateVM.

   Either way, also ensure that an extracted Tor Browser will be available in `~/.tb/tor-browser/` (e.g. by running the Tor Browser Downloader `update-torbrowser` in whonix-ws-XX).

4. You can enable the Split Browser application launcher shortcuts for your persistent VM as usual through the Applications tab in Qube Settings, or alternatively run `split-browser` in a terminal (with `-h` to see the help message).

Install the qubes-split-browser package from qubes-repo-contrib in your persistent VM's TemplateVM (e.g. fedora-XX).
 ensure that an extracted Tor Browser will be available in ~/.tb/tor-browser/ (e.g. by running the Tor Browser Downloader update-torbrowser in whonix-ws-XX). You can enable the Split Browser application launcher shortcuts for your persistent VM as usual through the Applications tab in Qube Settings, or alternatively run split-browser in a terminal (with -h to see the help message).
