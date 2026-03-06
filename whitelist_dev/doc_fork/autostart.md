# 自动启动（Fork 说明）

## 目标

本页描述这个 fork 下更推荐的启动方式，而不是逐字重复上游 CLI 帮助。

## 推荐顺序

### 方案 1：`whkd` 主线方案

适合：

- 你不需要复杂脚本逻辑
- 希望尽量贴近上游当前维护方向

常见组合：

```powershell
komorebic enable-autostart --whkd --bar
```

### 方案 2：AHK 兼容方案

适合：

- 你已经决定用 AHK 做主热键层
- 你需要复杂条件、IDE 例外规则

常见组合：

```powershell
komorebic enable-autostart --ahk --bar
```

但请注意：

- `--ahk` 属于 **legacy / EOL 路线**
- 仍可用，但不建议把它理解为上游主推方案

## 本 fork 的默认配置变化

本 fork 已修改 Quickstart 模板，执行 `komorebic quickstart` 后生成的 `komorebi.json` 将默认包含：

```json
"whitelist_mode": true,
"force_manage": true
```

这意味着：

- 初始行为默认偏“白名单 + 手动管理强化”
- 如果你使用 AHK，建议尽早为 `manage` / `unmanage` 配热键

## 选择建议

### 想要稳妥跟随上游

推荐：

- `komorebic enable-autostart --whkd`

### 想要 IDE 友好与脚本能力

推荐：

- `komorebic enable-autostart --ahk`
- 同时在 AHK 中写应用级条件限制

## 注意事项

### 1. AHK 自动加载

如果你打算依赖 legacy 的 `komorebi.ahk` 自动加载，请额外注意：

- `komorebi.ps1` 的优先级更高
- 静态 JSON 配置路径与 legacy 加载链并不是一回事
- 本 fork 更建议显式启动，而不是依赖“自动探测后加载”

### 2. `whkd` 配置路径

`whkd` 相关配置请以 `~/.config/whkdrc` 为准，不要使用过时的 `~/.config/whkd/whkdrc` 写法。

### 3. 日志位置

当前代码实际日志在 `%TEMP%`，不是旧文档里常见的 `%LOCALAPPDATA%\komorebi\komorebi.log`。

## 推荐阅读

- `./autohotkey.md`
- `./troubleshooting.md`
