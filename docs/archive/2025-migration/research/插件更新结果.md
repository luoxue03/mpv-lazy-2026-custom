# Plugin Update Result

Date: 2026-06-09

## Updated Plugins

- portable_config/scripts/sub-fastwhisper.lua
  - Source: dyphire/mpv-sub-fastwhisper via gh API.
  - Change summary: upstream adds compute_type support and path/cache handling fixes.
  - Local script-opts preserved; sub_fastwhisper API key remains unchanged.

- portable_config/scripts/sponsorblock_minimal.lua
  - Source: dyphire/mpv-config/scripts/sponsorblock_minimal.lua via gh API.
  - Change summary: upstream adds video_id reset on file end.

## Verification

- sub-fastwhisper.lua contains compute_type and --compute_type handling.
- sponsorblock_minimal.lua contains video_id = nil cleanup.
- replacement character count is 0 for both scripts.
- script-opts.conf was not changed by this update.
- sub_fastwhisper-api_key length remains 49.
