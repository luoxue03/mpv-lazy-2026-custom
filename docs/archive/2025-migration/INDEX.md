# 2025 → 2026 迁移文档精选索引

这里不是完整复制旧目录，而是按内容筛过后的精选归档：只保留能帮助理解 mpv-lazy 2025 → 2026 迁移、后续维护、RIFE/模型/插件决策的文档。

## 精简规则

- 保留：迁移 PRD、用户自定义分类、官方差异、配置/菜单/模型/插件/弹幕/RIFE 性能相关记录。
- 保留：少量外部资料快照，例如 `vs-mlrt`、RIFE、AnimeJaNai README/benchmark。
- 删除：Trellis/Claude 通用模板、空 journal、前后端示例 spec、bootstrap 指南、license、issue 模板、低相关硬件资料。
- 删除：正文已乱码、被更完整报告取代、或只适合工具自身维护的文档。
- 文件名已改为中文语义名，方便不看内容也能判断用途。

## 重点入口

| 文档 | 作用 |
|---|---|
| [迁移规则与PRD.md](<迁移规则与PRD.md>) | 本轮迁移原则、目标和审批规则 |
| [2025自定义内容分类.md](<research/2025自定义内容分类.md>) | 判断哪些是你的真实自定义，哪些只是版本差异 |
| [官方2025到2026更新日志.md](<research/官方2025到2026更新日志.md>) | 判断 2026 官方新增/删除内容 |
| [实时补帧超分模型调研.md](<research/实时补帧超分模型调研.md>) | RIFE / AnimeJaNai / 超分补帧调研主报告 |
| [RIFE自定义参数菜单接入.md](<research/RIFE自定义参数菜单接入.md>) | 动态 RIFE 菜单的实现依据 |
| [插件调研和主线进度.md](<research/插件调研和主线进度.md>) | 插件迁移和主线状态记录 |

## 迁移决策与差异

- [research/2025自定义内容分类.md](<research/2025自定义内容分类.md>) — User 2025 Customization Classification
- [research/API密钥迁移规则.md](<research/API密钥迁移规则.md>) — API Key Migration Rule
- [research/A类迁移审计.md](<research/A类迁移审计.md>) — A-Class Migration Audit
- [research/官方2025与本地2025差异.md](<research/官方2025与本地2025差异.md>) — Official 2025V2 vs User 2025 Local Diff Report
- [research/官方2025到2026更新日志.md](<research/官方2025到2026更新日志.md>) — mpv_PlayKit 2025V2 (20250525) → 2026FM (20260510) 官方变更报告
- [迁移规则与PRD.md](<迁移规则与PRD.md>) — mpv 2025 → 2026 版本迁移

## 配置与菜单验证

- [research/input_uosc切换官方结果.md](<research/input_uosc切换官方结果.md>) — input_uosc Official Switch Result
- [research/input_uosc审批结果.md](<research/input_uosc审批结果.md>) — input_uosc Approval Result
- [research/script-opts上下文菜单审计.md](<research/script-opts上下文菜单审计.md>) — script-opts contextmenu_plus Audit
- [research/UI菜单快捷键和统计修复.md](<research/UI菜单快捷键和统计修复.md>) — UI Menu, Hotkey, and Stats Fix
- [research/VF菜单和OSD样式修复.md](<research/VF菜单和OSD样式修复.md>) — VF Menu and OSD Style Fix
- [research/当前VS路径验证.md](<research/当前VS路径验证.md>) — Active VS Path Validation
- [research/当前滤镜模型验证.md](<research/当前滤镜模型验证.md>) — Active Filter Model Validation
- [research/着色器引用检查.md](<research/着色器引用检查.md>) — 着色器引用文件存在性检查（2026-06-13）
- [research/运行验证和截图菜单修复.md](<research/运行验证和截图菜单修复.md>) — Runtime validation and screenshot menu fix

## RIFE 与模型

