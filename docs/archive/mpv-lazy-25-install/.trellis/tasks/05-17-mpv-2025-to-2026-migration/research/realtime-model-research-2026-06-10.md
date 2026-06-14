# 2026 实时补帧 / 超分模型调研报告

生成时间：2026-06-10  
目标目录：`F:\mpv_2026\mpv-lazy`  
调研目标：基于当前 mpv-lazy 2026 整合包、本机硬件和分享兼容性，判断是否存在更好、更适合当前机器的补帧与超分模型。

## 0. 结论先行

### 推荐优先级

1. **超分优先升级：AnimeJaNai V3 / V3.1 系列**
   - 当前包已带 `the_database_AnimeJaNaiV3L1_sharp_HD_x2_fp16_op17.onnx`，但 `MIX_UAI_NV_TRT.vpy` 和 `MIX_UAI_DML.vpy` 仍默认调用 `the_database_AnimeJaNaiV2L1_x2_fp16_op17.onnx`。
   - 这是最低风险、最高收益的升级方向：只需要新增/调整 VS 预设和菜单，不必引入全新运行时。
   - 对本机 `RTX 4080 SUPER / 16GB`，官方 benchmark 显示 1080p 输入到 4K 的实时超分可以使用更高档模型；但分享默认应保守，优先 `SuperUltraCompact` 或当前低成本 V3 L1。

2. **补帧默认保持当前 2026 RIFE/DRBA，不建议强行切到全新 vs-rife Python 路线**
   - 当前 `k7sfunc.RIFE_NV` 只支持 `46, 422, 4221, 4251, 4151, 426, 4262`，不支持 `47`。
   - 官方 `vs-mlrt.py` 的 `RIFEModel` 已包含 `v4_7`，但当前 `k7sfunc` 没暴露该枚举，也没有对应本地 ONNX 文件。
   - 若要接入 `RIFE 4.7`，需要升级 `k7sfunc` 封装、补模型、验证 `rife_v2`/`rife` 路径和 TensorRT engine 生成，不属于“直接换配置”。

3. **DRBA 可保留为动漫补帧备选，但不应作为默认**
   - `VS-DRBA` 上游仍活跃，支持 `4.0` 到 `4.26.heavy`，默认 `4.26.heavy`。
   - 当前本地 `DRBA_NV` 模型是 `distilDRBA_v2_lite` 系列，适合作为动漫运动保护备选；但速度慢于纯 RIFE，且视觉收益依片源而定。

4. **Real-CUGAN / ModernSpanimation / GMFSS / DDFI 不建议立即接入默认实时菜单**
   - Real-CUGAN 质量有场景优势，但 1080p 实时到 4K 的性能压力明显大于 AnimeJaNai Compact 系，且当前包没有 `k7sfunc` 的活动菜单接入。
   - ModernSpanimation V2 有 benchmark 和 ONNX 路线，但本地没有模型文件，当前包没有专门封装；适合作为后续实验项。
   - GMFSS 更偏离线高质量补帧，当前没有 mpv-lazy 实时封装；不适合现在接入。
   - DDFI 是去重帧 + 补帧流程工具，不是单独补帧模型；更适合离线处理 24fps 重复帧动画，不适合当前播放默认链路。

## 1. 本机与本地现状

### 硬件

- GPU：`NVIDIA GeForce RTX 4080 SUPER`
- 显存：`16376 MiB`
- 驱动：`595.97`
- 结论：本机可以跑较激进的 TensorRT/NV 预设；分享包默认仍应考虑 `RTX 3060 / 8-12GB` 用户。

### 当前补帧入口

`portable_config/input_uosc.conf` 当前活动入口：

- `MEMC_MVT_LQ.vpy`：MVTools 快速补帧，2026 官方入口。
- `MEMC_RIFE_DML.vpy`：RIFE DirectML/DX12。
- `MEMC_DRBA_DML.vpy`：DRBA DirectML/DX12。
- `MEMC_RIFE_NV.vpy`：RIFE TensorRT/NV。
- `MEMC_DRBA_NV.vpy`：DRBA TensorRT/NV。

当前保留但注释的 2025 自定义项包括：

