# mpv 2025 → 2026 版本迁移

## 目标

将 `D:\mpv-lazy-25_install`（2025 旧版，深度自定义）迁移到 `F:\mpv_2026\mpv-lazy`（2026FM 20260510），以新版本为基础，保留所有自定义功能。

**核心原则：用 git 追踪每一步，diff 对比后决策，有疑问必提问。**

## 背景

- **2025 版本**：`D:\mpv-lazy-25_install`，基于 2025V2 (2025-05-25)，已使用约一年，配置高度定制
- **2026 版本**：`F:\mpv_2026\mpv-lazy`，2026FM 版 (2026-05-10)，上游彻底重做
- **上游变更摘要**（来自 Discussion #194）：组件精简、参数极简化无注释、script-opts 改为单文件内联、uosc 集成上下文菜单、新增 thumb_engine

## 不变量

1. **2026 二进制全部保留**（mpv.exe、dll、Python 3.14 等）
2. **2026 新增功能全部保留**（thumb_engine、新版 uosc 等）
3. **2025 独有的自定义内容迁移到 2026**（脚本、着色器、模型、滤镜预设）
4. **两版都有的项目，diff 对比后由用户决策**

## 操作规则（最高优先级）

1. 每步迁移一个独立类别，单独 git commit
2. 涉及两版都有的文件时，用 `git diff` 或文件对比展示差异
3. **对任何不确定的内容，必须给出选项让用户选择，禁止自行决定**
4. commit message 清晰标注迁移来源和决策理由

5. **diff 审批规则**：两版都有的配置文件，提取关键差异参数，每个参数提供单选框：
   - **2025 值**（说明含义）
   - **2026 值**（说明含义）
   - **两者合并**（仅在无冲突时提供此选项，如扩展列表类参数）
   每次展示 3-4 个参数为一组，等用户逐批确认后执行。



## 迁移规则 v2（当前执行准则）

1. **2026 架构优先**：F:\mpv_2026\mpv-lazy 的 2026FM 作为运行底座；2025 内容只作为补丁迁入，禁止用 2025 整体覆盖 2026。
2. **不删除旧内容**：弃用或暂不启用的 2025 文件必须通过 _2025、_2025_obsolete、注释或记录方式留存；只有用户明确批准时才删除。
3. **同名/同功能冲突必须审批**：遇到同名文件、同一快捷键、同一脚本功能、同一模型接口时，先给出 2025 值、2026 值、可合并值；有行为冲突时不提供合并选项。
4. **不确定时保留两版**：如果无法判断哪个版本正确，保留 2026 原文件，同时将 2025 版本旁路保存或注释引用，等待用户确认。
5. **逐项 diff，不整文件替换**：尤其是 input_uosc.conf、script-opts.conf、profiles.conf、mpv.conf、k7sfunc 相关文件，必须按差异项处理。
6. **编码必须验证**：修改含中文的配置后，必须用 UTF-8 读回，确认没有中文乱码，也没有误删 2026 独有有效行。
7. **插件与 mpv_PlayKit 分开管理**：用户额外安装的插件不视为上游 mpv_PlayKit 的一部分；更新前需要确认插件上游、兼容性和本地配置。
8. **大文件与密钥不进 git**：faster-whisper-win/ 等大模型目录通过 .gitignore 排除；任何 API key、cookie、token 不写入提交。
9. **每个迁移动作必须留记录**：记录内容是什么、从哪里迁到哪里、采用 2025/2026/合并的原因、是否需要后续验证。

## Secret Handling Rule Update

User decision on 2026-06-09: existing local API keys and similar configured values should be migrated as-is when they are part of local working configuration. Do not blank, mask, redact, or synthesize replacement values during local file migration.

Operational boundary:
- Preserve values in local files when migrating configuration.
- Do not print secret values into chat or research summaries unless the user explicitly asks to view them.
- If committing local configuration, include the value when it is part of the approved migrated file.

This supersedes earlier notes that said sub_fastwhisper-api_key must remain blank.

## User Customization Source Index

Use research/user-2025-customization-classification.md as the primary index for migration decisions. Do not treat the whole 2025 directory as user customization.

Classification from that document:

1. A / Must migrate: user-added scripts, VS presets, shaders, and other clear custom functionality. Verify whether each item exists in the 2026 target and whether references still load.
2. B / Review item by item: modified official configs, k7sfunc, uosc/input_plus, and root helper files. These must follow parameter-level diff approval; no whole-file overwrite.
3. C / Keep as reference only: old implementations replaced by 2026 or not safe to activate by default. Keep by rename/comment/sidecar only.
4. D / Ignore by default: runtime files, caches, binary dependencies, downloaded artifacts, and official-2025-missing items. Do not commit unless the user explicitly approves.

