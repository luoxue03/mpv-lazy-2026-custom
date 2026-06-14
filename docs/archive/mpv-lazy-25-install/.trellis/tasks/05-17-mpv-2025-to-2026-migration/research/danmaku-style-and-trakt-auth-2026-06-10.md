# Danmaku style sync and Trakt auth state

Date: 2026-06-10
Target: `F:\mpv_2026\mpv-lazy`

## User report

- Trakt web authorization seemed successful, but the second attempt showed:
  - `The code A24FC8FF has expired. Please get a new code on your device and try again`
- Trakt sync appeared to have no effect; manual selection produced:
  - `[trakt_scrobble] Starting scrobbling to Trakt.tv`
  - `[trakt_scrobble] Check-in failed`
- User requested `uosc_danmaku` style to match `bilibiliAssert`.
- User asked whether `uosc_danmaku` adds a VS/VF and whether it conflicts with other VS/VF filters.

## Findings

### Trakt

- `portable_config/trakt_config.json` existed but only contained `device_code`.
- It did not contain:
  - `access_token`
  - `refresh_token`
  - `user_slug`
- Therefore Trakt was not actually authorized locally, even if the web page showed a success-like flow.
- The expired code message means the old device authorization code timed out before mpv exchanged it for tokens.

Action:

- Cleared the stale `device_code` only, leaving `trakt_config.json` as `{}`.
- This prevents the stale authorization code from being reused or misread.

Correct flow:

1. Open a normal video.
2. Use menu `工具 > Trakt > 授权登录`.
3. Open the shown Trakt activation URL.
4. Complete browser authorization.
5. Return to mpv before the code expires.
6. Press `Ctrl+Alt+r` in mpv.
7. Verify `trakt_config.json` then contains `access_token` and `refresh_token`.

### uosc_danmaku style sync

Read source values from `portable_config/scripts/bilibiliAssert/main.lua`:

- `fontname = SimHei`
- `fontsize = 16`
- `opacity = 0.55`
- `duration_marquee = 10`
- `duration_still = 5`
- `percent = 0.95`
- style effectively uses bold and outline size around 1

Applied to `portable_config/script-opts/uosc_danmaku.conf`:

- `fontname=SimHei`
- `fontsize=16`
- `opacity=0.55`
- `scrolltime=10`
- `fixtime=5`
- `displayarea=0.95`
- `bold=yes`
- `outline=1`
- `shadow=0`
- `vf_fps=no`

### VF / VS conflict

- `uosc_danmaku` does not use VapourSynth.
- It can optionally append an mpv VF filter:
  - `@danmaku:fps=fps=<value>`
- This only happens when `vf_fps=yes`.
- Current config sets `vf_fps=no`, so it will not add that VF filter.
- If enabled later, it appends a labeled `fps` filter to the VF chain and removes `@danmaku` on hide/unload.
- This can affect filter order and performance, especially with VapourSynth interpolation/upscale chains, so keep it disabled by default.

## Validation

- Local video short validation loaded:
  - `bilibiliAssert`
  - `uosc_danmaku`
  - `trakt_scrobble`
- `uosc_danmaku.conf` was read.
- `trakt_config.json` was read from `portable_config`.
- No Lua stack traceback was seen in the filtered validation output.
- Temporary validation log was deleted.

