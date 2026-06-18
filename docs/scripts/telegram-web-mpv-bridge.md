# Telegram Web MPV Bridge 使用说明

## 1. 介绍

`telegram-web-mpv-bridge` 用于把 Telegram Web K 中当前正在播放的视频转交给 mpv 播放。它不需要 Telegram API ID/Hash，而是复用浏览器已登录的 Telegram Web 页面，由用户脚本在页面内读取当前视频流，再通过本地 WebSocket/HTTP bridge 提供给 mpv。

链路：

```text
Telegram Web K 页面 → userscript → WebSocket → bridge.py → http://127.0.0.1:8999/stream/current → mpv.exe
```

依赖/相关仓库：

- 当前本地工具：`tools/telegram-web-mpv-bridge/`
- 浏览器用户脚本管理器：Tampermonkey / Violentmonkey
- Python 依赖：`websockets`

## 2. 文件介绍

| 文件 | 作用 |
|---|---|
| `tools/telegram-web-mpv-bridge/bridge.py` | 本地 HTTP + WebSocket 中继服务，处理 mpv 的 Range 请求。 |
| `tools/telegram-web-mpv-bridge/telegram-web-mpv-bridge.user.js` | 浏览器用户脚本，运行在 Telegram Web K 页面，捕获当前视频源并响应 bridge 的 range 请求。 |
| `tools/telegram-web-mpv-bridge/README.md` | 工具原始说明。 |
| `portable_config/scripts/telegram_web_mpv_bridge.lua` | mpv 端控制脚本，可从 mpv 菜单启动/停止/查看 bridge 状态。 |
| `bridge.out.log` / `bridge.err.log` | 运行日志，自动生成，已被 Git 忽略。 |
| `.venv/` | 本地 Python 虚拟环境，需用户自行创建，已被 Git 忽略。 |

## 3. 配置

### Python 虚拟环境

在完整包根目录下执行：

```bat
cd tools\telegram-web-mpv-bridge
python -m venv .venv
.venv\Scripts\python.exe -m pip install --upgrade pip websockets
```

### 浏览器用户脚本

1. 安装 Tampermonkey / Violentmonkey。
2. 导入 `tools/telegram-web-mpv-bridge/telegram-web-mpv-bridge.user.js`。
3. 打开 `https://web.telegram.org/k/`。
4. 完整刷新页面，确保 userscript 在 `document-start` 阶段加载。

### 端口

默认端口：

- HTTP：`127.0.0.1:8999`
- WebSocket：`127.0.0.1:9000`

mpv 端脚本 `telegram_web_mpv_bridge.lua` 也使用这两个端口。

## 4. 使用

### 方式 A：从 mpv 菜单控制 bridge

菜单入口：

```text
工具 > Telegram Web MPV Bridge 开关
工具 > Telegram Web MPV Bridge 状态
```

对应命令：

```text
script-message-to telegram_web_mpv_bridge toggle
script-message-to telegram_web_mpv_bridge status
```

流程：

1. 先按上文安装 `.venv` 和浏览器 userscript。
2. 打开 mpv，进入 `工具 > Telegram Web MPV Bridge 开关` 启动 bridge。
3. 打开 [Telegram Web K](https://web.telegram.org/k/) 并播放目标视频。
4. 页面上应出现 `MPV` 按钮。
5. 点击 `MPV`，bridge 会注册当前视频并启动 mpv 播放。

### 方式 B：手动启动 bridge

```bat
cd tools\telegram-web-mpv-bridge
.venv\Scripts\python.exe bridge.py --http-port 8999 --ws-port 9000 --mpv-path "..\..\mpv.exe"
```

然后在 Telegram Web K 页面点击 `MPV` 按钮。

### 手动测试接口

状态：

```powershell
Invoke-RestMethod http://127.0.0.1:8999/status
```

播放当前视频：

```powershell
Invoke-RestMethod -Method Post http://127.0.0.1:8999/play/current
```

手动让 mpv 打开当前流：

```bat
mpv.exe "http://127.0.0.1:8999/stream/current"
```

## 5. 常见错误

### mpv 菜单提示缺少 `.venv`

没有创建 Python 虚拟环境，或路径不是 `tools/telegram-web-mpv-bridge/.venv/Scripts/python.exe`。

处理：按“Python 虚拟环境”步骤安装。

### Telegram 页面没有 `MPV` 按钮

- userscript 未安装或未启用。
- 没有使用 `https://web.telegram.org/k/`。
- 页面没有完整刷新，脚本错过了内部视频 URL 捕获时机。

处理：确认用户脚本启用后，完整刷新 Telegram Web K 页面。

### 点击 MPV 后无法播放

- bridge 未启动。
- Telegram Web 页面已关闭或视频源失效。
- 浏览器登录态失效。
- 端口 8999 / 9000 被占用。

处理：查看 `bridge.err.log`，并用 `/status` 接口确认状态。

### 播放中断或拖动失败

该工具通过 WebSocket 转发二进制 Range 请求，不是下载器。拖动和大范围读取依赖浏览器、Telegram Web 当前源和本机回环吞吐。遇到异常时重新点击页面 `MPV` 按钮注册当前视频。