- RIFE NV：`4.15_lite`、`4.6`、`4.22`、`4.22_lite`、`4.25_lite`、`4.26`、`4.26_heavy`
- RIFE + UAI 组合：2K / 4K 多个组合
- RIFE + ARTCNN 组合：2K / 4K 多个组合
- RIFE + ESRGAN 组合：2K / 4K 多个组合

### 当前超分入口

活动入口：

- `MIX_UAI_DML.vpy`
- `MIX_UAI_NV_TRT.vpy`
- `SR_ARTCNN_NV.vpy`

当前 `MIX_UAI_*` 默认模型：

```python
Model = "the_database_AnimeJaNaiV2L1_x2_fp16_op17.onnx"
```

但本地模型目录实际还存在：

- `the_database_AnimeJaNaiV2L1_x2_fp16_op17.onnx`
- `the_database_AnimeJaNaiV3L1_sharp_HD_x2_fp16_op17.onnx`
- `Phhofm_HFA2kCompact_x2_fp16_op17.onnx`
- `Sirosky_Ani4Kv2_UltraCompact_x2_fp16_op17.onnx`
- `Zarxrax_Anime1080Fixer_SUC_x1_fp16_op17.onnx`
- `ArtCNN/ArtCNN_R16F96.onnx`
- `ArtCNN/ArtCNN_R8F64.onnx`
- `ArtCNN/ArtCNN_R8F64_DS.onnx`

## 2. 证据来源

### 本地证据

- `research/local-model-inventory.json`：本地模型、VS 脚本、`k7sfunc` 枚举盘点。
- `portable_config/vs/*.vpy`：当前运行预设。
- `Lib/site-packages/k7sfunc/mod_memc.py`：RIFE/DRBA 调用封装。
- `Lib/site-packages/k7sfunc/mod_mix.py`：自定义 ONNX / UAI 调用封装。
- `Lib/site-packages/k7sfunc/mod_scale.py`：ARTCNN / CUGAN 调用封装。

### 官方 / 上游证据

- `AmusementClub/vs-mlrt`：官方 README 声明支持 RealESRGANv2/v3、Real-CUGAN、RIFE、ArtCNN 等，并说明 TensorRT 性能最好但需要本机生成 engine。
- `AmusementClub/vs-mlrt/scripts/vsmlrt.py`：官方源码中 `RIFEModel` 支持到 `v4_26_heavy`，并包含 `v4_7`；`RealESRGANModel` 包含 AnimeJaNai V2 / V3 / Ani4Kv2；`ArtCNNModel` 支持更多模型枚举。
- `the-database/mpv-upscale-2x_animejanai`：官方 README、release、manifest、wiki benchmark。
- `HolyWu/vs-rife`：VapourSynth RIFE Python 包，支持自动下载模型和 TensorRT 路线。
- `routineLife1/VS-DRBA`：VapourSynth DRBA 包，支持 RIFE 4.0 到 4.26.heavy，默认 4.26.heavy。
- `styler00dollar/VSGAN-tensorrt-docker`：VapourSynth + TensorRT 多模型 benchmark 与示例。
- `SVP RIFE AI interpolation wiki`：实际播放场景下的硬件级别估计。

## 3. 补帧模型调研

### 3.1 当前低成本可用模型

当前 `k7sfunc.RIFE_NV` 支持：

| 模型号 | 含义 | 本地是否有模型 | 当前适配状态 | 建议 |
|---|---|---:|---|---|
| `46` | RIFE 4.6 | 是 | 活动默认 | 稳定默认，保留 |
| `4151` | RIFE 4.15 lite | 是 | 2025 注释保留 | 可保留为轻量旧备选 |
| `422` | RIFE 4.22 | 是 | 2025 注释保留 | 可作为质量备选 |
| `4221` | RIFE 4.22 lite | 是 | 2025 注释保留 | 可作为轻量备选 |
| `4251` | RIFE 4.25 lite | 是 | 2025 注释保留，用户实测可用 | 推荐恢复为手动备选 |
| `426` | RIFE 4.26 | 是 | 2025 注释保留 | 可作为新模型备选 |
| `4262` | RIFE 4.26 heavy | 是 | 2025 注释保留 | 仅高配 / 测试，不默认 |

当前 `k7sfunc.DRBA_NV` 支持：

