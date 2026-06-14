# 着色器引用文件存在性检查（2026-06-13）

## 扫描范围

- 扫描目录：`F:/mpv_2026/mpv-lazy/portable_config`
- 检查引用：`~~/shaders/...` 下的 `.glsl` / `.hook`
- 引用总数：`105`
- 修复后缺失：`0`

## 修复内容

`profiles.conf` 中 6 组 Anime4K profile 的着色器路径缺少 `Anime4K/` 子目录。已统一修正：

- 修复前：`~~/shaders/Anime4K_Clamp_Highlights.glsl`
- 修复后：`~~/shaders/Anime4K/Anime4K_Clamp_Highlights.glsl`

## 影响文件

- `F:/mpv_2026/mpv-lazy/portable_config/profiles.conf`

## 验证结果

修复后重新扫描全部着色器引用，没有发现缺失文件。
