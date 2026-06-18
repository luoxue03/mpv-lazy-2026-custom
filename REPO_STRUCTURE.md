# 仓库目录结构与本地依赖说明

本仓库是 mpv-lazy 2026 自定义整合包的配置层仓库，已清洗二进制、模型和敏感内容，只保留可分享的配置、脚本、文档和工具源码。

## 远端信息

- 仓库地址：https://github.com/luoxue03/mpv-lazy-2026-custom
- 可见性：private
- 本地路径：F:\mpv_2026\mpv-lazy-26_github
- 工作目录（日常使用）：F:\mpv_2026\mpv-lazy
- 历史保留：60 个 commit，涵盖 2025→2026 迁移、RIFE 性能调查、真人超分接入、Telegram Bridge 等

## 顶层目录

| 路径 | 用途 | 是否上传远端 | 本地依赖 |
|---|---|---|---|
| portable_config/ | MPV 便携配置核心：conf、脚本、着色器、VS 滤镜脚本、字体 | 是 | 依赖 mpv.exe、VapourSynth 运行时、模型文件（不在仓库） |
| docs/ | 文档：研究记录、迁移归档、文章、可视化报告 | 是 | 无 |
| tools/ | 工具源码：RIFE benchmark、RealESRGAN 导出、Telegram Bridge | 是 | Telegram Bridge 需本机 Python venv |
| external_player.js | 油猴脚本，网页拉起 MPV 播放 | 是 | 依赖 url-scheme-handler 或 MPV 可执行路径 |
| .gitignore | 忽略规则 | 是 | 无 |
| LICENSE.txt / LICENSE.MD / README.MD | 许可证和上游说明 | 是 | 无 |
| MANIFEST.in | Python 打包清单（上游遗留） | 是 | 无 |

## portable_config/ 详细

### 配置文件（已上传）

- mpv.conf：MPV 主配置入口。
- input_uosc.conf：uosc 菜单和快捷键绑定，包含所有 VF 滤镜、超分、补帧、组合菜单项。
- input_uosc.conf_2025：2025 版菜单备份，仅作参考。
- menu.conf：原生右键菜单定义。
- profiles.conf：自动 profile 预设（按分辨率、片源类型自动应用）。
- script-opts.conf：脚本选项集中配置。注意：sub_fastwhisper-api_key 已置为 YOUR_API_KEY_HERE 占位符，本地使用前需填入真实 key。
- fonts.conf：字体配置。
- manager.json：管理器窗口状态。

### script-opts/（已上传）

- uosc_danmaku.conf：uosc 弹幕插件配置。
- rife_runtime_default.json：RIFE 动态菜单的默认参数。
- rife_runtime.json：RIFE 动态菜单当前选择状态。属于运行态，已纳入 .gitignore，但历史中被 track；后续应 git rm --cached 移除。

### scripts/（已上传）

MPV Lua/JS 脚本，全部已上传：

- quality-menu.lua：清晰度菜单，支持 yt-dlp 格式和直接 HLS editions。
- rife_runtime_menu.lua：RIFE 动态参数菜单（模型/Turbo/flow_scale/H_Pre）。
- ytdl-retry.lua：yt-dlp 403 自动重试（SpankBang 场景）。
- telegram_web_mpv_bridge.lua：Telegram Bridge MPV 端控制脚本。
- sub-fastwhisper.lua：AI 字幕脚本。
- recentmenu.lua：最近播放菜单。
- input_plus.lua / inputevent.lua：输入增强。
- save_global_props.lua：全局属性保存恢复。
- stats.lua：统计信息覆盖层。
- manager.lua：管理器脚本。
- auto_load_fonts.js / auto_sub_fonts_dir.lua：字体自动加载。
- thumbfast_2025.lua / playlist_osd_2025.lua：2025 版缩略图和播放列表。

### scripts 子目录（已上传）

- bilibiliAssert/：B 站弹幕集成（含 main.lua、模块、Danmu2Ass 转换逻辑）。注意：Danmu2Ass.exe 已从仓库移除，本地需自行准备。
- uosc/：uosc 现代化界面框架。注意：bin/ziggy-windows.exe 已从仓库移除。
- uosc_danmaku/：uosc 弹幕插件。
- trakt-scrobble/：Trakt 追踪插件（含 main.lua、modules、README）。
- thumb_engine/：缩略图引擎。

