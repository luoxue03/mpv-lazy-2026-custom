# 发布打包与播放验证脚本

本目录包含两个独立脚本：

- `package_release.py`：生成 GitHub Release 用的分类压缩包。
- `smoke_test_mpv.py`：启动发布包里的 `mpv.exe` 播放视频，做真实播放冒烟验证。

两者职责不同：打包脚本负责“结构验证”，播放验证脚本负责“行为验证”。

## `package_release.py`：分类打包脚本

### 脚本用途

`package_release.py` 用于把完整 mpv-lazy 目录重新打成适合 GitHub Release 发布的分类包。

当前 `mpv-lazy-26_github` 仓库只保存配置、脚本、文档和工具源码，不保存 `mpv.exe`、Python 运行时、VapourSynth 插件、模型等大型依赖。打包时脚本会：

1. 复制一个已验证可运行的完整源目录。
2. 将当前 Git 仓库里的最新配置、脚本、文档覆盖进去。
3. 清理 cookies、日志、播放历史、Trakt token、缓存等不应发布的内容。
4. 拆分生成 `base / ai / config / docs` 四类压缩包。
5. 解压 `base + ai + config + docs` 到临时目录。
6. 检查关键文件是否存在，并验证 `VSPipe.exe` 和 `vapoursynth` 可用。
7. 生成 `SHA256SUMS-*.txt` 校验文件。

### 分类包说明

- `base`：基础可播放包，包含 `mpv.exe`、基础配置、脚本、着色器、文档、工具；不包含大型 AI/VapourSynth 依赖。
- `ai`：AI/VS 大包，包含 VapourSynth、TensorRT/CUDA、RIFE、UAI、RealESRGAN、AnimeJaNai、faster-whisper 等依赖；会自动分卷。
- `config`：小型配置更新包，包含菜单、脚本、快捷键、`.vpy` 滤镜和配置文件；后续只改配置时通常只发这个。
- `docs`：可选文档包，包含迁移记录、测试报告、RIFE benchmark HTML 和使用说明。

### 默认路径

- 配置仓库：当前仓库，即 `F:\mpv_2026\mpv-lazy-26_github`。
- 完整源目录：`F:\mpv_2026\_release_test`。
- 临时工作目录：`F:\mpv_2026\_release_package_work`。
- 输出目录：`F:\mpv_2026\_release_artifacts_split`。

脚本默认不使用 `F:\mpv_2026\mpv-lazy`，避免影响你日常使用的目录。

### 本地打包并验证

```bat
python tools\release\package_release.py
```

执行后会重新生成全部分类包，并自动解压验证。验证内容包括：

- `mpv.exe`、`portable.vs`、`VSPipe.exe`、`Lib`、`Scripts`、`vs-plugins`、`portable_config\vs` 等关键文件是否存在。
- `VSPipe.exe --version` 是否正常。
- 内置 Python 是否可以 `import vapoursynth`。
- 是否存在 cookies、Trakt token、播放历史、缓存等禁止发布文件。
- 是否出现本地敏感文本扫描列表中的内容。

### 发布到 GitHub Release

新发版：

```bat
python tools\release\package_release.py --version v2026.06.1 --upload
```

`--upload` 默认是“创建新 Release 并上传资产”。如果目标 tag 已存在，脚本会直接失败，避免误删旧资产。

如确实要修复已有 tag 的资产，必须显式加危险参数：

```bat
python tools\release\package_release.py --version v2026.06 --upload --replace-existing-assets
```

`--replace-existing-assets` 会删除已有 Release 的全部资产再重新上传，只应在紧急修复旧版本时使用。常规更新应使用新的 `--version`。

### 本地敏感文本扫描

如果要扫描 API key、token 或其他敏感值，新建本地文件：

```text
tools\release\forbidden_texts.local.txt
```

规则：

- 一行一个禁止出现的文本。
- `#` 开头的行视为注释。
- 该文件已被 `.gitignore` 忽略，只保留在本机，不会上传。
- 打包验证时脚本会自动读取这个文件。

也可以临时传入：

```bat
python tools\release\package_release.py --forbidden-text "YOUR_SECRET_VALUE"
set MPV_RELEASE_FORBIDDEN_TEXT=YOUR_SECRET_VALUE
```

### 常用参数

