# MPV plugin wide search

Date: 2026-06-10
Purpose: broaden plugin/script research beyond the current local scenario and produce a candidate pool for user selection.

## Sources

- Exa search: `best mpv scripts plugins user scripts recommended GitHub high stars`
- Exa advanced search: `mpv user scripts recommended subtitles playlist chapters crop thumbnails search menu quality of life`
- Exa fetch: `https://github.com/stax76/awesome-mpv`
- Exa fetch: `https://nudin.github.io/mpv-script-directory/`
- GitHub CLI search: `topic:mpv-script`, sorted by stars
- GitHub CLI search: `mpv lua script`, sorted by stars
- GitHub README checks performed earlier for selected repositories:
  - `dyphire/mpv-sub-fastwhisper`
  - `SYSTRAN/faster-whisper`
  - `Purfview/whisper-standalone-win`
  - `Eisa01/mpv-scripts`
  - `occivink/mpv-scripts`
  - `mar04/chapters_for_mpv`
  - `aidanholm/mpv-easycrop`
  - `Ben-Kerman/mpv-sub-scripts`
  - `Ben-Kerman/immersive`
  - `CogentRedTester/mpv-scripts`

## Important search notes

- Exa MCP search is usable in this session; it returned useful broad results including `stax76/awesome-mpv`, `tomasklaen/uosc`, `po5/thumbfast`, mpv official Wiki User Scripts, and mpv script directory.
- `mpv-script-directory` fetch exposed only the page header and table header through Exa fetch; the official mpv Wiki and `awesome-mpv` gave richer content.
- GitHub search query `topic:mpv-script` produced high-quality mpv-specific results. Query `topic:mpv scripts` was polluted by unrelated repositories and should be weighted lower.
- Stars are useful for initial ranking, but many mpv scripts live inside multi-script repositories; per-script popularity can be overstated or understated.

## Already present or functionally covered

These should not be installed again unless replacing the current implementation is intentional.

| Area | Existing local coverage | Notes |
| --- | --- | --- |
| Modern menu/OSC | `uosc` | Already active. Alternative OSCs such as `ModernZ`, `mpv-osc-modern`, `oscc`, `mpv_thumbnail_script` would overlap heavily. |
| Thumbnails | `thumb_engine`, `thumbfast_2025` | `po5/thumbfast` is high-star, but current 2026 setup already has thumbnail integration. |
| Recent/history menu | `recentmenu` | Alternatives include `po5/memo`, `recent-menu`, `hacel/recent`, `SimpleHistory`, but installing them now likely duplicates behavior. |
| Stream quality menu | `quality-menu` + uosc stream-quality integration | Keep unless it fails in real web video use. |
| AI subtitle generation | `sub-fastwhisper.lua` | Current script already has 2026 upstream `compute_type` support. |
| Input event helper | `inputevent.lua` | GitHub high-star `natural-harmonia-gropius/input-event` appears related; local copy already exists. |

## Strong candidates for user selection

These are worth considering because they add distinct behavior not fully covered by current setup.

