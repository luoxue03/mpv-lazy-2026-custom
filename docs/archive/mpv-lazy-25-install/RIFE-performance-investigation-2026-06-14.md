# RIFE 4.15 lite 丢帧调查与修复记录（2026-06-14）

## 现象

- 2025 版使用 `MEMC_RIFE_NV_4.15_lite.vpy` 播放同类 4K 内容更稳。
- 2026 版使用同名 4.15 lite 模型播放在线 4K 内容会出现丢帧。
- 本地 `S02E25_4K.mp4` 测试不丢帧的一个关键原因是：它实际是 `3840x1608`，不是满高 `3840x2160`。
- 在线源截图显示视频轨为 `3840x2160 / 25 fps / HEVC Main10 / d3d11va-copy`，处理压力明显高于本地 `3840x1608`。

## 已排除的主因

- `uosc_danmaku` 不是主因：你确认添加弹幕插件前，2026 版也已经会丢帧。
- 模型文件不是主因：2025/2026 的 `rife_v4.15_lite.onnx` hash 完全一致。
- 静态 `.vpy` 表面配置不是主因：2026 版已经把旧版 `turbo=True` 语义显式写成 `turbo=2`。

## TensorRT 调研结论

目前不能严谨地说“已经查明 TensorRT 内部某个具体改动导致性能下降”。更准确的结论是：

- 官方 release 显示，2025 使用的 `vs-mlrt v15.11` 升级到 TensorRT `10.11.0`；2026 使用的 `vs-mlrt v15.16` 升级到 TensorRT `10.16.0`，同时升级到 CUDA `13.2.0`，并包含 `vstrt`、`vsmlrt.py`、构建脚本等多处变更。
- 本机实测显示：同一 RIFE 4.15 lite ONNX、同一 `turbo=2` 快速路径下，2026 栈在 `3840x2160` 满高 4K 场景比 2025 栈慢，慢到低于实时安全余量。
- `vs-mlrt` issue 72 的维护者评论证明：RIFE + TensorRT 曾出现过 NVIDIA/TensorRT 层面的兼容与性能回归；维护者曾提到怀疑 `/GridSample_3` 相关计算图被拆到 worker stream，破坏算子融合。但这是历史 issue 中的判断，不能直接等同于本机 10.16 下 4.15 lite 的最终根因。
- 因此当前根因只能写为：`vsmlrt/TensorRT/CUDA` 新栈与 RIFE 4.15 lite 满高 4K 的性能组合不如 2025 旧栈；具体是 TensorRT 10.16 内部优化、`vstrt` 调度、`vsmlrt.py` 参数、CUDA 13.2，还是多因素叠加，尚未单独拆分验证。

## 关键差异

| 项目 | 2025 版 | 2026 版 |
|---|---|---|
| `vsmlrt.py` | `3.22.21` | `3.22.38` |
| `trtexec` | TensorRT `v101100` | TensorRT `v101600` |
| `vstrt.dll` | 2025-05-15 版本 | 2026-03-26 版本 |
| `vs-mlrt release` | `v15.11`，TensorRT `10.11.0` | `v15.16`，TensorRT `10.16.0`，CUDA `13.2.0` |
| `mpv` | 较旧 FFmpeg/libplacebo 构建 | 更新构建 |

## 基准结果

测试方式：同一台机器、同一 RIFE 4.15 lite 模型、同样 `turbo=2` 快速路径语义，直接请求 VapourSynth 输出帧。

| 场景 | 2025 版 | 2026 版 | 结论 |
|---|---:|---:|---|
| `3840x1608` | 约 `68 output fps` | 约 `56 output fps` | 2026 版慢约 17% |
| `3840x2160` | 约 `54 output fps` | 约 `47 output fps` | 2026 版满高 4K 低于 50fps 安全线 |
| `3840x2160, sc_mode=0` | 约 `55 output fps` | 约 `49 output fps` | 关闭场景检测只小幅改善 |
| `3840x2160, H_Pre=1920` | 未重点测试 | 约 `58 output fps` | 2026 版恢复实时余量 |
| `3840x2160, H_Pre=1608` | 未重点测试 | 约 `82 output fps` | 余量明显，但细节下降更多 |
| `3840x2160, H_Pre=1440` | 未重点测试 | 约 `104 output fps` | 极限流畅档，画质损失风险更高 |

## H_Pre / 处理高度含义

`H_Pre` 是进入 RIFE 前的预处理高度。源视频如果高于 `H_Pre`，会先按原始宽高比缩小，再送入 RIFE 补帧；补帧后再交给 mpv 渲染链显示。它不是显示器输出分辨率，而是“RIFE 实际处理的工作分辨率”。

