# External Player 与 HLS 清晰度菜单接入记录（2026-06-16）

## 背景

本记录整理 `external_player.js` 拉起 MissAV 直连 HLS 流到本地 MPV，以及 `quality-menu.lua` 对直接 HLS `.m3u8` 流提供清晰度菜单的实现结论。

相关文件：

- `F:\mpv_2026\mpv-lazy\external_player.js`
- `F:\mpv_2026\mpv-lazy\portable_config\scripts\quality-menu.lua`
- `F:\mpv_2026\mpv-lazy\config.json`

## 已落地行为

### Pornhub 拉起 MPV

Pornhub 不需要像 MissAV 一样写浏览器侧 HLS parser。本地 `yt-dlp.exe --list-extractors` 已包含 `PornHub`、`PornHubPlaylist` 等 extractor，yt-dlp 上游 `pornhub.py` 也支持常见视频页：

- `https://www.pornhub.com/view_video.php?viewkey=...`
- `https://www.pornhub.com/video/show?viewkey=...`
- `https://www.pornhub.com/embed/...`
- `pornhub.com / pornhub.net / pornhub.org / pornhubpremium.com` 的同类 URL

`external_player.js` 因此只在 YTDLP 默认 parser 中增加 Pornhub 视频页正则，把页面 URL 交给 MPV 的 yt-dlp 流程处理。2026-06-17 已收窄为只匹配明确视频页 / embed 页，并在 `matchParser()` 加了 Pornhub 视频页兜底，避免浏览器旧配置没有同步默认正则时视频页无法出现按钮。

Pornhub 视频页当前传给 MPV/yt-dlp 的附加选项：

- `--force-window=immediate`：尽快显示 MPV 窗口，避免 yt-dlp 探测期间看不到前台窗口。
- `--user-agent=...Chrome...`：让 MPV 网络请求使用浏览器 UA。
- `--ytdl-raw-options-append="impersonate=chrome"`：让 yt-dlp 使用浏览器指纹模拟能力。本地 `yt-dlp.exe --help` 已确认支持 `--impersonate`。
- `--ytdl-raw-options-append="cookies=F:\mpv_2026\mpv-lazy\cookies.txt"`：只在 Pornhub 分支读取本地 Netscape cookies 文件，避免每次播放都复制 Edge/Chrome 正在使用的 cookie 数据库。
- `--ytdl-format="best[protocol^=m3u8]/best"`：优先选择 HLS 流，失败时回退 best。

注意 `ytdl-raw-options` 必须用 `append` 形式传递。MPV 支持 `--ytdl-raw-options-append`；使用不带 append 的 `--ytdl-raw-options=...` 容易覆盖 `mpv.conf` 中已有的 `sub-langs=-danmaku` 等配置。

注意：

- 当前只默认匹配明确的视频页 / embed 页，不默认匹配搜索页、频道页、用户页和 playlist 页，避免误触发整页播放列表。即使浏览器旧配置里残留了更宽泛的 Pornhub 正则，`matchParser()` 也会跳过非视频页 Pornhub URL。
- 如果视频被删除、地区限制、登录限制或站点返回错误，yt-dlp 会失败；这属于站点访问条件，不是本地 parser 失效。
- `HTTP Error 410: Gone` 通常表示站点或 CDN 返回的资源已不可用、过期、地区/权限不满足，或 extractor 拿到的临时地址失效。优先处理顺序是：更新 yt-dlp、使用本地 `cookies.txt`，必要时重新导出 cookies；不要优先写页面内抓流 parser。
- `cookies-from-browser=edge` 在 Edge 正在运行时可能报 `Could not copy Chrome cookie database`，导致 yt-dlp 直接失败；2026-06-17 已改为播放时读取 `cookies.txt`。
- `--disable-features=LockProfileCookieDatabase` 是 Chromium/Edge 的浏览器启动参数，不是 MPV 或 yt-dlp 参数。它可以降低浏览器锁住 cookie 数据库导致 yt-dlp 导出失败的概率，但不能替代 `cookies.txt`。如果需要刷新 `cookies.txt`，优先关闭 Edge 后运行导出命令，或用该参数启动 Edge 后再导出。
- 不要在 userscript 中硬转存 Pornhub 敏感 cookie；登录态应由 yt-dlp 的本地 `cookies.txt` 机制处理。

### MissAV 拉起 MPV

