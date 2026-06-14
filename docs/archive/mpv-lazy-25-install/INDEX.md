# mpv-lazy 2025 安装目录文档快照

这是从 `D:\mpv-lazy-25_install` 复制到 2026 仓库的 Markdown 文档快照，用于保留 2025 自定义迁移过程、Trellis 工作流记录、调研材料和旧版说明。

## 复制范围

- 已包含：根目录 Markdown、`.trellis/`、`.claude/`、`mpv_PlayKit_clone/` 中的 Markdown。
- 已排除：Python 依赖包 `Lib/`、Git 子仓库 `external-player/`、`url-scheme-handler/`、`.git/`、`node_modules/`。
- 文件保留原相对路径，便于从旧会话或 Trellis 记录中按路径查找。

## 数量概览

- 根目录: 4 个 Markdown
- `.claude/`: 32 个 Markdown
- `.trellis/`: 70 个 Markdown
- `mpv_PlayKit_clone/`: 3 个 Markdown

## 关键入口

| 文档 | 说明 |
|---|---|
| [.trellis/tasks/05-17-mpv-2025-to-2026-migration/prd.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/prd.md>) | 2025 → 2026 迁移任务 PRD 和规则 |
| [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/user-2025-customization-classification.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/user-2025-customization-classification.md>) | 2025 用户自定义差异分类，迁移判断的重要依据 |
| [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/upstream-changelog.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/upstream-changelog.md>) | 上游 2025/2026 更新记录对比 |
| [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/realtime-model-research-2026-06-10.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/realtime-model-research-2026-06-10.md>) | 补帧/超分模型第一轮调研 |
| [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/realtime-model-research-followup-2026-06-10.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/realtime-model-research-followup-2026-06-10.md>) | 补帧/超分模型后续调研 |
| [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-runtime-menu-implementation-2026-06-13.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-runtime-menu-implementation-2026-06-13.md>) | RIFE 动态菜单实现记录 |
| [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-combination-matrix-2026-06-13.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-combination-matrix-2026-06-13.md>) | RIFE 模型/参数组合矩阵 |
| [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-cleanup-and-recommendations-2026-06-09.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-cleanup-and-recommendations-2026-06-09.md>) | 插件清理和推荐记录 |
| [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/shader-reference-check-2026-06-13.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/shader-reference-check-2026-06-13.md>) | 着色器引用检查 |

## 完整文件列表

