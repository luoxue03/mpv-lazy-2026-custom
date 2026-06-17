# 真人/通用超分与补帧组合接入总结（2026-06-17）

本文记录 2026 自定义整合包中“真人/通用”超分模型的接入、菜单整理、超分补帧组合测试结论，以及后续维护规则。

## 目标

- 为真人电影、网络视频、手持拍摄视频等非动画片源补充更明显的画质增强方案。
- 保留已有动画向超分、RIFE 补帧配置，不回退用户手动整理过的菜单结构。
- 在 4080S 本机播放链路下优先保证真实播放可用，而不是只追求离线 benchmark 数字。

## 已接入模型

### RealESRGAN General x4v3

- 模型文件：`vs-plugins/models/realesr-general-x4v3_dynamic.onnx`
- 来源：`realesr-general-x4v3`，本地从官方权重转换为动态 ONNX。
- 作用：强力通用/真人超分，视觉增强最明显，但负载也最高。
- 菜单位置：`VF 滤镜 > 超分 > 2026 > 真人/通用`
- 已接入脚本：
  - `portable_config/vs/MIX_UAI_NV_TRT_RealESRGAN_General_x4v3_540P.vpy`
  - `portable_config/vs/MIX_UAI_NV_TRT_RealESRGAN_General_x4v3_720P.vpy`
  - `portable_config/vs/MIX_UAI_NV_TRT_RealESRGAN_General_x4v3_1080P.vpy`

结论：`540P→4K` 是当前最实用档位。`720P→4K` 和 `1080P→4K` 更像实验项，容易产生丢帧。

### LiveActionV1 SPAN

- 模型文件：`vs-plugins/models/2xLiveActionV1_SPAN_490000.onnx`
- 作用：真人/电影向 2x 超分，增强比 RealESRGAN 克制，负载更合理。
- 菜单位置：`VF 滤镜 > 超分 > 2026 > 真人/通用`
- 已接入脚本：
  - `portable_config/vs/MIX_UAI_NV_TRT_LiveActionV1_SPAN_540P.vpy`
  - `portable_config/vs/MIX_UAI_NV_TRT_LiveActionV1_SPAN_720P.vpy`
  - `portable_config/vs/MIX_UAI_NV_TRT_LiveActionV1_SPAN_1080P.vpy`

结论：适合需要更稳、更自然的真人片源。`720P→1440P` 是均衡档，`1080P→4K` 是高质档。

### StarSample Lite NS 1x

- 模型文件：`vs-plugins/models/1x_StarSample_V2.0_Lite_NS_fp16.onnx`
- 作用：不放大，只做原分辨率修复/增强。
- 菜单位置：`VF 滤镜 > 超分 > 2026 > 真人/通用`
- 脚本：`portable_config/vs/MIX_UAI_NV_TRT_StarSample_Lite_NS_1x.vpy`

结论：适合压缩源、网页视频、已有 4K 视频的轻修复。效果不如强超分明显，但负载低。

### StarSample Lite 2x

- 模型文件：`vs-plugins/models/2x_StarSample_V2.0_Lite_fp16.onnx`
- 作用：2x 真人/通用轻量超分。
- 菜单位置：`VF 滤镜 > 超分 > 2026 > 真人/通用`
- 已接入脚本：
  - `portable_config/vs/MIX_UAI_NV_TRT_StarSample_Lite_2x_540P.vpy`
  - `portable_config/vs/MIX_UAI_NV_TRT_StarSample_Lite_2x_720P.vpy`
  - `portable_config/vs/MIX_UAI_NV_TRT_StarSample_Lite_2x_1080P.vpy`

结论：模型可用，但用户实测存在“果冻化”倾向。因此暂不推荐把它作为超分补帧组合的默认候选。

## 已删除/未采用项

### 真人/电影着色器组合

之前新增过若干“真人/电影”shader 组合，但效果不够明确，且容易与现有着色器分类混杂，已从菜单和 profile 中移除。

### BSRGANx2 fp16

尝试过 `BSRGANx2_fp16` ONNX 方案。模型形状修正后仍无法被当前 TensorRT 解析通过，报错与卷积输入尺寸有关，因此未接入菜单。

### LAPAR / BasicVSR / RealBasicVSR

- `LAPAR`：实时潜力存在，但当前可直接接入 mpv/vs-mlrt/TensorRT 的成熟资源不足。
- `BasicVSR / RealBasicVSR`：视频级超分质量方向正确，但涉及时序缓冲、DCN/插件、ONNX/TensorRT 转换复杂度，暂不适合当前实时播放整合包。

## 超分补帧组合

组合逻辑统一为：先超分/修复，再 RIFE 补帧。

理由：现有 2025 组合脚本也是这个顺序；先把单帧画质处理好，再生成中间帧。代价是补帧发生在更高分辨率上，性能压力更大。

### RealESRGAN + RIFE

当前保留项：

