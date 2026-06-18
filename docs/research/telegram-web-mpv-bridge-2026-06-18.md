# Telegram Web MPV Bridge 接入记录（2026-06-18）

## 背景

目标是在不申请 Telegram `api_id/api_hash` 的情况下，把 Telegram Web K 中已登录账号可在线播放的视频转给本地 MPV 播放，并尽量保留快进能力。`yt-dlp` 只能处理部分公开 `t.me` embed 页面，不支持完整 `web.telegram.org/k/` 登录态视频；Telegram Web K 页面中的 `<video>` 常见为 `blob:`，外部进程不能直接读取。

## 调研结论

- 成熟的“浏览器打开 MPV”项目（如 `play-with-mpv`、`mpvnet`、`open-in-mpv`）主要是把普通 URL 交给 MPV，不处理 Telegram Web 的 `blob:` / Service Worker 流。
- Telegram 文件流代理（如 MediaFlow Proxy、TG-FileStreamBot、TelePlay、stremio-telegram-debrid）证明 HTTP Range 是正确抽象，但通常需要 Telegram API credentials、bot token 或 storage channel。
- WebVideo2NAS 这类项目提供了可借鉴模式：浏览器侧复用当前登录态 fetch session-bound stream，再把数据交给本地服务。

## 当前实现

实现位置：

- `tools/telegram-web-mpv-bridge/bridge.py`
- `tools/telegram-web-mpv-bridge/telegram-web-mpv-bridge.user.js`
- `tools/telegram-web-mpv-bridge/README.md`

端口：

- HTTP：`http://127.0.0.1:8999`
- WebSocket：`ws://127.0.0.1:9000/ws`
- MPV 播放 URL：`http://127.0.0.1:8999/stream/current`
- 自动拉起 MPV：`POST http://127.0.0.1:8999/play/current`

实现链路：

```text
MPV
  -> HTTP Range GET /stream/current
local bridge
  -> WebSocket fetchRange request
Telegram Web userscript
  -> fetch(webk.telegram.org/hls_stream..., Range)
  -> binary WebSocket response
local bridge
  -> 206 Partial Content to MPV
```

## 使用方式

1. 启动 bridge：

```powershell
cd F:\mpv_2026\mpv-lazy\tools\telegram-web-mpv-bridge
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip websockets
.\.venv\Scripts\python.exe .\bridge.py
```

2. 在 Tampermonkey / Violentmonkey 安装 `telegram-web-mpv-bridge.user.js`。
3. 完整刷新 Telegram Web K 页面，打开并播放目标视频。
4. 点击右下角 `MPV` 按钮，脚本会先注册当前视频，再请求本地 bridge 拉起 MPV。

状态检查：

```powershell
Invoke-RestMethod http://127.0.0.1:8999/status
```

正常时应看到 `connected: true`，且 `video.url` 为 `https://webk.telegram.org/hls_stream/...` 或类似 Telegram Web 内部 stream URL，而不是 `blob:`。

## 已验证现象

- 新版 userscript 能捕获 `https://webk.telegram.org/hls_stream/...`。
- 本地 bridge 可以连续接收 MPV 的 Range 请求，并通过 WebSocket 从浏览器返回二进制数据。
- `/play/current` 已能拉起 `F:\mpv_2026\mpv-lazy\mpv.exe` 播放本地 bridge URL。
- `8999` 端口原计划曾使用 `8899`，但 `8899` 被小米 PC 管理器 `MiPCAudio.exe` 占用，因此改为 `8999/9000`。

## 约束与风险

- Telegram Web 页面必须保持打开并处于登录状态。
- 当前视频源依赖 Telegram Web 的 Service Worker/页面上下文，刷新或切换视频后需要重新注册。
- 数据经 WebSocket 从浏览器回传本地服务，性能取决于浏览器和本地回环吞吐。
- 当前 MVP 支持单 Range；多 Range 请求按第一段处理。
- `bridge.py --debug` 会记录大量 binary frame，确认可用后应使用非 debug 模式。

## 不再使用的方案

MediaFlow Proxy 曾用于验证 MTProto HTTP Range 代理方向，但创建 Telegram API app 受 `my.telegram.org/apps` 风控影响较大。当前已停止并清理 `D:\mpv-lazy-25_install\tools\mediaflow-proxy`，2026 版本不依赖 MediaFlow。
