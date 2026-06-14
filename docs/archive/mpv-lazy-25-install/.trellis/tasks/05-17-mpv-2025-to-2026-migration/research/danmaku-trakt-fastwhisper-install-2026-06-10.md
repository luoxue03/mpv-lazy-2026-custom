# Danmaku, Trakt, and fastwhisper install notes

Date: 2026-06-10
Target: `F:\mpv_2026\mpv-lazy`

## Changes

- Installed `Tony15246/uosc_danmaku` into `portable_config/scripts/uosc_danmaku`.
- Installed `dyphire/trakt-scrobble` into `portable_config/scripts/trakt-scrobble`.
- Added `portable_config/script-opts/uosc_danmaku.conf`.
- Added `portable_config/script-opts/trakt_scrobble.conf`.
- Added `sub_fastwhisper-compute_type=float16` to `portable_config/script-opts.conf`.
- Added uosc menu entries for danmaku and Trakt in `portable_config/input_uosc.conf`.

## Key decisions

- `uosc_danmaku` is installed for testing but defaults remain conservative:
  - `auto_load=no`
  - `autoload_for_url=yes`
  - `autoload_local_danmaku=no`
  - `save_danmaku=no`
  - `vf_fps` is not enabled
- `uosc_danmaku` already dynamically binds:
  - `Ctrl+d` for search
  - `j` for toggle
- To avoid duplicate key bindings, `input_uosc.conf` only keeps danmaku menu entries as commented `#!` menu commands.
- `trakt-scrobble` hard-coded `x` as forced auth/search confirmation key, which conflicts with subtitle delay. Patched local `main.lua` to use `Ctrl+Alt+r` and updated prompt text accordingly.
- Trakt install does not perform authorization. The user still needs to authorize inside mpv when prompted.

## Validation

- Short local video validation loaded:
  - `sub_fastwhisper`
  - `uosc_danmaku` version `2.2.0`
  - `trakt_scrobble`
- `sub_fastwhisper-compute_type=float16` was read by mpv.
- `trakt_scrobble` loaded `script-opts/trakt_scrobble.conf`.
- `uosc_danmaku` loaded `script-opts/uosc_danmaku.conf`.
- `curl.exe` is available on the system.
- No Lua stack traceback was observed in the filtered validation logs.
- Temporary logs and clone directories were removed.

## URL test result

Test URL: `https://www.bilibili.com/video/BV1kx411o7Yo`

Result:

- `uosc_danmaku` loaded and initialized.
- mpv did not reach a successful `file-loaded` state because `yt-dlp` failed on the raw Bilibili URL with HTTP 412.
- Therefore this test does not prove failure of `uosc_danmaku`; it only shows that naked URL playback failed before the danmaku loader could run.

Implication:

- `uosc_danmaku` should work with `url-scheme-handler` if mpv's `path` remains a Bilibili URL or a supported bilivideo URL and the media actually reaches `file-loaded`.
- The real browser plugin -> url-scheme-handler -> mpv path should be tested manually with the user's actual Bilibili workflow.

