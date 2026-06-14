# script-opts contextmenu_plus Audit

Date: 2026-06-09

## Finding

script-opts.conf had active contextmenu_plus options, but the target scripts directory does not contain contextmenu_plus.lua.
2026 uses the uosc built-in menu path instead, so active contextmenu_plus options are stale.

## Action

- Commented active contextmenu_plus script-opts lines.
- Preserved the original values as inactive comments.
- Did not change active options for user plugins that have corresponding scripts: auto_load_fonts, mpv_torrserver, quality-menu, recentmenu, sponsorblock_minimal, sub_fastwhisper.

## Verification

- contextmenu_plus active options: 0.
- sub_fastwhisper-api_key remains blank.
- The question marks in quality-menu format strings are valid yt-dlp syntax, not mojibake.
