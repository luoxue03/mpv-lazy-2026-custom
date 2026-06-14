# Plugin cleanup and recommendation research

Date: 2026-06-09
Target: `F:\mpv_2026\mpv-lazy`

## Cleanup decision

User decided these plugins are low-value and should be removed:

- `mpv_torrserver`
- `sponsorblock_minimal`

Changes applied:

- Deleted `portable_config/scripts/mpv-torrserver.lua`.
- Deleted `portable_config/scripts/sponsorblock_minimal.lua`.
- Removed `mpv_torrserver-*` entries from `portable_config/script-opts.conf`.
- Removed `sponsorblock_minimal-*` entries from `portable_config/script-opts.conf`.
- Removed stale `script-binding sponsorblock/toggle` comment from `portable_config/input_uosc.conf`.

Validation:

- `rg` found no remaining `mpv_torrserver`, `mpv-torrserver`, `sponsorblock_minimal`, or `script-binding sponsorblock/toggle` references under `portable_config`.
- Runtime validation with the real local video showed no `mpv_torrserver` or `sponsorblock` script loading.
- `sub_fastwhisper`, `recentmenu`, and `uosc` still loaded after cleanup.
- Temporary validation logs were deleted after inspection.

## sub-fastwhisper upstream status

Sources checked via GitHub API:

- `dyphire/mpv-sub-fastwhisper`
- `SYSTRAN/faster-whisper`
- `Purfview/whisper-standalone-win`

Findings:

- `dyphire/mpv-sub-fastwhisper` is still active; latest checked push: `2026-05-30T02:58:35Z`.
- Recent upstream commits include:
  - `2026-05-30 a627d1a`: add `compute_type` option for fastwhisper command.
  - `2026-05-21 6d94980`: fix cache condition logical grouping.
  - `2025-03-09 b9bc817`: streaming support and semi-real-time AI subtitle translation.
- Local `F:\mpv_2026\mpv-lazy\portable_config\scripts\sub-fastwhisper.lua` already contains `compute_type` and matches the current upstream script length observed through GitHub API, so the script body appears already updated.
- The script supports model names: `base`, `small`, `medium`, `large`, `large-v2`, `large-v3`, `turbo`.
- Local `faster-whisper.exe --help` supports `--compute_type` values including `float16`, `int8_float16`, and `int8`.
- Local model directory currently contains:
  - `faster-whisper-tiny`
  - `faster-whisper-base`
  - `faster-whisper-small`
  - `faster-whisper-medium`
  - `faster-whisper-large-v2`
  - `faster-whisper-large-v3`
- Local model directory does not currently contain `turbo` or `distil-large-v3`.

## Model guidance

Recommended default for quality:

- Keep `sub_fastwhisper-model=large-v3`.
- Add `sub_fastwhisper-compute_type=float16` for CUDA if stability is good.
- If VRAM pressure appears, use `int8_float16` instead.

Recommended speed experiment:

- Add/download `turbo` model only if the user wants faster transcription and accepts possible quality loss versus `large-v3`.
- Consider `distil-large-v3` only after confirming the local standalone binary can resolve/download or load that model cleanly; `mpv-sub-fastwhisper` README mentions `turbo` but not `distil-large-v3` in its option comment.

Confidence:

- High for upstream activity and local support of `compute_type`, because verified through GitHub API and local executable help.
- Medium for `turbo` recommendation, because it is supported by the script and faster-whisper, but not present locally.
- Medium/low for `distil-large-v3` inside this mpv script flow, because faster-whisper supports it but this specific script's documented model list does not mention it.

## Plugin recommendation candidates

Recommended to consider:

- `mar04/chapters_for_mpv`: add/edit/remove/save/load chapters, supports saving text/xml and embedding with ffmpeg/mkvpropedit. Fits anime/series workflows better than ad-skip plugins.
- `Ben-Kerman/mpv-sub-scripts`: `sub-pause` and `sub-skip` for subtitle-driven watching/language learning. Useful if the user studies with subtitles; otherwise optional.
- `aidanholm/mpv-easycrop` or `occivink/mpv-scripts/crop.lua`: visual crop tools. Useful for odd aspect ratio videos; overlaps with existing filter workflows, so install only if user wants interactive cropping.
- `jonniek/mpv-playlistmanager`: strong playlist manager by stars/search result. Potentially useful if uosc playlist handling feels insufficient; otherwise redundant.
- `CogentRedTester/mpv-scripts`: selected scripts worth considering individually, especially `sub-select`, `search-page`, `file-browser`, `display-name`, not the whole collection.
- `Eisa01/mpv-scripts`: selected scripts worth considering individually, mainly `SmartSkip`, `SimpleBookmark`, `UndoRedo`; avoid if it overlaps too much with uosc/current keymaps.

Not recommended for this user now:

- SponsorBlock-like plugins, because user explicitly judged them low-value.
- TorrServer integration, because user explicitly removed it and current target lacks service/dependency.
- `mpv-nextfile`, because current uosc/playlist navigation already covers next/previous file behavior.
- Heavy Anki workflows like `Ben-Kerman/immersive`, unless the user explicitly wants language-learning card mining.

## Search limitation

- Exa MCP resource list shows `web_search_exa` and `web_search_advanced_exa` enabled, but this Codex tool panel exposes only MCP resource list/read functions, not a callable Exa search function.
- Therefore, no Exa broad web search was actually executed in this session.
- GitHub project research used `gh` according to the routing rule for GitHub resources.
