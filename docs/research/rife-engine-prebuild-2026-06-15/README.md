# RIFE Engine 预构建记录（2026-06-15）

## 结论

- 有效组合：`136`
- 成功：`128`
- 失败：`8`
- 新生成 engine：`50`
- 当前非空 engine 总数：`55`
- 0 字节 engine：`0`
- 记录耗时合计：`81.5` 分钟

成功生成的 engine 位于 `vs-plugins/models/rife` 与 `vs-plugins/models/rife_v2`，可被后续 mpv/VapourSynth 播放实际复用；本目录只保存脚本日志与结果表。

## 按模型统计

| 模型 | ok | failed |
|---|---:|---:|
| `4.6` | `20` | `8` |
| `4.15 lite` | `12` | `0` |
| `4.22` | `12` | `0` |
| `4.22 lite` | `12` | `0` |
| `4.25 lite` | `12` | `0` |
| `4.26` | `12` | `0` |
| `4.26 heavy` | `12` | `0` |
| `4.7` | `12` | `0` |
| `4.8` | `12` | `0` |
| `4.9` | `12` | `0` |

## 失败组合

| 组合 | 原因 |
|---|---|
| `m46_4p6_t2_f0p5_h2160` | RIFEMerge tile size 约束；4.6 + turbo=2 + flow_scale<1 不适合当前 4K/H_Pre 预构建矩阵 |
| `m46_4p6_t2_f0p5_h1920` | RIFEMerge tile size 约束；4.6 + turbo=2 + flow_scale<1 不适合当前 4K/H_Pre 预构建矩阵 |
| `m46_4p6_t2_f0p5_h1608` | RIFEMerge tile size 约束；4.6 + turbo=2 + flow_scale<1 不适合当前 4K/H_Pre 预构建矩阵 |
| `m46_4p6_t2_f0p5_h1440` | RIFEMerge tile size 约束；4.6 + turbo=2 + flow_scale<1 不适合当前 4K/H_Pre 预构建矩阵 |
| `m46_4p6_t2_f0p25_h2160` | RIFEMerge tile size 约束；4.6 + turbo=2 + flow_scale<1 不适合当前 4K/H_Pre 预构建矩阵 |
| `m46_4p6_t2_f0p25_h1920` | RIFEMerge tile size 约束；4.6 + turbo=2 + flow_scale<1 不适合当前 4K/H_Pre 预构建矩阵 |
| `m46_4p6_t2_f0p25_h1608` | RIFEMerge tile size 约束；4.6 + turbo=2 + flow_scale<1 不适合当前 4K/H_Pre 预构建矩阵 |
| `m46_4p6_t2_f0p25_h1440` | RIFEMerge tile size 约束；4.6 + turbo=2 + flow_scale<1 不适合当前 4K/H_Pre 预构建矩阵 |

## 关键修正

- 静态 `MEMC_RIFE_NV_4.6_4K_scale0.5.vpy` 可用，因为它是 `4.6 + Turbo=1 + flow_scale=0.5`。
- 动态菜单已限制：只有 `4.6 > Turbo 1` 显示 `flow_scale=1 / 0.5 / 0.25`。
- `4.6 > Turbo 0/2` 只显示 `flow_scale=1`，避免误选失败组合。

## 文件

- `rife-engine-combos.csv`：全部组合预构建结果
- `summary.json`：机器可读摘要
- `monitor.log` / `monitor-status.json`：运行过程监控
- `logs/`：每个组合的 `.vpy`、stdout、stderr
