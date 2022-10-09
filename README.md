journoQUBES
=========================

**This repo is "under construction" [Oct. 2022]

Existing guides and infrastructure for journalists insuffiecently prepares them for interacting with sources, working on sensitive stories while protecting sensitive materials, and traveling cross borders with personal and professional data.

There are myriad good resources for online anonymity,[^1] online privacy,[^2] and circumventing authoritarian regime strangholds on internet restrictions.[^3] But the job of keeping a secure digital environment is a marathon, not a race,[^4] one which is difficult to maintain while operating in mass media structures reliant on poor digital security infrastructure and loose guidelines for digital health.

Most journalists do not fundamentally understand how networks associate with their technology. [^5] Not for a lack of care or concern. There is simply a choice to be made: get the story, or dwaddle learning Linux, coding, and the demands of jobs which often offer only tools distributed by the news or media organization.

Researchers have also concluded similar failings of existing tools for journalists not pirmarily because of usability and integration issues, but that they actively hinder reporting, most sources dictate how communication is handled, and not least of all financial and timing constraints. [^6]

Attacks on journalists and freedom of the press have increased markedly over the past several
years around the globe, according to a paper published by the UC Berkely Center for Long-Term Cybersecurity, and a reason why "journalists do not take sufficient action to protect themselves online is that there is an overwhelming amount of security advice on the internet, most of which is difficult for journalist-readers to understand or translate into practice, and difficult for the authors of the advice to keep up to date."

The author, Kristen Berdan, continues:

>Most guides do not account for journalists’ busy schedules and time-pressured work cycles. Journalists also operate in an increasingly hostile environment, even in countries with democratic governments and some historical guarantees of freedom of the press and rule of law.

Berdan concludes advice available online "provide[s] no clear path for users to improve
their security in a time-efficient way."[^7]

This guide aims to help journalsts a) understand their threat model and b) assit in easily integrating security practices into their workflow, despite hurdles presented by company-proferred equipment and systems.

***
[^1]: https://anonymousplanet.org/guide.html
[^2]: https://www.privacyguides.org/
[^3]: https://thenewoil.org/
[^4]: https://www.amazon.com/Extreme-Privacy-What-Takes-Disappear/dp/B0898YGR58
[^5]: Quote by Edward Snowden, on Twitter (looking for source)
[^6]: 2015, "Investigating the Computer Security Practices and Needs of Journalists" https://www.franziroesner.com/pdf/journalism-sec15.pdf
[^7]: 2021, "An Evaluation of
Online Security Guides
for Journalists" https://cltc.berkeley.edu/wp-content/uploads/2021/01/Online_Security_Guides_for_Journalists.pdf


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
