# 文档索引

这是当前 mpv-lazy 2026 自定义整合包的文档入口。目标是把“可直接操作的结论”“深度调查过程”“自动生成知识库”和“Trellis 迁移记录”分开，避免以后继续迁移时找不到上下文。

## 快速入口

| 文档 | 内容 | 适合什么时候看 |
|---|---|---|
| [RIFE/TensorRT 性能调查与修复](research/RIFE-performance-investigation-2026-06-14.md) | 记录 RIFE 4.15 lite 丢帧、TensorRT 10.16 回退到 10.13 的测试和结论 | 排查补帧丢帧、回滚/升级 vs-mlrt、解释为什么选 TensorRT 10.13 |
| [TensorRT 深度调研参考](research/deep-research-report.md) | 外部/深度调研汇总，作为假设和后续验证参考 | 需要继续拆 TensorRT 性能根因时 |
| [调研报告索引](research/README.md) | 本仓库内手工研究报告的目录和阅读顺序 | 想按主题追溯决策过程时 |
| [Repowiki 知识库索引](repowiki/README.md) | `.qoder/repowiki` 自动/半自动知识库的导航 | 想按模块理解 mpv-lazy 配置体系时 |
| [2025 迁移文档精选](archive/2025-migration/INDEX.md) | 按内容筛选后的 2025→2026 迁移记录 | 追溯 2025 自定义、迁移规则、模型和插件决策时 |
| [README.MD](../README.MD) | 上游 mpv_PlayKit / mpv-lazy 原始说明入口 | 查官方使用说明和上游链接时 |

## 当前主线结论

- 2026 整合包的主线目标是：以 2026 版本为基底，保留 2025 本地自定义模型、滤镜、菜单和脚本配置。
- RIFE 4.15 lite 满高 4K 丢帧的当前落地方案是：全局使用 `vs-mlrt v15.13 / TensorRT 10.13.0`，替代原 2026 的 `TensorRT 10.16`。
- RIFE 自定义菜单已加入 `H_Pre / 处理高度`，用于在画质和实时性能之间切换。
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
