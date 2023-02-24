# Qubes compartmentalization

In an effort to keep the configuration at its most basic for working journalists and to require the least amount of maintenence, I've compartmentalized my digital personal and work lives thusly (intermediate and advanced options are elsewhere within this folder:

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
