/******
*    name: journoQUBES thunderbird user-overrides.js
*    date: 09 October 2022
*    version: 102r2 (based on Thunderbird v102.*)
*     url: https://github.com/kennethrrosen/journoQUBES/
*    NOTES:
*    These settings work for me and my threat level. They may break some websites. Refer back to arkenfox for greater assessments and sourcing on practicality of most.
*    Credits below
******/


/**
 *   _ | _  )  _ ) \ \  / __ __| __|   __|      _ \  _ \   __|
 *     |   /   _ \  \  /     |   _|  \__ \     (   |   /  (_ |
 *    _| ___| ___/   _|     _|  ___| ____/ _) \___/ _|_\ \___|
 *
 * U S E R-O V E R R I D E S.J S   F O R   T H U N D E R B I R D
*/

/**
 * name     : 12bytes user-overrides.js for HorlogeSkynet's Thunderbird user.js
 * version  : 102r2 (based on Thunderbird v102.*)
 * author   : 12bytes.org
 * credit   : the 'ghacks' crew (https://github.com/ghacksuserjs/ghacks-user.js)
 * credit   : HorlogeSkynet (https://github.com/HorlogeSkynet/thunderbird-user.js)
 * website  : The Thunderbird Privacy Guide for Dummies!
 *          : https://12bytes.org/articles/tech/the-thunderbird-privacy-guide-for-dummies
 * code     : https://codeberg.org/12bytes.org/thunderbird-user.js-supplement/
 *
 * NOTE TO SELF: search for *TODO*
 */

/**
 * !!! IMPORTANT !!!        HOW TO WORK WITH THIS FILE         !!! IMPORTANT !!!
 * =============================================================================
 *
 * this file is an optional supplement that may be apended to the
 * 'HorlogeSkynet' user.js and used in conjunction with the 'The Thunderbird
 * Privacy Guide for Dummies!'
 * (https://12bytes.org/articles/tech/the-thunderbird-privacy-guide-for-dummies)
 *
 * the versioning scheme for this file is 'NrN' where the first 'N' is a
 * number corresponding to the major version of Thunderbird for which this file
 * is intended, the 'r' stands for 'revision' and the last 'N' is the revision
 * number, so '12r3' would indicate this file is for Thunderbird 12.x and it is
 * the 3rd revision of the file
 *
 * preferences may be tagged with one or more of [SET], [SAFE=*] and [PRIV=*]
 * where 'SET' means the value must be checked, 'SAFE' is a safe value less
 * likely to break mail functionality but may compromise privacy, and 'PRIV' is
 * a value which is more protective of privacy but may break mail functionality
 * more often - suggested values are marked with an asterik character ( * )
 * inside the tag
 *
 * THIS FILE CONTAINS MY PERSONAL SETTINGS, SOME OF WHICH MAY NOT WORK FOR YOU
 * and therefore it is important to go through it and make the required changes
 * - AT A MINIMUM YOU SHOULD EVALUATE ALL PREFERENCES TAGGED WITH [SET]
 *
 * TO MAKE UPDATING THIS FILE EASIER, DO NOT EDIT ANY EXISTING PREFERENCES -
 * instead, copy the entire line you want to change in this file or the
 * 'HorlogeSkynet' user.js file to the USER CUSTOMIZATION section and change the
 * preference value there, then when you update this file you can replace
 * everything except your custom preferences - to make checking for updates
 * easy, subscribe to the 'Thunderbird' category at:
 * https://12bytes.org/subscribe
 *
 * CUSTOM PREFERENCES THAT YOU ADD AND LATER REMOVE WILL REMAIN ACTIVE IN
 * prefs.js - to reset/remove a custom preference, the suggested method is to
 * comment it out by preceeding it with 2 forward slaches ( // ) and then run
 * the prefsCleaner.sh (Linux) or prefsCleaner.bat (Windows) script - make sure
 * Thunderbird is closed when you run the prefsCleaner script - see:
 * https://github.com/ghacksuserjs/ghacks-user.js/wiki/3.1-Resetting-Inactive-Prefs-[Scripts]
 *
 * WHEN YOU ARE FINISHED EDITING, append this file to the 'HorlogeSkynet'
 * user.js by copying the entire contents and pasting it on a blank line at the
 * very end of the 'HorlogeSkynet' user.js then run the prefsCleaner.sh script
 *
 * YOU MUST PERFORM THE FOLLOWING INTEGRITY CHECKS AFTER UPDATING OR EDITING
 * THIS FILE (you should disable your network connection prior):
 *
 * INTEGRITY CHECK 1: start Thunderbird and open its preferences dialog, then
 * click the 'Advanced' button followed by the 'Config Editor' button - next
 * find the "_user.js.parrot" troubleshooting preference and check that its
 * value is "SUCCESS! USER SETTINGS LOADED" - if it is not then there is a
 * syntax error in which case you need to search this file for the value of the
 * "_user.js.parrot" troubleshooting preference - the error will be between that
 * point and the very next "_user.js.parrot" troubleshooting preference - if you
 * know how to use regular expressions the following may help locate the syntax
 * error - this expression should highlight all lines except those containing
 * the error:
 *
 * ^user_pref\("[a-zA-Z0-9._-]*", (?:true|false|""|\d*|"[!a-zA-Z0-9]*[ \w:/.%-@]*[a-zA-Z0-9]*"|"#[A-Z0-9]+")\);
 *
 * INTEGRITY CHECK 2: open the Error Console from the 'Tools' > 'Developer
 * Tools' > 'Error Console' menu item (Ctrl+Shift+J might work) and check for
 * any error messages related to preferences - to make these errors easy to
 * find, filter the output using "user.js" or "prefs" - this is a sample error:
 *
 * /home/[user]/.thunderbird/[profile name]/user.js:[line no.]: prefs parse error: [error description]
 *
 * [line no.] will be a line number corrasponding to the line in user.js where
 * the error lies - if you have not edited user.js, then search this file for
 * the same line and correct the error here, then copy this entire file to the
 * end of the user.js being careful to replace the old copy
 */