Execution meaning:
- A items are migration validation targets.
- B items are approval targets.
- C items are reference-only targets.
- D items are excluded by default.

## 当前主线计划

1. [x] 建立 2026FM 基线 git 提交。
2. [x] 迁移 2025 独有的小型配置、脚本、根目录工具文件。
3. [x] 合并 mpv.conf、profiles.conf。
4. [~] 审核 input_uosc.conf：当前文件仍需逐项复核，重点确认 2026 新快捷键、2025 自定义快捷键、shader/vs 路径均保留。
5. [x] 迁移 shaders/：保留 2026 原文件；同名 2025 文件以 _2025 留存。
6. [x] 迁移 portable_config/vs/：2025 独有预设复制；同名预设以 _2025 留存。
7. [~] 迁移 k7sfunc 兼容层：以 2026 模块化包为主，补齐 2025 自定义模型/函数引用，不恢复旧单文件为主入口。
8. [~] 审核额外插件：sub-fastwhisper.lua、sponsorblock_minimal.lua、mpv-torrserver.lua、recentmenu.lua。
9. [~] 审核 script-opts.conf：使用 2026 单文件结构，插件参数是否激活/注释需按插件审查结果确认。
10. [ ] 审核 uosc/、input_plus.lua、save_global_props.lua：原则上保留 2026，新功能不被 2025 覆盖。
11. [ ] 处理重复功能：contextmenu_plus vs 2026 uosc 内置菜单；thumbfast vs 2026 thumb_engine。
12. [ ] 最终验证：mpv 启动、脚本加载、B 站播放、VS 滤镜、shader 切换、uosc UI。

## k7sfunc 重点迁移策略

1. **当前有效入口**：2026 的 Lib/site-packages/k7sfunc/ 模块包是主入口；2025 根目录 k7sfunc.py 系列只作为参考和留存。
2. **迁移方式**：只把 2025 自定义 .vpy 实际引用、且 2026 缺失的模型编号或函数能力补进 2026 对应模块。
3. **已确认需要兼容的 RIFE 模型**：422、4221、4151 需要在 mod_memc.py 中保留支持，因为 2025 预设仍可能引用。
4. **待继续审查的模型/函数**：逐一扫描 portable_config/vs/、input_uosc.conf、profiles.conf 对 k7sfunc、模型编号、ESRGAN_*、WAIFU_*、RIFE_* 的引用，生成清单后再决定是否补兼容。
5. **ESRGAN/WAIFU 当前策略**：相关 .vpy 和历史引用保留，但活动引用先注释标注；不恢复 ESRGAN_DML、ESRGAN_NV、WAIFU_DML、WAIFU_NV 函数，除非用户审批。
6. **验证要求**：静态验证引用是否都有目标文件/函数；最终再用 mpv/VapourSynth 实际加载相关预设验证。

## 额外插件处理策略

1. **sub-fastwhisper.lua**：属于用户额外插件，已有上游更新线索；更新前需确认是否采用上游最新版，并保留本地参数，api_key 必须留空不提交。
2. **sponsorblock_minimal.lua**：属于用户额外插件，可低风险更新，但仍需用户确认后执行。
3. **mpv-torrserver.lua**：未找到可靠脚本上游，默认保留当前版本；TorrServer 二进制更新作为独立议题。
4. **recentmenu.lua**：未找到可靠上游，默认保留当前版本；如与 2026 uosc 交互冲突再处理。
5. **script-opts.conf**：插件参数按插件是否启用决定；不确定的参数先保留注释说明，不直接删除。

## 已决策记录

| # | 决策项 | 选择 | 理由 |
|---|--------|------|------|
| 1 | mpv.conf 合并策略 | 以 2026 为底，挑 2025 改动加回 | 保证新版参数不丢失，自定义选择性迁移 |

## 迁移分类

### 第一类：2025 独有、2026 不存在 → 直接复制

