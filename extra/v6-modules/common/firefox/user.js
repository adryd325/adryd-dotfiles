/* SOME PREFS TAKEN FROM https://gitlab.com/librewolf-community/settings/-/blob/master/librewolf.cfg */

// Color-Management
// user_pref("gfx.color_management.mode", 1);
// user_pref("gfx.color_management.enablev4", true);
// user_pref("gfx.color_management.rendering_intent", -1);
// user_pref("gfx.color_management.display_profile", "__REPLACE_ME__ICC_PROFILE_PATH__");

user_pref("extensions.pocket.enabled", false);

// Theming
// user_pref("browser.devedition.theme.enabled", true);
// user_pref("devtools.theme", "dark");
// user_pref("extensions.activeThemeID", "default-theme@mozilla.org");
// user_pref("browser.devedition.theme.showCustomizeButton", true);
// user_pref("browser.tabs.drawInTitlebar", true);
// user_pref("browser.uidensity", 0);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("gnomeTheme.systemIcons", false);
user_pref("gnomeTheme.hideSingleTab", true);

// Enable SVG context-propertes (GNOME Theme)
user_pref("svg.context-properties.content.enabled", true);

// Don't try fix typo'd URLs
user_pref("browser.fixup.alternate.enabled", false);

// no ff acc
// user_pref("identity.fxaccounts.enabled", false);

// Disable SSL Stapling
// user_pref("security.OCSP.enabled", 0);

// Fix emoji font
user_pref("font.name-list.emoji", "Noto Color Emoji");

// Use VAAPI for video decode (Once ready)
user_pref("media.ffmpeg.vaapi.enabled", true);

// Disable private window dark theme
// user_pref("browser.theme.dark-private-windows", false);

// Enable rounded bottom window corners
// user_pref("widget.gtk.rounded-bottom-corners.enabled", true);