- `--source <path>`：指定另一个已验证完整源目录。
- `--artifacts <path>`：指定输出目录。
- `--work <path>`：指定临时工作目录。
- `--version <tag>`：指定发版 tag，例如 `v2026.06.1`。
- `--volume 2000m`：指定 AI 包分卷大小。
- `--skip-verify`：只打包，不解压验证。
- `--no-clean`：不清理旧工作目录和旧输出目录。
- `--upload`：创建 GitHub Release 并上传资产。
- `--replace-existing-assets`：允许替换已有 Release 的资产。
- `--forbidden-text <text>`：临时添加一个禁止出现的敏感文本。
- `--forbidden-text-file <path>`：从指定文件读取敏感文本列表。

## `smoke_test_mpv.py`：MPV 播放冒烟验证脚本

### 脚本用途

`smoke_test_mpv.py` 用于真实启动发布目录里的 `mpv.exe`，播放一个本地视频或 URL，生成日志并扫描致命错误。

它不参与打包流程，适合在正式发版前作为最后一道人工/半自动验证。

### 验证内容

脚本会扫描日志中的典型致命问题，例如：

- `Failed to initialize VSScript`
- `Creating filter 'vapoursynth' failed`
- `failed to create filter`
- `error parsing option`
- `script failed`
- `cannot load script`
- `lua error`
- `python exception`
- `traceback`
- `no such file or directory`

同时会列出部分警告，例如 `unknown key`、`deprecated`、`audio device underrun` 等，方便判断是否需要进一步检查。

### 基础播放验证

```bat
python tools\release\smoke_test_mpv.py --root F:\mpv_2026\_release_test --video "I:\Torren_DownloadFile\剑来\第二季\S02E25_4K.mp4"
```

默认行为：

- 启动 `--root` 下的 `mpv.exe`。
- 从 `--start=00:00:10` 开始播放。
- 播放 `20` 秒。
- 自动关闭 mpv。
- 在 release 根目录生成 `smoke-test-mpv.log`。
- 扫描日志并输出 fatal / warning 命中项。

### 验证指定 VF 滤镜

```bat
python tools\release\smoke_test_mpv.py --root F:\mpv_2026\_release_test --video "I:\Torren_DownloadFile\剑来\第二季\S02E25_4K.mp4" --vf "vapoursynth=~~/vs/MEMC_RIFE_NV_4.15_lite.vpy"
```

这个命令适合验证某个补帧、超分或超分补帧组合是否能被 mpv 实际加载。

### 手动观察模式

```bat
python tools\release\smoke_test_mpv.py --keep-open
```

`--keep-open` 会启动 mpv 后保持窗口打开，不自动关闭，适合肉眼观察画面、菜单、弹幕和 GPU 占用。

### 无窗口验证

```bat
python tools\release\smoke_test_mpv.py --no-window
```

`--no-window` 会加上 `--vo=null --ao=null`，不打开可见视频窗口。它适合快速检查脚本/配置是否初始化，但不适合判断画面效果、掉帧或 GPU 实际负载。

### 常用参数

- `--root <path>`：指定包含 `mpv.exe` 的发布包根目录。
- `--video <path-or-url>`：指定要播放的视频文件或 URL。
- `--seconds 30`：播放 30 秒后自动关闭。
- `--start 00:05:00`：从指定时间点开始播放。
- `--vf <value>`：指定要测试的 VF，例如 `vapoursynth=~~/vs/xxx.vpy`。
- `--profile <name>`：加载指定 mpv profile，可重复传入。
- `--log <path>`：指定日志输出路径。
- `--keep-open`：启动后不自动关闭。
- `--no-window`：不打开可见窗口。
- `--ignore-warning <text>`：忽略某类 warning，可重复传入。
- `--extra-arg <arg>`：追加任意 mpv 参数，可重复传入。

## 推荐发布前流程

1. 在 `mpv-lazy-26_github` 中完成配置或脚本修改。
2. 运行 `python tools\release\package_release.py` 生成并解压验证分类包。
3. 用 `smoke_test_mpv.py` 对解压后的完整包做基础播放验证。
4. 如果改过 VF、模型或 `vs-plugins`，再用 `--vf` 验证一个补帧/超分组合。
5. 确认无 fatal 后，用新的 `--version` 执行 `--upload` 发版。