/**
 * === HorlogeSkynet ACTIVE DIFFS ===
 *
 * these prefs are duplicates of *active* 'HorlogeSkynet' user.js prefs
 *
 * if the value of the "_user.js.parrot" pref in about:config is "syntax error @
 * HorlogeSkynet DIFFS" then there is a syntax error between this
 * point and the very next "_user.js.parrot" pref
 */

user_pref("_user.js.parrot", "DEAD BIRDY @ HorlogeSkynet ACTIVE DIFFS"); // do not edit
/**/
user_pref("calendar.timezone.local", "America/New_York");               // [SET] set to "" to allow TB to aquire local time zone, or "UTC", or your local timezone
user_pref("devtools.chrome.enabled", true);                             // [*SAFE=false] whether to enable developer tools
user_pref("devtools.debugger.remote-enabled", true);                    // [*SAFE=false] whether to enable remote debugging (needed for developer tools)
user_pref("mail.collect_email_address_outgoing", true);                 // [SET] whether to save outgoing mail address in the "Collected Address" address book
user_pref("mail.phishing.detection.enabled", false);                    // [SET] whether to enable phishing detection
user_pref("mailnews.headers.showUserAgent", true);                      // whether to display the user-agent string of the senders email client
user_pref("privacy.resistFingerprinting", false);                       // [*PRIV=true] whether to enable anti-fingerprinting - 'true' *may* break dates/times in mails and calandar(?) and color options for mail preview pane, options pages, etc. - if JS is disabled, most fingerprinting techniques should be thwarted even if this set to 'false'
user_pref("privacy.userContext.enabled", false);                        // [SET] whether to enable containers
user_pref("privacy.userContext.ui.enabled", false);                     // [SET] whether to enable the UI for containers
user_pref("security.external_protocol_requires_permission", false);     // [*SAFE=true] whether to prompt when opening a link in an external program

