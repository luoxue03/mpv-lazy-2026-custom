# sub-fastwhisper 使用说明

## 1. 介绍

`sub-fastwhisper.lua` 是 mpv AI 字幕脚本，用于调用 faster-whisper 生成字幕，并可调用兼容 OpenAI Chat Completions 结构的 API 将字幕翻译成目标语言。

当前整合包默认使用本地 `portable_config/faster-whisper-win/faster-whisper.exe`，模型为 `large-v3`，设备为 CUDA，翻译 API 默认配置为智谱 GLM 接口占位。

依赖/相关仓库：

- sub-fastwhisper 上游：https://github.com/dyphire/mpv-sub-fastwhisper
- faster-whisper Windows 构建参考：https://github.com/Purfview/whisper-standalone-win

## 2. 文件介绍

| 文件/目录 | 作用 |
|---|---|
| `portable_config/scripts/sub-fastwhisper.lua` | mpv 脚本入口，注册 `sub-fastwhisper` 和 `sub-translate` 消息。 |
| `portable_config/script-opts.conf` | 当前整合包集中配置 `sub_fastwhisper-*` 参数。 |
| `portable_config/faster-whisper-win/faster-whisper.exe` | faster-whisper 命令行程序；在完整 AI 包中提供，仓库不保存。 |
| `portable_config/faster-whisper-win/_models/` | faster-whisper 模型目录；完整 AI 包中提供，仓库不保存。 |
| 输出 `.srt` / `.translate.srt` / `.ass` | 生成的字幕文件，通常保存在源视频目录或脚本配置的输出目录。 |

## 3. 配置

配置集中在 `portable_config/script-opts.conf`，当前关键项：

```ini
script-opts-append = sub_fastwhisper-fast_whisper_path=portable_config/faster-whisper-win/faster-whisper.exe
script-opts-append = sub_fastwhisper-model=large-v3
script-opts-append = sub_fastwhisper-device=cuda
script-opts-append = sub_fastwhisper-compute_type=float16
script-opts-append = sub_fastwhisper-max_line_width=100
script-opts-append = sub_fastwhisper-output_path=source
script-opts-append = sub_fastwhisper-update_interval=20
script-opts-append = sub_fastwhisper-use_segment=no
script-opts-append = sub_fastwhisper-segment_duration=10
script-opts-append = sub_fastwhisper-api_url=https://open.bigmodel.cn/api/paas/v4/chat/completions
script-opts-append = sub_fastwhisper-api_key=YOUR_API_KEY_HERE
script-opts-append = sub_fastwhisper-api_mode=glm-4-flash
script-opts-append = sub_fastwhisper-api_rate=15
script-opts-append = sub_fastwhisper-translate=Chinese
script-opts-append = sub_fastwhisper-font_name=Noto Sans CJK SC
```

说明：

- `api_key` 必须本地填写，仓库和发布包中应保持 `YOUR_API_KEY_HERE` 或空值。
- `output_path=source` 表示字幕输出到视频同目录。
- `use_segment=yes` 可加快长视频首屏字幕生成，但可能降低整体准确性或增加切片复杂度。
- `device=cuda` 需要 NVIDIA GPU；无 CUDA 环境可改为 `cpu`，但速度会慢很多。

## 4. 使用

菜单入口：

```text
工具 > 生成 AI 字幕
```

当前 `input_uosc.conf` 中对应命令为：

```text
ALT+f script-message-to sub_fastwhisper sub-fastwhisper
```

注意：该快捷键当前在配置中是注释形式，菜单项仍可显示；如要直接用快捷键，可按需取消注释。

基础流程：

1. 打开视频。
2. 进入 `工具 > 生成 AI 字幕`。
3. 脚本调用 `faster-whisper.exe` 生成 `.srt`。
4. 如果配置了 `api_key`，脚本会继续翻译并生成 `.translate.srt` / `.ass`。
5. 生成完成后 mpv 自动加载字幕。

仅翻译已有字幕：

```text
script-message-to sub_fastwhisper sub-translate <字幕路径>
```

通常不需要手动执行，除非你在调试脚本。

## 5. 常见错误

### 点击生成字幕后没有反应

- `portable_config/faster-whisper-win/faster-whisper.exe` 不存在。
- 没有安装完整 AI 包。
- 脚本消息名称或菜单项未正确加载。

处理：确认完整安装 `base + ai + config`，并检查 mpv 控制台日志。

### CUDA 报错或速度极慢

- 显卡/驱动/CUDA 运行时不匹配。
- 当前模型过大。
- `device=cuda` 不可用时应改 `device=cpu` 测试。

处理：先用较小模型 `base` / `small` 验证，再切回 `large-v3`。

### 翻译失败

- `api_key` 没填或仍是 `YOUR_API_KEY_HERE`。
- API URL、模型名、额度或频率限制异常。
- 网络代理问题。

处理：确认 `api_url`、`api_mode`、`api_key`，并降低 `api_rate`。

### 字幕生成到错误目录

- `output_path=source` 会写到视频源目录；如果视频来自网络 URL，路径行为可能不符合预期。

处理：把 `output_path` 改为一个固定本地目录。

