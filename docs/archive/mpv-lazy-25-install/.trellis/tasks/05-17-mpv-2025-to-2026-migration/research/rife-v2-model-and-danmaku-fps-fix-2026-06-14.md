# RIFE v2 模型补齐与弹幕 fps 修复（2026-06-14）

## 问题

1. 选择 `4.7/4.8/4.9 + turbo=2` 时，`k7sfunc.RIFE_NV` 会到 `vs-plugins/models/rife_v2/` 查找模型，但本地缺少对应 v2 ONNX，导致 `模块 RIFE_NV 所请求的模型缺失`。
2. RIFE 动态菜单重复选择同一 runtime vpy 时，mpv 不一定重建 VapourSynth 滤镜链，表现为“显示已加载但不生效”。
3. `uosc_danmaku` 的 `vf_fps=yes` 已开启，但旧 RIFE 菜单用 `vf set` 会清掉既有 `@danmaku:fps`，导致弹幕平滑滤镜可能丢失。

## 修复

- 从官方 `rife_v2_v4.7z` 解压以下模型到 `F:/mpv_2026/mpv-lazy/vs-plugins/models/rife_v2/`：
  - `rife_v4.7.onnx`
  - `rife_v4.8.onnx`
  - `rife_v4.9.onnx`
- 修改 `portable_config/scripts/rife_runtime_menu.lua`：
  - `4.7/4.8/4.9` 标记 `v2=true`。
  - 应用配置时先移除 `@rife_runtime`，再 append `@rife_runtime:vapoursynth=...`，强制重建滤镜链。
  - 如果应用前存在 `@danmaku:fps`，先移除，再在 RIFE 后恢复，确保滤镜顺序为 RIFE -> danmaku fps。
  - 修复 `opts` 未初始化导致脚本第一次应用后崩溃的问题。

## 弹幕显示配置

`uosc_danmaku.conf` 当前已与 `bilibiliAssert` 主要显示参数对齐：

- `vf_fps=yes`
- `fontname=SimHei`
- `fontsize=16`
- `opacity=0.55`
- `displayarea=0.95`
- `scrolltime=10`
- `fixtime=5`
- `bold=yes`
- `outline=1`
- `shadow=0`

## 验证

通过隐藏临时 mpv + IPC 验证：

- 手动添加 `@danmaku:fps=fps=60/1.001` 后选择 `4.7 + turbo=2`，vf 链为 `@rife_runtime` + `@danmaku:fps`。
- 再选择 `4.6 + turbo=2`，vf 链仍为 `@rife_runtime` + `@danmaku:fps`。
- 日志无 Lua traceback。
- 日志无 `所请求的模型缺失`。
- 日志无 `Can't find script 'rife_runtime_menu'`。
