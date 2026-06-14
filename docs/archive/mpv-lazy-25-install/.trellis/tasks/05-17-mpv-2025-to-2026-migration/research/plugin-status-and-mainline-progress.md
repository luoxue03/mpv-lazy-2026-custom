# 插件调研与主线进度记录

## 当前主线进度

迁移目标：以 `F:\mpv_2026\mpv-lazy` 的 2026FM 为运行基线，把 `D:\mpv-lazy-25_install` 的个人自定义能力补丁化迁入。

### 已完成

- `F:\mpv_2026\mpv-lazy` 已建立 git 基线提交：2026FM 原始版本。
- 已迁移 2025 独有脚本与配置数据。
- 已合并 `mpv.conf`：按用户审批保留 2026 为底，补回选定 2025 参数。
- 已合并 `profiles.conf`：HDR 使用融合版；BiliBili/SDR/Anime4K 预设已添加。
- 已处理 `input_uosc.conf`：当前仍需后续复核，尤其与 2026 新版快捷键和 shader 路径关系。
- 已迁移 `shaders/`：按 2026 目录分类；同名文件以 `_2025` 后缀保留，避免覆盖 2026 版本。
- 已迁移 `portable_config/vs/`：2025 独有预设直接复制；两版共有预设以 `_2025` 后缀保留。
- 已迁移根目录工具文件，包括 `url-scheme-handler.exe` 修正版、TorrServer、truehdrtweaks、cookies/config 等。
- 已复制 `faster-whisper-win/` 模型目录，并通过 `.gitignore` 排除，不进入 git。
- 已标注旧版根目录 `k7sfunc.py` 系列为 `_2025_obsolete`，不删除。
- 已标注 `playlist_osd.lua`、`thumbfast.lua` 为 `_2025`，不删除。
- 已补齐 `Lib/site-packages/k7sfunc/mod_memc.py` 的 RIFE 模型支持：`422`、`4221`、`4151`。
- 已处理 `script-opts.conf`：当前采用 2026 单文件结构，追加了用户插件相关参数；后续需根据插件更新策略复核是否保留/注释。

### 待完成

- 记录并固化新的迁移规则到 `prd.md`。
- 决定并执行用户插件更新策略：`sub-fastwhisper.lua`、`sponsorblock_minimal.lua` 是否更新上游。
- 复核 `script-opts.conf` 中插件参数是否保持激活，尤其 `sub_fastwhisper-api_key` 留空后的行为。
- 复核 `uosc/`、`input_plus.lua`、`save_global_props.lua`：原则上使用 2026 新版，不用 2025 覆盖。
- 复核 `input_uosc.conf` 与当前 `shaders/`、`vs/` 路径一致性。
- 处理 `contextmenu_plus` vs 2026 uosc 内置菜单。
- 处理 `thumbfast` vs 2026 `thumb_engine`。
- 最终验证：mpv 启动、脚本加载、B站播放、VS 滤镜、shader 切换、uosc UI。

## 额外插件调研结论

这四个插件均不是 `hooke007/mpv_PlayKit` 官方 2025/2026 tag 自带文件，属于用户额外安装插件。

### `sub-fastwhisper.lua`

- 本地来源线索：`https://github.com/dyphire/mpv-sub-fastwhisper`
- 上游仓库：`dyphire/mpv-sub-fastwhisper`
- 上游更新时间：2026-05-30
- 本地旧文件：38822 bytes
- 上游新文件：39587 bytes
- 更新摘要：
  - 新增 `compute_type` 参数。
  - 新增字幕输出路径可写性检查；源目录不可写时回退临时目录。
  - 修复缓存判断优先级。
- 建议：后续可更新到上游最新版，但保留本地 `script-opts` 参数；`api_key` 不提交。

### `sponsorblock_minimal.lua`

- 可能上游：`dyphire/mpv-config/scripts/sponsorblock_minimal.lua`
- 本地版本：`v0.5.1`
- 上游差异：增加 `video_id = nil`，切换文件时清理状态。
- 建议：低风险更新。

### `mpv-torrserver.lua`

- 脚本头只引用 `YouROK/TorrServer`，没有找到明确脚本上游仓库。
- 建议：保留当前脚本版本；TorrServer 二进制可单独更新。

### `recentmenu.lua`

- 未发现可靠独立上游；无版本头。
- 建议：保留当前脚本版本；若与 2026 uosc 交互出问题再处理。

## 当前风险点

- `script-opts.conf` 已追加插件参数，但用户认为该文件未高度自定义；后续可选择保持、注释或仅保留到 research 文档。
- `sub_fastwhisper-api_key` 当前应保持空值，避免密钥进入 git。
- `input_uosc.conf` 曾经出现直接覆盖/编码问题，后续任何修改必须逐项 diff，不整文件替换。
- `k7sfunc` 不应再恢复单文件版本，2026 模块包为主；只补必要兼容点。
