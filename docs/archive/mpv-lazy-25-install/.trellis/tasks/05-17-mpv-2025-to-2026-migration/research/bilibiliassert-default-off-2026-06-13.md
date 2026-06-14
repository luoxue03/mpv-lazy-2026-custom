# bilibiliAssert 默认关闭记录（2026-06-13）

## 目标

让 `bilibiliAssert` 不再在文件加载后自动拉取并挂载弹幕，但保留 `b` 快捷键手动触发能力。

## 修改

- 文件：`F:/mpv_2026/mpv-lazy/portable_config/scripts/bilibiliAssert/main.lua`
- 新增配置项：`auto_load = false`
- `file-loaded` 事件仅在 `auto_load=true` 时注册。
- `b` 快捷键保持可用：如果尚未生成弹幕文件，会先执行 `assprocess()` 拉取；如果已加载，则执行开关。

## 验证

- 启动隐藏临时 mpv 实例验证脚本可加载。
- `script-binding bilibiliAssert/toggle` 返回 success。
- 日志未出现 Lua traceback。
- 空闲加载时没有出现“开火”日志。

## 截图日志说明

截图中的 `vapoursynth` 警告：

- `Frame requested during init! This is unsupported.`
- `Returning black dummy frame with 0 duration.`

来源是 `k7sfunc` 在滤镜初始化阶段读取 `input.get_frame(0)` 用于取色彩范围等 frame props。当前补帧已经生效，通常不代表滤镜失败；风险主要是初始化阶段拿到黑色 dummy frame 时，某些基于 frame props 的判断可能使用默认值。若画面颜色/范围正常，可以视为低风险警告。

截图中的 `ffmpeg` 网络错误：

- `Stream ends prematurely`
- `Will reconnect ... error=I/O error`

这是网络流提前断开/重连日志，和 RIFE 菜单本身不是同一问题。只要播放能继续，属于网络源波动；若频繁中断，则需要查 ytdl/网络源连接。
