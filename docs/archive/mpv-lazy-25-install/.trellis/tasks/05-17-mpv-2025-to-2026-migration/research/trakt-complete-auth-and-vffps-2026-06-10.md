# Trakt complete-auth binding and danmaku vf_fps

Date: 2026-06-10
Target: `F:\mpv_2026\mpv-lazy`

## User report

- Browser-side Trakt authorization showed success.
- Pressing `Ctrl+Alt+r` in mpv had no visible effect.
- User requested enabling `uosc_danmaku` `vf_fps`.

## Findings

- `trakt_config.json` still contained only `device_code`.
- It had no `access_token` or `refresh_token`.
- Therefore mpv had not completed the second step of device authorization.
- `Ctrl+Alt+r` was only registered as a temporary forced key inside `trakt-scrobble` during parts of the auth flow.
- To avoid relying on temporary key state, a persistent input binding and explicit script message are better.

## Changes

- `trakt-scrobble/main.lua`
  - Added script message:
    - `complete-auth`
  - It calls the same internal `auth()` function and reports success/failure via OSD and log.

- `input_uosc.conf`
  - Added active binding:
    - `Ctrl+Alt+r script-message-to trakt_scrobble complete-auth`
  - Menu path:
    - `工具 > Trakt > 完成授权`

- `script-opts/uosc_danmaku.conf`
  - Changed:
    - `vf_fps=no`
    - to `vf_fps=yes`

## Validation

- Local video short validation loaded:
  - `trakt_scrobble`
  - `uosc_danmaku`
- `uosc_danmaku.conf` was read.
- No Lua stack traceback was observed.
- Touched files have no UTF-8 replacement characters or `????` runs.
- Temporary validation log was deleted.

## Usage

1. Use `工具 > Trakt > 授权登录` to request a new code.
2. Finish authorization in browser.
3. Return to mpv and use `Ctrl+Alt+r` or `工具 > Trakt > 完成授权`.
4. Confirm `trakt_config.json` contains `access_token` and `refresh_token`.

