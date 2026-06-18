# external_player.js 使用说明

## 1. 介绍

`external_player.js` 是浏览器端用户脚本，用于从网页中提取视频、音频、字幕、标题、时间点、Cookie、Referer 等信息，然后通过 `ush://` URL Scheme 调用本地播放器。

当前整合包主要用它配合 `url-scheme-handler.exe` 拉起 `mpv.exe`，常见链路是：

```text
网页视频页面 → external_player.js → ush://MPV?... → url-scheme-handler.exe → mpv.exe
```

本地维护/依赖仓库：

- url-scheme-handler：https://github.com/luoxue03/url-scheme-handler
- external-player：https://github.com/luoxue03/external-player
- 上游 external-player：https://github.com/LuckyPuppy514/external-player

当前脚本文件：`external_player.js`。

## 2. 文件介绍

| 文件/模块 | 作用 |
|---|---|
| `external_player.js` | 浏览器用户脚本主体，包含站点识别、媒体解析、按钮注入、播放器参数拼接和 `ush://` 拉起逻辑。 |
| `url-scheme-handler.exe` | 本地 URL Scheme 处理器，负责接收 `ush://` 链接并启动指定播放器。完整发布包根目录包含该文件，仓库不保存二进制。 |
| `config.json` | `url-scheme-handler` 的本机配置/注册状态文件，属于本地运行态，不应提交仓库。 |
| `cookies.txt` | 可选 Cookie 文件，用于部分需要登录态的网站；属于本地敏感文件，不应提交仓库。 |

`external_player.js` 内部主要区域：

- `defaultConfig.global.parser`：站点匹配规则和解析器配置。
- `defaultConfig.players`：播放器列表，例如 `MPV`、`MPVNET`、`PotPlayer`、`IINA`。
- `playEvent`：每个播放器实际执行的参数拼接逻辑。
- `BilibiliParser` / `BilibiliLiveParser` / `YtdlpParser` 等解析逻辑：按站点生成 `media.video`、`media.audio`、`media.subtitle` 等字段。

## 3. 配置

### 浏览器端

1. 安装用户脚本管理器，例如 Tampermonkey / Violentmonkey。
2. 点击扩展->添加新脚本。
3. 粘贴 `external_player.js`-> 保存。
4. 打开支持的网站，页面上会注入播放器按钮。
5. 可在脚本设置中调整播放器、代理、解析优先级和清晰度偏好。

当前配置内置支持/适配的网站类型：

| 类型 | 支持范围 | 备注 |
|---|---|---|
| B 站 | 番剧、视频、合集、活动页、直播 | 可提取 DASH、字幕、`cid`，用于 mpv 播放和弹幕联动。 |
| P 站 | 视频页、embed 页 | 走 yt-dlp 路径，当前分支会追加本地 cookies 与 impersonate 参数。 |
| SB 站 | 视频页、embed 页 | 走 yt-dlp 路径，配合 `ytdl-retry.lua` 处理概率性 403。 |
| MA 站 | `missav.ws` / `missav.com` / `missav.ai` / `missav.live` | 使用专门解析分支，优先提取可交给 mpv 的播放地址。 |
| YouTube | shorts、watch、playlist | 走 yt-dlp。 |
| 巴哈姆特动画疯 | `ani.gamer.com.tw/animeVideo.php` | 有站点匹配入口，实际播放取决于登录态与源可用性。 |
| Anime1 | `anime1.me` | 站点匹配入口。 |
| 直链/播放器页 | 常见 mp4、mkv、flv、m3u8、m3u、webm 等 URL；部分 moepoi/libvio/yhdmjx/cycanime/tucao/ddys/cnys 播放器页 | 会尝试直接提取媒体 URL 或把页面交给 mpv/yt-dlp。 |

### 本机端

本机端依赖 `url-scheme-handler.exe`，用于把浏览器打开的 `ush://MPV?...` 转成真正的本地命令。

