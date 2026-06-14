# 着色器审计报告（2026-06-15）

## 数据来源

- 本地：`F:/mpv_2026/mpv-lazy/portable_config/shaders`
- 官方基线：`hooke007/mpv_PlayKit` tag `20260510`（2026FM）
- 官方最新：`hooke007/mpv_PlayKit` `upstream/main`（commit `4921c6796620a13c2c03266f368d59d354a67b72`）
- 对比方式：Git blob SHA；不只比较文件名。

## 1. 是否有更新

- 本地 shader 文件：`780`
- 官方 20260510 shader 文件：`407`
- 官方 main shader 文件：`429`
- `local_only`：`334`
- `same_all`：`318`
- `local_modified_or_custom`：`72`
- `local_matches_main_new`：`39`
- `upstream_main_removed`：`17`

### 官方 main 中本地仍缺失/过期的 shader

- 未发现。官方 main 中新增的 ACNet/ARNet 与 FSRCNNX fastv2 已补齐到本地。

### 已同步官方 main、但 20260510 release 没有的新增 shader


### 本地独有/本地修改

- `ACNet/ACNet.glsl` — `local_only`
- `ACNet/ACNet_HDN_L1.glsl` — `local_only`
- `ACNet/ACNet_HDN_L2.glsl` — `local_only`
- `ACNet/ACNet_HDN_L3.glsl` — `local_only`
- `ACNet/ACNet_HDN_RT_2025.glsl` — `local_only`
- `Adaptive_sharpen/adaptive_sharpen_luma_RT.glsl` — `local_only`
- `Adaptive_sharpen/Adaptive_sharpen_RT.glsl` — `local_modified_or_custom`
- `Adaptive_sharpen/adaptive_sharpen_RT_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_2x_LineArt.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_2x_LineArt_RT.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Fast_2x_LineArt_RT_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_2x_Photo.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_2x_Photo_RT.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Fast_2x_Photo_RT_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_3x_LineArt.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_3x_LineArt_RT.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Fast_3x_LineArt_RT_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_3x_Photo.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_3x_Photo_RT.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Fast_3x_Photo_RT_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_4x_LineArt.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_4x_LineArt_RT.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Fast_4x_LineArt_RT_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_4x_Photo.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_4x_Photo_RT.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Fast_4x_Photo_RT_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_Sharp_2x_LineArt.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_Sharp_2x_Photo.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_Sharp_3x_LineArt.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_Sharp_3x_Photo.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_Sharp_4x_LineArt.glsl` — `local_only`
- `AiUpscale/AiUpscale_Fast_Sharp_4x_Photo.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_2x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_2x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_2x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_2x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_3x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_3x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_3x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_3x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_4x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_4x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_4x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_4x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_Sharp_2x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_Sharp_2x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_Sharp_2x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_Sharp_2x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_Sharp_3x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_Sharp_3x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_Sharp_3x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_Sharp_3x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_Sharp_4x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_Sharp_4x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_HQ_Sharp_4x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_HQ_Sharp_4x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_2x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_2x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_2x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_2x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_3x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_3x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_3x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_3x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_4x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_4x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_4x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_4x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_Sharp_2x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_Sharp_2x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_Sharp_2x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_Sharp_2x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_Sharp_3x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_Sharp_3x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_Sharp_3x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_Sharp_3x_Photo_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_Sharp_4x_LineArt.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_Sharp_4x_LineArt_2025.glsl` — `local_only`
- `AiUpscale/AiUpscale_Medium_Sharp_4x_Photo.glsl` — `local_modified_or_custom`
- `AiUpscale/AiUpscale_Medium_Sharp_4x_Photo_2025.glsl` — `local_only`
- `AiUpscale/TsubaUP.glsl` — `local_only`
- `AMD/AMD_CAS.glsl` — `local_only`
- `AMD/AMD_CAS_lite2_rgb.glsl` — `local_only`
- `AMD/AMD_CAS_lite_luma.glsl` — `local_only`
- `AMD/AMD_CAS_lite_rgb.glsl` — `local_only`
- `AMD/AMD_CAS_rgb.glsl` — `local_only`
- `AMD/AMD_CAS_rgb_RT.glsl` — `local_only`
- `AMD/AMD_CAS_RT.glsl` — `local_only`
- `AMD/AMD_CAS_scaled.glsl` — `local_only`
- `AMD/AMD_CAS_scaled_rgb.glsl` — `local_only`
- `AMD/AMD_CAS_scaled_rgb_RT.glsl` — `local_only`
- `AMD/AMD_CAS_scaled_RT.glsl` — `local_only`
- `AMD/AMD_FSR_EASU_chroma_RT.glsl` — `local_only`
- `AMD/AMD_FSR_EASU_luma_RT.glsl` — `local_only`
- `AMD/AMD_FSR_EASU_rgb_RT.glsl` — `local_only`
- `AMD/AMD_FSR_RCAS_luma_RT.glsl` — `local_only`
- `AMD/AMD_FSR_RCAS_rgb_RT.glsl` — `local_only`
- `AMD/AMD_FSR_rgb_RT.glsl` — `local_only`
- `AMD/AMD_FSR_RT.glsl` — `local_only`
- `AMD/LumaSharpen.glsl` — `local_only`
- `AMD/LumaSharpen_RT.glsl` — `local_only`
- `Ani/Ani4Kv2_ArtCNN_C4F32_i2_2025.glsl` — `local_only`
- `Ani/Ani4Kv2_ArtCNN_C4F32_i2_CMP_2025.glsl` — `local_only`
- `Ani/AniSD_ArtCNN_C4F32_i4_2025.glsl` — `local_only`
- `Ani/AniSD_ArtCNN_C4F32_i4_CMP_2025.glsl` — `local_only`
- `Anime4K/Anime4K_3DGraphics_AA_Upscale_x2_US_2025.glsl` — `local_only`
- `Anime4K/Anime4K_3DGraphics_Upscale_x2_US_2025.glsl` — `local_only`
- `Anime4K/Anime4K_AIO_optQ_2025.glsl` — `local_only`
- `Anime4K/Anime4K_AutoDownscalePre_x2_2025.glsl` — `local_only`
- `Anime4K/Anime4K_AutoDownscalePre_x4_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Clamp_Highlights_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Darken_Fast_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Darken_HQ_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Darken_VeryFast_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Deblur_DoG_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Deblur_Original_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Denoise_Bilateral_Mean_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Denoise_Bilateral_Median_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Denoise_Bilateral_Mode_2025.glsl` — `local_only`
- `Anime4K/Anime4K_legacy_09.glsl` — `local_only`
- `Anime4K/Anime4K_legacy_10.glsl` — `local_only`
- `Anime4K/Anime4K_legacy_10_Fast.glsl` — `local_only`
- `Anime4K/Anime4K_legacy_10_UltraFast.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_L_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_M_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_S_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_Soft_L_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_Soft_M_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_Soft_S_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_Soft_UL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_Soft_VL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_UL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_CNN_VL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_GAN_UL.glsl` — `local_only`
- `Anime4K/Anime4K_Restore_GAN_UUL.glsl` — `local_modified_or_custom`
- `Anime4K/Anime4K_Restore_GAN_UUL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Thin_Fast_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Thin_HQ_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Thin_VeryFast_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_CNN_x2_L_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_CNN_x2_M_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_CNN_x2_S_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_CNN_x2_UL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_CNN_x2_VL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_Deblur_DoG_x2_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_Deblur_Original_x2_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_Denoise_CNN_x2_L_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_Denoise_CNN_x2_M_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_Denoise_CNN_x2_S_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_Denoise_CNN_x2_UL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_Denoise_CNN_x2_VL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_DoG_x2_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_DTD_x2_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_GAN_x2_M_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_GAN_x2_S_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_GAN_x3_L_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_GAN_x3_VL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_GAN_x4_UL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_GAN_x4_UUL_2025.glsl` — `local_only`
- `Anime4K/Anime4K_Upscale_Original_x2_2025.glsl` — `local_only`
- ……其余 `246` 项见 `shader-file-compare.csv`