以在线满高 `3840x2160` 为基准，处理高度对应关系如下：

| H_Pre | RIFE 处理尺寸约为 | 像素量占满高 4K | 计算量降低 | 单边线性分辨率 |
|---:|---:|---:|---:|---:|
| `2160` | `3840x2160` | `100.00%` | `0.00%` | `100.00%` |
| `1920` | `3412x1920` | `78.98%` | `21.02%` | `88.89%` |
| `1608` | `2858x1608` | `55.41%` | `44.59%` | `74.44%` |
| `1440` | `2560x1440` | `44.44%` | `55.56%` | `66.67%` |

## 质量损失是否已量化

还没有完成可靠的内容级质量量化。当前只有“处理像素量/算力压力”的精确数字，还没有“画质下降百分之几”的可靠数字。

原因：

- `H_Pre=1920` 的质量损失取决于片源细节、线条密度、锐化、噪声、字幕/边缘、以及最后 mpv 渲染器上采样方式；不能只用一个固定百分比描述。
- PSNR/SSIM/VMAF 可以测，但必须基于同一段实际内容，把 `H_Pre=2160` 输出当参考，再比较 `H_Pre=1920/1608/1440` 输出；目前还没有对在线满高 4K 片段完成这一步。
- 直观预期：`1920` 是轻降档，像素量减少约 21%，线性分辨率保留约 88.9%；`1608` 和 `1440` 会明显牺牲更多细节。


## A/B 组件定位结果