依赖仓库：[luoxue03/url-scheme-handler](https://github.com/luoxue03/url-scheme-handler)

配置步骤：

1. 确认完整包根目录存在 `url-scheme-handler.exe`。
2. 运行 `url-scheme-handler.exe`。
3. 点击 `+ Add to Registry` 添加注册表，让 Windows 识别 `ush://` 协议。
4. 点击 `+` 添加应用。
5. 在左边输入框填写应用名称，例如 `MPV`。
6. 在右边选择当前整合包根目录下的 `mpv.exe`。
7. 应用名称必须与 `external_player.js` 中的播放器名称保持一致，大小写也要一致。

示意图：

![url-scheme-handler 添加注册表与应用](https://raw.githubusercontent.com/luoxue03/url-scheme-handler/main/screenshot/20241125202543.jpg)

![url-scheme-handler 配置 MPV](https://raw.githubusercontent.com/luoxue03/url-scheme-handler/main/screenshot/20250514203101.jpg)

建议导入仓库里的注册表补丁，首次运行外部协议时可出现“是否始终允许”的勾选框，之后无需每次弹窗确认：

- 开启勾选框：[Enable_ExternalProtocolDialog_ShowCheckbox.reg](https://raw.githubusercontent.com/luoxue03/url-scheme-handler/main/reg/Enable_ExternalProtocolDialog_ShowCheckbox.reg)
- 移除勾选框：[Remove_ExternalProtocolDialog_ShowCheckbox.reg](https://raw.githubusercontent.com/luoxue03/url-scheme-handler/main/reg/Remove_ExternalProtocolDialog_ShowCheckbox.reg)

如果移动了整合包目录，需要重新注册，否则浏览器仍可能调用旧路径。

### cookies 与代理

- 部分站点需要浏览器登录态或 cookies；我当前使用 `Get cookies` 浏览器扩展导出 `cookies.txt` 到整合包根目录。
- 导出时建议使用 Netscape cookies.txt 格式；文件名保持为 `cookies.txt`。
- 脚本支持把 Cookie、Referer、Origin 和代理参数传给 mpv / yt-dlp。
- cookies、token、个人代理信息都属于本地敏感配置，不要提交到 Git。

## 4. 使用

### 基础使用

1. 打开目标网页视频。
2. 等页面视频加载完成。
3. 点击页面上的 `MPV` 按钮。
4. 浏览器会打开 `ush://MPV?...`。
5. `url-scheme-handler.exe` 接管协议并启动 `mpv.exe`。

### B 站场景

脚本会尝试通过 B 站接口获取 DASH 视频、音频、字幕和 `cid`。拉起 mpv 时会追加类似：

```text
--audio-file=...
--sub-file=...
--script-opts-append="cid=..."
--force-media-title="..."
```

`cid` 可被弹幕相关脚本使用。

### P 站场景

P 站当前走 yt-dlp 视频页路径，不在浏览器侧做抓流 parser。脚本会按当前配置追加本地 `cookies.txt` 和 impersonate 参数，再交给 mpv/yt-dlp 解析。

常见用途：

- 使用网页标题作为 mpv 标题。
- 让 yt-dlp 处理视频页实际流地址。
- 通过本地 cookies 提供登录态。

### SB 站场景

SB 站同样走 yt-dlp 视频页路径。该站可能出现概率性 403，整合包内的 `portable_config/scripts/ytdl-retry.lua` 会尝试自动重试。

如果偶发失败，可以重新点击 MPV 按钮或等待脚本重试。

### MA 站场景

MA 站有独立匹配分支，支持 `missav.ws`、`missav.com`、`missav.ai`、`missav.live` 域名。脚本会优先尝试提取可直接交给 mpv 的播放地址。

如果站点页面结构变化，可能需要更新 `external_player.js` 的 MA 解析分支。

### yt-dlp / 通用网页场景

对于无法直接解析出视频 URL 的站点，脚本会把页面 URL 交给 mpv/yt-dlp，并可追加：

```text
--ytdl-format="bestvideo[height<=?1080]+bestaudio/best"
--ytdl-raw-options-append="proxy=[...]"
--ytdl-raw-options-append="impersonate=..."
```

### 和 MPV 清晰度菜单配合

部分 HLS / yt-dlp 路径会进入 `quality-menu.lua`，在 mpv 内显示清晰度菜单。若菜单不出现，先确认视频源是否真的提供多清晰度流。

## 5. 常见错误

### 点击按钮后无反应

- `ush://` 没注册，或注册到了旧路径。
- 浏览器拦截外部协议调用。
- `url-scheme-handler.exe` 配置中的播放器路径错误。

处理：重新运行 `url-scheme-handler` 注册，并确认 `MPV` 指向当前 `mpv.exe`。

### mpv 打开但无法播放

- yt-dlp 无法解析该站点。
- 站点需要登录态，缺少 `cookies.txt` 或 Cookie 已过期。
- Referer / Origin / User-Agent / 代理参数不符合站点要求。
- 视频实际是 DRM 内容，mpv 无法播放。

处理：查看 mpv 控制台和日志，更新 yt-dlp，必要时重新导出 cookies。

### B 站弹幕或字幕没有跟随

- 页面解析未拿到 `cid`。
- 当前链接不是脚本匹配的 B 站页面类型。
- 弹幕脚本未启用或其配置未匹配。

处理：打开浏览器控制台看 `external_player.js` 输出的 args，确认是否包含 `cid=...`。

### 移动整合包目录后失效

`url-scheme-handler` 记录的是本机绝对路径。移动目录后必须重新注册，否则还会调用旧的 `mpv.exe`。
