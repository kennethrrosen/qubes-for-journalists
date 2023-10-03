# dom0 tuning (T480)

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

### activate double-tap-to-click
- Open the “Session and Startup” option in the Xfce settings.
- Navigate to the “Application Autostart” tab.
- Click “Add” to add a new startup application.
- Enter a name, description, and the command you want to run, then click OK.
- Create a file in your home directory named set_trackpad.sh.
```
#xinput --list
#!/bin/bash
xinput --list-props 10
xinput --set-props 10 324 1
xinput --set-props 10 325 1
xinput --set-props 10 340 1,1
```
### add qcrypt to dom0
```
https://github.com/3hhh/qcrypt
```
### disable Qubes splash screen
```
sudo nano /etc/default/grub
Remove 'rhgb' and 'quiet' from GRUB_CMDLINE_LINUX line and add 'plymouth.enable=0'
Rebuild grub config sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Rebuild initrd sudo dracut -f
reboot
```

### install additional repos
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

### config thinkfan
`sudo qubes-dom0-update thinkfan` then add `/etc/thinkfan.conf`:
```
tp_fan /proc/acpi/ibm/fan
tp_thermal /proc/acpi/ibm/thermal (0, 10, 15, 2, 10, 5, 0, 3)

hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp6_input
hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp3_input
hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp7_input
hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp4_input
hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp8_input
hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp1_input
hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp5_input
#hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp2_input
hwmon /sys/devices/virtual/thermal/thermal_zone0/hwmon1/temp1_input
hwmon /sys/devices/virtual/thermal/thermal_zone3/hwmon4/temp1_input

(0,	0,	65)
(1,	65,	75)
(2,	75,	80)
(3,	80,	85)
(4,	85,	90)
(5,	90,	95)
(7,	95,	32767)

```
### Add dom0 startup menu
```
[see start menu repo](https://github.com/kennethrrosen/qubes-boot-verification)
```
### Adjust battery charging thershold
```
[see 'toggle_mode' repo](https://github.com/kennethrrosen/qubes-mode-toggler)
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
### or swap sys-firewall for sys-pihole
Following: https://forum.qubes-os.org/t/tool-simple-set-up-of-new-qubes-and-software/13064

### add /.config/devilspie2/ config
First `qubes-dom0-update devilspie2`, then add devilspie2 folder to `.config`.
```
qube = get_window_property("_QUBES_VMNAME");
ws = 0;

if qube == "dom0" then ws = 0
elseif qube == "writ" then ws = 2
elseif qube == "browser" then ws = 1
elseif qube == "mutli" then ws = 4
elseif qube == "comms" then ws = 3
elseif qube == "admin" then ws = 4
elseif qube == "core-lombroso-admin" then ws = 3
elseif qube == "vault" then ws = 4
elseif qube == "win10" then ws = 3
elseif qube == "core-sdadmin" then ws = 5
end

if ws > 0 then
    set_window_workspace(ws);
    change_workspace(ws);
end

if (get_window_name() == "win10") then
    set_window_fullscreen(true);
end

```

### add split-ssh
```
tktktkt
```

### add dom0 backup local
```
tktktkt
```

### enable Yubikey for mandatory login removal lockswitch
```
https://www.qubes-os.org/doc/yubikey/
```