### vs/（已上传）

VapourSynth 滤镜脚本，全部 .vpy 文件已上传：

- MEMC_*.vpy：补帧脚本（RIFE、MVTools、DRBA）。
- MIX_UAI_*.vpy：超分脚本（UAI、AnimeJaNai、RealESRGAN、LiveAction、StarSample）。
- SR_*.vpy：着色器超分脚本。
- ETC_*.vpy：去隔行、IVTC 脚本。

这些脚本引用的 ONNX 模型和 CUDA/TensorRT DLL 不在仓库，需本地准备。

### shaders/（已上传）

780 个 GLSL 着色器文件，按类别分目录：AA、Anime4K、ACNet、FSRCNNX、ESRGAN、Krig、SSimDownscaler 等。

### fonts/（已上传）

字体文件：LXGWWenKaiMono、MaterialIcons、uosc_textures。

## docs/ 详细

- README.md：文档总索引。
- research/：人工研究报告（RIFE 性能调查、真人超分、Telegram Bridge、HLS 清晰度菜单等）。
- articles/：面向用户的介绍文章。
- reports/：可视化 HTML 报告（RIFE Benchmark Dashboard）。
- archive/2025-migration/：2025→2026 迁移文档精选。
- repowiki/README.md：知识库索引（.qoder 内容已从仓库移除）。

## tools/ 详细

- rife_benchmark.py：RIFE 性能基准测试脚本。
- rife_engine_builder.py / rife_engine_monitor.py：TensorRT engine 预构建和监控。
- export_realesr_general_x4v3_dynamic.py：RealESRGAN 模型动态 ONNX 导出工具。
- telegram-web-mpv-bridge/：Telegram Web MPV Bridge（bridge.py、userscript、README）。运行需本机 Python venv + websockets 包。

## 未上传的内容（本地依赖）

以下内容不在仓库，本地使用前需自行准备：

### 二进制运行时

- mpv.exe、mpv.com：MPV 播放器主体。
- python.exe 及整个 Lib/、Scripts/：嵌入式 Python 运行时。
- yt-dlp.exe：在线视频提取。
- TorrServer-windows-amd64.exe：BT 种子播放。
- url-scheme-handler.exe：URL scheme 注册和拉起。
- umpv.exe / umpv.py：MPV 管道通信。
- VSPipe.exe、VSScript.dll：VapourSynth 命令行和脚本接口。
- 7z.exe、AVFS.exe、pfm-192-vapoursynth-win.exe：辅助工具。
- 各种 VC++/OpenSSL 运行时 DLL。

### VapourSynth 插件和模型

- vs-plugins/：VapourSynth 插件（vsmlrt-cuda、TensorRT、CUDA DLL 等，约 5GB）。
- vs-coreplugins/：核心插件。
- vs-plugins/models/：AI 模型（RIFE、DRBA、AnimeJaNai、RealESRGAN、LiveAction、StarSample 等 ONNX 文件）。

### 敏感文件

- cookies.txt：浏览器登录态 cookie，已从历史清除。
- config.json：url-scheme-handler 本机注册状态。
- settings.json：TorrServer 配置。
- portable_config/recent.json：播放历史。
- portable_config/saved-props.json：保存的播放属性。
- portable_config/trakt_config.json：Trakt 认证 token。
- portable_config/trakt_history.json：Trakt 历史。

### 自动生成

- .qoder/：Qoder IDE 知识库（含明文 API key，已从历史清除）。
- *.log：各类调试日志。

## 日常维护

- 日常配置修改在 F:\mpv_2026\mpv-lazy 完成。
- 需要同步到远端时，将改动复制到 F:\mpv_2026\mpv-lazy-26_github 对应文件，再 git add && commit && push。
- 涉及敏感信息（cookie、token、api key）的文件永远不要 git add。
- 新增模型或二进制时，确认 .gitignore 规则覆盖，避免误提交。