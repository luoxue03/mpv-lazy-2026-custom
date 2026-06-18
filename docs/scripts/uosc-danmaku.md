# uosc_danmaku 使用说明

## 1. 介绍

`uosc_danmaku` 是 mpv 弹幕插件，基于 uosc UI 框架和弹弹play API，可在 mpv 内搜索、加载、开关和调整弹幕。

当前整合包中它用于补充/替代部分 B 站弹幕体验，并支持网络视频自动加载弹幕。配置已按当前整合包样式做过调整，例如字体、透明度、显示区域、滚动速度和 `vf_fps`。

依赖/相关仓库：

- uosc_danmaku 上游：https://github.com/Tony15246/uosc_danmaku
- uosc 上游：https://github.com/tomasklaen/uosc
- url-scheme-handler 本地维护：https://github.com/luoxue03/url-scheme-handler?tab=readme-ov-file
- external-player 本地维护：https://github.com/luoxue03/external-player

## 2. 文件介绍

| 文件/目录 | 作用 |
|---|---|
| `portable_config/scripts/uosc_danmaku/main.lua` | 插件入口，注册弹幕搜索、开关、保存、延迟、样式等消息。 |
| `portable_config/scripts/uosc_danmaku/apis/` | 弹幕 API 适配，例如弹弹play与扩展服务。 |
| `portable_config/scripts/uosc_danmaku/sites/` | 站点适配，例如 Bilibili、巴哈姆特、爱奇艺、芒果、腾讯、优酷。 |
| `portable_config/scripts/uosc_danmaku/modules/` | 菜单、渲染、解析、哈希、压缩、工具函数等内部模块。 |
| `portable_config/scripts/uosc_danmaku/dicts/` | 简繁转换字典。 |
| `portable_config/scripts/uosc_danmaku/README.md` | 插件上游说明。 |
| `portable_config/script-opts/uosc_danmaku.conf` | 当前整合包的弹幕插件配置。 |
| `portable_config/input_uosc.conf` | 菜单入口定义：`工具 > 弹幕 > ...`。 |

## 3. 配置

当前配置文件：`portable_config/script-opts/uosc_danmaku.conf`。

当前关键配置：

```ini
api_server=https://api.dandanplay.net
auto_load=no
autoload_for_url=yes
vf_fps=yes
opacity=0.55
fontname=SimHei
fontsize=16
bold=yes
outline=1
shadow=0
displayarea=0.05
scrolltime=10
fixtime=5
history_path=~~/_cache/danmaku-history.json
```

说明：

- `autoload_for_url=yes`：网络视频可尝试自动加载弹幕。
- `auto_load=no`：本地番剧记忆型自动加载默认关闭，避免误匹配。
- `vf_fps=yes`：启用弹幕帧率相关处理，用于补帧后弹幕速度/帧率适配。
- `displayarea=0.05`：弹幕显示区域较小，避免覆盖画面过多。
- `opacity=0.55`：弹幕透明度。
- `history_path=~~/_cache/danmaku-history.json`：弹幕历史缓存路径，属于运行态。

如要恢复更密集的弹幕区域，可以提高 `displayarea`；如觉得弹幕过快/过慢，调整 `scrolltime`。

## 4. 使用

当前菜单入口位于 `工具 > 弹幕`：

| 菜单项 | 对应命令 | 作用 |
|---|---|---|
| `BilibiliAssert 开关 (b)` | `script-binding bilibiliAssert/toggle` | 开关旧 B 站弹幕脚本。 |
| `搜索弹幕` | `script-message open_search_danmaku_menu` | 打开搜索弹幕菜单。 |
| `开关弹幕 开关 (j)` | `script-message show_danmaku_keyboard` | 显示/隐藏弹幕。 |
| `弹幕设置` | `script-message open_add_total_menu` | 打开弹幕设置总菜单。 |

基础流程：

1. 打开视频。
2. 打开 `工具 > 弹幕 > 搜索弹幕`。
3. 输入番剧名或选择匹配结果。
4. 选择剧集。
5. 弹幕加载后可用 `开关弹幕` 显示/隐藏。
6. 如弹幕时间不准，进入弹幕设置调整延迟。

网络视频流程：

1. 用 `external_player.js` 从网页拉起 mpv。
2. 对支持 URL 自动识别的站点，插件会尝试自动加载弹幕。
3. 如果自动加载失败，手动进入 `搜索弹幕`。

## 5. 常见错误

### 搜索弹幕没有结果

- 弹弹play API 变更或网络不可达。
- 标题识别不准确。
- 当前视频不是动画/番剧类资源，弹幕库没有匹配项。

处理：手动改关键词搜索；确认网络能访问 `api.dandanplay.net`。

### 补帧后弹幕速度不对

- 确认 `vf_fps=yes`。
- 若仍异常，先清空当前 VF，确认是补帧组合还是弹幕插件自身问题。
- 某些超分+补帧组合负载很高，可能导致画面与弹幕感知不同步。

### 弹幕区域太大或太小

调整 `displayarea`。值越大，可显示弹幕的区域越高；当前整合包偏向低遮挡。

### 网络视频自动加载失败

- 站点不在插件支持范围。
- `external_player.js` 没有传入足够的 URL / 标题 / cid 信息。
- URL 是中转链接或临时流，插件无法识别原站。

处理：手动搜索弹幕；B 站场景确认 external_player args 中是否包含 `cid`。