- [research/k7sfunc不兼容MVT_STD决策.md](<research/k7sfunc不兼容MVT_STD决策.md>) — k7sfunc MVT_STD Compatibility Decision
- [research/k7sfunc静态引用审计.md](<research/k7sfunc静态引用审计.md>) — k7sfunc VS Static Audit
- [research/RIFE-v2模型和弹幕FPS修复.md](<research/RIFE-v2模型和弹幕FPS修复.md>) — RIFE v2 模型补齐与弹幕 fps 修复（2026-06-14）
- [research/RIFE动态菜单和Engine缓存方案.md](<research/RIFE动态菜单和Engine缓存方案.md>) — RIFE 动态菜单与配置选择方案（2026-06-13，修正版）
- [research/RIFE组合测试建议.md](<research/RIFE组合测试建议.md>) — RIFE 组合测试建议（2026-06-13，修正版）
- [research/RIFE自定义参数菜单接入.md](<research/RIFE自定义参数菜单接入.md>) — RIFE 自定义参数动态菜单接入记录（2026-06-13）
- [research/实时模型调研补充.md](<research/实时模型调研补充.md>) — 2026 实时模型调研补充：AnimeJaNai V3.1 与 RIFE 4K 补帧
- [research/实时补帧超分模型调研.md](<research/实时补帧超分模型调研.md>) — 2026 实时补帧 / 超分模型调研报告
- [research/模型接入结果.md](<research/模型接入结果.md>) — 模型接入结果：AnimeJaNai V3.1 与 RIFE 实验项

## 插件与弹幕

- [research/bilibiliAssert默认关闭.md](<research/bilibiliAssert默认关闭.md>) — bilibiliAssert 默认关闭记录（2026-06-13）
- [research/MPV插件广泛搜索.md](<research/MPV插件广泛搜索.md>) — MPV plugin wide search
- [research/Trakt完成授权和弹幕vf_fps.md](<research/Trakt完成授权和弹幕vf_fps.md>) — Trakt complete-auth binding and danmaku vf_fps
- [research/弹幕Trakt和fastwhisper安装.md](<research/弹幕Trakt和fastwhisper安装.md>) — Danmaku, Trakt, and fastwhisper install notes
- [research/弹幕和Trakt后续修复.md](<research/弹幕和Trakt后续修复.md>) — Danmaku and Trakt follow-up fixes
- [research/弹幕样式和Trakt授权状态.md](<research/弹幕样式和Trakt授权状态.md>) — Danmaku style sync and Trakt auth state
- [research/插件上游审计.md](<research/插件上游审计.md>) — Plugin Upstream Audit
- [research/插件更新结果.md](<research/插件更新结果.md>) — Plugin Update Result
- [research/插件清理和推荐.md](<research/插件清理和推荐.md>) — Plugin cleanup and recommendation research
- [research/插件调研和主线进度.md](<research/插件调研和主线进度.md>) — 插件调研与主线进度记录

## 外部资料快照

- [sources/AnimeJaNai-Benchmarks.md](<sources/AnimeJaNai-Benchmarks.md>) — Overview
- [sources/AnimeJaNai-RTX5070基准.md](<sources/AnimeJaNai-RTX5070基准.md>) — AnimeJaNai-RTX5070基准
- [sources/AnimeJaNai-RTX5090基准.md](<sources/AnimeJaNai-RTX5090基准.md>) — AnimeJaNai-RTX5090基准
- [sources/AnimeJaNai_README.md](<sources/AnimeJaNai_README.md>) — Upscaling Anime in mpv with 2x_AnimeJaNai V3
- [sources/ECCV2022-RIFE_README.md](<sources/ECCV2022-RIFE_README.md>) — Real-Time Intermediate Flow Estimation for Video Frame Interpolation
- [sources/MPV_lazy-2025-README.md](<sources/MPV_lazy-2025-README.md>) — mpv播放器折腾记录
- [sources/mpv_PlayKit-README.md](<sources/mpv_PlayKit-README.md>) — mpv播放器折腾记录
- [sources/Practical-RIFE_README.md](<sources/Practical-RIFE_README.md>) — Practical-RIFE
- [sources/vs-mlrt_README.md](<sources/vs-mlrt_README.md>) — vs-mlrt
- [sources/vs-rife_README.md](<sources/vs-rife_README.md>) — RIFE

总计保留 `44` 份内容文档。
