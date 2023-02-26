# dom0 tuning (Librem 14)

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
### install TLP power management utility
```
sudo qubes-dom0-update tlp
install and configure tlp in dom0 (file is here: /etc/tlp.conf)
add PM_RUNTIME=y
systemctl mask systemd-rfkill.socket
Rebuild grub config sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Rebuild initrd sudo dracut -f
reboot
```
### Adjust battery charging thershold
```
cat /sys/class/power_supply/BAT0/charge_control_start_threshold
cat /sys/class/power_supply/BAT0/charge_control_end_threshold
nano /sys/class/power_supply/BAT0/charge_control_start_threshold
nano /sys/class/power_supply/BAT0/charge_control_end_threshold
```

### install librem-ec-acpi-dkms
https://source.puri.sm/-/snippets/1170. Have had issues with this before. LED persist:

```
sudo -i
modprobe ledtrig-netdev
echo netdev > /sys/class/leds/librem_ec\:airplane/trigger
echo wls6 > /sys/class/leds/librem_ec\:airplane/device_name
echo 1 > /sys/class/leds/librem_ec\:airplane/rx
echo 1 > /sys/class/leds/librem_ec\:airplane/tx
exit

```
Now place all these as a command in the `session and starup` section of the Qubes menu to allow the wifi/bluetooh light to persist.

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
### add /.config/devilspie2/ config
```
tktktkt
```

### enable Yubikey for mandatory login removal lockswitch
```
https://www.qubes-os.org/doc/yubikey/
