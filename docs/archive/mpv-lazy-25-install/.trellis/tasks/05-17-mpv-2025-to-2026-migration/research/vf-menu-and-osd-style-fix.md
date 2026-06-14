# VF Menu and OSD Style Fix

Date: 2026-06-09

## User Report

1. Non-2026 menu items under interpolation/upscaling should be grouped under 2025.
2. The I stats overlay still looked purple.

## Changes

- input_uosc.conf: every inactive/commented VF menu item under interpolation/upscaling/super-resolution-interpolation that is not marked 2026 is now under a 2025 hierarchy.
- input_uosc.conf: active VF menu items remain under 2026 official hierarchy.
- mpv.conf: OSD base color/style restored to 2025 values so stats inherits white text with black outline instead of the 2026 purple OSD color.

## Verification

- Non-2026 inactive VF interpolation/upscaling menu violations: 0.
- Active VF menu entries remain 2026 official.
- Active referenced files missing: 0.
- OSD values now set to: osd-color #FFFFFF, osd-outline-color #FF000000, osd-outline-size 1.65, osd-font-size 40.
