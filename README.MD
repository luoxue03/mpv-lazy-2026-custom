# mpv-lazy 2026 自定义整合包

这是基于 [hooke007/mpv_PlayKit](https://github.com/hooke007/mpv_PlayKit) 的 Windows 版 mpv-lazy 自定义整合包。

本仓库主要保存配置、脚本、菜单、VapourSynth 滤镜脚本、着色器和文档；完整可运行包请到 [Releases](https://github.com/luoxue03/mpv-lazy-2026-custom/releases) 下载。

## 项目定位

- 面向 Windows 10/11 的 mpv 播放器整合包。
- 以 `mpv_PlayKit` 2026 版为基础，迁移并整理了个人 2025 版配置。
- 重点强化 RIFE 补帧、AI 超分、着色器菜单、B 站/网页拉起播放、弹幕、AI 字幕等场景。
- 当前配置主要在 RTX 4080 SUPER 上调试，NVIDIA RTX 显卡优先。

## 快速下载

进入 [Releases](https://github.com/luoxue03/mpv-lazy-2026-custom/releases) 下载分类包。

完整安装通常需要：

1. `mpv-lazy-2026-custom-base-*.zip`
2. `mpv-lazy-2026-custom-ai-*.zip.001` 起始的所有 AI 分卷
3. `mpv-lazy-2026-custom-config-*.zip`

解压顺序：

1. 先解压 `base`。
2. 再用 7-Zip 解压 AI 的 `.001` 分卷到同一目录覆盖。
3. 最后解压 `config` 到同一目录覆盖。
4. 运行 `mpv-lazy-2026-custom\mpv.exe`。

如果只需要基础播放，可以只下载 `base`；如果已经完整安装，后续菜单、脚本、滤镜配置的小更新通常只需要下载 `config` 覆盖。

## 主要特性

- **RIFE 补帧**：整理了 4.6、4.7、4.8、4.9、4.15 lite、4.25 lite 等模型与菜单入口。
- **动态 RIFE 参数菜单**：支持模型、Turbo、flow_scale、H_Pre 等参数组合，并可保存默认配置。
- **AI 超分**：包含 UAI、AnimeJaNai、RealESRGAN、LiveAction、StarSample 等超分方案。
- **超分 + 补帧组合**：提供面向 720P/1080P 片源的组合预设。
- **着色器菜单**：整理 780+ GLSL 着色器，并按标准、动漫、真人/通用、组合等场景分类。
- **网页拉起播放**：包含 `external_player.js`，可配合 `url-scheme-handler` 从浏览器拉起 mpv。
- **弹幕与 B 站场景**：保留 bilibiliAssert，并接入 uosc_danmaku。
- **AI 字幕**：集成 sub-fastwhisper 相关配置和模型目录说明。
- **Trakt / Telegram Bridge**：保留相关脚本和文档，需自行授权或安装依赖。

## 仓库内容

本仓库不是完整运行包，主要包含：

- `portable_config/`：mpv 配置、脚本、菜单、VapourSynth `.vpy` 滤镜、着色器、字体。
- `docs/`：迁移记录、调研报告、RIFE benchmark HTML、文章草稿。
- `tools/`：RIFE benchmark、engine 预构建、RealESRGAN 导出、Telegram Bridge、Release 打包工具。
- `external_player.js`：网页端拉起 mpv 的脚本。
- `REPO_STRUCTURE.md`：更详细的目录结构与本地依赖说明。

完整目录解释见 [REPO_STRUCTURE.md](./REPO_STRUCTURE.md)。

## 不在仓库中的内容

为了安全和仓库体积，以下内容不会提交到 Git：

- `mpv.exe`、`yt-dlp.exe`、`url-scheme-handler.exe` 等二进制运行文件。
- Python / VapourSynth 运行时。
- `vs-plugins`、CUDA / TensorRT DLL、ONNX 模型等大型依赖。
- cookies、API key、Trakt token、播放历史、缓存和日志。

如果只是想使用整合包，请下载 Release，不要只克隆仓库。

## 使用前注意

- 建议解压到不含中文、空格和特殊符号的路径。
- 不建议直接覆盖旧版 mpv-lazy 目录，推荐新建目录解压。
- 首次使用 RIFE/AI 超分时可能会生成 TensorRT engine，耗时较长，属于正常现象。
- AI 字幕、Trakt、cookies、Telegram Bridge 等个人功能需要自行配置。
- 补帧和 AI 超分对显卡要求较高，低于 RTX 4070 的显卡可能需要选择更轻量的模型或关闭部分组合。

## 维护与发版

Release 打包脚本位于：

- `tools/release/package_release.py`
- `tools/release/smoke_test_mpv.py`
- `tools/release/README.md`

推荐流程：

1. 在本仓库修改配置、脚本或文档。
2. 使用 `package_release.py` 生成 `base / ai / config / docs` 分类包。
3. 使用 `smoke_test_mpv.py` 启动 mpv 播放本地视频，检查真实运行日志。
4. 确认无致命错误后，通过新 tag 发布 Release。

## 上游与致谢

本项目基于 `mpv_PlayKit` / `mpv-lazy` 进行个人定制：

- 上游仓库：[hooke007/mpv_PlayKit](https://github.com/hooke007/mpv_PlayKit)
- mpv：[mpv-player/mpv](https://github.com/mpv-player/mpv)
- VapourSynth：[vapoursynth/vapoursynth](https://github.com/vapoursynth/vapoursynth)

如果需要了解 mpv-lazy 的基础使用方式，请优先阅读上游说明与 Release 文档。

## 免责声明

这是个人自用配置整理后的公开留存版本，默认按我的使用场景和硬件偏好优化。不同显卡、驱动、视频源和网络环境下，补帧、超分、在线拉起播放等功能可能表现不同。

