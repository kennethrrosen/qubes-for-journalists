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



//OCT2022 UPDATE
browser.newtabpage.activity-stream.feeds.telemetry to false
browser.ping-centre.telemetry to false
browser.tabs.crashReporting.sendReport to false
devtools.onboarding.telemetry.logged to false
toolkit.telemetry.enabled to false
toolkit.telemetry.server, and leave it empty
toolkit.telemetry.unified to false
browser.newtabpage.activity-stream.feeds.discoverystreamfeed to false
browser.newtabpage.activity-stream.feeds.section.topstories to false
browser.newtabpage.activity-stream.section.highlights.includePocket to false
browser.newtabpage.activity-stream.showSponsored to false
extensions.pocket.enabled to false
network.dns.disablePrefetch to true
network.prefetch-next to false
pdfjs.enableScripting to false
security.ssl3.rsa_des_ede3_sha to false
security.ssl.require_safe_negotiation to true
identity.fxaccounts.enabled to false
geo.enabled to false
dom.webnotifications.enabled to false
media.peerconnection.enabled to false
media.navigator.enabled to false
webgl.disabled to true
privacy.resistFingerprinting to true
network.http.sendRefererHeader to 0
privacy.firstparty.isolate to true
network.cookie.lifetimePolicy to 2

//Alt: https://codeberg.org/12bytes.org/firefox-user.js-supplement/src/branch/master/user-overrides.js

/* put user.js in /home/user/.mozilla/firefox/xxxxxxx.default/
 *
 * http://kb.mozillazine.org/User.js_file
 * 
 * Important: Once an entry for a preference setting exists in the user.js file,
 * any change you make to that setting in the options and preference dialogs
 * or via about:config will be lost when you restart your Mozilla application
 * because the user.js entry will override it. 
 *
 * About:config entries
 * http://kb.mozillazine.org/About:config_entries
 */


user_pref("accessibility.blockautorefresh",true); // Instead of refreshing a page automatically when <meta http-equiv="refresh"> is present (or Refresh HTTP headers),
// display a browser message indicating the refresh and allow the user to follow it manually. 

user_pref("browser.fixup.alternate.enabled",false); // To avoid the fix of http://foo to http://(prefix)foo(suffix)

// kick pocket
user_pref("browser.pocket.api",""); // https://support.mozilla.org/en-US/kb/save-web-pages-later-pocket-firefox
user_pref("browser.pocket.enabled",false); // https://support.mozilla.org/en-US/kb/save-web-pages-later-pocket-firefox
user_pref("browser.pocket.enabledLocales",""); // https://support.mozilla.org/en-US/kb/save-web-pages-later-pocket-firefox
user_pref("browser.pocket.oAuthConsumerKey",""); // https://support.mozilla.org/en-US/kb/save-web-pages-later-pocket-firefox
user_pref("browser.pocket.site",""); // https://support.mozilla.org/en-US/kb/save-web-pages-later-pocket-firefox
user_pref("browser.pocket.useLocaleList",false); // https://support.mozilla.org/en-US/kb/save-web-pages-later-pocket-firefox

// I remove all URL because I don't want to
// connecte my PC to Google
user_pref("browser.safebrowsing.appRepURL", ""); // http://korben.info/comment-empecher-google-savoir-ce-telechargez-firefox.html
user_pref("browser.safebrowsing.downloads.enabled", false); // kick google
user_pref("browser.safebrowsing.downloads.remote.enabled", false); // kick google
user_pref("browser.safebrowsing.enabled", false); // kick google
user_pref("browser.safebrowsing.gethashURL", ""); // kick google
user_pref("browser.safebrowsing.malware.enabled", false); // kick google
user_pref("browser.safebrowsing.malware.reportURL", ""); // kick google
user_pref("browser.safebrowsing.reportErrorURL", ""); // kick google
user_pref("browser.safebrowsing.reportGenericURL", ""); // kick google
user_pref("browser.safebrowsing.reportMalwareErrorURL", ""); // kick google
user_pref("browser.safebrowsing.reportMalwareURL", ""); // kick google
user_pref("browser.safebrowsing.reportPhishURL", ""); // kick google
user_pref("browser.safebrowsing.reportURL", ""); // kick google
user_pref("browser.safebrowsing.updateURL", ""); // kick google
user_pref("browser.trackingprotection.gethashURL", ""); // kick mozilla
user_pref("browser.trackingprotection.updateURL", ""); // kick mozilla

