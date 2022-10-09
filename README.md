journoQUBES
=========================

**This repo is "under construction" [Oct. 2022]

Tweaks and configurations to QubesOS (4.1.1) for use by journalists, lawyers, and at-risk populations.

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
