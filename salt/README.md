qujourno (salt states for journalists)
=========================

Journalists rarely have the time to learn and navigate a new operating system. But they are familiar with many of the privacy- and security-focused tools and applications which Qubes hosts so well. QubesOS does a great many things, none of which (as yet) I explain here or in the Wiki. These scripts offer exactly what a journalist might use, in an environment that does not require a learning curve.

If you have suggestions for other applications you, or the journalists you work, with use frequently, please open an `issue` orn write me direcly.

### 🟧 some notes on some decisions I've made
 - **Gnome instead of XFCE:** Recently Qubes switched the default templates to the XFCE windows manager. Gnome is better-suited to newcomers to Qubes, so I've created all qubes with Debian and Fedora templates based on Gnome. This may take extra time to download the base templates (Fedora-39, Debian-12), but the end-user experience will be easier.
 - **No minimal templates:** Minimal templates offer a smaller footprint on computers with less storage, and lessen the potential attack surface. For useability, these are not used.
 - **Packages installed in AdminVM (dom0):** Don't trust me. Read the scripts, or ask an admin to review. In some scripts I've installed `qubes-shared-folders` into dom0, but this is not strictly necessary. Always review the packages before installing. When possible, I've tried to package the remote applications into files here to make the installation quicker, but it is possible to use `curl` or `wget` from trusted sources instead, though this may take longer.
 - **All communications apps connect through Tor:** Since most journalists are familiar with the tenants and benefits of the Tor network, all communications (Signal, WhatsApp, Telegram, Proton Mail) are served over Tor through the `sys-whonix` qube.
 -  **Individual READMEs:** Please familiarize yourself with the `README`s including in each salt subdirectory before installing. They provide additional information on what to expect after the qube is installed.
 
### 🟧 how to install the salt scripts
 - Ask a network admin or security admin in your newsroom to assist. Buy a new laptop for QubesOS only. (A $150 Lenovo x230 with 8gb of memory and a 250GB harddrive is a great choice.)
 - Write to me kennethrrosen@proton.me
 - There is a helpful `setup` script, but first you must (trust) and then clone this repository to a disp-vm in Qubes, [then transfer to dom0](https://www.qubes-os.org/doc/how-to-copy-from-dom0/#copying-to-dom0), then run the `setup` script. Presently (April, 2024) the setup script does not assume you wish all qubes/applications to be installed, so those commands to install them separately are provided in each README of the various subdirectories.
 - A `setup-full` script is included to blindly install all the qubes and applications found in this repository. 

### 🟧 todo
 - add `qubes-idle-shutdown-app` in templates
 - add Mac-inspired XFCE tray
 - remove/replace gnome-keyring prompt in `proton-vpn`
 - add `syncthingtray` rpm to `writing` qube
 - add `qubes-shared-folders` policies to `dom0`
 - add `crossover` rpm to `writing` files
 - reevaluate `set-menu-items` in each salt config