`external_player.js` 增加了 MissAV parser，用于从当前页面、Performance API、DOM 属性和脚本内容中发现真实媒体候选 URL，优先选择可播放的 HLS `.m3u8`。

MissAV 直连播放时传给 MPV 的关键选项：

- `--no-ytdl`：直连 m3u8 不再让 yt-dlp 介入，避免多余探测和启动延迟。
- `--force-window=immediate`：尽快显示 MPV 窗口。
- `--user-agent=...Chrome...`：使用浏览器 UA。
- `--http-header-fields="origin: https://missav.ws"`
- `--http-header-fields="referer: <当前 MissAV 页面>"`

不要把 MissAV 页面 cookie 发送给 `surrit.com` CDN。实测跨域 cookie 会触发 403；保留 `origin`、`referer` 和 UA 即可播放。

### SpankBang 拉起 MPV

本地 `yt-dlp.exe --list-extractors` 已包含 `SpankBang` 和 `SpankBangPlaylist`，因此 SpankBang 也采用 Pornhub 同类的轻量接入方式：`external_player.js` 只识别明确视频页 / embed 页，把页面 URL 交给 MPV 的 yt-dlp 流程处理，不写浏览器侧 HLS parser。

当前默认匹配：

- `https://spankbang.com/<id>/video/<slug>`
- `https://spankbang.com/embed/<id>`
- 同类子域名 URL

暂不默认匹配搜索页、频道页、标签页和 playlist 页，避免误触发整页播放列表。`matchParser()` 也提供 SpankBang 视频页兜底，避免浏览器旧配置没有同步默认正则时按钮不显示。

2026-06-18 追加：SpankBang 的 `HTTP Error 403: Forbidden` 实测是概率性反爬拦截，不是固定 header 或固定 cookie 问题。样例 `https://spankbang.com/9hzql/video/lin+yu+5v1` 多次测试表现为：同一命令有时失败、有时成功；手动多次点击会打开多个 MPV，其中某个窗口可能成功播放。

当前 `external_player.js` 对 SpankBang 的处理：

- 匹配明确视频页 / embed 页，把页面 URL 交给 MPV 的 yt-dlp 流程处理，不写浏览器侧 HLS parser。
- 传入 `--force-window=immediate`，让 MPV 在 yt-dlp 探测期间尽快显示前台窗口。
- `impersonate` 从 `Chrome-124` 改为 `Safari-18.0`。本机实测 `Chrome-124/chrome` 更容易 403，`Safari-18.0` 成功率更高。
- `format` 保持 `best[protocol^=m3u8]/best`，优先选择 HLS，失败时回退 best。
- 默认不为 SpankBang 注入 `cookies.txt`。现有 `cookies.txt` 中虽有 `.spankbang.com` 的 `cf_clearance`、`__cf_bm`、`age_pass` 等条目，但实测 `--cookies cookies.txt` 仍会频繁 403；Cloudflare clearance 往往绑定浏览器 TLS/指纹，和 yt-dlp 的请求指纹不一致时不会稳定生效。

已更新本机 `D:\mpv-lazy-25_install\yt-dlp.exe` 到 `2026.06.09`。该版本晚于 yt-dlp 上游 PR `#14130`（SpankBang impersonation 修复），但对当前站点仍无法完全消除概率性 403。`F:\mpv_2026\mpv-lazy\yt-dlp.exe` 当前为 `2026.05.05.233942`，尝试 `-U` 时遇到 GitHub rate limit，后续可在不限速时再更新。

最终兜底方案是新增 MPV 脚本 `portable_config/scripts/ytdl-retry.lua`，已同步到 D 盘运行目录和 F 盘 2026 目录。逻辑：当 MPV 通过 yt-dlp 打开 `http(s)` 页面 URL 且 `end-file` 原因为 `error` 时，自动等待 2 秒后重新 `loadfile` 同一 URL，最多 8 次，并在 OSD 显示 `Retrying (N/8)...`。这等价于把“手动多点几次直到成功”变成“一次点击后自动重试”。

不要为 SpankBang 新增 `portable_config/script-opts/ytdl_hook.conf` 的 `try_ytdl_first=yes`，也不要把 `cookies.txt` 全局加到 `mpv.conf` 的 `ytdl-raw-options-append`。Pornhub 需要本地 cookies，仍只在 external_player 的 Pornhub 分支单独追加。

### 通用 HLS 清晰度菜单

