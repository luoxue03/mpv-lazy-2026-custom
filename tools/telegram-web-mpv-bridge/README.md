# Telegram Web MPV Bridge

Local proof-of-concept bridge for streaming the currently open Telegram Web video in MPV without a Telegram API ID/hash.

## What It Does

- A userscript runs inside `web.telegram.org` where you are already logged in.
- A local Python bridge exposes `http://127.0.0.1:8999/stream/current` for MPV.
- MPV sends HTTP Range requests to the bridge.
- The bridge asks the userscript to fetch the same byte range from Telegram Web's current video source.
- The userscript returns binary bytes over WebSocket, and the bridge replies to MPV with `206 Partial Content`.

## Setup

```powershell
cd F:\mpv_2026\mpv-lazy\tools\telegram-web-mpv-bridge
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip websockets
.\.venv\Scripts\python.exe .\bridge.py
```

In mpv-lazy 2026, the native menu also provides `工具 > Telegram Web MPV Bridge 开关` and `工具 > Telegram Web MPV Bridge 状态`.

Install `telegram-web-mpv-bridge.user.js` in Tampermonkey/Violentmonkey, then fully refresh Telegram Web K and play a video. The script runs at `document-start` so it can capture Telegram Web's internal `/stream/...` URLs before they become `blob:` URLs.

## Manual Test

1. Start the bridge.
2. Open `https://web.telegram.org/k/` and play the target video.
3. Confirm the floating `MPV` button appears.
4. Click `MPV` once to register the current video and ask the local bridge to launch MPV. The button should change briefly to `Starting...` and then `MPV started`; it should not open a new browser tab.
5. If manual launch is needed, run:

```powershell
F:\mpv_2026\mpv-lazy\mpv.exe "http://127.0.0.1:8999/stream/current"
```

Status endpoint:

```powershell
Invoke-RestMethod http://127.0.0.1:8999/status
```

Manual launch endpoint:

```powershell
Invoke-RestMethod -Method Post http://127.0.0.1:8999/play/current
```

## Constraints

- Telegram Web must stay open and logged in.
- The current video source must remain valid in that browser page.
- This is a bridge, not a downloader; it does not persist full files.
- Large binary ranges cross WebSocket, so performance depends on browser and local loopback throughput.
- v1 supports single-range requests. Multi-range requests are treated as the first range.