| 模型号 | 含义 | 本地模型 | 建议 |
|---|---|---|---|
| `1` | DRBA v1 | `distilDRBA_v1*` | 不默认，保留备选 |
| `2` | DRBA v2 lite | `distilDRBA_v2_lite*` | 当前默认，适合作为动漫备选 |

### 3.2 RIFE 4.7 的状态

`vs-mlrt.py` 官方源码中 `RIFEModel` 包含：

```python
v4_6 = 46
v4_7 = 47
...
v4_26 = 426
v4_26_heavy = 4262
```

但当前本地 `k7sfunc.RIFE_NV` 只允许：

```python
typing.Literal[46, 422, 4221, 4251, 4151, 426, 4262]
```

并且本地 `vs-plugins/models` 没有：

- `rife/rife_v4.7.onnx`
- `rife_v2/rife_v4.7.onnx`

因此：

- `RIFE 4.7` 是**值得关注的升级候选**。
- 但它不是当前包里的低成本切换项。
- 若接入，需要补模型 + 改 `k7sfunc` 枚举 + 改 `mdl_fname` 映射 + 写新 VS 预设 + 验证 TensorRT engine。

### 3.3 RIFE / DRBA 性能与质量

`VSGAN-tensorrt-docker` benchmark 给出 RTX 4090 / 7950x 下的参考：

| 模型 | 720p fps | 1080p fps | 1080p 显存 | 备注 |
|---|---:|---:|---:|---|
| RIFE 4.7 | 1084.70 | 476.60 | 2.2GB | 很快，社区认为质量较好，但当前本地未接入 |
| RIFE 4.26 | 828.65 | 409.53 | 2.3GB | 当前本地可接入 |
| RIFE 4.26 heavy | 567.59 | 278.55 | 3.5GB | 更重，未必比轻量模型稳定 |
| DRBA RIFE 4.7 | 558.40 | 313.70 | 2.3GB | 动漫运动保护，但慢于纯 RIFE |
| DRBA RIFE 4.26 | 545.49 | 308.84 | 2.4GB | 当前方向可比照 |
| DRBA RIFE 4.26 heavy | 474.09 | 264.02 | 3.6GB | 高配测试项，不默认 |

`SVP` 的实际播放估计显示 TensorRT 路线下：

- `1080p @60-72fps`：约 `RTX 3060` 起步。
- `4K @48fps`：约 `RTX 4080` 起步。
- `4K @60-72fps`：约 `RTX 4090` 级别。

这与本机 `RTX 4080 SUPER` 匹配：1080p 补帧有足够余量；4K 补帧应谨慎，尤其叠加超分时。

### 3.4 GMFSS / DDFI / 其他补帧路线

| 路线 | 优点 | 问题 | 结论 |
|---|---|---|---|
| GMFSS | 动漫质量潜力高 | 上游较老，当前包无实时封装，性能与依赖成本高 | 不接入当前默认；后续离线实验 |
| DDFI-RIFE | 适合去重复帧动画源 | 是流程脚本，不是模型；播放实时链路复杂 | 不接入默认；可作为离线工具研究 |
| VS-DRBA Python 包 | 上游支持广，支持 `4.0` 到 `4.26.heavy` | 当前包用的是 `k7sfunc` 内置封装，不是直接 pip 包路线 | 保持当前 DRBA 封装，暂不换线 |
| HolyWu/vs-rife | 活跃，自动下载模型，支持 TensorRT | 引入新 Python 包和 Torch/TensorRT 依赖，与 mpv-lazy 当前封装差异大 | 作为二期路线，不做当前主线 |

## 4. 超分模型调研

### 4.1 当前最值得升级：AnimeJaNai V3 / V3.1

`the-database/mpv-upscale-2x_animejanai` 最新 release `3.3.0`：

- 发布时间：2026-06-02
- `manifest.json` 声明：
  - `vapoursynth`: `R73`
  - `vsmlrt`: `v15.16`
  - `mpvnet`: `v7.1.2.0`
  - RIFE 模型包从 `rife_v4.7.7z` 到 `rife_v4.26_heavy.7z`
