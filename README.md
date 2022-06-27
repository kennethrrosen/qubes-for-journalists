# secureQUBES
Steps taken to harden Qubes (4.1) on a Librem 14. Despite the security of the Purism laptop, I took additional steps (hardware, software) to add enhanced security. This is a working list as I go through the intitialization of the OS, a running tab of work done to it for future reference and backup purposes; also, for future project on journalist digital security.

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
###### add VPN Qube
- tk
- 
###### add Windows Qube
- tk

### Qubes Compartmentalization