| Candidate | Source | Why it matters | Risk / overlap |
| --- | --- | --- | --- |
| `mar04/chapters_for_mpv` | GitHub, awesome-mpv, official Wiki | Add/edit/remove/save/load chapters; can save sidecar text/xml and embed into MKV with tools. Useful for anime/series where chapter metadata is missing or wrong. | Needs keymap design. Embedding chapters requires external tools such as ffmpeg/mkvpropedit. |
| `po5/chapterskip` | GitHub, awesome-mpv | Skip chapters by title, useful for OP/ED/preview style chapters. | Similar to ad/intro skip; only useful if files have reliable chapter names. |
| `po5/trackselect` or `CogentRedTester/mpv-sub-select` | GitHub, awesome-mpv | More deterministic audio/subtitle track selection based on title/language rules. | Must not fight existing `slang`, `alang`, uosc track menus, or mpv-lazy profiles. |
| `davidde/mpv-autosub` | GitHub, official Wiki | Fully automatic subtitle downloading. | uosc already supports OpenSubtitles download; external dependencies/accounts may be needed. |
| `Tony15246/uosc_danmaku` | GitHub high-star | DanDanPlay danmaku integration based on uosc, relevant to anime/Bilibili-style viewing. | External API/network dependency; may be redundant with existing `bilibiliAssert`. |
| `TheAMM/mpv_crop_script` or `aidanholm/mpv-easycrop` | GitHub, official Wiki | Interactive cropped screenshots or visual crop during playback. | Overlaps with existing screenshot/filter workflows; key conflicts likely. |
| `aerobounce/trim.lua`, `Ajatt-Tools/videoclip`, `Sagnac/streamsave` | GitHub high-star/search | Clip/export workflows from inside mpv. | Requires clear workflow and ffmpeg; can add complexity quickly. |
| `CogentRedTester/mpv-search-page` | GitHub, awesome-mpv | Search keybindings, commands, properties, options in OSD. Useful during heavy custom config migration. | Requires `scroll-list` and `user-input`; uosc already has searchable menus but not necessarily full command/property search. |
| `tsl0922/mpv-menu-plugin` | GitHub high-star, awesome-mpv | Windows context menu, file dialog, clipboard support. | C/plugin dependency and overlap with uosc/menu setup. Test in isolated branch if considered. |
| `Eisa01/mpv-scripts`: `UndoRedo`, `SimpleBookmark`, `SmartSkip` | GitHub, Exa, README | Undo seeks, bookmark points, or smart OP/ED/silence/chapter skipping. | SmartSkip overlaps with chapter skip workflows; install selected scripts only, not the whole collection. |

## Conditional candidates

Install only if the specific workflow is desired.

| Candidate | When to consider |
| --- | --- |
| `Ben-Kerman/mpv-sub-scripts` | Language learning or subtitle-driven viewing: auto-pause per subtitle line, replay line, skip no-subtitle gaps. |
| `oltodosel/interSubs`, `EnergoStalin/subtitle-translate-mpv` | Interactive subtitle translation or word/sentence lookup inside mpv. |
| `Ajatt-Tools/mpvacious`, `Ben-Kerman/immersive`, `SubMiner`, `Yomipv` | Anki mining / Japanese learning workflows. High setup cost; not general viewing plugins. |
| `jonniek/mpv-playlistmanager` | If current uosc playlist handling is insufficient for long playlist management. |
| `CogentRedTester/mpv-file-browser` | If uosc file browser is insufficient or unavailable. |
| `po5/evafast`, `skip-silence`, `ff-silence` | If fast-forwarding through quiet/no-subtitle parts is useful. |
| `po5/mpv_manager` | If user wants script/shader management inside mpv instead of Git/manual file management. |
| `verygoodlee/mpv-pip` | If Windows picture-in-picture is desired. |
| `cvzi/mpv-youtube-upnext`, `cvzi/mpv-youtube-download` | If YouTube-in-mpv workflow matters. Requires yt-dlp/network. |
| `simple-mpv-webui` | If remote control from phone/browser is desired. |

## Not recommended now

| Candidate | Reason |
| --- | --- |
| SponsorBlock variants | User explicitly removed `sponsorblock_minimal` as low-value. |
| TorrServer/webtorrent/btfs hooks | User removed TorrServer integration; torrent streaming is not part of the desired current workflow. |
| Alternative OSCs (`ModernZ`, `mpv-osc-modern`, `oscc`, `tethys`) | Current 2026 config is uosc-centric. Replacing OSC would be a major UI migration. |
| `mpv_thumbnail_script` | High-star but old and overlaps with current uosc/thumb integration. |
| `mpv-nextfile` | uosc and current bindings already provide next/previous file behavior. |
| `mpv-mpris` | Linux-specific; current target is Windows. |

## Practical shortlist

If only a small number should be evaluated next, use this order:

1. `mar04/chapters_for_mpv`
2. `CogentRedTester/mpv-sub-select` or `po5/trackselect`
3. `Tony15246/uosc_danmaku` after comparing against current `bilibiliAssert`
4. `CogentRedTester/mpv-search-page`
5. `TheAMM/mpv_crop_script` or `aidanholm/mpv-easycrop`
6. `Eisa01/mpv-scripts` selected script only: `UndoRedo` or `SimpleBookmark`
7. `Ben-Kerman/mpv-sub-scripts` if subtitle-driven watching is wanted