- 3.3.0 release note 声明新增 `2x_AnimeJaNai V3.1` 模型，并引入 Standard / Sharp 切换：
  - `2x_AnimeJaNai_HD_V3.1_Balanced_SPANF3_b8f64_unshuffle_fp16`
  - `2x_AnimeJaNai_HD_V3.1_Performance_SPANF3_b5f48_unshuffle_fp16`
  - 默认静态 engine，提高性能并降低播放时 GPU 使用。

官方 README 对 V3 的描述：

- 相比 V2 更忠实于原始源。
- 更好处理过锐化、ringing、aliasing。
- 更好保留景深虚化等有意模糊。
- 更准确的线条颜色、明暗和粗细。
- 更好保留柔和阴影边缘。

### 4.2 AnimeJaNai benchmark 与硬件策略

`AnimeJaNai` wiki benchmark：

| GPU | 1080p 输入 2x Compact | 1080p 输入 2x UltraCompact | 1080p 输入 2x SuperUltraCompact | 解读 |
|---|---:|---:|---:|---|
| RTX 4080 SUPER | 28.26 fps | 49.60 fps | 112.08 fps | 本机 4080S 级别，UltraCompact 可实时 24fps，SuperUltraCompact 余量很大 |
| RTX 4080 | 27.93 fps | 52.73 fps | 118.53 fps | 与 4080S 接近 |
| RTX 4070S | 18.15 fps | 35.22 fps | 83.86 fps | 默认应避免 Compact，SuperUltraCompact 稳 |
| RTX 3080 12G | 23.06 fps | 38.05 fps | 88.24 fps | 官方 Balanced 推荐 3080+ 有依据 |
| RTX 3060 12G | 约 7.67-9.62 fps | 约 13.78-18.28 fps | 约 30.41-57.36 fps | 分享默认只能保守选 SuperUltraCompact 或不默认启用重超分 |
| RTX 3060 Laptop 6GB | 9.60 fps | 15.43 fps | 50.10 fps | 低显存笔记本更应保守 |

结论：

- 本机高配：可提供 `AnimeJaNai V3/V3.1 Balanced/Sharp` 之类高质量选项。
- 分享默认：不能默认启用 Compact；建议默认保留 2026 官方轻量配置，或使用 `SuperUltraCompact` 级别作为“兼容预设”。
- 对 3060：1080p 到 4K 若要实时，必须轻量模型；否则应只作为手动开启选项。

### 4.3 本地可直接尝试的低成本超分预设

当前本地模型中，低成本候选按优先级：

| 候选 | 本地文件 | 类型 | 迁移成本 | 建议 |
|---|---|---|---|---|
| AnimeJaNai V3 L1 Sharp HD | `the_database_AnimeJaNaiV3L1_sharp_HD_x2_fp16_op17.onnx` | Real-ESRGAN Compact | 低：改 `Model` 路径即可 | 第一优先级，新增预设，不覆盖 V2 |
| AnimeJaNai V2 L1 | `the_database_AnimeJaNaiV2L1_x2_fp16_op17.onnx` | Real-ESRGAN Compact | 已接入 | 保留为兼容/旧预设 |
| Ani4Kv2 UltraCompact | `Sirosky_Ani4Kv2_UltraCompact_x2_fp16_op17.onnx` | RealESRGAN/Ani4K v2 系 | 中：需要写 UAI 预设 | 可作为轻量备选 |
| HFA2kCompact | `Phhofm_HFA2kCompact_x2_fp16_op17.onnx` | Compact | 中 | 备选，需视觉测试 |
| Anime1080Fixer SUC | `Zarxrax_Anime1080Fixer_SUC_x1_fp16_op17.onnx` | 1x 修复 | 中：不是 2x 超分 | 作为修复类实验项，不放默认超分 |
| ArtCNN R8F64_DS | `ArtCNN/ArtCNN_R8F64_DS.onnx` | ArtCNN | 已封装 | 保留轻量快速选项 |
| ArtCNN R16F96 | `ArtCNN/ArtCNN_R16F96.onnx` | ArtCNN | 已封装 | 高质量 ArtCNN 备选 |

### 4.4 Real-CUGAN 与 ModernSpanimation

`vs-mlrt` 和 `k7sfunc` 都有 CUGAN 路线，但当前本地没有活动菜单入口，也没有看到 `models/cugan/*.onnx` 文件。`VSGAN-tensorrt-docker` benchmark 显示 Real-CUGAN 1080p 速度明显低于 AnimeJaNai / ModernSpanimation：