## 2. UI 分类审计

- `着色器 > Anime4K > 线条重建系列`：`12` 项
- `着色器 > Anime4K > 放大系列`：`12` 项
- `着色器 > Anime4K > 放大混合系列`：`9` 项
- `着色器 > 快捷/常用 > LUMA 放大`：`5` 项
- `着色器 > Anime4K > 其它系列`：`5` 项
- `着色器 > MAIN 主处理 > Anime4K`：`3` 项
- `着色器 > Anime4K > 降噪系列`：`3` 项
- `着色器 > Anime4K > 线条加深系列`：`3` 项
- `着色器 > Anime4K > 线条变细系列`：`3` 项
- `着色器 > 快捷/常用 > MAIN 放大`：`2` 项
- `着色器 > 快捷/常用 > SCALED 锐化`：`2` 项
- `着色器 > MAIN 主处理 > k7`：`2` 项
- `着色器 > Anime4K > 去模糊系列`：`2` 项
- `着色器 > 快捷/常用 > POSTKERNEL 锐化`：`1` 项

### 分类结论

- `默认` 已改为 `快捷/常用`，并保留 `LUMA`、`MAIN`、`SCALED`、`POSTKERNEL` 阶段提示。
- `MAIN 主处理 > Anime4K/k7` 用于主重建/主放大类 shader，和 LUMA/后锐化分开。
- Anime4K 长列表继续按功能分类：去模糊、线条重建、降噪、线条加深/变细、放大、放大混合、其它。

## 3. profiles.conf 组合审计