| 组合 | 脚本 | 实测结论 |
|---|---|---|
| RealESRGAN 540P→4K + RIFE 4.6 T1 F0.25 | `portable_config/vs/MEMC_RIFE_NV_4.6_t1_f0.25_RealESRGAN_General_x4v3_540P.vpy` | 用户实测可用，当前保留为最高性能档 |
| RealESRGAN 540P→4K + RIFE 4.7 T2 F1 | `portable_config/vs/MEMC_RIFE_NV_4.7_t2_f1.0_RealESRGAN_General_x4v3_540P.vpy` | 本地脚本可用，但真实播放需超高性能 |
| RealESRGAN 540P→4K + RIFE 4.9 T2 F1 | `portable_config/vs/MEMC_RIFE_NV_4.9_t2_f1.0_RealESRGAN_General_x4v3_540P.vpy` | 本地脚本可用，但真实播放需超高性能 |

曾测试后删除项：

| 组合 | 处理 |
|---|---|
| RealESRGAN 540P→4K + RIFE 4.15 lite | 用户实测丢帧，已从菜单和脚本中移除 |
| RealESRGAN 540P→4K + RIFE 4.6 T1 F0.5 | 用户实测仍丢帧，已从菜单和脚本中移除 |

关键结论：在 `RealESRGAN x4v3` 强超分后叠加 RIFE 时，单独 RIFE benchmark 的“富余”不能代表真实播放一定不丢帧。真实链路还叠加了解码、网络流、渲染、脚本、弹幕等开销。

### LiveAction / StarSample + RIFE

当前保留的实验组合：

| 组合 | 脚本 | 目的 |
|---|---|---|
| LiveAction 720P→1440P + RIFE 4.15 lite | `portable_config/vs/MEMC_RIFE_NV_4.15_lite_LiveActionV1_SPAN_720P.vpy` | 均衡真人增强与补帧，建议优先测试 |
| LiveAction 1080P→4K + RIFE 4.15 lite | `portable_config/vs/MEMC_RIFE_NV_4.15_lite_LiveActionV1_SPAN_1080P.vpy` | 更高画质，负载更高 |
| StarSample 1x修复 + RIFE 4.15 lite | `portable_config/vs/MEMC_RIFE_NV_4.15_lite_StarSample_Lite_NS_1x.vpy` | 不放大，只修复后补帧，适合压缩源 |

这些组合仍需真实视频继续测试。由于 `StarSample 2x` 有果冻化反馈，暂不新增 `StarSample 2x + RIFE` 组合。

## RIFE 参数结论

### 4.6 T1 F0.25

- 当前 RealESRGAN 组合的最高性能可用档。
- `flow_scale=0.25` 会降低运动估计分辨率，换取更高性能。
- 代价是运动细节更粗，复杂运动场景可能更容易出现细节不准。

### 4.6 T1 F0.5

- 从 RIFE benchmark 看性能也很高，但用户在 `RealESRGAN 540P→4K` 组合中实测仍丢帧。
- 已从 RealESRGAN 组合菜单中移除。

### 4.7 / 4.9 T2 F1

- 作为新版模型风格对比项保留。
- 菜单中标注“需超高性能”。
- 它们不支持像 4.6 那样通过 `flow_scale=0.5/0.25` 降档，因此性能救火能力弱于 4.6。

## 菜单落地

### 超分菜单

`RealESRGAN General x4v3` 已从独立目录移动到：

`VF 滤镜 > 超分 > 2026 > 真人/通用`

这样与 `LiveAction SPAN`、`StarSample` 归在同一类，便于按片源类型选择。

### 超分补帧菜单

新增/整理目录：

`VF 滤镜 > 超分补帧 > 真人/通用_RIFE`

当前 RealESRGAN 组合顺序：

1. `RealESRGAN 540P→4K + RIFE 4.6 T1 F0.25（最高性能｜细节降档）`
2. `RealESRGAN 540P→4K + RIFE 4.7 T2 F1（需超高性能｜线条/平移）`
3. `RealESRGAN 540P→4K + RIFE 4.9 T2 F1（需超高性能｜风格测试）`

## 使用建议

### 720P 真人/通用视频

优先顺序：

1. `RealESRGAN 540P→4K + RIFE 4.6 T1 F0.25`：强增强 + 可用性能档。
2. `LiveAction 720P→1440P + RIFE 4.15 lite`：更稳、更轻，效果比 RealESRGAN 克制。
3. 单独 `RealESRGAN General x4v3 540P→4K`：如果组合补帧仍吃力，先只开超分。

### 1080P 真人/通用视频

优先顺序：

1. `LiveAction SPAN 1080P→4K`：真人/电影更自然。
2. `RealESRGAN General x4v3 540P→4K`：需要明显增强时使用，但注意它实际是降到 540P 后做 x4。
3. `StarSample Lite NS 1x修复`：不想改变分辨率，只想修复压缩感时使用。

### 已有 4K 或高质量片源

优先使用 `StarSample Lite NS 1x修复` 或关闭超分。强超分可能引入过锐、纹理误判或运动伪影。

## 后续维护规则

- 新增真人/通用模型时，先做单独超分脚本，再考虑组合补帧脚本。
- 组合脚本必须标明超分输入高度、输出目标、RIFE 模型、`turbo`、`flow_scale`。
- 用户实测丢帧的组合不保留在主菜单，除非明确标注“实验/需超高性能”。
- 真实播放结果优先于合成 benchmark。
- `vs-plugins/models/` 被 `.gitignore` 忽略，如需发布整合包，应通过压缩包分发或在提交时显式处理模型文件。

