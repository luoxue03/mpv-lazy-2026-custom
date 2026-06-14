# 2026 实时模型调研补充：AnimeJaNai V3.1 与 RIFE 4K 补帧

生成时间：2026-06-10  
补充原因：用户修正规则并补充目标：本机优先、`input_uosc.conf` 中 `#`/`#!` 不按普通注释处理、AnimeJaNai 不局限本地、重点调研 RIFE 4.7/新模型是否能改善 4K 一倍补帧的掉帧与细线/楼梯糊影。

## 1. 规则修正

### `input_uosc.conf` 的 `#` 语义

`#` 在 `input_uosc.conf` 里不能简单当普通注释删除。`uosc` 的菜单构建逻辑位于：

- `F:\mpv_2026\mpv-lazy\portable_config\scripts\uosc\lib\menus.lua`

关键逻辑：

```lua
local key, command, comment = string.match(line, '%s*([%S]+)%s+([^#]*)%s*(.-)%s*$')
local is_commented_out = key and key:sub(1, 1) == '#'
local is_menu_item = comment and is_uosc_menu_comment(comment)

if key
  and not (is_commented_out and #key > 1)
  and (not is_commented_out or is_menu_item) then
  all_user_bindings[#all_user_bindings + 1] = {...}
end

local is_dummy = key:sub(1, 1) == '#'
```

含义：

- `#                  command #! 菜单路径`：`key == '#'`，是 uosc 菜单项，通常表示“无快捷键但可在菜单执行”。
- `#F2 command #! 菜单路径`：`key` 长度大于 1 且以 `#` 开头，会被过滤，更接近禁用。
- `_ command #menu: ...` 或 `#_ command #menu: ...` 也常用于 mpv.net/uosc 菜单占位。

后续迁移规则：

1. 不能因为行首 `#` 就判断为删除/禁用。
2. 带 `#!` 或 `#menu:` 的行需要按菜单声明处理。
3. 真正要禁用菜单项，应明确删除菜单声明或使用不会被 uosc 识别的禁用写法，而不是随意注释。

## 2. 本机优先策略

用户明确要求暂时忽略 3060 等低配。当前本机：

- GPU：`NVIDIA GeForce RTX 4080 SUPER`
- VRAM：`16GB`
- 驱动：`595.97`

因此推荐策略调整为：

- 超分：优先追求当前机器上可实时的更高质量模型，不再以 3060 作为默认约束。
- 补帧：优先解决用户实际 4K 观看场景：`4.25_lite` 一倍补帧偶发掉帧、华丽场景压力、楼梯/细线/平移糊影。
- 分享兼容性后置，等本机体验确认后再做轻量备选菜单。

## 3. AnimeJaNai 最新状态

### 3.1 最新版本

`the-database/mpv-upscale-2x_animejanai` 最新 release：

- 版本：`3.3.0`
- 发布时间：`2026-06-02`
- 关键更新：新增 `2x_AnimeJaNai V3.1` 模型，支持每个 profile 的 `Standard / Sharp` 切换。

release note 明确给出两个新模型：

- `2x_AnimeJaNai_HD_V3.1_Balanced_SPANF3_b8f64_unshuffle_fp16`
- `2x_AnimeJaNai_HD_V3.1_Performance_SPANF3_b5f48_unshuffle_fp16`

官方描述：

- Balanced：应接近 UltraCompact 的速度，同时质量超过 Compact。
- Performance：应接近 SuperUltraCompact 的速度，同时质量超过 UltraCompact。
- 默认 TensorRT engine 改为 static；每个分辨率需要构建 engine，但性能更好、播放时 GPU 使用更低。
- 大幅改善启用超分时的 seek 性能。

### 3.2 已确认压缩包内容

用户下载位置：`F:\Edge_DownloadFile`

已确认文件：

- `mpv-upscale-2x_animejanai-overlay-3.3.0.7z`，大小 `38,880,856` bytes。
- `mpv-upscale-2x_animejanai-full-package-3.3.0.7z.001`，大小 `1,992,294,400` bytes。
- `mpv-upscale-2x_animejanai-full-package-3.3.0.7z.002`，大小 `1,565,069,684` bytes。

Overlay 已解压到研究目录：

- `D:\mpv-lazy-25_install\.trellis\tasks\05-17-mpv-2025-to-2026-migration\research\model-research-sources\animejanai-overlay-3.3.0`

其中 `animejanai\onnx` 包含：

