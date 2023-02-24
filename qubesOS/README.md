QubesOS for Journalists
=========================

These is an open repository containing my notes from intitialization of the Qubes 4.1.1 (on a Librem 14), a running tab of work done to it for future reference and backup purposes; also, for future project on journalist digital security. It is also a description of my various Qubes and their setups.

## Contents 
- docs - How Tos
- qubes-setup - Describes basic, intermediate, and advanced setups
- automate - Scripts for dom0 tuning and automating setup
- salt - Salt scripts for advanced users

## General Thoughts/Nots

Qubes is as the most secure possible OS for journalists as a daily driver. (TAILS is the preferred choice for in-a-pinch necessity, emergencies, and use under opressive regimes with active net-monitoring.) Nevertheless, the steps below consider a threat model in the grey area between levels 2 - 3 (of 4) of the Cupwire standard (https://www.cupwire.com/threat-modeling/). I've found this middle ground idylic for most foreign correspondents who are often already operating (or seeking to operate) with this level of anonymity. Much of this repository was created from various sources in an attempt to centralize tools for journalists. If credit is not cited where credit is do, please let me know and I will rectify.

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
