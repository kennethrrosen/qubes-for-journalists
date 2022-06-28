# secureQUBES
Steps taken to harden Qubes (4.1) on a Librem 14. Despite the security of the Purism laptop, I took additional steps (hardware, software) to add enhanced security. This is a working list as I go through the intitialization of the OS, a running tab of work done to it for future reference and backup purposes; also, for future project on journalist digital security.

###### physical (& BIOS/firmware) hardening
- disabled IME (Librem standard)
- Librem Key boot access (Purism standard)
- anti-evil-maid (not necessary with Librem)
- coreboot/pureboot firmware
- physical hardware disconnect for microphone, wifi, bluetooth, webcam
- removed speakers
- removed beeper
- tamper-evident screws

###### enlarged dom0
```
sudo kvresize --size 50G /dev/qubes_dom0/root
sudo resize2fs /dev/mapper/qubes_dom0-root
```

###### sys-net as usbvm (not created at initialization)
```
qubesctl top.enable qvm.sys-usb qvm.sys-net
qubesctl state.highstate
(qubesctl top.disable qvm.sys-net-as-usbvm pillar=True) if intention was to get separate sys-usb as it is by default
```

###### Encrypt secondary SDD with LVM on LUKS
```
vgcreate vg1 /dev/crypt1
(https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/logical_volume_manager_administration/vg_admin#VG_create)

lvcreate -L 100M -T vg001/cyrptpool
(https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/logical_volume_manager_administration/thinly_provisioned_volume_creation)

sudo pvs
sudo lvs
# <pool_name> is a freely chosen pool name
# <vg_name> is LVM volume group name
# <thin_pool_name> is LVM thin pool name
qvm-pool --add <pool_name> lvm_thin -o volume_group=<vg_name>,thin_pool=<thin_pool_name>,revisions_to_keep=2
qvm-create -P <pool_name> --label red <vmname>
qvm-clone -P <pool_name> <sourceVMname> <cloneVMname>
qvm-remove <sourceVMname>
qvm-prefs <appvmname_based_on_old_template> template <new_template_name>

sudo cryptsetup luksFormat --hash=sha512 --key-size=512 --cipher=aes-xts-plain64 --verify-passphrase /dev/sdb
sudo blkid /dev/sdb

sudo nano /etc/crypttab
luks-($NAME) UUID=($NAME) none
sudo pvcreate /dev/mapper/luks-($NAME)
sudo vgcreate qubes /dev/mapper/luks-($NAME)
sudo lvcreate -T -n poolhd0 -l +100%FREE qubes
qvm-pool --add poolhd0_qubes lvm_thin -o volume_group=qubes,thin_pool=poolhd0,revisions_to_keep=2
qvm-create -P poolhd0_qubes --label red unstrusted-hdd (ONLY IF YOU WANT TO CREATE QUBES ON THE NEW DISK)
```
### to do
```
Consider disabling microphones

Consider enabling SysRq "Security Keys" functionality as insurance against system malfunctions

Secure Access Key ("Sak"; SysRq + k) procedure.

detach webcams or even better, physically cover webcams with a sticker or switch

Since speakers (all audio output devices) can be turned into microphones, if possible, physically remove speakers on the host and remove/disable the beeper.

Preferably disable or remove Bluetooth hardware modules.

If using Qubes-Whonix ™, assign the webcam to an untrusted VM (if needed)

In File Manager, disable previews of files from untrusted sources. Change file preferences in the Template's File Manager so future App Qubes inherit this feature.
Files received or downloaded from untrusted sources (the internet, via email etc.) should not be opened in a trusted VM. Instead, open them in a DisposableVM: Right-click → Open In DisposableVM
Untrusted PDFs should be opened in a DisposableVM or converted into a trusted (sanitized) PDF to prevent exploitation of the PDF reader and potential infection of the VM.

Since the mobile devices security best practices for risk mitigation are often difficult / infeasible to adhere to, it might be easier to physically move all mobiles devices to a distant physical location such as a different room and close the door and/or to power off mobile devices.

dnf list | grep microcode
The Qubes check should confirm the microcode_ctl.x86_64 package is already installed.

Enable all available apparmor profiles in the Whonix-Workstation ™ and Whonix-Gateway ™ Templates.
Enable seccomp on Whonix-Gateway ™ (sys-whonix ProxyVM).

Move files downloaded by Tor Browser from the ~/Downloads folder to another specially created one.

At a minimum, lock the screen of the host when it is unattended. power button shutdown

consider using Diceware passphrases

Download Internet files securely using scurl

Prepare and safely utilize a USB qube. [30] [31]
Configure a disposable sys-usb

In Qubes-Whonix ™, consider installing the tirdad kernel module to protect against TCP ISN-based CPU information leaks

Set the Qubes, Debian and Whonix ™ package updates to Tor onion service repositories.

Consider installing a hardened memory allocator ('Hardened Malloc') to launch regularly used applications

Prefer the Debian Template for networking (sys-net and sys-firewall) since it is minimal in nature and does not "ping home", unlike the Fedora Template. [48]
Consider using customized minimal templates for NetVMs to reduce the attack surface and memory requirements. Four options are currently available:
CentOS [49]
Debian. [50]
Debian can optionally be morphed into a Kicksecure ™ Template for greater security

Test the LAN's router/firewall with either an internet port scanning service or preferably a port scanning application from an external IP address.

configure a de-militarized zone (perimeter network)

Follow all other Whonix ™ recommendations to lock down the router.

For greater security, higher performance and a lower resource footprint, consider using an experimental MirageOS-based unikernel firewall that can run as a QubesOS ProxyVM.
Consider utilizing OpenBSD for sys-net to reduce the attack surface. [52] See also other OpenBSD considerations.

Configure each ServiceVM as a static DisposableVM to mitigate the threat from persistent malware accross VM reboots. [64]

Consider disabling the Control Port Filter Proxy to reduce the attack surface of both the Whonix-Gateway ™ and Whonix-Workstation ™.
Consider hardening systemcheck.

Use split-GPG for email to reduce the risk of key theft used for encryption / decryption and signing.
Create an App Qube that is exclusively used for email and change the VM's firewall settings to only allow network connections to the email server and nothing else ("Deny network access except...").
Only open untrusted email attachments in a DisposableVM to prevent possible infection.

For anonymous PGP-encrypted email over Tor, use Mozilla Thunderbird.

Consider running ArpON

Anti-Evil Maid

Disable Intel ME Functionality

corridor as a filtering gateway to ensure only connections to Tor relays pass through

Opensource Firmware

Whonix-Workstation ™ Installation Steps

EXTERNAL_OPEN_PORTS+=" $(seq 17600 17659) "

On Whonix-Gateway ™. [7] [8]

Add onion-grater profile.

sudo onion-grater-add 40_onionshare Menu Donate

OnionShare Logo

Contents
Introduction
OnionShare Functionality
Security Design
Installation
Whonix-Gateway ™ Installation Steps
onion-grater Profile
Whonix-Workstation ™ Installation Steps
Firewall Settings
Installation
Using OnionShare
Start OnionShare
OnionShare Configuration
How-to: Use OnionShare
Share Files
Receive Files and Messages
Website Hosting
Anonymous Chat
Visit Authenticated OnionShare Services using Tor Browser in Whonix
OnionShare AppArmor Profiles
Troubleshooting
Footnotes
Introduction
OnionShare Functionality
OnionShare is an open source program that allows users to share/receive files, host a website or chat anonymously utilizing the Tor network. [1] The OnionShare wiki succinctly describes the design: [2]

Web servers are started locally on your computer and made accessible to other people as Tor onion services.

By default, OnionShare web addresses are protected with a random password. A typical OnionShare address might look something like this:

http://onionshare:constrict-purity@by4im3ir5nsvygprmjq74xwplrkdgt44qmeapxawwikxacmr3dqzyjad.onion

You’re responsible for securely sharing that URL using a communication channel of your choice like in an encrypted chat message, or using something less secure like unencrypted e-mail, depending on your threat model.

The people you send the URL to then copy and paste it into their Tor Browser to access the OnionShare service.

As of OnionShare version 2.0 it is also possible to run the program in Receive mode. This means you can receive files via OnionShare after they are uploaded by Tor Browser users; this is a sort of 'SecureDrop Lite' or personal dropbox. Version 2.2 of OnionShare also permits the easy hosting of anonymous websites:

In addition to the “Share Files” and “Receive Files” tabs, OnionShare 2.2 introduces the “Publish Website” tab. You drag all of the files that make up your website into the OnionShare window and click “Start sharing.” It will start a web server to host your static website and give you a .onion URL. This website is only accessible from the Tor network, so people will need Tor Browser to visit it. People who visit your website will have no idea who you are – they won’t have access to your IP address, and they won’t know your identity or your location. And, so long as your website visitors are able to access the Tor network, the website can’t be censored.

Version 2.3 of OnionShare allows users to share/receive files, host websites or chat anonymously at the same time using a tabs feature. The secure, ephemeral and anonymous chat feature is particularly useful since it does not require account creation, is encrypted end-to-end and reduces the risk of messages being stored locally: [3]

Now when you open OnionShare you are presented with a blank tab that lets you choose between sharing files, receiving files, hosting a website, or chatting anonymous. You can have as many tabs open as you want at a time, and you can easily save tabs (that's what the purple thumbtack in the tab bar means) so that if you quit OnionShare and open it again later, these services can start back up with the same OnionShare addresses. ... Another major new feature is chat. You start a chat service, it gives you an OnionShare address, and then you send this address to everyone who is invited to the chat room (using an encrypted messaging app like Signal, for example). Then everyone loads this address in a Tor Browser, makes up a name to go by, and can have a completely private conversation.

As OnionShare is an actively developed project, it is recommended to refer to official documentation for the latest features and information before use. Advanced users should also consider additional features like saving of tabs, turning off passwords, scheduled start/stop times, command line operations and legacy addresses.

Security Design
Table: OnionShare Security Design [4]

Protections Description
Third party access Third parties cannot access anything that happens in OnionShare because services are hosted directly on your computer. Filesharing does not utilise online servers, and chat rooms also use your computer as a server; trust in other computers is removed.
Network eavesdroppers Eavesdroppers cannot spy on OnionShare activities in transit because connections between Tor onions services and Tor Browser are encrypted end-to-end. Even malicious Tor nodes used for connections will only see encrypted traffic using the onion service's private key.
Anonymity OnionShare anonymity is protected by Tor. If OnionShare addresses are anonymously communicated with Tor Browser users, then eavesdroppers cannot learn the identity of the OnionShare user.
Onion service discovery Malicious actors cannot access anything just by learning about the onion service; attackers also need to guess the private key used for client authentication (access). [5]
OnionShare cannot protect users if the OnionShare address and private key is not communicated securely. For example, do not share this information via email which can be potentially monitored by attackers. It is far safer to utilize encrypted text messages for this purpose (preferably with disappearing messages enabled), encrypted email, or in-person sharing of this information. This method is not anonymous unless a new email account or chat account is only created/accessed over Tor.

Installation
Whonix-Gateway ™ Installation Steps
onion-grater Profile
Ambox notice.png This application requires incoming connections through a Tor onion service. Supported Whonix-Gateway ™ modifications are therefore necessary for full functionality; see instructions below.

For better security, consider using Multiple Whonix-Gateway ™ and Multiple Whonix-Workstation ™. In any case, Whonix ™ is the safest choice for running it. [6]

Extend the onion-grater whitelist in Whonix-Gateway ™ (sys-whonix).

On Whonix-Gateway ™. [7] [8]

Add onion-grater profile.

sudo onion-grater-add 40_onionshare
Whonix-Workstation ™ Installation Steps
Firewall Settings
Modify the Whonix-Workstation ™ (anon-onionshare) user firewall settings and reload them.

Modify Whonix-Workstation ™ User Firewall Settings

Note: If no changes have yet been made to Whonix ™ Firewall Settings, then the Whonix ™ User Firewall Settings File /etc/whonix_firewall.d/50_user.conf appears empty (because it does not exist). This is expected.

If using Qubes-Whonix ™, complete these steps.
In Whonix-Workstation ™ App Qube. Make sure folder /usr/local/etc/whonix_firewall.d exists.

sudo mkdir -p /usr/local/etc/whonix_firewall.d
Qubes App Launcher (blue/grey "Q") → Whonix-Workstation ™ App Qube (commonly called anon-whonix) → Whonix ™ User Firewall Settings

If using a graphical Whonix-Workstation ™, complete these steps.

Start Menu → Applications → System → User Firewall Settings

If using a terminal-only Whonix-Workstation ™, complete these steps.

Open file /usr/local/etc/whonix_firewall.d/50_user.conf with root rights.

sudoedit /usr/local/etc/whonix_firewall.d/50_user.conf
For more help, press on Expand on the right.

Add. [9]

EXTERNAL_OPEN_PORTS+=" $(seq 17600 17659) "
Save.

Reload Whonix-Workstation ™ Firewall.

If you are using Qubes-Whonix ™, complete the following steps.

Qubes App Launcher (blue/grey "Q") → Whonix-Workstation ™ App Qube (commonly named anon-whonix) → Reload Whonix ™ Firewall

If you are using a graphical Whonix-Workstation ™, complete the following steps.

Start Menu → Applications → System → Reload Whonix ™ Firewall

If you are using a terminal-only Whonix-Workstation ™, run.

sudo whonix_firewall
Installation
Before installing OnionShare:

A separate Whonix-Workstation ™ (Qubes-Whonix ™: anon-onionshare App Qube) is also recommended; see footnote. [10] The reason is the OnionShare installation will persist in this configuration and it is best practice to separate different, anonymous activities in distinct VMs (App Qubes).
After installation has finished, apply the Whonix ™ VM Configuration steps.
Installation using flatpak is discouraged because it leads to Tor over Tor.
Installation from Debian package sources as documented below is recommended.
Inside Whonix-Workstation ™.

Install package(s) onionshare.

A. Update the package lists and upgrade the system.

sudo apt update && sudo apt full-upgrade
B. Install the onionshare package(s).

Using apt command line parameter --no-install-recommends is in most cases optional.

sudo apt install --no-install-recommends onionshare
C. Done.

If using Qubes-Whonix ™, complete these steps.
In Whonix-Workstation ™ App Qube. Make sure folder /usr/local/etc/whonix_firewall.d exists.

sudo mkdir -p /usr/local/etc/whonix_firewall.d
Qubes App Launcher (blue/grey "Q") → Whonix-Workstation ™ App Qube (commonly called anon-whonix) → Whonix ™ User Firewall Settings

If using a graphical Whonix-Workstation ™, complete these steps.

Start Menu → Applications → System → User Firewall Settings

Configuring (not an official instructions link) the experimental GUI domain; [8] [9] and/or
Setting up an AudioVM. [1

Check gpg is enabled in config files (gpgcheck=1) if new Fedora repositories are installed.

If utilizing a SSD, consider setting up a periodic job in dom0 to trim the disk since this aids against local forensics. [17] [18]

Consider creating separate, specialized minimal Templates for distinct App Qube clearnet activities (like browsing) to reduce the attack surface. [21] [22]

Do not configure Kicksecure ™ as a Standalone VM

Consider replacing passwordless root access with a dom0 user prompt. [23

Consider split dm-crypt to isolate device-mapper based secondary storage encryption (not the root filesystem) and LUKS header processing to Disposables.

vm-boot-protect-root: suitable for service VMs like sys-usb and sys-net, as well as App Qubes such as untrusted, personal, banking, vault and so. [26]
vm-boot-protect: suitable for virtually any Debian or Fedora VM, such as Kicksecure ™ VMs, Standalone VMs and Disposable VMs.

Consider setting dom0 and all Templates to update over Tor by configuring this option on Qubes' first boot. [27] [28]

sudo systemctl enable hide-hardware-info.service
Reboot required.

```

###### add VPN Qube
- tk
- 
###### add Windows Qube
- tk

### qubes compartmentalization

### best practices