| 文件 | 大小 | 用途 |
|---|---:|---|
| `2x_AnimeJaNai_HD_V3.1_Balanced_SPANF3_b8f64_unshuffle_fp16.onnx` | 1,971,970 | HD V3.1 Balanced 标准版 |
| `2x_AnimeJaNai_HD_V3.1Sharp1_Balanced_SPANF3_b8f64_unshuffle_fp16.onnx` | 1,971,970 | HD V3.1 Balanced 锐化版 |
| `2x_AnimeJaNai_HD_V3.1_Performance_SPANF3_b5f48_unshuffle_fp16.onnx` | 740,318 | HD V3.1 Performance 标准版 |
| `2x_AnimeJaNai_HD_V3.1Sharp1_Performance_SPANF3_b5f48_unshuffle_fp16.onnx` | 740,318 | HD V3.1 Performance 锐化版 |
| `2x_AnimeJaNai_SD_V1beta34_Compact_1x3xHxW_dyn-HW_strong_fp16_op23_dynamo.onnx` | 1,212,903 | SD V1 beta 模型 |

### 3.3 与本地当前模型对比

当前 `F:\mpv_2026\mpv-lazy\vs-plugins\models` 只有：

- `the_database_AnimeJaNaiV2L1_x2_fp16_op17.onnx`
- `the_database_AnimeJaNaiV3L1_sharp_HD_x2_fp16_op17.onnx`
- `Phhofm_HFA2kCompact_x2_fp16_op17.onnx`
- `Sirosky_Ani4Kv2_UltraCompact_x2_fp16_op17.onnx`
- `Zarxrax_Anime1080Fixer_SUC_x1_fp16_op17.onnx`

结论：

- 本地已有的 `V3L1_sharp_HD` 不是最新 V3.1 SPANF3。
- 最新 V3.1 模型已经在 overlay 包中可取。
- 对本机优先，应优先接入 `V3.1 Balanced` 和 `V3.1 Balanced Sharp`；`Performance` 可作为快速备选。

### 3.4 AnimeJaNai 3.3.0 默认 profile

Overlay 的默认 profile 由 `animejanai/core/animejanai_config.py` 内置；full package 的 `animejanai.conf` 仅保存全局配置：

```ini
[global]
config_version=2
backend=TensorRT
logging=yes
```

未设置 `quality_preset` / `balanced_preset` / `performance_preset` 时，默认使用 Standard；如果设置为 `sharp`，代码会把模型名从：

```text
_HD_V3.1_
```

替换为：

```text
_HD_V3.1Sharp1_
```

内置默认：

- `Quality`：HD 1080p/720p 使用 `Balanced_SPANF3`，SD 使用 `SD_V1beta34`。
- `Balanced`：HD 使用 `Balanced_SPANF3`，SD 使用 `SD_V1beta34`。
- `Performance`：HD 使用 `Performance_SPANF3`，SD 使用 `SD_V1beta34`。

### 3.5 接入建议

当前 mpv-lazy 的 `k7sfunc.UAI_NV_TRT` 可以直接加载自定义 ONNX，因此低侵入接入方式是：

1. 将 V3.1 ONNX 复制到 `F:\mpv_2026\mpv-lazy\vs-plugins\models`。
2. 新增独立 VS 预设，例如：
   - `MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Balanced.vpy`
   - `MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Balanced_Sharp.vpy`
   - `MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Performance.vpy`
   - `MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Performance_Sharp.vpy`
3. 不覆盖当前 `MIX_UAI_NV_TRT.vpy`，先作为菜单新增项实测。
4. 由于本机优先，首测建议：`Balanced_Sharp` 与 `Balanced` 两个，比较是否过锐。

## 4. RIFE 最新与版本收益

### 4.1 官方状态

`HolyWu/vs-rife` 最新 release：

- 版本：`v5.7.0`
- 发布时间：`2026-02-09`
- 变化：Torch 2.10、VapourSynth R69、TensorRT 显式 typing 适配。
- 默认模型：`4.25`。

`HolyWu/vs-rife` 当前支持模型：

```text
4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9,
4.10, 4.11, 4.12, 4.12.lite, 4.13, 4.13.lite,
4.14, 4.14.lite, 4.15, 4.15.lite, 4.16.lite,
4.17, 4.17.lite, 4.18, 4.19, 4.20, 4.21,
4.22, 4.22.lite, 4.23, 4.24,
4.25, 4.25.lite, 4.25.heavy,
4.26, 4.26.heavy
```

`hzwer/Practical-RIFE` README 当前写明：

- “Currently, it is recommended to choose 4.25 by default for most scenes.”
- `4.25`：尝试使用更多 flow blocks，`scale_list` 变化，anime scenes 显著改善。
- `4.26`：2024-09-21 发布。
- 高分辨率例如 4K，官方建议 `scale=0.5`。
- `--UHD` 等价于 `scale=0.5`。

