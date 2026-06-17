# 调研报告索引

这里收纳人工整理的研究、测试和决策记录。阅读优先级按“越接近当前落地状态越靠前”。

## 推荐阅读顺序

1. [RIFE 4.15 lite 丢帧调查与修复记录（2026-06-14）](RIFE-performance-investigation-2026-06-14.md)
   - 当前最重要的性能修复记录。
   - 包含 2025/2026 差异、TensorRT 10.11–10.16 对比、超分兼容性测试、最终选择 TensorRT 10.13 的理由。
   - 需要回滚或继续升级 `vs-mlrt` 时先看这份。

2. [TensorRT 深度调研参考](deep-research-report.md)
   - 作为外部调研/假设库使用，不等同于本机已验证结论。
   - 适合继续做 TensorRT 算子级定位、`trtexec`/`nsys` 深挖时参考。

3. [着色器审计报告（2026-06-15）](shader-audit-2026-06-15/README.md)
   - 对比本地、官方 `20260510`、官方 `main` 的 shader 文件。
   - 记录 UI 分类、Anime4K 组合、引用完整性和已补齐的 ACNet/FSRCNNX 文件。

4. [真人/通用超分与补帧组合接入总结（2026-06-17）](live-action-upscale-and-rife-combo-2026-06-17.md)
   - 记录 RealESRGAN General x4v3、LiveAction SPAN、StarSample 的接入和菜单归类。
   - 记录 RealESRGAN + RIFE 组合的实测取舍：保留 `4.6 T1 F0.25`，删除丢帧的 `4.15 lite` 与 `4.6 T1 F0.5`。

5. [External Player 与 HLS 清晰度菜单接入记录（2026-06-16）](external-player-hls-quality-menu-2026-06-16.md)
   - 记录 MissAV 直连 HLS 拉起 MPV、403 避免方式、`quality-menu.lua` 通用 HLS editions 清晰度菜单实现。
   - 后续升级 `external_player.js` 或 `quality-menu.lua` 时需要先看这份，避免丢失本地补丁。

## 当前已落地结论

- RIFE 补帧路径优先保证真实播放流畅，而不是追最新版 TensorRT。
- `TensorRT 10.13` 在本机 RIFE 4.15 lite 满高 4K 测试中比 `10.14/10.16` 更稳。
- AnimeJaNai V3.1 超分没有观察到同类 `10.16` 性能回退，但单个 mpv 进程混用两个 TensorRT 运行时不安全，所以当前采用全局 10.13。
- `H_Pre=1920` 是“轻降处理高度”的实用档位：降低约 21% RIFE 处理像素量，保留较多细节，并给 4K 播放更多实时余量。
- `RealESRGAN General x4v3 540P→4K + RIFE` 组合目前只保留 `4.6 T1 F0.25` 作为真实播放可用档；`4.7/4.9 T2 F1` 保留为需超高性能的新版对比项。
- 直接 HLS `.m3u8/.m3u` 流的清晰度菜单优先使用 MPV `edition-list` / `edition`；没有 editions 时再回退到 `track-list` / `hls-bitrate`。这条逻辑不绑定 MissAV 域名，不影响 B 站等 yt-dlp 路径。

## 后续建议

- 真实在线 4K 播放验证优先级高于合成 benchmark。
- 如果未来升级 `vs-mlrt`，先新建隔离目录测试，不要直接覆盖主目录 DLL。
- 性能报告要同时记录：模型、分辨率、`turbo`、`flow_scale`、`H_Pre`、TensorRT 版本、是否重新生成 engine。
