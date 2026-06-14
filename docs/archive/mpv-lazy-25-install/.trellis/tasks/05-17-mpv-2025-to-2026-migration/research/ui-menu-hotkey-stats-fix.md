# UI Menu, Hotkey, and Stats Fix

Date: 2026-06-09

## Reported Issues

1. Menu hierarchy should distinguish 2026 official items and preserved 2025 items.
2. Selecting RIFE_NV 4.15_lite from the menu triggered input errors, including Command "2025" not found.
3. z did not open recent play history.
4. I stats overlay should match the 2025 font/color style.

## Root Causes

- Preserved comment lines used the prefix "2025 inactive preserved" while still containing uosc #! menu markers. uosc parsed these as menu commands, causing the fake command "2025".
- z was left on the 2026 subtitle-delay binding, while the 2025 working config used z for recentmenu/open.
- 2026 script-opts.conf only had a compact stats option subset, while the 2025 stats visual/page-control block was not fully migrated.

## Fixes

- Rewrote preserved 2025 menu entries into safe menu-only lines or pure non-menu comments.
- Kept MVT_STD as reference-only because k7sfunc 2026 does not restore MVT_STD.
- Reorganized active filter and shader menu labels with 2026 official vs 2025 hierarchy.
- Restored z -> script-binding recentmenu/open.
- Preserved subtitle preload as a menu-only command.
- Replaced compact stats options with the 2025 stats option block, including font, color, alpha, graph colors, page keys, and redraw timing.

## Verification

- No preserved line still combines "2025 inactive preserved" with #!.
- No question-mark-corrupted menu labels remain.
- z binds to recentmenu/open.
- Active input references missing count: 0.
- stats-font_size=20, stats-font_mono=monospace, stats-plot_bg_color=262626, stats-plot_color=FFFFFF, stats-alpha=11, stats-duration=4, stats-redraw_delay=1 are present.
