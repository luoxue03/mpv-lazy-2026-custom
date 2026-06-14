# Active VS Path Validation

Date: 2026-06-09

## Scope

Validate current active vapoursynth bindings from target input_uosc.conf after switching approved keys to 2026 official behavior.

## Active VS Bindings

- ! -> vs/MEMC_MVT_LQ.vpy
- @ -> vs/MEMC_RIFE_DML.vpy
- SHARP -> vs/MEMC_DRBA_DML.vpy
- $ -> vs/MEMC_RIFE_NV.vpy
- % -> vs/MEMC_DRBA_NV.vpy
- ^ -> vs/MIX_UAI_DML.vpy
- & -> vs/MIX_UAI_NV_TRT.vpy

## Result

- All active VS preset files exist.
- None of the active VS presets reference MVT_STD.
- None of the active VS presets reference ESRGAN_NV.
- Missing functions MVT_STD and ESRGAN_NV only affect preserved inactive/legacy VS presets.

## Decision Impact

Do not restore MVT_STD or ESRGAN_NV into the 2026 k7sfunc package. Keep legacy presets as references unless the user explicitly reactivates them later.
