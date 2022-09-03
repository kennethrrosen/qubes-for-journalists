/******
*    name: journoQUBES arkenfox user-overrides.js
*    date: 3 September 2022
*    version: 103
*     url: https://github.com/kennethrrosen/journoQUBES/
******/

user_pref("browser.startup.page", 3); // 0102
user_pref("privacy.clearOnShutdown.history", false); // 2811
user_pref("browser.download.useDownloadDir", true); //always download files to the System Download Directory
user_pref("browser.download.dir", "D:\Downloads");
user_pref("browser.compactmode.show", true); //compact mode is displayed by default
user_pref("browser.uidensity", 1); //enables compact mode by default
user_pref("privacy.spoof_english", 2); //spoofs english by default
user_pref("network.trr.mode", 2); //set DoH to custom adress
user_pref("network.trr.custom_uri", "https://adblock.doh.mullvad.net/dns-query"); //custom adress
user_pref("network.trr.uri", "https://adblock.doh.mullvad.net/dns-query"); //custom adress
user_pref("permissions.default.geo", 2); //deny location access
user_pref("geo.enabled", false); //fullly disable location acces
user_pref("browser.safebrowsing.downloads.remote.enabled", false); //disabled safebrowsing (data sent to google)
user_pref("browser.safebrowsing.phishing.enabled", false); //same as above
user_pref("extensions.pocket.enabled", false); //fully disable pocket
user_pref("identity.fxaccounts.enabled", false); //disable sync
user_pref("places.history.enabled", false); // disables history entirely
user_pref("javascript.options.ion", false); //javascript "hardening", might cause slowdowns/breakage
user_pref("javascript.options.asmjs", false); //same as above
user_pref("javascript.options.wasm", false); //WebAssembly support. Completly disables WASM, for the security gain and speed loss
user_pref("javascript.options.baselinejit", false); //Disabled Just In Time compilation - usually breaks sites with a lot of javascript but is a huge security gain
user_pref("dom.webaudio.enabled",false); //old api used for fingerprinting probably, hasn't broken anything FOR ME
user_pref("browser.safebrowsing.downloads.remote.enabled", false); //disabled safebrowsing (data sent to google)
user_pref("browser.safebrowsing.phishing.enabled", false); //same as above
user_pref("browser.safebrowsing.malware.enabled", false); // -||-
user_pref("dom.webnotifications.enabled", false); // fully disabled notifications
user_pref("browser.urlbar.suggest.topsites", false); //no top sites in the suggestions
user_pref("signon.management.page.breach-alerts.enabled",false); //no breach alerts
user_pref("signon.rememberSignons", false); //never ask to save passwords
user_pref("permissions.default.microphone", 2); // same but with microphone
user_pref("permissions.default.desktop-notification", 2); //same but with notifications
