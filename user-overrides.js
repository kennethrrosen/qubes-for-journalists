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
user_pref("privacy.resistFingerprinting.letterboxing.dimensions", "800x800")

/*** [SECTION 5000]: OPTIONAL OPSEC ***/
user_pref("browser.cache.memory.enable", false);
user_pref("browser.cache.memory.capacity", 0);
user_pref("browser.urlbar.suggest.topsites", false); //no top sites in the suggestions
user_pref("signon.rememberSignons", false); //never ask to save passwords
user_pref("permissions.memory_only", true); // [HIDDEN PREF]
user_pref("security.nocertdb", true); // [HIDDEN PREF in FF101 or lower]
user_pref("browser.chrome.site_icons", false);
user_pref("browser.sessionstore.max_tabs_undo", 0);
user_pref("browser.download.forbid_open_with", true);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.bookmark", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.topsites", false); // [FF78+]
user_pref("browser.urlbar.maxRichResults", 0);
user_pref("places.history.enabled", false);
user_pref("browser.download.folderList", 2);

/*** [SECTION 5500]: OPTIONAL HARDENING ***/
user_pref("javascript.options.ion", false); //javascript "hardening", might cause slowdowns/breakage
user_pref("javascript.options.asmjs", false); //same as above
user_pref("javascript.options.wasm", false); //WebAssembly support. Completly disables WASM, for the security gain and speed loss
user_pref("javascript.options.baselinejit", false); //Disabled Just In Time compilation - usually breaks sites with a lot of javascript but is a huge security gain

/*** [SECTION 9000]: PERSONAL ***/
user_pref("extensions.pocket.enabled", false); //fully disable pocket
user_pref("identity.fxaccounts.enabled", false); //disable sync
user_pref("ui.systemUsesDarkTheme", 1); //
user_pref("media.autoplay.default", 5);
user_pref("media.autoplay.blocking_policy", 2); // disable autoplay if you interacted with the site [FF78+]
user_pref("clipboard.autocopy", false); // disable autocopy default [LINUX]
user_pref("browser.quitShortcut.disabled", true); // disable Ctrl-Q quit shortcut [LINUX] [MAC] [FF87+]

