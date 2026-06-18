# 文档索引

这是当前 mpv-lazy 2026 自定义整合包的文档入口。目标是把“可直接操作的结论”“深度调查过程”“自动生成知识库”和“Trellis 迁移记录”分开，避免以后继续迁移时找不到上下文。

## 快速入口

| 文档 | 内容 | 适合什么时候看 |
|---|---|---|
| [工具脚本安装、配置与使用说明](工具脚本安装配置使用说明.md) | 汇总 installer、external_player、MPV scripts、script-opts、tools、Release 脚本的安装、配置、使用和排错 | 想知道整合包里每个脚本工具怎么用、是否需要安装或授权时 |
| [external_player](scripts/external-player.md) | 浏览器用户脚本、url-scheme-handler、网页拉起 mpv 的安装配置和排错 | 配置 B 站/网页视频从浏览器拉起 mpv 时 |
| [uosc_danmaku](scripts/uosc-danmaku.md) | 弹幕插件文件结构、样式配置、菜单入口和常见错误 | 配置弹幕显示、搜索弹幕、排查补帧后弹幕异常时 |
| [sub-fastwhisper](scripts/sub-fastwhisper.md) | AI 字幕脚本、faster-whisper、翻译 API 配置与使用 | 生成/翻译字幕或配置 API key 时 |
| [trakt-scrobble](scripts/trakt-scrobble.md) | Trakt 授权、同步、手动匹配和错误处理 | 同步观看记录、修正识别错误或重新授权时 |
| [Telegram Web MPV Bridge](scripts/telegram-web-mpv-bridge.md) | Telegram Web K 用户脚本、本地 bridge、mpv 菜单控制与排错 | 从 Telegram Web 播放当前视频到 mpv 时 |
| [RIFE/TensorRT 性能调查与修复](research/RIFE-performance-investigation-2026-06-14.md) | 记录 RIFE 4.15 lite 丢帧、TensorRT 10.16 回退到 10.13 的测试和结论 | 排查补帧丢帧、回滚/升级 vs-mlrt、解释为什么选 TensorRT 10.13 |
| [TensorRT 深度调研参考](research/deep-research-report.md) | 外部/深度调研汇总，作为假设和后续验证参考 | 需要继续拆 TensorRT 性能根因时 |
| [External Player 与 HLS 清晰度菜单](research/external-player-hls-quality-menu-2026-06-16.md) | 记录 MissAV 直连 HLS、Pornhub/SpankBang 走 yt-dlp、403/410 处理、通用 HLS editions 清晰度菜单 | 维护 `external_player.js`、`quality-menu.lua` 或排查网页拉起 MPV 时 |
| [Telegram Web MPV Bridge](research/telegram-web-mpv-bridge-2026-06-18.md) | 记录 Telegram Web K 登录态视频通过浏览器中继转 MPV 的方案、使用方式和约束 | 不申请 Telegram API ID/Hash，直接把 Web K 当前视频在线播放到 MPV 时 |
| [真人/通用超分与补帧组合](research/live-action-upscale-and-rife-combo-2026-06-17.md) | 记录 RealESRGAN、LiveAction、StarSample 接入，以及 RealESRGAN + RIFE 组合实测取舍 | 选择真人视频超分、解释菜单项、排查组合丢帧时 |
| [可视化报告索引](reports/README.md) | RIFE Benchmark 等 HTML 可视化报告入口 | 需要查看性能仪表盘或公网展示版本时 |
| [调研报告索引](research/README.md) | 本仓库内手工研究报告的目录和阅读顺序 | 想按主题追溯决策过程时 |
| [Repowiki 知识库索引](repowiki/README.md) | `.qoder/repowiki` 自动/半自动知识库的导航 | 想按模块理解 mpv-lazy 配置体系时 |
| [2025 迁移文档精选](archive/2025-migration/INDEX.md) | 按内容筛选后的 2025→2026 迁移记录 | 追溯 2025 自定义、迁移规则、模型和插件决策时 |
| [README.MD](../README.MD) | 上游 mpv_PlayKit / mpv-lazy 原始说明入口 | 查官方使用说明和上游链接时 |