| 模型 | 4090 Linux 1080p fps | 5090 Windows 1080p fps | 显存 | 结论 |
|---|---:|---:|---:|---|
| AnimeJaNai V2 | 61.52 | 55.79 | 4.1-5.8GB | 实时成熟 |
| ModernSpanimation V2 | 51.34 | 64.33 | 6.3-7.6GB | 有潜力，但当前本地无模型 |
| Real-CUGAN | 21.67 | 31.22 | 12.7-13.4GB | 太重，不适合分享默认 |

结论：

- Real-CUGAN 可以作为高质量离线或高配实验项，不建议默认接入播放菜单。
- ModernSpanimation V2 值得作为二期下载实验项，但当前没有本地模型，不应优先于已存在的 AnimeJaNai V3。

## 5. 与当前 mpv-lazy 的适配成本

### 低成本：新增 VS 预设 + 菜单入口

适用于：

- `AnimeJaNai V3L1_sharp_HD`
- 现有 `AnimeJaNai V2L1`
- `Ani4Kv2 UltraCompact`
- `HFA2kCompact`
- 现有 ArtCNN 模型

改动点：

1. 新增 `portable_config/vs/MIX_UAI_NV_TRT_AnimeJaNai_V3L1.vpy`。
2. 新增 `portable_config/vs/MIX_UAI_DML_AnimeJaNai_V3L1.vpy`。
3. 在 `input_uosc.conf` 的 `VF 滤镜 > 超分` 菜单中增加“2026 / AnimeJaNai V3”项。
4. 保留 V2 旧项，不覆盖；V2 可标为兼容旧版。
5. 对分享包默认不启用重型超分，只作为手动菜单。

风险：低。主要风险是 TensorRT engine 首次构建耗时，以及不同分辨率下动态/静态 shape 的兼容性。

### 中成本：扩展 `k7sfunc` 枚举与映射

适用于：

- `RIFE 4.7`
- 更多 `vs-mlrt.RealESRGANModel` 内置枚举
- 更多 ArtCNN model 枚举

改动点：

1. 修改 `Lib/site-packages/k7sfunc/mod_memc.py` 的 `RIFE_NV` / `RIFE_DML` 支持列表。
2. 补模型文件：`rife/rife_v4.7.onnx` 与可能的 `rife_v2/rife_v4.7.onnx`。
3. 验证 `implementation_version`、`scale`、`tile requirement`、TensorRT precision workaround。
4. 新增 VS 脚本与菜单。

风险：中。会触及核心封装，必须单独验证，不能直接替换默认。

### 高成本：引入新运行时 / 新包 / 新模型族

适用于：

- HolyWu/vs-rife Python 包路线。
- VS-DRBA Python 包路线。
- GMFSS / DDFI。
- ModernSpanimation V2 下载、转换、TRT engine 策略。

风险：高。会增加依赖、包体、维护成本，并可能破坏分享包的开箱即用。

## 6. 推荐迁移方案

### 阶段 A：无破坏新增

目标：不回退当前可用配置，只新增可手动选择的模型。

1. 新增 `AnimeJaNai V3L1 Sharp HD` 的 `NV_TRT` 与 `DML` VS 预设。
2. 菜单新增：`VF 滤镜 > 超分 > 2026 > AnimeJaNai > V3L1 Sharp HD`。
3. 保留当前 `UAI_RTX` 默认 V2 入口，暂不覆盖。
4. 新增注释说明：V3 是新模型，V2 是旧兼容。
5. 用本地测试视频验证 720p/1080p 开启、切换、关闭是否稳定。

### 阶段 B：本机高配预设

目标：给 `RTX 4080 SUPER` 使用者一个更好的高质量选择。

1. 若能从 `AnimeJaNai 3.3.0` 包中取得 V3.1 Balanced/Performance ONNX，优先增加：
   - `V3.1 Performance`：分享兼容首选。
   - `V3.1 Balanced`：本机高质量首选。
   - `V3.1 Quality/Compact`：仅高配测试，不默认。
2. 不直接把 V3.1 写成默认，先作为菜单项。
3. 每个模型记录首次 engine 构建耗时和播放时帧率。

### 阶段 C：补帧模型小步升级