| 条目 | 路径 | 大小 |
|------|------|------|
| AI 语音模型 | `portable_config/faster-whisper-win/` | ~8 GB |
| LUT 色彩查找表 | `portable_config/luts/` | 小 |
| 自定义脚本 | `portable_config/scripts/bilibiliAssert/` | 小 |
| 自动加载字体 | `portable_config/scripts/auto_load_fonts.js` | 小 |
| 字幕字体目录 | `portable_config/scripts/auto_sub_fonts_dir.lua` | 小 |
| 输入事件 | `portable_config/scripts/inputevent.lua` | 小 |
| 管理器 | `portable_config/scripts/manager.lua` | 小 |
| TorrServer 集成 | `portable_config/scripts/mpv-torrserver.lua` | 小 |
| 播放列表 OSD | `portable_config/scripts/playlist_osd.lua` | 小 |
| 画质菜单 | `portable_config/scripts/quality-menu.lua` | 小 |
| 最近播放 | `portable_config/scripts/recentmenu.lua` | 小 |
| SponsorBlock | `portable_config/scripts/sponsorblock_minimal.lua` | 小 |
| 统计信息 | `portable_config/scripts/stats.lua` | 小 |
| 字幕转写 | `portable_config/scripts/sub-fastwhisper.lua` | 小 |
| 缩略图 | `portable_config/scripts/thumbfast.lua` | 小 |
| 字体配置 | `portable_config/fonts.conf` | 小 |
| 管理器数据 | `portable_config/manager.json` | 小 |
| 播放记录 | `portable_config/recent.json` | 小 |
| 保存属性 | `portable_config/saved-props.json` | 小 |
| 示例目录 | `portable_config/示例/` | 小 |
| 自定义字体 | `portable_config/fonts/LXGWWenKaiMono-Regular.ttf` | ~20 MB |
| cookies | `cookies.txt` | 小 |
| url-handler 配置 | `config.json`、`settings.json` | 小 |
| url-handler exe | `url-scheme-handler.exe` | 4.3 MB |
| TorrServer | `TorrServer-windows-amd64.exe` | 47 MB |
| TrueHD 补丁 | `truehdrtweaks.asi`、`.ini` | 小 |
| umpv 源码 | `umpv.py`、`umpv.spec` | 小 |
| 播放记录 | `viewed.json` | 小 |
| winmm 兼容层 | `winmm.dll` | 小 |
| k7sfunc 本地版 | `k7sfunc.py` 系列 | 小 |

### 第二类：两版都有 → diff 对比后决策

| 条目 | 2025 | 2026 | 说明 |
|------|------|------|------|
| `mpv.conf` | 33 KB，带注释 | 精简无注释 | 主配置文件 |
| `profiles.conf` | 4.3 KB | 精简版 | 预设配置 |
| `input_uosc.conf` | 37 KB | 精简版 | 快捷键 |
| `script-opts.conf` vs `script-opts/` | 43 KB + 20个独立文件 | 单文件内联 | 结构重组 |
| `scripts/uosc/` | 旧版 | 新版 | UI 框架 |
| `scripts/input_plus.lua` | 已修改 | 新版 | 输入增强 |
| `scripts/save_global_props.lua` | 已修改 | 新版 | 状态保存 |
| `fonts/LXGWWenKaiMono` | Regular | Lite | 字体变体 |
| `fonts/MaterialIconsRound` | v1 | v2 | 图标字体 |
| `fonts/uosc_textures.ttf` | v1 | v2 | UI 纹理 |

### 第三类：功能重复 → 需确认保留哪个

| 功能 | 2025 实现 | 2026 实现 | 问题 |
|------|-----------|-----------|------|
| 上下文菜单 | `contextmenu_plus.lua` | uosc 内置 | 是否还需要独立脚本？ |
| 缩略图 | `thumbfast.lua` | `thumb_engine/` | 是否需要两个？ |
| VapourSynth 预设 | 大量自定义 .vpy | 新版 k7sfunc (Lib 内) | 预设文件是否兼容？ |

### 第四类：2026 独有 → 保留不动

- `thumb_engine/`
- `menu.conf`
- `installer/` 新版安装脚本
- 所有根目录二进制（mpv.exe, dll, Python 3.14 等）

## 执行步骤（每次 commit 一个类别）

```
1. [git] 2026 目录 git init + 首次提交（基线）
2. [copy] 第一类中无争议的小文件直接复制
3. [compare] mpv.conf — 展示 diff，等用户决策
4. [compare] profiles.conf — 展示 diff，等用户决策
5. [compare] input_uosc.conf — 展示 diff，等用户决策
6. [compare] script-opts 结构 — 展示差异，等用户决策
7. [compare] uosc/ 版本 — 展示差异，等用户决策
8. [compare] input_plus.lua / save_global_props.lua — 展示 diff
9. [decide] contextmenu_plus.lua vs uosc 内置
10. [decide] thumbfast.lua vs thumb_engine
11. [copy] shaders/ — 2025 着色器迁移
12. [copy] vs/ — VapourSynth 预设迁移
13. [copy] 根目录额外文件
14. [copy] faster-whisper-win (8GB)
15. [verify] 测试启动 + 基本功能验证
```

## 验收标准

- [ ] `F:\mpv_2026\mpv-lazy` 可正常启动 mpv
- [ ] 自定义脚本全部加载无报错
- [ ] bilibili 番剧可正常播放
- [ ] 着色器/滤镜正常触发
- [ ] uosc 界面正常显示
- [ ] git log 显示清晰的迁移历史