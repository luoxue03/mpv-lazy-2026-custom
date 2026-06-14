# 模型接入结果：AnimeJaNai V3.1 与 RIFE 实验项

生成时间：2026-06-11

## 改动范围

目标目录：`F:\mpv_2026\mpv-lazy`

本次只做新增/扩展，不替换现有默认项。

## AnimeJaNai V3.1

新增模型文件到 `vs-plugins\models`：

- `2x_AnimeJaNai_HD_V3.1_Balanced_SPANF3_b8f64_unshuffle_fp16.onnx`
- `2x_AnimeJaNai_HD_V3.1Sharp1_Balanced_SPANF3_b8f64_unshuffle_fp16.onnx`
- `2x_AnimeJaNai_HD_V3.1_Performance_SPANF3_b5f48_unshuffle_fp16.onnx`
- `2x_AnimeJaNai_HD_V3.1Sharp1_Performance_SPANF3_b5f48_unshuffle_fp16.onnx`

新增 VS 预设：

- `portable_config\vs\MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Balanced.vpy`
- `portable_config\vs\MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Balanced_Sharp.vpy`
- `portable_config\vs\MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Performance.vpy`
- `portable_config\vs\MIX_UAI_NV_TRT_AnimeJaNai_V3.1_Performance_Sharp.vpy`

实现策略：

- 复用官方组件 `k7sfunc.UAI_NV_TRT`。
- 不修改 `MIX_UAI_NV_TRT.vpy` 现有默认。
- 按 AnimeJaNai 3.3.0 的倾向使用静态 TensorRT engine：`St_Eng=True`。
- 预设面向 `1080p -> 4K` 动画超分；原生 4K 会先限制到 1080 后再 2x，不建议叠加到 4K 原画上。

菜单新增为无快捷键 uosc 菜单项：

- `VF Filters > Super Resolution > 2026 > AnimeJaNai V3.1 > Balanced standard (quality-first)`
- `VF Filters > Super Resolution > 2026 > AnimeJaNai V3.1 > Balanced Sharp (sharper edges)`
- `VF Filters > Super Resolution > 2026 > AnimeJaNai V3.1 > Performance standard (speed-first)`
- `VF Filters > Super Resolution > 2026 > AnimeJaNai V3.1 > Performance Sharp (speed+sharp)`

## RIFE 实验项

新增模型文件到 `vs-plugins\models\rife`：

- `rife_v4.7.onnx`
- `rife_v4.8.onnx`
- `rife_v4.9.onnx`

修改 `Lib\site-packages\k7sfunc\mod_memc.py`：

- 扩展 `RIFE_NV` / `RIFE_DML` / `RIFE_COREML` / `RIFE_ORT_HUB` 的模型枚举，加入 `47`、`48`、`49`。
- 扩展模型名映射，支持 `rife_v4.7`、`rife_v4.8`、`rife_v4.9`。
- 给 `RIFE_NV` 新增可选参数 `flow_scale`。
- `flow_scale != 1.0` 禁止用于 `RIFE 4.7+`，符合 vs-mlrt 限制。

新增 VS 预设：

- `portable_config\vs\MEMC_RIFE_NV_4.7_exp.vpy`
- `portable_config\vs\MEMC_RIFE_NV_4.8_exp.vpy`
- `portable_config\vs\MEMC_RIFE_NV_4.9_exp.vpy`
- `portable_config\vs\MEMC_RIFE_NV_4.6_4K_scale0.5.vpy`

重要说明：

- `4.7/4.8/4.9` 是实验项，用于平移、细线、动画场景对比，不设为默认。
- `4.6_4K_scale0.5` 是真正的 4K 流畅优先项；`scale=0.5` 降低光流处理分辨率，可能降低插帧细节。
- 没有创建 `4.25_lite scale=0.5` 项，因为当前 `vs-mlrt` 对对应路径限制较多，强行标注会误导。

同时修正：

- `portable_config\vs\MEMC_RIFE_NV_4.26.vpy` 原文件名为 4.26，但内部 `Model = 46`，已修正为 `Model = 426`。

菜单新增为无快捷键 uosc 菜单项：

- `VF Filters > Interpolation > 2026 > RIFE Experiments > 4.6 4K smooth-first (scale=0.5, less detail)`
- `VF Filters > Interpolation > 2026 > RIFE Experiments > 4.7 pan/fine-line test`
- `VF Filters > Interpolation > 2026 > RIFE Experiments > 4.8 anime test`
- `VF Filters > Interpolation > 2026 > RIFE Experiments > 4.9 mixed anime/live test`

## 验证

- Python 编译检查通过：`mod_memc.py` 与新增 `.vpy` 均可编译。
- 模型存在检查通过：V3.1 四个 ONNX 与 RIFE 4.7/4.8/4.9 均存在。
- `input_uosc.conf` 新增菜单项无乱码。
- 新增 `.vpy` 文件无乱码。

## 待实测

首次运行 V3.1 与 RIFE 实验项会触发 TensorRT engine 生成，可能耗时较长。建议先用同一段 4K 问题片源依次测试：

1. 当前 `4.25_lite` 作为基准。
2. `4.6 4K smooth-first` 看是否解决华丽场景掉帧。
3. `4.7/4.8/4.9` 看是否改善楼梯、细线、平移糊影。
4. `AnimeJaNai V3.1 Balanced` 与 `Balanced Sharp` 看超分质量和锐化程度。

