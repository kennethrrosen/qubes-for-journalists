journoQUBES
=========================
This is a working list as I go through the intitialization of the Qubes 4.1.1 (on a Librem 14), a running tab of work done to it for future reference and backup purposes; also, for future project on journalist digital security. It is also a description of my various Qubes and their setups.

NOTE: Qubes is as the hardest possible OS for journalists as a daily driver. (TAILS is the preferred choice for in-a-pinch necessity, emergencies, and use under opressive regimes with active net-monitoring.) Nevertheless, the steps below consider a threat model in the grey area between levels 2 - 3 (of 4) of the Cupwire standard (https://www.cupwire.com/threat-modeling/). I've found this middle ground idylic for most foreign correspondents who are often already operating (or seeking to operate) with this level of anonymity. Much of this repository was created from various sources in an attempt to centralize tools for journalists. If credit is not cited where credit is do, please let me know and I will rectify.

digital and personal security best practices
--------
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
- Open all links in a preferred AppVM (like the Split Browser, or your disposable Tor): https://github.com/Qubes-Community/Contents/blob/master/docs/configuration/tips-and-tricks.md#opening-links-in-your-preferred-appvm
- for anonymous PGP-encrypted email over Tor, use Mozilla Thunderbird.
- physically move all mobiles devices to a distant physical location or faraday bag

pre-installation hardware/software configurations
--------
### TKKT
- disabled Intel ME (Librem standard)
- coreboot & seaBIOS firmware
- physical hardware disconnect for microphone, wifi, bluetooth, webcam
- removed speakers
- removed beeper
- tamper-evident screws and ports

post-installation OS configurations
--------
### TKKT
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
- configure a system-wide URL-redirector: https://github.com/raffaeleflorio/qubes-url-redirector
- configure app-speciic (Thunderbird) URL-redirector: https://github.com/Qubes-Community/Contents/blob/master/docs/common-tasks/opening-urls-in-vms.md

### swap PureBoot to Coreboot and SeaBIOS
Secure boot is necessary; but with the system changes ahead, I've found it easier to switch to Coreboot before reverting after all initial system setup changes are made. 

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
### disable Qubes splash screen
In Dom0 -- (TODO: consider organizing under dom0 customization header)
```
sudo nano /etc/default/grub
Remove rhgb from GRUB_CMDLINE_LINUX line
Rebuild grub config sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Rebuild initrd sudo dracut -f
reboot
```

### install additional repos
In Dom0 -- (TODO: consider organizing under dom0 customization header)
```
sudo qubes-dom0-update qubes-repo-contrib
In Fedora: sudo dnf install qubes-repo-contrib
In Debian: sudo apt update && sudo apt install qubes-repo-contrib
```

### fix CPU scaling
In dom0:
```
sudo nano /etc/modules-load.d/xen-acpi-processor.conf
Write xen-acpi-processor and save.
Reboot.
```

### resize dom0
```
sudo lvresize --size 25G /dev/mapper/qubes_dom0-root
sudo resize2fs /dev/mapper/qubes_dom0-root
```

### install librem-ec-acpi-dkms
https://source.puri.sm/-/snippets/1170
```
Have had issues with this before, but will continue trying.
```

### swap sys-firewall for mirage-firewall
Following: https://builds.robur.coop/job/qubes-firewall
```
qvm-run --pass-io <src_domain> 'cat /path/to/file_in_src_domain' > /path/to/file_name_in_dom0

tar xjf mirage-firewall.tar.bz2

dir -p /var/lib/qubes/vm-kernels/mirage-firewall/
cd /var/lib/qubes/vm-kernels/mirage-firewall/
qvm-run -p dev 'cat mirage-firewall/vmlinuz' > vmlinuz

gzip -n9 < /dev/null > initramfs

qvm-create \
  --property kernel=mirage-firewall \
  --property kernelopts='' \
  --property memory=64 \
  --property maxmem=64 \
  --property netvm=sys-net \
  --property provides_network=True \
  --property vcpus=1 \
  --property virt_mode=pvh \
  --label=green \
  --class StandaloneVM \
  mirage-firewall

qvm-features mirage-firewall qubes-firewall 1
qvm-features mirage-firewall no-default-kernelopts 1
```

Qubes compartmentalization
--------
In an effort to keep the configuration at its most basic for working journalists and to require the least amount of maintenence, I've compartmentalized my digital personal and work lives thusly:

1.
2.
3.
4.
5.



## configure offline write & research Qube vault
Into a Fedora-xx template clone, install CrossOver. Create a Bottle for the writing tool of your choice. For me, that's Scrivener: 
https://www.dropbox.com/s/bnsysjubsyq45ud/Scrivener-1.9.0.1beta-x86_64_language_pack.AppImage.tar.gz

Since I prefer to keep my interview transcriptions and sourcing lists offline and separate from other Qubes, I've install Split-Browser into the researcher/write vault: https://github.com/rustybird/qubes-app-split-browser

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

### configure VPN Qube
Manage, run, protect VPN connections in Proxy VMs. In this instance, I'm using ProtonVPN, which I recommend for journalists across platforms and devices. Regular usage is simple: Just use `sys-vpn` as NetVM for other VMs. I use only in my browserVM.

Follow these steps: https://forum.qubes-os.org/t/how-to-setup-openvpn-fedora-appvm-for-ovpn/3354

### configure Comms Qube (Signal, WhatsApp)
Note: if you've the time, it's prudent to break these into two separate Qubes.
- tk

### configue disposable Zoom, Skype (multimedia) qube
- tk

### configure email (Thunderbird with Proton Bridge) Qube 
- tk

### configure multimedia Qube for Spotify
I've assigned bluetooth audio to this VM. First you need to identify an user VM dedicated to audio and assign a device to it. In the most common case the assigned device is the USB controller to which your USB audio card will be connected.

(Adobe-Connect-Linux by mahancoder)

```
Make sure template has these packages installed:
qubes-usb-proxy bluez blueman pulseaudio-module-bluetooth
 
Start the VM. Connect the dongle to the VM. Put the speaker/headphones in pairing mode. Open Bluetooth Devices and click search. Let the search finish. Do NOT connect to it yet.Run these commands:
 
pulseaudio -k
pulseaudio -D
 
Now connect the speaker/headphones. It should pair and connect successfully.
```

### configure Thunderbird Qube

Open a text editor and copy and paste this into it:

    [Desktop Entry]
    Encoding=UTF-8
    Name=BrowserVM
    Exec=qvm-open-in-vm APPVMNAME %u
    Terminal=false
    X-MultipleArgs=false
    Type=Application
    Categories=Network;WebBrowser;
    MimeType=x-scheme-handler/unknown;x-scheme-handler/about;text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;

Replace `APPVMNAME` with the AppVM name you want to open links in. Now save, in the AppVM that you want to modify, this file to `~/.local/share/applications/browser_vm.desktop`

Finally, set it as your default browser:

`xdg-settings set default-web-browser browser_vm.desktop`

Credit: [Micah Lee](https://micahflee.com/2016/06/qubes-tip-opening-links-in-your-preferred-appvm/)

### configure CryptPad Qube
- TK

### configure syncthing Qube
- TK

### configure banking DVM
- open only to port 443 through Qubes firewall settings

### configure OSINT Qube for Mantego use
```
qvm-template-gui
install Kali template
```

### configure Windows Qube
Legacy and more personal software live here.
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
