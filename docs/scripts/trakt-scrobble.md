# trakt-scrobble 使用说明

## 1. 介绍

`trakt-scrobble` 是 mpv 的 Trakt.tv 同步脚本，用于把正在播放的电影/剧集同步到 Trakt。脚本会在视频播放时尝试识别片名、季集信息，开始 scrobble；暂停或播放结束时停止同步。

依赖/相关仓库：

- trakt-scrobble 上游：https://github.com/dyphire/trakt-scrobble
- Trakt 官网：https://trakt.tv

当前整合包已接入菜单和快捷键：

```text
工具 > Trakt > 搜索匹配
工具 > Trakt > 开关同步
工具 > Trakt > 授权登录
工具 > Trakt > 完成授权
```

## 2. 文件介绍

| 文件/目录 | 作用 |
|---|---|
| `portable_config/scripts/trakt-scrobble/main.lua` | 脚本入口，负责授权、搜索匹配、开始/停止 scrobble。 |
| `portable_config/scripts/trakt-scrobble/modules/` | base64、标题猜测、菜单等内部模块。 |
| `portable_config/scripts/trakt-scrobble/imgs/` | 上游说明图片。 |
| `portable_config/scripts/trakt-scrobble/README.md` | 上游英文说明。 |
| `portable_config/trakt_config.json` | 授权 token 等运行态配置，自动生成，不应提交。 |
| `portable_config/trakt_history.json` | 手动匹配历史，自动生成，不应提交。 |
| `portable_config/input_uosc.conf` | Trakt 菜单与快捷键定义。 |

## 3. 配置

脚本内默认配置：

```lua
enabled = true
congfig_path = "~~/trakt_config.json"
history_path = "~~/trakt_history.json"
max_title_length = 100
```

当前使用脚本内置 Trakt API client。一般不需要自行配置。

如果你想使用自己的 Trakt API：

1. 打开 https://trakt.tv/oauth/applications 创建应用。
2. 获取 `client_id` 和 `client_secret`。
3. Base64 后替换脚本配置或放入脚本配置文件。

注意：`trakt_config.json` 和 `trakt_history.json` 是个人运行态文件，已被 `.gitignore` 忽略。

## 4. 使用

### 首次授权

1. 打开任意视频。
2. 进入 `工具 > Trakt > 授权登录`。
3. mpv 会显示类似 `https://trakt.tv/activate/XXXXXX` 的地址或验证码。
4. 在浏览器打开该地址，登录 Trakt 并输入验证码。
5. 回到 mpv，选择 `工具 > Trakt > 完成授权`，或按 `Ctrl+Alt+r`。
6. 成功后会生成 `portable_config/trakt_config.json`。

如果验证码过期，需要重新执行 `授权登录` 获取新 code。

### 日常同步

- 脚本默认启用，视频加载后会尝试自动识别并 scrobble。
- 暂停或播放结束时会停止/更新同步状态。
- 如果识别错误，可进入 `工具 > Trakt > 搜索匹配` 手动选择正确条目。

### 菜单与快捷键

| 入口 | 命令 | 作用 |
|---|---|---|
| `Alt+d` | `script-message-to trakt_scrobble search-menu` | 打开搜索匹配菜单。 |
| `Alt+D` | `script-message-to trakt_scrobble toggle-scrobble` | 开关当前同步。 |
| `Ctrl+Alt+r` | `script-message-to trakt_scrobble complete-auth` | 完成授权；也会在识别失败时临时用作搜索菜单快捷键。 |
| `工具 > Trakt > 授权登录` | `script-message-to trakt_scrobble auth-menu` | 获取 Trakt 设备授权 code。 |

## 5. 常见错误

### 第二次授权提示 code expired

如果你已经成功授权，第二次再用旧 code 登录提示过期是正常现象。真正要看的是 `完成授权` 后是否生成/更新 `trakt_config.json`，以及播放时是否能 scrobble。

### `Ctrl+Alt+r` 无反应

- 当前没有处于等待授权或等待搜索纠错状态。
- 快捷键被其他脚本或系统占用。
- 菜单命令未加载。

处理：直接使用 `工具 > Trakt > 完成授权` 或 `工具 > Trakt > 搜索匹配`。

### 同步到了错误的电影/剧集

- 文件名无法准确解析。
- Trakt 搜索结果误匹配。

处理：使用 `Alt+d` 或 `工具 > Trakt > 搜索匹配`，选择正确条目；选择结果会写入 `trakt_history.json`。

### 完全不同步

- 未完成授权。
- 网络无法访问 Trakt API。
- `trakt_config.json` 过期或损坏。

处理：删除本地 `portable_config/trakt_config.json` 后重新授权。

