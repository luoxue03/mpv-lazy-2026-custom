# k7sfunc MVT_STD Compatibility Decision

Date: 2026-06-09

## User Decision

Do not add a strong compatibility shim for MVT_STD. The 2026 k7sfunc package no longer supports MVT_STD, and forcing the old 2025 function back into the new package may increase maintenance and runtime risk.

## Applied State

- MVT_STD compatibility code that was temporarily drafted was removed before commit.
- ESRGAN_NV is also not restored.
- 2025 VS presets that reference MVT_STD or ESRGAN_NV remain as preserved files/reference material.
- Active input_uosc bindings now follow 2026 official presets, so MVT_STD is not on the active shortcut path.

## Verification

- mod_memc.py has no uncommitted diff from the temporary MVT_STD draft.
- Existing RIFE model compatibility patch remains in prior commits.
