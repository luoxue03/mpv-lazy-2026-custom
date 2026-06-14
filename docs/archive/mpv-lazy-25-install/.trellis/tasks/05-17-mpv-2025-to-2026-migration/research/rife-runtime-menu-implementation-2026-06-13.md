# RIFE 自定义参数动态菜单接入记录（2026-06-13）

## 目标

在不破坏现有 `input_uosc.conf` 补帧菜单结构的前提下，新增 `补帧 > RIFE 自定义参数` 动态入口，用于快速测试不同 RIFE 模型、`turbo` 与 `flow_scale` 组合，并支持保存/应用默认配置。

## 官方/本地依据

- `vs-mlrt` 官方 `RIFEMerge` 中按语义版本判断：`(model_major, model_minor) >= (4, 7) and scale != 1.0` 会直接拒绝。
- 当前本地 `vsmlrt.py` 的模型枚举显示 `4151=4.15_lite`、`422=4.22`、`4251=4.25_lite`、`426=4.26` 都按语义版本高于 4.7。
- 因此 `flow_scale=0.5/0.25` 目前只对 `4.6` 放开；其他模型菜单显示但禁用非 `1.0` 项，避免运行时报错。

## 修改文件

| 文件 | 作用 | 说明 |
|---|---|---|
| `F:/mpv_2026/mpv-lazy/Lib/site-packages/k7sfunc/mod_memc.py` | 修正 RIFE 版本判断 | 将 `model >= 47` 改为语义版本判断，避免数值 ID 误判；保留官方 4.7+ `flow_scale != 1.0` 限制。 |
| `F:/mpv_2026/mpv-lazy/portable_config/vs/MEMC_RIFE_NV_runtime.vpy` | 运行时 RIFE 入口 | 读取 `script-opts/rife_runtime.json`，动态调用 `k7f.RIFE_NV(...)`。 |
| `F:/mpv_2026/mpv-lazy/portable_config/scripts/rife_runtime_menu.lua` | uosc 动态菜单 | 提供模型、Turbo、flow_scale 三级选择；支持保存默认和应用默认。 |
| `F:/mpv_2026/mpv-lazy/portable_config/script-opts/rife_runtime.json` | 当前配置 | 默认 `4.6 / turbo=2 / flow_scale=1.0`。 |
| `F:/mpv_2026/mpv-lazy/portable_config/script-opts/rife_runtime_default.json` | 默认配置 | 默认 `4.6 / turbo=2 / flow_scale=1.0`。 |
| `F:/mpv_2026/mpv-lazy/portable_config/input_uosc.conf` | 菜单入口/快捷键 | 新增 `补帧 > RIFE 自定义参数` 与 `Ctrl+Alt+f` 应用默认配置。 |

## 当前模型接入范围

| 模型 | ID | flow_scale 可选 | 说明 |
|---|---:|---|---|
| RIFE 4.6 | 46 | `1.0` / `0.5` / `0.25` | 稳定通用；适合验证 4K 流畅降档。 |
| RIFE 4.15 lite | 4151 | 仅 `1.0` | 轻量旧模型；你之前常用 4.15 lite。 |
| RIFE 4.22 | 422 | 仅 `1.0` | 旧质量取向。 |
| RIFE 4.22 lite | 4221 | 仅 `1.0` | 旧轻量模型。 |
| RIFE 4.25 lite | 4251 | 仅 `1.0` | 你当前常用/测试的轻量模型。 |
| RIFE 4.26 | 426 | 仅 `1.0` | 较新质量取向。 |
| RIFE 4.26 heavy | 4262 | 仅 `1.0` | 重型模型，负载极高。 |
| RIFE 4.7 | 47 | 仅 `1.0` | 官方限制非 1.0 scale。 |
| RIFE 4.8 | 48 | 仅 `1.0` | 官方限制非 1.0 scale。 |
| RIFE 4.9 | 49 | 仅 `1.0` | 官方限制非 1.0 scale。 |

## 交互方式

- 菜单入口：`VF 滤镜 > 补帧 > RIFE 自定义参数`
- 快捷键：`Ctrl+Alt+f` 应用默认配置
- 默认配置：在动态菜单中选择“设置当前配置为默认”写入 `rife_runtime_default.json`
- 应用方式：菜单选择参数后写入 `rife_runtime.json`，并执行 `vf set vapoursynth=~~/vs/MEMC_RIFE_NV_runtime.vpy`

## 验证结果

- Python 编译检查通过：`mod_memc.py`、`MEMC_RIFE_NV_runtime.vpy`
- JSON 配置读取通过：`rife_runtime.json`、`rife_runtime_default.json`
- Lua 简单块结构检查通过：`rife_runtime_menu.lua`
- 模型文件检查通过：已接入模型的 ONNX 文件均存在；4.7/4.8/4.9 只有 `rife/` 路径；`turbo=2` 传入 `_implementation=2` 后，`vsmlrt` 会在缺少 `rife_v2` 文件时回退到 implementation 1，但这不等同于 2025 类快速路径，需要实测性能。

## 风险与后续验证

1. `turbo=2` 对 `4.7/4.8/4.9` 不一定是快速路径；底层可能回退到 implementation 1，菜单已提示，需要实测性能。
2. `turbo=0` 对 4.22+ / 4.25+ / 4.26+ 由于官方禁用 ensemble，菜单提示“实际接近 turbo=1”。
3. 播放中切换会重建 VapourSynth 滤镜链；首次使用新组合可能触发 TensorRT engine 编译，已有 engine 后会复用。

## 菜单结构调整（2026-06-13）

- `4.6` 保留 `Turbo -> flow_scale` 二次选择，可选 `1.0 / 0.5 / 0.25`。
- 其他 RIFE 模型不再显示 `flow_scale` 子菜单，选择 `Turbo` 后直接应用 `flow_scale=1.0`。
- 这样避免菜单里出现“不可选”项，也不暗示其他模型可以安全尝试 `flow_scale=0.5/0.25`。