user_pref("browser.search.geoip.url", ""); // kick mozilla
user_pref("geo.enabled",false); // Is location aware browsing enabled. Default is true. See http://www.mozilla.com/en-US/firefox/geolocation/
user_pref("geo.wifi.uri", ""); // Which geolocation service provider to use. Default is https://www.google.com/loc/json

user_pref("datareporting.healthreport.service.enabled",false);
user_pref("datareporting.healthreport.uploadEnabled",false);
user_pref("dom.event.clipboardevents.enable",false);

user_pref("media.autoplay.enabled",false); // Stop autoplay of videos
user_pref("media.directshow.enabled",false); // https://support.mozilla.org/fr/questions/999164
user_pref("media.eme.enabled",false); // https://wiki.mozilla.org/Media/EME
user_pref("media.gmp-eme-adobe.enabled",false); // https://wiki.mozilla.org/Media/EME
user_pref("media.peerconnection.enabled",false); // http://thehackernews.com/2015/02/webrtc-leaks-vpn-ip-address.html https://github.com/diafygi/webrtc-ips
user_pref("media.windows-media-foundation.enabled",false); // https://support.mozilla.org/fr/questions/999164
user_pref("network.dns.disablePrefetch",true);
user_pref("network.http.sendRefererHeader",0); // http://lehollandaisvolant.net/?d=2012/01/17/15/30/15-proteger-votre-vie-privee-sur-le-web-en-masquant-votre-provenance
user_pref("network.http.speculative-parallel-limit",0); // http://news.slashdot.org/story/15/08/14/2321202/how-to-quash-firefoxs-silent-requests
user_pref("network.proxy.socks_remote_dns",true); // http://www.libre-parcours.net/2012/09/eviter-les-fuites-dns-dans-firefox-quand-on-utilise-un-proxy-socks/
user_pref("plugins.click_to_play",true); // http://www.howtogeek.com/123986/how-to-enable-click-to-play-plugins-in-firefox/?PageSpeed=noscript
user_pref("security.tls.version.max",4); // 4 == TLS 1.3 https://www.ghacks.net/2017/06/15/how-to-enable-tls-1-3-support-in-firefox-and-chrome/
user_pref("security.tls.version.min",2); // but some fucking web site use tls < 2 T_T
user_pref("services.sync.prefs.sync.browser.safebrowsing.enabled",false);
user_pref("services.sync.prefs.sync.browser.safebrowsing.malware.enabled",false);
user_pref("toolkit.telemetry.enabled",false); // https://www.mozilla.org/en-US/privacy/firefox/#telemetry


/* My personnal conf */


user_pref("browser.cache.disk.enable", false); // Don't store cache on the hard drive. 
user_pref("browser.download.panel.shown", true); // ask me where to save files
user_pref("browser.newtab.url","about:blank");
user_pref("browser.search.defaultenginename", "DuckDuckGo");
user_pref("browser.search.openintab",true);
user_pref("browser.search.showOneOffButtons",false); // old search bar
user_pref("browser.search.suggest.enabled",false);
user_pref("browser.startup.page", 0);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.tabs.warnOnOpen", false);
user_pref("browser.urlbar.formatting.enabled",false); // Don't fade non domain portions of url in location bar. 
user_pref("browser.urlbar.trimURLs",false); // I want to see http:// and https://

user_pref("general.warnOnAboutConfig",false);

// user-agent
user_pref("general.appname.override", "");
user_pref("general.appversion.override", "");
user_pref("general.oscpu.override", "");
user_pref("general.platform.override", "");
user_pref("general.useragent.override", "Mozilla/5.0 () Gecko");
user_pref("general.useragent.vendor", "");

// Phishing protection
user_pref("network.IDN_show_punycode", true); //  https://thehackernews.com/2017/04/unicode-Punycode-phishing-attack.html