### 4.2 RIFE 4.7 是否值得添加

证据显示 `4.7` 不是“最新最好”，但在某些场景有独特价值。

支持添加的证据：

- `Practical-RIFE` / `ECCV2022-RIFE` 记录：`v4.7-4.10` 是 2023-11 引入的 anime scene 优化分支。
- issue #34 中用户报告：`4.7` 相比 `4.6` 改善了一些 artifact，但仍有严重大运动 artifact；另有测试称 `4.7` 在 fast continuous motion / fine patterns / panning jitter 上可优于后续模型。
- SVFI 文档：`4.8` 是 anime material optimization，`4.9` 是 anime + live-action 优化，速度与 `4.6` 类似。

不支持把它设为默认的证据：

- `HolyWu/vs-rife` 当前默认是 `4.25`，不是 `4.7`。
- `Practical-RIFE` 当前推荐默认是 `4.25`。
- issue #34 后续讨论：`4.15` / `4.15.lite` 在快运动 artifact 上常优于 `4.7`；`4.7` 只是某些平移/细线场景有优势。
- 当前本地 `k7sfunc.RIFE_NV` 不支持 `47`，也没有 `rife_v4.7.onnx`。

结论：

- **值得添加为实验/场景专用项**，尤其用于你提到的“楼梯、细线、平移糊/抖”的对比。
- **不值得直接替换当前默认**。
- 如果只选一个新补帧实验模型，优先级不是 `4.7` 单独，而是：`4.15_lite` / `4.25` / `4.7` / `4.8` / `4.9` 做小菜单集合，用同一段 4K 问题片源实测。

### 4.3 4.25、4.25_lite、4.26 的争议

issue #112 关键点：

- 用户反馈 `4.26` 在部分场景出现大块伪影；同场景 `4.25`、`4.22_lite`、`4.18`、`4.15_lite`、`4.9` 没有，`4.6` 有部分。
- 同一用户反馈 `4.25_lite` 也有许多伪影，且速度和 `4.25` 差距很小。
- 另有用户反馈标准 `4.26` 在自己测试中优于 `4.25`，但 `4.26 heavy` 有争议。
- 讨论中提到模型尺寸限制变化：`4.25_lite` 需要 128 对齐，`4.25_heavy` / `4.26` 需要 64 对齐，老版本多为 32。

issue #110 关键点：

- 对动漫场景，用户认为 GMFSS Union 在某些样例上明显优于 RIFE 4.26。
- RIFE 4.26 优点：某些对象/线条可能更清晰。
- RIFE 4.26 缺点：更多 ghosting/trailing/warping/deformation，正常速度下会被感知为 stutter。
- GMFSS 缺点：更 blend/blur；优点：更流畅、变形少。

issue #34 关键点：

- `4.7` 相比 `4.6` 改善 artifact，但仍有严重“角色隔帧闪烁”等问题。
- `4.9` 对部分 artifact 又有改善，且比 `4.7` 稍更高效。
- 对直线/建筑栅栏/平移场景，RIFE 老问题是细线 warping；有用户称 `4.9` 明显降低，`4.13` 基本消失。
- `4.15` / `4.15_lite` 被多次认为对 fast motion artifact 更好。
- 用户提到提高目标 FPS 到 72/90 可减轻某些 artifact，但会增加性能压力。

### 4.4 你的 4K 一倍补帧问题分析

你当前常用：`4.25_lite` 一倍补帧，即 24→48 或类似 2x 输出，但 4K 输入。问题：

1. **华丽场景掉帧**
   - 更像性能/显存/engine shape/处理分辨率问题。
   - 4K 下官方建议 `scale=0.5`，即降低 optical-flow 处理分辨率。
   - 当前 `k7sfunc.RIFE_NV` 的 4.25_lite 预设 `H_Pre=2160`，不会预降到 1080；对 4K 是满分辨率处理，压力大。
   - 当前 `k7sfunc.RIFE_NV` 中 `turbo=True` 会使用 `rife_v2` 路径和 static engine，速度更好，但质量/行为受 `rife_v2` ONNX 实现影响。

2. **楼梯/细线/平移糊或扭曲**
   - 更像模型运动估计 artifact，不一定靠显卡解决。
   - `4.7`、`4.8`、`4.9`、`4.15_lite`、`4.25` 在不同场景互有优劣。
   - `4.25_lite` 并不一定是最优；issue 反馈它 artifact 不少，且相对 `4.25` 速度优势可能不明显。
   - 降 `scale` 能缓解掉帧，但可能增加 blur；换模型能改善 artifact，但可能变慢。

