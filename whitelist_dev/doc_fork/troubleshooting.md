# 故障排查（Fork 说明）

## 1. AHK 能用，但要知道它是 legacy/EOL

如果你看到 `komorebic start --ahk` 还能工作，这并不代表它仍是上游主推路径。

当前代码行为是：

- AHK 仍可用
- 但 `--ahk` 会输出 EOL 提示
- 更维护中的路径仍然是 `whkd`

### 什么时候仍然推荐 AHK

在本 fork 中，以下场景仍然推荐 AHK：

- 需要复杂热键逻辑
- 需要对 Rider / JetBrains 做例外控制
- 需要上下文热键与脚本能力

## 2. `could not find autohotkey`

如果你遇到：

```text
could not find autohotkey, please make sure it is installed before using the --ahk flag
```

处理方式：

- 确认 AHK 已安装
- 确认可执行文件名称
- 必要时设置环境变量 `KOMOREBI_AHK_EXE`

## 3. 日志到底在哪

这个 fork 当前核对到的实际情况是：

- 日志在 `%TEMP%`
- 常见文件名：
  - `komorebi.log.YYYY-MM-DD`
  - `komorebi_plaintext.log.YYYY-MM-DD`

不要只盯旧文档里的 `%LOCALAPPDATA%\komorebi\komorebi.log`。

### 常用查看方式

```powershell
Get-ChildItem $env:TEMP -Filter 'komorebi*.log*'
Get-Content $env:TEMP\komorebi_plaintext.log.2026-03-06 -Tail 200
```

## 4. 进程“像是崩了”，但其实可能是被 stop 了

如果你怀疑 `komorebi` 自己崩溃了，先看日志里是否有：

- `panic`
- `thread panicked`
- `deadlock`
- 或者明确的 `received stop command`

本 fork 的实际排查里，曾出现“看起来像崩溃”，但日志显示其实是收到了 `Stop` 命令后正常终止。

## 5. 双屏切工作区切错了

这是本 fork 当前最常见的多显示器问题之一。

### 现象

- 你在另一块屏选中了窗口
- 但 `Win+数字` / `focus-workspace` 仍然切了当前屏

### 原因

`focus-workspace` 只作用于 **focused monitor**。

### 解决建议

优先使用：

```powershell
komorebic focus-monitor 0
komorebic focus-monitor 1
komorebic focus-monitor-workspace 1 2
```

## 6. Rider 中热键冲突

这是 **本 fork 的本地经验结论**，不是上游保证。

### 现象

- `whkd` 在 Rider 中导致部分快捷键失效
- 输入响应异常
- 有时会感觉卡顿

### 建议

- 如果你的主工作场景是 Rider，优先尝试 AHK
- 用 `#HotIf` 对 Rider 做窗口级热键限制
- 只保留真正需要的全局热键，例如：
  - `Win+数字`
  - `manage` / `unmanage`
  - `focus-monitor`

## 7. Quickstart 之后为什么默认就是白名单模式

这是本 fork 的定制改动，不是上游默认值。

当前 fork 的 Quickstart 模板默认包含：

```json
"whitelist_mode": true,
"force_manage": true
```

所以 `komorebic quickstart` 后生成的新 `komorebi.json` 会直接进入更偏白名单的行为模式。

## 推荐阅读

- `./autohotkey.md`
- `./autostart.md`
- `./multi-monitor-setup.md`
