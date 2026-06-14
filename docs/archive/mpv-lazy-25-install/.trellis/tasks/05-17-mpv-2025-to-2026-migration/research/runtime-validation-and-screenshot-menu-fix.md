# Runtime validation and screenshot menu fix

Date: 2026-06-09
Target: `F:\mpv_2026\mpv-lazy`
Source video: `I:\Torren_DownloadFile\剑来\第二季\06 4K.mkv`

## Scope

- Validate the latest `input_uosc.conf` menu/hotkey changes after the user reported duplicated screenshot root menu entries.
- Keep the 2026 active screenshot commands at the root screenshot menu.
- Move preserved 2025 screenshot reference commands into the `截屏 > 2025` submenu.
- Do not change active screenshot key bindings or screenshot behavior.

## Change made

File: `F:\mpv_2026\mpv-lazy\portable_config\input_uosc.conf`

- Active 2026 root menu kept:
  - `Ctrl+s screenshot scaled+subtitles #! 截屏 > 窗口（无OSD）`
  - `Ctrl+S screenshot window #! 截屏 > 窗口`
- Preserved 2025 reference menu moved:
  - `# screenshot scaled+subtitles #! 截屏 > 2025 > 窗口（无OSD）`
  - `# screenshot window #! 截屏 > 2025 > 窗口`
  - `# screenshot video #! 截屏 > 2025 > 原始`
- Existing 2025 `uosc/shot` reference remains under `截屏 > 2025 > uosc截图`.

## Static validation

- `input_uosc.conf` UTF-8 replacement characters: `0`.
- Root screenshot menu entries after fix: `2`.
- 2025 screenshot submenu entries after fix: `4`.
- Active `z` binding remains `script-binding recentmenu/open`.
- Active `I` binding remains `script-binding display-stats-toggle`.
- Active quoted `~~/` references in `input_uosc.conf`: no missing files.
- Inactive VF interpolation/upscaling menu items remain classified under `2025` or `2026`.

## Runtime validation

Temporary `runtime-validation*.log` files were created during validation and then deleted to avoid leaving expanded local `script-opts` values on disk.

### Real video, configured mpv

- Command shape: `mpv.com <video> --frames=120 --vo=null --audio=no --hwdec=no --load-stats-overlay=no --msg-level=all=warn`.
- Result: video opened and ran to about 5 seconds in the log.
- `input_uosc.conf` parsed successfully with `129` binds.
- `recentmenu.lua` loaded.
- `uosc/main.lua` loaded and reported `uosc-version 5.12.1`.
- No `Command "2025" not found` found.
- No `No key binding found for key 'a'` found.
- No Lua stack traceback found.

### A/B exit-code check

- `mpv.com` returned `-1073740791` with current config.
- `mpv.com` returned the same `-1073740791` with `--no-config`.
- Interpretation: this exit code is not evidence that the current migrated config caused a crash; it also appears under no-config with the same video/test style.

### Invalid mpv.exe check discarded

- A hidden `mpv.exe` test used `Start-Process -ArgumentList` with an unquoted path containing a space.
- That split `06 4K.mkv` into separate arguments and produced file-open errors.
- This run is not used as evidence for playback or config correctness.

## Remaining notes

- The user reported RIFE NV `4.25_lite` works in manual runtime testing; no action needed there.
- `auto_profiles` condition errors appear during synthetic/no-VO validation when properties are not available yet; they were not tied to the screenshot menu change.
- Manual UI confirmation is still useful for the screenshot menu because the automated check validates source menu paths, not visual rendering.