/**
 * -----------------------
 * USER CUSTOM PREFERENCES
 * -----------------------
 */

/**
 * !!! IMPORTANT !!!   !!! IMPORTANT !!!   !!! IMPORTANT !!!   !!! IMPORTANT !!!
 * =============================================================================
 *
 * TO RESET/REMOVE/DELETE A PREFERENCE:
 * ------------------------------------
 * 1. exit Thunderbird
 * 2. comment out the preference(s) by prefixing it with 2 forward slashes (//)
 *    and save your changes (do not move it to the DEPRECIATED/REMOVED PREFS
 *    section below)
 * 3. copy this entire file to the very end of the 'HorlogeSkynet' user.js
 * 4. run the 'ghacks' prefsCleaner script
 *
 * TO CHANGE THE VALUE OF A PREFERENCE:
 * ------------------------------------
 * 1. exit Thunderbird
 * 2. copy the entire preference line to the CUSTOM CODE section below
 * 3. change the preference value and save your changes
 * 4. copy this entire file to the very end of the 'HorlogeSkynet' user.js
 *
 * TO FIND THE DEFAULT VALUE OF A PREFERENCE:
 * ------------------------------------------
 * 1. find the preference in Thunderbird > Preferences > Advanced > Config
 * Editor
 * 2. right click the preference and select 'Reset'
 * note that not all preferences are listed in the Config Editor
 */

/**
 * if the value of the "_user.js.parrot" pref in about:config is
 * "syntax error @ BEGIN USER CUSTOMIZATIONS" then there is a syntax
 * error between this point and the very next "_user.js.parrot" pref
 */
user_pref("_user.js.parrot", "syntax error @ USER CUSTOM PREFERENCES"); // do not edit
/**/
/**
 * YOUR CUSTOM CODE GOES BELOW THIS LINE
 * -------------------------------------
 *
 * note that these are my personal preferences - to reset any of these
 * preferences, comment them out and move them to the DEPRECIATED/REMOVED PREFS
 * section, save the file, then run the prefsCleaner script
 */

/**
 * misc. prefs
 */
user_pref("accessibility.tabfocus", 3);                             // which elements can be focused using the Tab key - 1=text fields, 2=all form fields except text, 4=links ony (values can be added together)
user_pref("app.update.auto", false);                                // [SET] [*SAFE=true] whether to enable automatic updates (non-Windows)
user_pref("browser.display.background_color", "#2C2C31");           // [SET] preview pane background color
user_pref("browser.display.foreground_color", "#D4D4DB");           // [SET] preview pane text color
user_pref("browser.safebrowsing.blockedURIs.enabled", false);       // [SET] [*SAFE=true] it is not suggested to disable these safebrowsing features
user_pref("browser.safebrowsing.downloads.enabled", false);         // [SET] [*SAFE=true] "
user_pref("browser.safebrowsing.malware.enabled", false);           // [SET] [*SAFE=true] "
user_pref("browser.safebrowsing.phishing.enabled", false);          // [SET] [*SAFE=true] "
user_pref("browser.search.update", false);                          // whether to disable search engine plugin updates
user_pref("browser.triple_click_selects_paragraph", false);         // whether to select entire paragraph when text is triple clicked
user_pref("clipboard.plainTextOnly", true);                         // whether to retain formatting when copying(?)/pasting text
user_pref("dom.push.enabled", false);                               // whether to enable push notifications
user_pref("dom.webnotifications.enabled", false)                    // whether to enable web notifications
user_pref("extensions.getAddons.cache.enabled", false);             // whether to enable extension metadata (extension detail tab)
user_pref("extensions.update.autoUpdateDefault", false);            // [SET] whether to automatically install extension updates (after checking for updates)
user_pref("extensions.webextensions.restrictedDomains", "");        // list of domains for webextensions are disabled
user_pref("general.useragent.compatMode.firefox", true);            // [*PRIV=true] whether to limit sending extra user-agent data
user_pref("image.animation_mode", "once");                          // how to display animated GIF images - none=do not animate, once=play animation once, normal=play the animation normally
user_pref("intl.date_time.pattern_override.time_medium", "hh:mm:ss a"); // force 12 hr. time format for mail and calendar (may only be necessary on Linux)
user_pref("intl.date_time.pattern_override.time_short", "hh:mm a"); // force 12 hr. time format for mail and calendar (may only be necessary on Linux)
user_pref("mail.mdn.report.enabled", false);                        // whether to enable sending return receipts
user_pref("mailnews.database.global.indexer.enabled", false);       // whether to enable the search indexer
user_pref("msgcompose.background_color", "#2C2C31");                // [SET] compose mail background color
user_pref("msgcompose.default_colors", false);                      // [SET] whether to use default colors when composing mail
user_pref("msgcompose.text_color", "#D4D4DB");                      // [SET] compose mail text color
user_pref("messenger.startup.action", 0);                           // whether to enable chat on startup
user_pref("offline.autoDetect", false);                             // whether to auto-detect if Thunderbird is on/off line
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // whether to load user styles from chrome folder
user_pref("view_source.syntax_highlight", true);                    // whether to highlight the source code of a document when viewing it
user_pref("view_source.wrap_long_lines", true);                     // whether to wrap long lines when viewing document source code

