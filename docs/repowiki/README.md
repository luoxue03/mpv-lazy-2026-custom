# Repowiki 知识库索引

`.qoder/repowiki/zh/content/` 是当前整合包的结构化知识库，适合按模块理解配置和脚本体系。它与 `docs/research/` 的区别是：这里偏系统说明，`docs/research/` 偏调查结论和决策记录。

## 重点入口

| 模块 | 文档 | 说明 |
|---|---|---|
| 项目总览 | [项目概述](../../.qoder/repowiki/zh/content/项目概述.md) | 整体结构入口 |
| 快速开始 | [快速开始](../../.qoder/repowiki/zh/content/快速开始.md) | 基础使用入口 |
| 核心配置 | [核心配置系统](../../.qoder/repowiki/zh/content/核心配置系统/核心配置系统.md) | mpv 主配置、脚本选项、快捷键、预设 |
| 快捷键/菜单 | [键盘映射和快捷键配置](../../.qoder/repowiki/zh/content/核心配置系统/键盘映射和快捷键配置.md) | `input.conf` / `input_uosc.conf` 相关 |
| AI 超分/补帧 | [AI超分辨率系统](../../.qoder/repowiki/zh/content/AI超分辨率系统/AI超分辨率系统.md) | RIFE、UAI、ARTCNN、VapourSynth 管道 |
| RIFE | [RIFE模型集成](../../.qoder/repowiki/zh/content/AI超分辨率系统/RIFE模型集成.md) | RIFE 模型和菜单相关 |
| VapourSynth | [VapourSynth处理管道](../../.qoder/repowiki/zh/content/VapourSynth处理管道/VapourSynth处理管道.md) | VS 插件、脚本、处理链 |
| 着色器 | [实时着色器系统](../../.qoder/repowiki/zh/content/实时着色器系统/实时着色器系统.md) | Anime4K、FSRCNNX、NVIDIA/AMD 着色器等 |
| 脚本扩展 | [脚本系统和扩展](../../.qoder/repowiki/zh/content/脚本系统和扩展/脚本系统和扩展.md) | Lua 脚本、弹幕、Trakt 等 |
| 弹幕 | [uOSC 弹幕系统](../../.qoder/repowiki/zh/content/脚本系统和扩展/uOSC%20弹幕系统.md) | `uosc_danmaku` 相关 |
| Trakt | [Trakt.tv 媒体跟踪系统](../../.qoder/repowiki/zh/content/脚本系统和扩展/Trakt.tv%20媒体跟踪系统.md) | trakt-scrobble 相关 |
| 性能调试 | [性能优化和调试](../../.qoder/repowiki/zh/content/性能优化和调试/性能优化和调试.md) | GPU、缓存、监控、故障排查 |
| 故障排除 | [故障排除和常见问题](../../.qoder/repowiki/zh/content/故障排除和常见问题.md) | 常见问题入口 |

## 当前修改中的 Repowiki 文档

这些文档在当前工作区有未提交变更，后续应作为单独 `docs` 类提交处理：

- `.qoder/repowiki/zh/content/AI超分辨率系统/AI超分辨率系统.md`
- `.qoder/repowiki/zh/content/AI超分辨率系统/RIFE模型集成.md`
- `.qoder/repowiki/zh/content/AI超分辨率系统/VapourSynth处理管道.md`
- `.qoder/repowiki/zh/content/VapourSynth处理管道/VapourSynth处理管道.md`
- `.qoder/repowiki/zh/content/实时着色器系统/Anime4K系列着色器.md`
- `.qoder/repowiki/zh/content/核心配置系统/MPV主播放器配置.md`
- `.qoder/repowiki/zh/content/核心配置系统/核心配置系统.md`
- `.qoder/repowiki/zh/content/核心配置系统/脚本选项配置.md`
- `.qoder/repowiki/zh/content/核心配置系统/键盘映射和快捷键配置.md`
- `.qoder/repowiki/zh/content/脚本系统和扩展/Lua脚本架构.md`
- `.qoder/repowiki/zh/content/脚本系统和扩展/uOSC 弹幕系统.md`

## 维护建议

- 如果 `.qoder/repowiki` 是工具生成的，优先用工具重建，不手工大改。
- 如果必须手工补充，建议只写“本整合包特有差异”，避免和上游文档重复。
- Repowiki 中的内容可作为导航和解释，但涉及性能结论时，以 `docs/research/` 的实测报告为准。
