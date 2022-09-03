/******
*    name: journoQUBES arkenfox user-overrides.js
*    date: 3 September 2022
*    version: 103
*     url: https://github.com/kennethrrosen/journoQUBES/
*    NOTES:
*    These settings work for me and my threat level. They may break some websites. Refer back to arkenfox for greater assessments and sourcing on practicality of most.
******/

/*** [SECTION 0100]: STARTUP ***/
user_pref("browser.startup.page", 3); // 103, default is 0

/*** [SECTION 0400]: SAFE BROWSING ***/
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);

/*** [SECTION 700]: DNS/DoH/PROXY/SOCKS/IPV6 ***/
	//user_pref("network.trr.mode", 2); //set DoH to custom adress (0710: disable DNS-over-HTTPS (DoH) rollout [FF60+] 0=off by default, 2=TRR (Trusted Recursive Resolver) first, 3=TRR only, 5=explicitly off)
	//user_pref("network.trr.custom_uri", "https://adblock.doh.mullvad.net/dns-query"); //custom adress
	//user_pref("network.trr.uri", "https://adblock.doh.mullvad.net/dns-query"); //custom adress

/*** [SECTION 2600]: MISC. ***/
user_pref("browser.download.useDownloadDir", true); //always download files to the System Download Directory

/*** [SECTION 2800]: SHUTDOWN & SANITIZING ***/
user_pref("privacy.clearOnShutdown.history", false); // default is TRUE

/*** [SECTION 4500:] RESIST FINGERPRINTING ***/

/*** [SECTION 5000]: OPTIONAL OPSEC ***/
user_pref("places.history.enabled", false); // disables history entirely
user_pref("browser.urlbar.suggest.topsites", false); //no top sites in the suggestions
user_pref("signon.rememberSignons", false); //never ask to save passwords

/*** [SECTION 5500]: OPTIONAL HARDENING ***/
user_pref("javascript.options.ion", false); //javascript "hardening", might cause slowdowns/breakage
user_pref("javascript.options.asmjs", false); //same as above
user_pref("javascript.options.wasm", false); //WebAssembly support. Completly disables WASM, for the security gain and speed loss
user_pref("javascript.options.baselinejit", false); //Disabled Just In Time compilation - usually breaks sites with a lot of javascript but is a huge security gain

/*** [SECTION 7000]: "DON'T BOTHER" ***/
user_pref("permissions.default.geo", 2); //deny location access.default 0, 1=allow, 2=block
user_pref("permissions.default.camera", 0);
user_pref("permissions.default.microphone", 0);
user_pref("permissions.default.desktop-notification", 0);
user_pref("permissions.default.xr", 0); // Virtual Reality
user_pref("geo.enabled", false); //fullly disable location acces
user_pref("dom.webaudio.enabled",false); //old api used for fingerprinting probably, hasn't broken anything FOR ME
user_pref("dom.webnotifications.enabled", false); // fully disabled notifications

/*** [SECTION 9000]: PERSONAL ***/
user_pref("extensions.pocket.enabled", false); //fully disable pocket
user_pref("identity.fxaccounts.enabled", false); //disable sync