- 6 个原有 Anime4K 组合路径正确，缺失引用为 `0`。
- 720P 组合中的两段 `x2` 放大继承上游逻辑，不按错误处理；风险主要是负载较高。
- 已新增 `Anime4K_720P_轻量流畅`，作为性能优先测试项；菜单中默认注释，不占用快捷键。

### `Anime4K_1080P_清晰线条低锐度`（line `102`）

- `Anime4K/Anime4K_Clamp_Highlights.glsl`
- `Anime4K/Anime4K_Restore_CNN_UL.glsl`
- `Anime4K/Anime4K_Upscale_CNN_x2_UL.glsl`
- `Anime4K/Anime4K_AutoDownscalePre_x2.glsl`
- `Anime4K/Anime4K_Thin_HQ.glsl`
- `Anime4K/Anime4K_Deblur_DoG.glsl`

### `Anime4K_1080P_细线条观感好`（line `107`）

- `Anime4K/Anime4K_Clamp_Highlights.glsl`
- `Anime4K/Anime4K_Restore_CNN_UL.glsl`
- `Anime4K/Anime4K_Upscale_Denoise_CNN_x2_UL.glsl`
- `Anime4K/Anime4K_AutoDownscalePre_x2.glsl`
- `Anime4K/Anime4K_Thin_HQ.glsl`

### `Anime4K_1080P_深线条高锐度`（line `112`）

- `Anime4K/Anime4K_Clamp_Highlights.glsl`
- `Anime4K/Anime4K_Restore_CNN_UL.glsl`
- `Anime4K/Anime4K_Upscale_CNN_x2_UL.glsl`
- `Anime4K/Anime4K_AutoDownscalePre_x2.glsl`
- `Anime4K/Anime4K_Darken_HQ.glsl`

### `Anime4K_720P_清晰线条低锐度`（line `117`）

- `Anime4K/Anime4K_Clamp_Highlights.glsl`
- `Anime4K/Anime4K_Restore_CNN_UL.glsl`
- `Anime4K/Anime4K_Upscale_CNN_x2_UL.glsl`
- `Anime4K/Anime4K_AutoDownscalePre_x4.glsl`
- `Anime4K/Anime4K_Thin_HQ.glsl`
- `Anime4K/Anime4K_Upscale_Deblur_DoG_x2.glsl`

说明：
- 720P→4K 两段式放大链路，结构继承上游但负载较高

### `Anime4K_720P_细线条观感好`（line `122`）

- `Anime4K/Anime4K_Clamp_Highlights.glsl`
- `Anime4K/Anime4K_Restore_CNN_UL.glsl`
- `Anime4K/Anime4K_Upscale_Denoise_CNN_x2_UL.glsl`
- `Anime4K/Anime4K_AutoDownscalePre_x4.glsl`
- `Anime4K/Anime4K_Upscale_Denoise_CNN_x2_UL.glsl`

说明：
- 720P→4K 两段式放大链路，结构继承上游但负载较高

### `Anime4K_720P_深线条高锐度`（line `127`）

- `Anime4K/Anime4K_Clamp_Highlights.glsl`
- `Anime4K/Anime4K_Restore_CNN_UL.glsl`
- `Anime4K/Anime4K_Upscale_CNN_x2_UL.glsl`
- `Anime4K/Anime4K_AutoDownscalePre_x4.glsl`
- `Anime4K/Anime4K_Upscale_DTD_x2.glsl`

说明：
- 720P→4K 两段式放大链路，结构继承上游但负载较高

### `Anime4K_720P_轻量流畅`（line `132`）

- `Anime4K/Anime4K_Clamp_Highlights.glsl`
- `Anime4K/Anime4K_Restore_CNN_M.glsl`
- `Anime4K/Anime4K_Upscale_CNN_x2_M.glsl`
- `Anime4K/Anime4K_AutoDownscalePre_x4.glsl`
- `Anime4K/Anime4K_Upscale_CNN_x2_M.glsl`

说明：
- 新增轻量测试项，菜单中默认注释，不影响既有快捷键

## 4. 引用完整性

- 配置中 shader 引用总数：`102`
- 缺失引用：`0`

## 5. 已执行修改

- 从官方 `upstream/main` 补齐 `39` 个新增 shader：`33` 个 `ACNet/ARNet` 文件、`6` 个 `FSRCNNX fastv2` 文件。
- 优化 `input_uosc.conf` 的快捷/常用着色器分类文案。
- 修正 Anime4K profile 的 `profile-desc`。
- 新增 `Anime4K_720P_轻量流畅` profile。

## 6. 明细文件

- `shader-file-compare.csv`：本地 / 20260510 / upstream/main 文件级 hash 对比
- `shader-references.csv`：菜单、profile、mpv.conf 中所有 shader 引用
- `profile-combos.json`：Anime4K profile 组合结构化分析
- `summary.json`：统计摘要