- [.claude/agents/trellis-check.md](<.claude/agents/trellis-check.md>)
- [.claude/agents/trellis-implement.md](<.claude/agents/trellis-implement.md>)
- [.claude/agents/trellis-research.md](<.claude/agents/trellis-research.md>)
- [.claude/commands/trellis/continue.md](<.claude/commands/trellis/continue.md>)
- [.claude/commands/trellis/finish-work.md](<.claude/commands/trellis/finish-work.md>)
- [.claude/skills/trellis-before-dev/SKILL.md](<.claude/skills/trellis-before-dev/SKILL.md>)
- [.claude/skills/trellis-brainstorm/SKILL.md](<.claude/skills/trellis-brainstorm/SKILL.md>)
- [.claude/skills/trellis-break-loop/SKILL.md](<.claude/skills/trellis-break-loop/SKILL.md>)
- [.claude/skills/trellis-check/SKILL.md](<.claude/skills/trellis-check/SKILL.md>)
- [.claude/skills/trellis-meta/references/customize-local/add-project-local-conventions.md](<.claude/skills/trellis-meta/references/customize-local/add-project-local-conventions.md>)
- [.claude/skills/trellis-meta/references/customize-local/change-agents.md](<.claude/skills/trellis-meta/references/customize-local/change-agents.md>)
- [.claude/skills/trellis-meta/references/customize-local/change-context-loading.md](<.claude/skills/trellis-meta/references/customize-local/change-context-loading.md>)
- [.claude/skills/trellis-meta/references/customize-local/change-hooks.md](<.claude/skills/trellis-meta/references/customize-local/change-hooks.md>)
- [.claude/skills/trellis-meta/references/customize-local/change-skills-or-commands.md](<.claude/skills/trellis-meta/references/customize-local/change-skills-or-commands.md>)
- [.claude/skills/trellis-meta/references/customize-local/change-spec-structure.md](<.claude/skills/trellis-meta/references/customize-local/change-spec-structure.md>)
- [.claude/skills/trellis-meta/references/customize-local/change-task-lifecycle.md](<.claude/skills/trellis-meta/references/customize-local/change-task-lifecycle.md>)
- [.claude/skills/trellis-meta/references/customize-local/change-workflow.md](<.claude/skills/trellis-meta/references/customize-local/change-workflow.md>)
- [.claude/skills/trellis-meta/references/customize-local/overview.md](<.claude/skills/trellis-meta/references/customize-local/overview.md>)
- [.claude/skills/trellis-meta/references/local-architecture/context-injection.md](<.claude/skills/trellis-meta/references/local-architecture/context-injection.md>)
- [.claude/skills/trellis-meta/references/local-architecture/generated-files.md](<.claude/skills/trellis-meta/references/local-architecture/generated-files.md>)
- [.claude/skills/trellis-meta/references/local-architecture/overview.md](<.claude/skills/trellis-meta/references/local-architecture/overview.md>)
- [.claude/skills/trellis-meta/references/local-architecture/spec-system.md](<.claude/skills/trellis-meta/references/local-architecture/spec-system.md>)
- [.claude/skills/trellis-meta/references/local-architecture/task-system.md](<.claude/skills/trellis-meta/references/local-architecture/task-system.md>)
- [.claude/skills/trellis-meta/references/local-architecture/workflow.md](<.claude/skills/trellis-meta/references/local-architecture/workflow.md>)
- [.claude/skills/trellis-meta/references/local-architecture/workspace-memory.md](<.claude/skills/trellis-meta/references/local-architecture/workspace-memory.md>)
- [.claude/skills/trellis-meta/references/platform-files/agents.md](<.claude/skills/trellis-meta/references/platform-files/agents.md>)
- [.claude/skills/trellis-meta/references/platform-files/hooks-and-settings.md](<.claude/skills/trellis-meta/references/platform-files/hooks-and-settings.md>)
- [.claude/skills/trellis-meta/references/platform-files/overview.md](<.claude/skills/trellis-meta/references/platform-files/overview.md>)
- [.claude/skills/trellis-meta/references/platform-files/platform-map.md](<.claude/skills/trellis-meta/references/platform-files/platform-map.md>)
- [.claude/skills/trellis-meta/references/platform-files/skills-and-commands.md](<.claude/skills/trellis-meta/references/platform-files/skills-and-commands.md>)
- [.claude/skills/trellis-meta/SKILL.md](<.claude/skills/trellis-meta/SKILL.md>)
- [.claude/skills/trellis-update-spec/SKILL.md](<.claude/skills/trellis-update-spec/SKILL.md>)
- [.trellis/spec/backend/database-guidelines.md](<.trellis/spec/backend/database-guidelines.md>)
- [.trellis/spec/backend/directory-structure.md](<.trellis/spec/backend/directory-structure.md>)
- [.trellis/spec/backend/error-handling.md](<.trellis/spec/backend/error-handling.md>)
- [.trellis/spec/backend/index.md](<.trellis/spec/backend/index.md>)
- [.trellis/spec/backend/logging-guidelines.md](<.trellis/spec/backend/logging-guidelines.md>)
- [.trellis/spec/backend/quality-guidelines.md](<.trellis/spec/backend/quality-guidelines.md>)
- [.trellis/spec/frontend/component-guidelines.md](<.trellis/spec/frontend/component-guidelines.md>)
- [.trellis/spec/frontend/directory-structure.md](<.trellis/spec/frontend/directory-structure.md>)
- [.trellis/spec/frontend/hook-guidelines.md](<.trellis/spec/frontend/hook-guidelines.md>)
- [.trellis/spec/frontend/index.md](<.trellis/spec/frontend/index.md>)
- [.trellis/spec/frontend/quality-guidelines.md](<.trellis/spec/frontend/quality-guidelines.md>)
- [.trellis/spec/frontend/state-management.md](<.trellis/spec/frontend/state-management.md>)
- [.trellis/spec/frontend/type-safety.md](<.trellis/spec/frontend/type-safety.md>)
- [.trellis/spec/guides/code-reuse-thinking-guide.md](<.trellis/spec/guides/code-reuse-thinking-guide.md>)
- [.trellis/spec/guides/cross-layer-thinking-guide.md](<.trellis/spec/guides/cross-layer-thinking-guide.md>)
- [.trellis/spec/guides/index.md](<.trellis/spec/guides/index.md>)
- [.trellis/tasks/00-bootstrap-guidelines/prd.md](<.trellis/tasks/00-bootstrap-guidelines/prd.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/prd.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/prd.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/a-class-migration-audit.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/a-class-migration-audit.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/active-filter-model-validation.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/active-filter-model-validation.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/active-vs-path-validation.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/active-vs-path-validation.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/api-key-migration-rule.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/api-key-migration-rule.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/bilibiliassert-default-off-2026-06-13.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/bilibiliassert-default-off-2026-06-13.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/danmaku-area-and-static-rife-4-15-fix-2026-06-14.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/danmaku-area-and-static-rife-4-15-fix-2026-06-14.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/danmaku-style-and-trakt-auth-2026-06-10.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/danmaku-style-and-trakt-auth-2026-06-10.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/danmaku-trakt-fastwhisper-install-2026-06-10.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/danmaku-trakt-fastwhisper-install-2026-06-10.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/danmaku-trakt-fixes-2026-06-10.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/danmaku-trakt-fixes-2026-06-10.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/input-uosc-2026-baseline-audit.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/input-uosc-2026-baseline-audit.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/input-uosc-approval-result.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/input-uosc-approval-result.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/input-uosc-official-switch-result.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/input-uosc-official-switch-result.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/k7sfunc-no-mvt-std-compat-decision.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/k7sfunc-no-mvt-std-compat-decision.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/k7sfunc-vs-static-audit.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/k7sfunc-vs-static-audit.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-integration-result-2026-06-11.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-integration-result-2026-06-11.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/AmusementClub_vs-mlrt_README.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/AmusementClub_vs-mlrt_README.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/Astral-RTX-5090-OC---9950X3D---v3.2.2-build-(Smoothdeath).md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/Astral-RTX-5090-OC---9950X3D---v3.2.2-build-(Smoothdeath).md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/Benchmarks.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/Benchmarks.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/Home.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/Home.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/RTX-2080Ti---i5‐11400.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/RTX-2080Ti---i5‐11400.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/RTX-5070---12900k---v3.2.1-build.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/RTX-5070---12900k---v3.2.1-build.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/RTX-5070ti---Ryzen-7-9700X-(64GB-DDR5-5600Mhz).md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/RTX-5070ti---Ryzen-7-9700X-(64GB-DDR5-5600Mhz).md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/Setup-for-AMD-or-Intel-Arc-users.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/animejanai-wiki/Setup-for-AMD-or-Intel-Arc-users.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/HolyWu_vs-rife_README.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/HolyWu_vs-rife_README.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/hzwer_ECCV2022-RIFE_README.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/hzwer_ECCV2022-RIFE_README.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/hzwer_Practical-RIFE_README.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/hzwer_Practical-RIFE_README.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/styler00dollar_VSGAN-tensorrt-docker_README.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/styler00dollar_VSGAN-tensorrt-docker_README.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/the-database_mpv-upscale-2x_animejanai_README.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/model-research-sources/the-database_mpv-upscale-2x_animejanai_README.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/mpv-plugin-wide-search-2026-06-10.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/mpv-plugin-wide-search-2026-06-10.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/official-2025-vs-user-2025-diff.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/official-2025-vs-user-2025-diff.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-cleanup-and-recommendations-2026-06-09.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-cleanup-and-recommendations-2026-06-09.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-status-and-mainline-progress.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-status-and-mainline-progress.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-update-result.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-update-result.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-upstream-audit.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/plugin-upstream-audit.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/realtime-model-research-2026-06-10.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/realtime-model-research-2026-06-10.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/realtime-model-research-followup-2026-06-10.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/realtime-model-research-followup-2026-06-10.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-combination-matrix-2026-06-13.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-combination-matrix-2026-06-13.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-dynamic-menu-and-engine-cache-report-2026-06-13.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-dynamic-menu-and-engine-cache-report-2026-06-13.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-runtime-menu-implementation-2026-06-13.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-runtime-menu-implementation-2026-06-13.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-v2-model-and-danmaku-fps-fix-2026-06-14.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/rife-v2-model-and-danmaku-fps-fix-2026-06-14.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/runtime-validation-and-screenshot-menu-fix.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/runtime-validation-and-screenshot-menu-fix.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/script-opts-contextmenu-audit.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/script-opts-contextmenu-audit.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/shader-reference-check-2026-06-13.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/shader-reference-check-2026-06-13.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/trakt-complete-auth-and-vffps-2026-06-10.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/trakt-complete-auth-and-vffps-2026-06-10.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/ui-menu-hotkey-stats-fix.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/ui-menu-hotkey-stats-fix.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/upstream-changelog.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/upstream-changelog.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/user-2025-customization-classification.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/user-2025-customization-classification.md>)
- [.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/vf-menu-and-osd-style-fix.md](<.trellis/tasks/05-17-mpv-2025-to-2026-migration/research/vf-menu-and-osd-style-fix.md>)
- [.trellis/workflow.md](<.trellis/workflow.md>)
- [.trellis/workspace/index.md](<.trellis/workspace/index.md>)
- [.trellis/workspace/luoxue/index.md](<.trellis/workspace/luoxue/index.md>)
- [.trellis/workspace/luoxue/journal-1.md](<.trellis/workspace/luoxue/journal-1.md>)
- [AGENTS.md](<AGENTS.md>)
- [LICENSE.MD](<LICENSE.MD>)
- [mpv_PlayKit_clone/.github/ISSUE_TEMPLATE/错误报告.md](<mpv_PlayKit_clone/.github/ISSUE_TEMPLATE/错误报告.md>)
- [mpv_PlayKit_clone/LICENSE.MD](<mpv_PlayKit_clone/LICENSE.MD>)
- [mpv_PlayKit_clone/README.MD](<mpv_PlayKit_clone/README.MD>)
- [README.MD](<README.MD>)
- [RIFE-performance-investigation-2026-06-14.md](<RIFE-performance-investigation-2026-06-14.md>)