/**
 * [SET] the following preferences adjusts the smooth scrolling feature of
 * Thunderbird when using a mouse wheel or keyboard keys to scroll
 */
user_pref("general.smoothscroll", true);                            // whether to enable smooth scrolling
user_pref("general.smoothScroll.lines.durationMaxMS", 400);         // smooth the start/end of line scrolling operations in ms (up/down arrow/page keys)
user_pref("general.smoothScroll.lines.durationMinMS", 200);         // smooth the start/end of line scrolling operations in ms (up/down arrow/page keys)
user_pref("general.smoothScroll.mouseWheel.durationMaxMS", 600);    // smooth the start/end of scrolling operations in ms
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 300);    // smooth the start/end of scrolling operations in ms
user_pref("general.smoothScroll.other.durationMaxMS", 400);         // smooth the start/end of other scrolling operations in ms
user_pref("general.smoothScroll.other.durationMinMS", 200);         // smooth the start/end of other scrolling operations in ms
user_pref("general.smoothScroll.pages.durationMaxMS", 400);         // smooth the start/end of page scrolling operations in ms (PgUp/PgDn keys)
user_pref("general.smoothScroll.pages.durationMinMS", 200);         // smooth the start/end of page scrolling operations in ms (PgUp/PgDn keys)
user_pref("mousewheel.acceleration.factor", 10);                    // sets acceleration factor if mouse wheel.acceleration.start > -1
user_pref("mousewheel.acceleration.start", 0);                      // when to apply mouse wheel.acceleration.factor (after how many scroll clicks of mouse wheel) - value must be greater than -1
user_pref("mousewheel.default.delta_multiplier_x", 85);             // sets the x-axis step size
user_pref("mousewheel.default.delta_multiplier_y", 85);             // sets the y-axis step size
user_pref("mousewheel.default.delta_multiplier_z", 85);             // sets the z-axis step size
user_pref("mousewheel.min_line_scroll_amount", 10);                 // if the CSS line height is smaller than this value in pixels, each scroll click will scroll this amount

/*
 * -------------------------------------
 * YOUR CUSTOM CODE GOES ABOVE THIS LINE
 */

/**
 * DEPRECIATED - DO NOT EDIT - these prefs are needed when running the prefsCleaner script
 */

/**
 * !!! IMPORTANT !!!   !!! IMPORTANT !!!   !!! IMPORTANT !!!   !!! IMPORTANT !!!
 * =============================================================================
 *
 * below is the "_user.js.parrot" preference you must check in Thunderbird's
 * Config Editor - if the value is "SUCCESS! USER SETTINGS LOADED" then there
 * was no syntax error above
 */
user_pref("_user.js.parrot", "SUCCESS! USER SETTINGS LOADED"); // do not edit
