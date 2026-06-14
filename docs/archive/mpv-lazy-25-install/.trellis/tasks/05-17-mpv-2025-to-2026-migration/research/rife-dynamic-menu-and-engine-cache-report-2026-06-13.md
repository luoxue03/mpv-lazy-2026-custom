# RIFE 动态菜单与配置选择方案（2026-06-13，修正版）

## 1. 核心结论

动态菜单可以做，但不建议在选择时重写一个基础 `.vpy`。更稳的方案是：提前生成一组明确命名的测试配置文件，动态菜单只负责按用户选择映射到某个已有 `.vpy`。

这样做的优点：
- 每个组合都是可审计的固定文件。
- 不会因为运行时写文件失败或模板错误导致不可预期行为。
- Git 可以追踪每个测试配置。
- 菜单逻辑只做“选择 -> 应用”，不做“生成代码”。

## 2. 推荐目录结构

建议新增目录：

`portable_config/vs/rife_test/`

示例文件：

- `RIFE_4.15_lite_turbo2_flow1.0.vpy`
- `RIFE_4.15_lite_turbo1_flow1.0.vpy`
- `RIFE_4.15_lite_turbo1_flow0.5.vpy`
- `RIFE_4.15_lite_turbo1_flow0.25.vpy`
- `RIFE_4.6_turbo1_flow0.5.vpy`
- `RIFE_4.6_turbo2_flow1.0.vpy`

注意：`4.15_lite_turbo1_flow0.5/0.25` 需要先修正 `k7sfunc` 的 flow_scale 限制逻辑，否则当前会被拒绝。

## 3. 动态菜单怎么做

新增 Lua 脚本，例如：

`portable_config/scripts/rife-test-menu.lua`

脚本维护一个组合表：

```lua
local presets = {
  ["4.15_lite"] = {
    { title = "turbo=2 / flow=1.0（2025快速路径）", file = "~~/vs/rife_test/RIFE_4.15_lite_turbo2_flow1.0.vpy" },
    { title = "turbo=1 / flow=1.0（完整尺度）", file = "~~/vs/rife_test/RIFE_4.15_lite_turbo1_flow1.0.vpy" },
  },
}
```

用户选择后执行：

```lua
mp.commandv("vf", "set", "vapoursynth=" .. file)
```

或者用命令字符串：

```lua
mp.command('vf set vapoursynth="' .. file .. '"')
```

## 4. 是否需要重新编译

切换配置文件会重新初始化 VapourSynth 滤镜链。

TensorRT engine 是否重新编译取决于该组合对应的 engine 是否已存在：

- 已存在且匹配：直接复用。
- 不存在：第一次切换会编译。
- 参数不同：会生成不同 engine identity，需要单独编译一次。

当前 `vsmlrt.py` 会检查 `.engine` 文件是否存在且大于 `1024` 字节；满足则复用。

## 5. 实施建议

第一阶段：静态配置文件。

- 先生成 4.6、4.15_lite、4.25_lite 的核心测试 `.vpy`。
- 每个文件固定写死 `Model/Turbo/Flow_Scale`。
- 菜单可以先用 `input_uosc.conf` 静态入口。

第二阶段：动态菜单。

- 等确认组合有效后，再加 Lua 动态菜单。
- 动态菜单只列“已有配置文件”。
- 不做运行时写 `.vpy`。

## 6. 与组合矩阵的关系

组合状态和建议见：

`D:\mpv-lazy-25_install\.trellis\tasks\05-17-mpv-2025-to-2026-migration\research\rife-combination-matrix-2026-06-13.md`
