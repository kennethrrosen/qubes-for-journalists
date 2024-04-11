qujourno (salt states for journalists)
=========================

Journalists rarely have the time to learn and navigate a new operating system. But they are familiar with many of the privacy- and security-focused tools and applications which Qubes hosts so well. QubesOS does a great many things, none of which (as yet) I explain here or in the Wiki. These scripts offer exactly what a journalist might use, in an environment that does not require a learning curve.

### 🟧 some notes on some decisions I've made

[TK]

### 🟧 how to install the salt scripts
 - Ask a network admin or security admin in your newsroom to assist. Buy a new laptop for Qubes only.
 - Write to me kennethrrosen@proton.me
 - There is a helpful `setup` script, but first you must (trust) and then clone this repository to a disp-vm in Qubes, [then transfer to dom0](https://www.qubes-os.org/doc/how-to-copy-from-dom0/#copying-to-dom0), then run the `setup` script. Presently (April, 2024) the setup script does not assume you wish all qubes/applications to be installed, so those commands to install them separately are provided in each README of the various subdirectories.
 - A `setup-full` script is included to blindly install all the qubes and applications found in this repository. 

### 🟧 tools
 - add qubes-idle-shutdown-app in templates
 - add Mac-inspired XFCE tray
 - remove/replace gnome-keyring prompt in proton-vpn
