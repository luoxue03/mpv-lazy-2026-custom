# Active Filter Model Validation

Date: 2026-06-09

## Scope

Static validation for active vapoursynth filters currently bound by input_uosc.conf.
This checks preset files, required plugin DLLs, and model files. It does not perform GPU runtime execution.

## Checks

- [OK] MEMC_MVT_LQ plugin: vs-plugins\mvtools.dll (9587200 bytes) - mvtools plugin for MVT_LQ
- [OK] MEMC_RIFE_DML plugin: vs-plugins\vsort.dll (3451904 bytes) - core.ort plugin for DML backend
- [OK] MEMC_RIFE_DML plugin: vs-plugins\akarin.dll (22096384 bytes) - akarin plugin for RIFE DML
- [OK] MEMC_RIFE_DML model: vs-plugins\models\rife_v2\rife_v4.6.onnx (21297017 bytes) - RIFE_DML model=46 turbo=True
- [OK] MEMC_RIFE_NV plugin: vs-plugins\vstrt.dll (892928 bytes) - core.trt plugin for NV backend
- [OK] MEMC_RIFE_NV plugin: vs-plugins\akarin.dll (22096384 bytes) - akarin plugin for RIFE NV
- [OK] MEMC_RIFE_NV model: vs-plugins\models\rife_v2\rife_v4.6.onnx (21297017 bytes) - RIFE_NV model=46 turbo=2
- [OK] MEMC_DRBA_DML plugin: vs-plugins\vsort.dll (3451904 bytes) - core.ort plugin for DRBA DML
- [OK] MEMC_DRBA_DML plugin: vs-plugins\akarin.dll (22096384 bytes) - akarin plugin for DRBA DML
- [OK] MEMC_DRBA_DML model: vs-plugins\models\drba\distilDRBA_v2_lite_scale_ap_fp16.onnx (10736627 bytes) - DRBA_DML model=2 turbo=2
- [OK] MEMC_DRBA_NV plugin: vs-plugins\vstrt.dll (892928 bytes) - core.trt plugin for DRBA NV
- [OK] MEMC_DRBA_NV plugin: vs-plugins\akarin.dll (22096384 bytes) - akarin plugin for DRBA NV
- [OK] MEMC_DRBA_NV model: vs-plugins\models\drba\distilDRBA_v2_lite_ap.onnx (21334257 bytes) - DRBA_NV model=2 turbo=1
- [OK] MIX_UAI_DML plugin: vs-plugins\vsort.dll (3451904 bytes) - core.ort plugin for UAI DML
- [OK] MIX_UAI_DML model: vs-plugins\models\the_database_AnimeJaNaiV2L1_x2_fp16_op17.onnx (94436 bytes) - UAI_DML model_pth
- [OK] MIX_UAI_NV_TRT plugin: vs-plugins\vstrt.dll (892928 bytes) - core.trt plugin for UAI NV TRT
- [OK] MIX_UAI_NV_TRT model: vs-plugins\models\the_database_AnimeJaNaiV2L1_x2_fp16_op17.onnx (94436 bytes) - UAI_NV_TRT model_pth

## Result

All statically required active filter plugin/model files exist.

## Boundary

Runtime availability still depends on VapourSynth plugin loading, GPU backend support, and driver/runtime compatibility. A real mpv/VapourSynth run is still needed for final confirmation.