为避免污染主目录，已在 `F:\mpv_2026\mpv-lazy\_perf_ab\` 下建立临时沙盒测试。测试对象固定为 RIFE 4.15 lite、`3840x2160`、`turbo=2`、`H_Pre=2160`。

| 实验组合 | `vstrt.dll` | `vsmlrt-cuda / TensorRT库` | `vsmlrt.py` | 结果约值 | 判断 |
|---|---|---|---|---:|---|
| 2026 原始 | 2026 / v15.16 | 2026 / TensorRT 10.16 | 2026 / 3.22.38 | `48.3 output fps` | 慢 |
| 2026 + 2025 整套 TRT | 2025 / v15.11 | 2025 / TensorRT 10.11 | 2026 / 3.22.38 | `52.9 output fps` | 恢复实时余量 |
| 2026 `vstrt.dll` + 2025 `vsmlrt-cuda` | 2026 / v15.16 | 2025 / TensorRT 10.11 | 2026 / 3.22.38 | `53.1 output fps` | 主要性能跟 TensorRT 库走 |
| 2025 `vstrt.dll` + 2026 `vsmlrt-cuda` | 2025 / v15.11 | 2026 / TensorRT 10.16 | 2026 / 3.22.38 | `49.0 output fps` | 仍接近新版慢速表现 |
| 2026 TRT + 2025 `vsmlrt.py` | 2026 / v15.16 | 2026 / TensorRT 10.16 | 2025 / 3.22.21 | 约 `45 output fps` 左右 | 不能恢复，脚本层不是主因 |

结论：本机这次 RIFE 4.15 lite 满高 4K 性能下降，主要跟 `vsmlrt-cuda` 中的 TensorRT 10.16 库相关，而不是模型文件、菜单配置、`vstrt.dll` 单独版本或 `vsmlrt.py` 单独版本。

注意：混搭 `vstrt.dll` 与 `vsmlrt-cuda` 会出现 TensorRT version mismatch 警告，只适合定位，不建议作为发布方案。若要做兼容方案，应使用 2025 `vstrt.dll + vsmlrt-cuda` 成套隔离，不要半混搭。
## 当前根因判断

最可能的工程解释是：2026 新栈在 RIFE 4.15 lite 满高 4K 下吞吐不足，在线 `3840x2160` 刚好把它推过实时边界；本地 `3840x1608` 压力较低，所以不明显。

不建议现在直接全局回退 2026 的 `vsmlrt-cuda`，因为这可能影响 4.7/4.8/4.9、DRBA、AnimeJaNai 等新组件。更安全的策略是先用 `H_Pre` 建立可选性能档，必要时再做独立的旧 TensorRT 兼容实验。

## 已采取的修复

- 新增静态预设：`portable_config/vs/MEMC_RIFE_NV_4.15_lite_4K_H1920.vpy`
  - 保留 RIFE 4.15 lite。
  - 保留 `turbo=2` 快速路径。
  - 将 `H_Pre` 从 `2160` 改为 `1920`，降低满高 4K 的处理压力。
- 动态 RIFE 菜单新增 `选择处理高度`：
  - `2160`：原始 4K 高度，画质优先，2026 版满高可能低于实时。
  - `1920`：在线满高 4K 推荐流畅档，像素量减少约 21%。
  - `1608`：宽银幕 4K 等效高度，像素量减少约 45%。
  - `1440`：2K 处理高度，像素量减少约 56%。
- 当前动态默认配置已设为：`4.15 lite / turbo=2 / H_Pre=1920`。

## 后续建议

1. 先测试菜单中的 `4.15 lite 4K流畅（满高4K→1920P处理）` 在线源。
2. 如果仍然丢帧，在 RIFE 自定义参数菜单里把 `H_Pre` 切到 `1608`。
3. 如果 `H_Pre=1920` 流畅但你觉得画质不满意，再做实际片段的 `H_Pre=2160` vs `1920` 截帧对比和 PSNR/SSIM/VMAF 测试。
4. 如果你想追究性能根因到组件级，需要做 A/B：2026 配置 + 2025 `vsmlrt.py/vstrt.dll/vsmlrt-cuda` 独立兼容目录，逐个替换验证，而不是直接覆盖主目录。


## vsmlrt-cuda 细分定位（2026-06-14 追加）

进一步在 `_perf_ab` 沙盒中拆分 `vsmlrt-cuda` 后，结论如下：

| 实验组合 | 结果 | 说明 |
|---|---:|---|
| 2026 原始全套 TensorRT 10.16 | 约 `48.3 output fps` | 慢速基准 |
| 2025 `vstrt.dll + vsmlrt-cuda` 成套 | 约 `52.9 output fps` | 恢复实时余量 |
| 2026 `vstrt.dll` + 2025 TensorRT 核心 DLL 族 | 约 `52.2 output fps`，但有 mismatch 警告 | 可定位，不建议发布 |
| 2025 `vstrt.dll` + 2025 TensorRT 核心 DLL 族 + 保留 2026 其它 CUDA/cuDNN 文件 | 约 `53.1 output fps` | 小兼容包可行 |
| 只替换 `trtexec.exe` | 约 `48.3 output fps` | 不是主因 |
| 只替换旧 `nvinfer_10.dll` 或部分核心 DLL | 构建失败或不稳定 | TensorRT 核心 DLL 需要成套 |
| 只替换 builder resource / CUDA math / cuDNN 组 | 接近 2026 慢速表现 | 不是主要恢复点 |

更细判断：

- 性能恢复跟 `TensorRT 10.11` 核心 DLL 族走，尤其是 `nvinfer_10.dll` 及其匹配的 builder/plugin/parser/dispatch/lean 相关 DLL。
- `trtexec.exe` 只是调用入口，单独替换不能恢复性能。
- `vstrt.dll` 最好与 TensorRT 核心 DLL 版本匹配；混搭虽然能跑，但会输出 `TensorRT version mismatch`，不适合发布。
- 因此推荐的兼容方案不是“覆盖主目录”，而是为旧 RIFE 4.15 lite 建立独立 TensorRT 10.11 兼容运行时目录，使用成套旧 `vstrt.dll + TensorRT 核心 DLL 族`。

## 已知问题与外部线索

- 在 `AmusementClub/vs-mlrt` 中未搜到专门针对 `TensorRT 10.16 + RIFE 4.15 lite` 的公开 issue 或修复。
- 在 `NVIDIA/TensorRT` 中未搜到完全对应本机 RIFE 4.15 lite 性能回归的公开 issue。
- 但 TensorRT 仓库存在多个 GridSample / fusion / TensorRT 10.16 相关问题，例如 `NVIDIA/TensorRT#4804` 提到 TensorRT 10.16 中关闭部分 fusion 的需求，`NVIDIA/TensorRT#4646` 提到 GridSample 在特定 opset 下输出错误。这些只能作为“TensorRT 相关算子/融合仍有风险”的旁证，不能直接证明本机 RIFE 性能下降的内部原因。
- `vs-mlrt` 历史 issue 72 中维护者曾提到 RIFE + TensorRT 的性能回归可能与 `/GridSample_3` 被拆到 worker stream、破坏算子融合有关；这与当前现象方向相符，但不是针对 TensorRT 10.16 的直接结论。

## TensorRT 10.16 升级内容与必要性

从 `NVIDIA/TensorRT v10.16` 和 `AmusementClub/vs-mlrt v15.16` release 摘要看：