### 4.5 现有本地 k7sfunc 限制

当前 `F:\mpv_2026\mpv-lazy\Lib\site-packages\k7sfunc\mod_memc.py`：

```python
model : typing.Literal[46, 422, 4221, 4251, 4151, 426, 4262]
```

当前支持：

- `46` = 4.6
- `4151` = 4.15_lite
- `422` = 4.22
- `4221` = 4.22_lite
- `4251` = 4.25_lite
- `426` = 4.26
- `4262` = 4.26_heavy

当前不支持但值得实验：

- `47` = 4.7
- `48` = 4.8
- `49` = 4.9
- `415` = 4.15
- `425` = 4.25
- `4252` = 4.25_heavy

AnimeJaNai 3.3.0 自带的 `animejanai/core/rife_cuda.py` 已支持通用 RIFE 模型名拼接，并处理 `model >= 47` 的特殊逻辑，但它是 AnimeJaNai 自己的封装，不是当前 `k7sfunc` 主线。

## 5. 推荐执行方案

### 阶段 A：先接入 AnimeJaNai V3.1 超分

目标：直接利用已下载 overlay 的新模型，低风险提升超分质量。

建议新增，不覆盖旧项：

1. 复制 V3.1 ONNX 到 `F:\mpv_2026\mpv-lazy\vs-plugins\models`。
2. 新增 `MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Balanced.vpy`。
3. 新增 `MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Balanced_Sharp.vpy`。
4. 新增 `MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Performance.vpy`。
5. 可选新增 `Performance_Sharp`。
6. 菜单增加到 `VF 滤镜 > 超分 > 2026 > AnimeJaNai V3.1`。

本机首测顺序：

1. `Balanced`
2. `Balanced Sharp`
3. `Performance`

### 阶段 B：RIFE 先做现有模型对比，不立即引入新运行时

现有低成本可测：

- `4.15_lite`：已有模型、已有 VS 文件，可能比 `4.25_lite` 更适合 fast motion artifact。
- `4.25_lite`：用户当前常用，作为基准。
- `4.26`：已有模型，标准版可测。
- `4.26_heavy`：已有模型，可能慢/伪影争议，作为高压测试。

需要新增模型/改封装才可测：

- `4.7`
- `4.8`
- `4.9`
- `4.15`
- `4.25`
- `4.25_heavy`

建议先做两条不改核心的测试：

1. 对 4K 问题片段，测 `4.15_lite`、`4.25_lite`、`4.26`、`4.26_heavy`。
2. 新增一个 `4K scale=0.5` 低分辨率光流预设，专门解决掉帧。

如果 `4.15_lite` 或 `4.26` 已经改善楼梯/细线/掉帧，就暂不动 `k7sfunc` 核心。

### 阶段 C：RIFE 4.7/4.8/4.9 实验分支

如果阶段 B 不能解决，建议建立实验分支：

1. 从 AnimeJaNai full package 或 manifest 中提取 `rife_v4.7.7z`、`rife_v4.8.7z`、`rife_v4.9.7z`。
2. 补到 `vs-plugins\models\rife` 和/或 `rife_v2`。
3. 修改 `k7sfunc.RIFE_NV` 支持 `47/48/49`，但必须保留原逻辑。
4. 每个版本只做无快捷键菜单项，避免污染现有快捷键。
5. 用同一段 4K 问题片源对比：掉帧、细线/楼梯、人物边缘、华丽运动场景。

### 阶段 D：GMFSS 不走当前实时主线

GMFSS/GMFSS_Fortuna 对动漫质量可能更好，但当前证据显示实时 mpv 播放成本高、封装复杂，不适合立即进入主线。它更适合作为离线增强或独立实验。

## 6. 当前推荐结论

1. **AnimeJaNai：应升级到 V3.1**。最新模型已在 overlay 包中，提升明确，接入成本低。
2. **RIFE 4.7：值得添加为实验项，不值得直接默认**。它可能解决部分平移/细线场景，但不是全局更优。
3. **优先解决 4K 掉帧：新增 `scale=0.5` / 预降处理分辨率的 RIFE 4K 预设**。这是性能问题的直接路径。
4. **优先解决楼梯/细线糊影：对比 `4.15_lite`、`4.25_lite`、`4.26`、`4.7/4.8/4.9`**。这是模型问题，不能靠单一参数保证修复。
5. **不要把 `#` 菜单行当注释清理**。后续迁移时，所有 `#!`/`#menu:` 行都按菜单声明处理。

