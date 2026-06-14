# mpv_PlayKit 2025V2 (20250525) → 2026FM (20260510) 官方变更报告

数据来源: GitHub API `compare/20250525...20260510` (hooke007/mpv_PlayKit)

## 一、被删除的文件 (需特别关注)

| 文件 | 行数 | 影响 |
|------|------|------|
| **k7sfunc.py** | 3575行 | **单文件版移除**，已模块化到 `Lib/site-packages/k7sfunc/` |
| **contextmenu_plus.lua** | 787行 | uosc 已内置上下文菜单功能 |
| **contextmenu_plus.conf** | 20行 | 被 `context_menu.conf` 替代 |
| **thumbfast.lua** | 855行 | 被 `thumb_engine/` (5个新文件) 完全替代 |
| **playlist_osd.lua** | 682行 | 功能移除/整合 |
| **playlist_osd.conf** | 66行 | 配置移除 |
| **input_contextmenu_plus.conf** | 30行 | 整合进 uosc |
| **thumbfast.conf** | 40行 | 被 `thumb_engine.conf` 替代 |
| **AMD_CAS_RT.glsl** 等 | ~8个着色器 | 重构为 AMD/ 子目录下的新版本 |
| **AMD_FSR_*.glsl** | ~6个着色器 | 重构为 AMD/ 子目录下的 FSR1 系列 |
| **ArtCNN_C4F16_DS.glsl** / **ArtCNN_C4F32_DS.glsl** | 2个 | 移到 ArtCNN/ 子目录 |

## 二、新增文件

### 脚本层
| 文件 | 行数 | 说明 |
|------|------|------|
| **thumb_engine/** (5个文件) | 1854行 | **全新缩略图引擎**，替代 thumbfast |
| **uosc_addones/** (5个文件) | 1631行 | **全新 uosc 扩展** (VCS/属性菜单/着色器菜单/字幕菜单) |
| **stats_mediainfo.lua** | 807行 | 媒体信息统计 |
| **cover_art_fallback.lua** | 68行 | 封面回退 |
| **uosc/lib/fzy.lua** | 297行 | 模糊搜索库 |

### 配置层
| 文件 | 行数 | 说明 |
|------|------|------|
| **menu.conf** | 155行 | 上下文菜单配置 (替代 contextmenu_plus) |
| **context_menu.conf** | 6行 | 简化版上下文菜单配置 |
| **stats_mediainfo.conf** | 31行 | 媒体信息统计配置 |
| **thumb_engine.conf** | 66行 | 缩略图引擎配置 |
| **uosc_addones.conf** | 41行 | uosc 扩展配置 |
| **mpv-register.bat** | 24行 | 新版注册脚本 |
| **mpv-unregister.bat** | 22行 | 新版反注册脚本 |

### 着色器 (大量新增)
- **AA/** (10个文件): SMAA/FAAA/DLAA/CMAA2 抗锯齿新系列
- **ACNet/** (18个文件新增): arnet_b4~b64 系列，acnet3_gan/hdn
- **AMD/** (10个文件新增): FSR1 系列, BCAS, CAS_AIO
- **Canvas/** (11个文件新增): 旋转/缩放/裁剪/特效
- **DPID/** (2个文件): 新降噪算法
- **Deband/** (3个文件新增): hdeband_rgb, kgradfun, neo_f3kdb
- **Anime4K/** (2个新增): GAN_x2_UL, Restore_GAN_UL_CC

## 三、重要修改 (按影响程度排序)

| 文件 | 变更行 | 说明 |
|------|--------|------|
| **input_plus.lua** | **1016行** | **大规模重写** (+245行净增) |
| **script-opts.conf** | **513行** | 配置结构重大重组 |
| **uosc/Menu.lua** | 373行 | 菜单系统重大更新 |
| **uosc/TopBar.lua** | 204行 | 顶栏重写 |
| **uosc/main.lua** | 138行 | 主逻辑更新 |
| **uosc/Timeline.lua** | 112行 | 时间轴更新 |
| **script-opts/osc.conf** | 161行 | OSC配置大改 |
| **mpv.conf** | 42行 | 核心配置精简 |
| **script-opts/stats.conf** | 96行 | 统计配置更新 |
| **script-opts/console.conf** | 42行 | 控制台配置更新 |
| **uosc/lib/text.lua** | 87行 | 文本渲染更新 |
| **uosc/lib/utils.lua** | 104行 | 工具函数更新 |
| **stats.lua** | 96行 | 统计脚本更新 |
| **save_global_props.lua** | 4行 | 微调 |

## 四、着色器重组总结

2026 将所有着色器从**扁平结构**重组为 **35个子目录**的分类体系:
- 大量 renamed: 移动+重命名到子目录 (不动代码内容)
- 部分 removed: 旧版本被新实现取代 (AMD_CAS→AMD, FSR→FSR1)
- 大量 added: 全新着色器 (~160个)

## 五、对我们迁移的影响

| 影响 | 说明 | 建议操作 |
|------|------|----------|
| **k7sfunc.py 根文件** | 2025版已过时，2026用模块包 | 删除根目录的旧 k7sfunc.py (migration copy)，用 Lib/ 版本 |
| **contextmenu_plus.lua** | 功能已被 2026 uosc+menu.conf 替代 | 可以不迁移(已复制，但可能不需要激活) |
| **thumbfast.lua** | 被 thumb_engine 替代 | 2026 用 thumb_engine，thumbfast.lua 作为备选保留 |
| **playlist_osd.lua** | 上游已移除 | 如需保留，需手动维护兼容性 |
| **input_plus.lua** | 2026 新版有 **1016行变更** | **必须用 2026 版**，变化太大无法合并 |
| **script-opts.conf** | 513行重组 | **必须用 2026 版**，2025的独立目录script-opts/需决策 |
| **uosc/** | 几乎每个文件都更新了 | **必须用 2026 版** |
| **shaders 重组** | 扁平→子目录 | 当前迁移策略(2026版+2025独有入_from2025)合理 |