`quality-menu.lua` 的 HLS 逻辑已从站点特判改为媒体形态判断：

- 当前 URL 是直接 `http(s)://...m3u8` 或 `http(s)://...m3u` 时，尝试启用 HLS 菜单分支。
- 优先读取 MPV 的 `edition-list` 生成清晰度菜单。
- 选择清晰度时设置 `file-local-options/edition` 并重载当前播放项。
- 如果没有 `edition-list`，回退到 `track-list` 中的 `hls-bitrate`，选择时设置 `file-local-options/hls-bitrate`。
- 如果两者都没有，只是不显示可切换清晰度，不影响当前播放。

这条分支不影响 B 站等非直接 `.m3u8` URL；它们仍走原 `yt-dlp` / `ytdl-format` 菜单路径。

## 为什么使用 edition-list

MPV 官方文档说明：

- `edition` 是可读写属性，设置后会重启当前播放。
- 对 MPEG-TS、HLS、EDL 流，`edition` 会映射到底层 program / variant。
- `track-list` 只列出当前 edition 下的轨道。
- `edition-list` 会列出所有 editions，并标记当前项。

MissAV 的 HLS master playlist 在 MPV 控制台中表现为：

```text
--edition=0 640x360 ...
--edition=1 854x480 ...
--edition=2 1280x720 ...
--edition=3 1920x1080 ...
```

因此，仅从 `track-list` 读取时通常只能看到当前选中的一档，例如 1080p；真正的多清晰度列表应该来自 `edition-list`。

## 失败与回退

### 菜单空白

原因：HLS 数据被套进 `quality-menu` 原本面向 yt-dlp formats 的表格列渲染流程，默认列可能全部为空或被隐藏。

处理：HLS 菜单项直接写入 `title`、`label`、`hint`，例如：

```text
1080p    HLS, 1920x1080, 7.86Mbps
720p     HLS, 1280x720, 4.51Mbps
```

### 只显示一档清晰度

原因：读取的是 `track-list`，而 `track-list` 只暴露当前 edition 的轨道。

处理：优先读取 `edition-list`；仅在没有 editions 时才回退到 `track-list` / `hls-bitrate`。

### 切换失败

可能原因：

- 该 HLS 源没有把 variant 暴露为 editions。
- `edition-list` title 缺少分辨率或码率信息，菜单只能显示 `Edition N`。
- CDN 或站点要求额外 headers，导致重载后网络请求失败。

原则：失败只影响菜单可用性，不应阻止当前视频继续观看。

## 验证方式

### 脚本加载检查

```powershell
$mpv='F:\mpv_2026\mpv-lazy\mpv.exe'
$script='F:\mpv_2026\mpv-lazy\portable_config\scripts\quality-menu.lua'
$log=Join-Path $env:TEMP 'quality-menu-load-check.log'
Remove-Item -LiteralPath $log -ErrorAction SilentlyContinue
$p = Start-Process -FilePath $mpv -ArgumentList @('--no-config', "--script=$script", '--idle=yes', '--force-window=no', '--terminal=no', "--log-file=$log", '--msg-level=all=warn') -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 2
if (!$p.HasExited) { Stop-Process -Id $p.Id -Force }
Select-String -LiteralPath $log -Pattern '\[e\]|\[fatal\]|Lua error|syntax error|failed to load' -CaseSensitive:$false
```

预期：无 Lua load error。

### 现场验证

1. 关闭旧 MPV 实例。
2. 从浏览器通过 `external_player.js` 重新拉起一个 MissAV 页面。
3. 等视频开始播放后打开 `流品质`。
4. 预期看到 360p / 480p / 720p / 1080p 等 HLS editions。
5. 选择较低清晰度后，MPV 会重载当前播放项并切换 edition。

## 维护注意

- `quality-menu.lua` 上游原设计是 yt-dlp `ytdl-format` 菜单；本地 HLS 分支是 mpv-lazy 2026 自定义补丁。
- 如果以后升级 `quality-menu.lua`，需要重新合并 HLS direct URL、`edition-list`、`hls-bitrate` 回退和 HLS 菜单项 `title/label/hint` 逻辑。
- 不要把此逻辑绑定到 MissAV 域名；通用触发条件应是直接 HLS URL 和 MPV 暴露的 HLS editions。
- 不要恢复向 CDN 发送页面 cookie 的行为，避免重新引入 403。