- TensorRT 10.16 的公开摘要重点包括：默认 CUDA 更新到 `13.2`、新增 `sampleDistCollective`、新增 `DistCollective` operator、多设备执行相关能力、ONNX parser 增加 `kADJUST_FOR_DLA` flag。
- `vs-mlrt v15.16` 对比 `v15.15`：升级 TensorRT `10.16.0`、TensorRT-RTX `1.4`、CUDA `13.2.0`。
- 这些升级对我们的 RIFE 4.15 lite / RTX 4080 SUPER 本地播放链路没有明显必需收益。
- 回退到 TensorRT 10.11 可能损失：较新 TensorRT 的 parser 支持、DLA / 多设备 / 新硬件支持、TensorRT-RTX 相关更新、未来模型兼容性。但对当前已验证的 RIFE 4.15 lite 播放性能，10.11 更合适。
- 不建议全局回退 2026 主目录，因为 DRBA、AnimeJaNai、RIFE 4.7/4.8/4.9、未来模型可能依赖新栈；建议只对旧 RIFE 4.15 lite 建独立兼容路径。

## 我们是否能独立解决

能力分三层：

1. **能做，且建议做**：工程级兼容方案。建立独立 TensorRT 10.11 运行时目录，给 RIFE 4.15 lite 或旧模型专用，避免影响 2026 新模型。
2. **可以尝试，但不保证**：参数级规避。尝试 TensorRT builder 参数、tactic source、`use_cuda_graph`、`builderOptimizationLevel`、`maxAuxStreams`、`precisionConstraints` 等组合，看能否让 10.16 生成更快 engine。
3. **不现实或成本很高**：真正修 TensorRT 内部性能回归。需要 NVIDIA TensorRT 源码不可见部分、Nsight profiling、最小复现 ONNX、向 NVIDIA 报 issue 等。我们可以准备复现材料，但很难本地直接修复黑盒 TensorRT 编译器/融合策略。

推荐路线：先实现工程级兼容路径；如果你仍想追根因，再导出最小 RIFE 4.15 lite `trtexec` 复现包，向 `NVIDIA/TensorRT` 或 `AmusementClub/vs-mlrt` 提 issue。

## 参数级规避测试（2026-06-14 追加）

参考 `deep-research-report.md` 后，实际可低成本验证的参数包括：`num_streams`、`workspace`、`use_cublas`、`use_cudnn`、`use_cuda_graph`、`max_aux_streams` 等。注意：当前 RIFE 4.15 lite 在 `turbo=2` 下本来就是静态 shape + CUDA Graph 路径，所以“静态 shape”不是额外新增优化。

在纯 2026 TensorRT 10.16 沙盒中测试满高 `3840x2160`、RIFE 4.15 lite、`turbo=2`：

| 参数组合 | 结果约值 | 结论 |
|---|---:|---|
| baseline | `46.0 output fps` | 慢速基准 |
| `num_streams=1` | `46.4 output fps` | 仅小幅提升 |
| `workspace=4096` | `46.6 output fps` | 小幅提升，不足以解决 |
| `use_cublas=True` | `46.5 output fps` | 小幅提升 |
| `use_cudnn=True` | `46.6 output fps` | 小幅提升 |

结论：参数级规避最多只带来约 1% 左右提升，无法接近 TensorRT 10.11 兼容栈的 `52+ output fps`。因此不建议把参数微调作为主修复方案。

## 25 TensorRT 10.11 小兼容包对新模型的可用性

用 `2025 vstrt.dll + 2025 TensorRT 10.11 核心 DLL 族 + 2026 模型/脚本/k7sfunc` 的小兼容沙盒测试：

| 测试对象 | 结果 | 说明 |
|---|---|---|
| `DRBA_NV` | 可运行 | 小样本首帧成功，TensorRT 10.11 构建通过 |
| `AnimeJaNai V3.1 Balanced` | 可运行 | 小样本 `640x360 -> 1280x720` 成功，TensorRT 10.11 构建通过 |
| `RIFE 4.7` | 可运行 | `960x540` 小样本成功 |
| `RIFE 4.8` | 可运行 | `960x540` 小样本成功 |
| `RIFE 4.9` | 可运行 | `960x540` 小样本成功 |

限制：这只是“可构建、可取帧”的兼容性验证，不代表满高 4K 性能和画质已全部验证。RIFE 4.7/4.8/4.9 在太小分辨率（如 `640x360`）会触发动态引擎范围限制，`960x540` 可通过。

当前判断：旧 TensorRT 10.11 小兼容路径不仅能跑 RIFE 4.15 lite，也能跑目前关心的 DRBA、AnimeJaNai、RIFE 4.7/4.8/4.9 的基础样本。因此做“旧 TRT 兼容运行时”不会天然排除这些模型；但是否让它们都默认走旧 TRT，还需要按满高性能逐个测试。