## 当前主线结论

- 2026 整合包的主线目标是：以 2026 版本为基底，保留 2025 本地自定义模型、滤镜、菜单和脚本配置。
- RIFE 4.15 lite 满高 4K 丢帧的当前落地方案是：全局使用 `vs-mlrt v15.13 / TensorRT 10.13.0`，替代原 2026 的 `TensorRT 10.16`。
- RIFE 自定义菜单已加入 `H_Pre / 处理高度`，用于在画质和实时性能之间切换。
- 真人/通用超分已归类到 `VF 滤镜 > 超分 > 2026 > 真人/通用`；RealESRGAN + RIFE 组合当前以 `4.6 T1 F0.25` 为真实播放可用档。
- `quality-menu.lua` 已加入直接 HLS `.m3u8/.m3u` 的通用清晰度菜单分支：优先使用 MPV `edition-list` / `edition`，回退到 `hls-bitrate`，不影响 B 站等 yt-dlp 路径。
- `external_player.js` 中 Pornhub 只走 yt-dlp 视频页路径，不做浏览器侧抓流 parser；仅 Pornhub 分支追加本地 `cookies.txt` 和 `impersonate=chrome`，并用 `ytdl-raw-options-append` 避免覆盖全局 yt-dlp 配置。
- `external_player.js` 中 SpankBang 也只走 yt-dlp 视频页路径；当前使用 `impersonate=Safari-18.0`，并通过 `portable_config/scripts/ytdl-retry.lua` 对概率性 403 自动重试。
- Telegram Web K 登录态视频当前使用独立 `tools/telegram-web-mpv-bridge`：浏览器 userscript 捕获 `hls_stream`，本地 bridge 提供 MPV 可用 HTTP Range，并可自动拉起 MPV；不依赖 Telegram API ID/Hash。
- 运行时状态文件不应作为迁移文档或配置结论提交，例如 `portable_config/recent.json`、`portable_config/saved-props.json`。

## 文档分区

### 研究报告

放在 `docs/research/`，用于记录人工调研、性能测试、决策理由和已知风险。这里的文档优先于聊天记忆，因为它们更稳定、可追溯。

### Repowiki 知识库

源文件仍在 `.qoder/repowiki/zh/content/`，索引放在 `docs/repowiki/README.md`。这部分更像系统结构说明，不一定全是最终决策。

### 插件原始 README

插件 README 保持在插件目录内：

- `portable_config/scripts/uosc_danmaku/README.md`
- `portable_config/scripts/trakt-scrobble/README.md`

### 脚本工具独立说明

面向用户的脚本工具说明放在 `docs/scripts/`：

- [external_player](scripts/external-player.md)
- [uosc_danmaku](scripts/uosc-danmaku.md)
- [sub-fastwhisper](scripts/sub-fastwhisper.md)
- [trakt-scrobble](scripts/trakt-scrobble.md)
- [Telegram Web MPV Bridge](scripts/telegram-web-mpv-bridge.md)

### 2025 迁移文档精选

2025 安装目录中的 Markdown 已按内容筛选后归档到 `docs/archive/2025-migration/`，索引见：

- [2025 迁移文档精选索引](archive/2025-migration/INDEX.md)

这批文件删除了 Trellis/Claude 通用模板、空 journal、license、issue 模板等低价值内容，只保留迁移规则、历史调研、旧版说明和外部资料快照。

## 维护规则

- 新的人工调研、测试报告、决策记录放入 `docs/research/`。
- 自动生成或结构性知识库继续留在 `.qoder/repowiki/zh/content/`，不要混进 `docs/research/`。
- 如果报告来自外部搜索或未经本机验证，标题或摘要里要标注“参考/待验证”。
- 涉及配置文件时，记录“文件路径、迁移来源、冲突处理、验证方式”。
- 不把播放历史、音量、缓存、快捷方式、临时测试目录写进文档索引或正式提交。