目标：不破坏当前 RIFE/DRBA 的前提下恢复合理手动备选。

1. 恢复 `RIFE_NV_4.25_lite` 为菜单手动项，因为用户已经实测可用。
2. 恢复 `RIFE_NV_4.26` 为菜单手动项。
3. `4.26_heavy` 标注为高配测试，不默认。
4. `RIFE 4.7` 单独建实验分支：先补模型和 `k7sfunc` 映射，再验证，不进入主线默认。

### 阶段 D：实验项归档

目标：避免主菜单膨胀。

1. Real-CUGAN：记录为离线/高配实验项，不接默认。
2. ModernSpanimation V2：记录为可下载测试项，先不接默认。
3. GMFSS / DDFI：记录为离线补帧研究项，暂不接播放器实时菜单。

## 7. 建议菜单设计

建议保留当前用户手动调整，不回退。新增项只追加到合适层级：

```text
VF 滤镜
  超分
    2026
      UAI
        UAI_RTX 当前默认 / V2 兼容
        AnimeJaNai V3L1 Sharp HD (RTX / TRT)
        AnimeJaNai V3L1 Sharp HD (DX12 / DML)
      ArtCNN
        R8F64_DS 快速
        R8F64 标准
        R16F96 高质量
    2025
      UAI 旧预设（注释 / 仅留存）
      ESRGAN 旧预设（注释 / 仅留存）
  补帧
    2026
      RIFE
        RIFE_RTX 默认 4.6
        RIFE_RTX 4.25 lite（手动备选）
        RIFE_RTX 4.26（手动备选）
        RIFE_RTX 4.26 heavy（高配测试）
      DRBA
        DRBA_RTX v2 lite
    实验
      RIFE 4.7（待接入，不默认）
```

## 8. 风险与验证清单

### 必测项

- 普通 1080p 动画：开启/关闭 AnimeJaNai V3。
- 720p 动画：V3 是否过锐、是否处理合理。
- 高码率 4K：确认不要误触发超分导致过载。
- RIFE + 超分组合：确认不会显存爆或 VS 链冲突。
- uosc 菜单：确认无重复目录、无错误命令。

### 性能记录项

- 首次 TensorRT engine 生成时间。
- 播放时 GPU 占用。
- VRAM 占用。
- 掉帧 / 音画同步。
- VS 错误日志。

### 分享包默认策略

- 不默认启用重型超分。
- 不默认启用 RIFE + 超分组合。
- 所有高配项必须菜单标注“高配 / 测试”。
- `RTX 3060` 用户可用项应优先保留轻量模型。

## 9. 当前最终建议

### 立即做

1. 新增 `AnimeJaNai V3L1 Sharp HD` VS 预设，不覆盖 V2。
2. 在菜单中追加 `AnimeJaNai V3` 项。
3. 恢复 `RIFE_NV_4.25_lite` 和 `RIFE_NV_4.26` 为手动菜单项。
4. 对 `4.26_heavy` 标注“高配测试”。

### 暂缓

1. 不改 `k7sfunc` 接 `RIFE 4.7`，先作为实验。
2. 不接 Real-CUGAN 到默认菜单。
3. 不接 GMFSS / DDFI 到实时播放链路。
4. 不把任何新模型设为默认。

### 需要用户确认后再做

1. 是否下载 `AnimeJaNai 3.3.0` 完整包或 overlay，以取得 V3.1 Balanced / Performance ONNX。
2. 是否允许新增菜单项并实测。
3. 是否开启 `RIFE 4.7` 实验分支。

## 10. 资料索引

- `https://github.com/AmusementClub/vs-mlrt`
- `https://github.com/HolyWu/vs-rife`
- `https://github.com/routineLife1/VS-DRBA`
- `https://github.com/styler00dollar/VSGAN-tensorrt-docker`
- `https://github.com/the-database/mpv-upscale-2x_animejanai`
- `https://github.com/the-database/mpv-upscale-2x_animejanai/wiki/Benchmarks`
- `https://www.svp-team.com/wiki/RIFE_AI_interpolation`
- `https://openmodeldb.info/models/2x-AnimeJaNai-HD-V3-Compact`
- `https://openmodeldb.info/models/2x-ModernSpanimationV1`

