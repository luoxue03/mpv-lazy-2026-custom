# API Key Migration Rule

Date: 2026-06-09

## User Decision

Existing local API keys and similar configured values should be migrated as-is. Do not blank, mask, redact, or synthesize replacement values when migrating local configuration files.

## Applied Case

- Source: D:/mpv-lazy-25_install/portable_config/script-opts/sub_fastwhisper.conf
- Target: F:/mpv_2026/mpv-lazy/portable_config/script-opts.conf
- Parameter: sub_fastwhisper-api_key
- Result: migrated as-is into the target file.

## Verification

- Source value exists and is non-empty.
- Target value exists and is non-empty.
- Source and target value length: 49.
- The key value is intentionally not printed in this document.
