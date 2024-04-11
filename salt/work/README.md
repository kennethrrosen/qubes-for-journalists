### work (slack & google chrome)

Creates a work appvm (qube) wherein you can use Google Chrome and Slack without needing to use the Qubes' global-copy-paste function. Save all your passwords in the `vault` qube, or have the browser remember them here and here alone.

Google Chrome is configured to launch at startup. Please ignore the `gnome-keyring` password prompt and it should go away thereafter.

**CAUTION**: The default is with a VPN connection through Proton, for which you must first install the proton vpn servicevm (qube). Otherwise the script will fail.

```
sudo qubesctl --targets=tpl-work,work state.apply qujourno.work.create
```
