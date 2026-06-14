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

## 当前已落地结论

- RIFE 补帧路径优先保证真实播放流畅，而不是追最新版 TensorRT。
- `TensorRT 10.13` 在本机 RIFE 4.15 lite 满高 4K 测试中比 `10.14/10.16` 更稳。
- AnimeJaNai V3.1 超分没有观察到同类 `10.16` 性能回退，但单个 mpv 进程混用两个 TensorRT 运行时不安全，所以当前采用全局 10.13。
- `H_Pre=1920` 是“轻降处理高度”的实用档位：降低约 21% RIFE 处理像素量，保留较多细节，并给 4K 播放更多实时余量。

## 后续建议

- 真实在线 4K 播放验证优先级高于合成 benchmark。
- 如果未来升级 `vs-mlrt`，先新建隔离目录测试，不要直接覆盖主目录 DLL。
- 性能报告要同时记录：模型、分辨率、`turbo`、`flow_scale`、`H_Pre`、TensorRT 版本、是否重新生成 engine。
