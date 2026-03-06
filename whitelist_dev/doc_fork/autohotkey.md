# AutoHotkey（Fork 说明）

> 最后核对日期：2026-03-06


## 结论

在这个 fork 的使用语境里，`AutoHotkey` 仍然可用，但应视为 **legacy / EOL 路线**：

- `komorebic start --ahk`、`stop --ahk`、`kill --ahk`、`enable-autostart --ahk` 相关能力仍存在
- 但上游当前代码会明确输出 `--ahk` 已进入 EOL、不会继续获得新功能和 bug fix 的提示
- 如果你只是想要稳定、简单的全局快捷键，优先考虑 `whkd`
- 如果你需要复杂条件、上下文热键、对 IDE 做例外处理，AHK 仍然是更灵活的方案

## 当前代码行为

### 1. AHK 的定位

AHK 不是内建热键系统，而是“**AHK 脚本 + 调用 `komorebic` CLI**”的外部热键方案。

### 2. 文件位置

默认情况下：

- `komorebi.ahk` 放在 `%USERPROFILE%`
- 如果设置了 `KOMOREBI_CONFIG_HOME`，则放在该目录

### 3. 自动加载说明

当前代码里，legacy 配置加载顺序大致是：

1. `komorebi.ps1`
2. `komorebi.ahk`

只有在没有走静态 JSON 配置主路径时，这条 legacy 自动加载链路才更有意义。因此在本 fork 中，**不建议依赖“隐式自动加载”作为主方案**。

更推荐：

- 明确使用 `komorebic start --ahk`
- 或使用 `komorebic enable-autostart --ahk`
- 或者直接自行管理 AHK 脚本启动

## 与 whkd 的取舍

### 适合 `whkd`

- 配置简单
- 热键数量少
- 不需要复杂条件判断
- 希望尽量贴近上游主线维护路径

### 适合 `AutoHotkey`

- 需要上下文热键
- 需要对特定应用禁用/放行快捷键
- 需要脚本能力、流程编排、条件判断
- 需要更容易处理 JetBrains / Rider 一类 IDE 冲突

## 本 fork 的建议

### Rider 场景

这是 **本 fork 的本地工作流建议**，不是上游保证：

- 如果在 Rider 中出现快捷键冲突，优先使用 AHK 而不是 `whkd`
- 推荐使用 `#HotIf WinActive("ahk_exe rider64.exe")` 或其反向条件来限制热键作用域
- 对 Rider 保留的热键建议尽量少，只保留真正需要的全局功能

例如：

- 全局保留 `Win+数字` 切工作区
- 全局保留 `manage` / `unmanage`
- 其余窗口操作热键在 Rider 激活时禁用

## 与本 fork 默认配置的关系

本 fork 已将 Quickstart 模板默认改为：

- `"whitelist_mode": true`
- `"force_manage": true`

这意味着：

- 默认更偏白名单工作流
- AHK 中的 `manage` / `unmanage` 对本 fork 更重要

## 推荐阅读

- `./autostart.md`
- `./multi-monitor-setup.md`
- `./troubleshooting.md`
- `./advanced-usage-guide.md`
- `./project-analysis.md`
