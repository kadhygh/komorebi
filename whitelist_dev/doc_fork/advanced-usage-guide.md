# 高级使用指南（Fork 版）

> 最后核对日期：2026-03-06

## 文档定位

这份文档是 `whitelist_dev/advanced_usage_guide.md` 的 fork 重写版，目标不是覆盖所有 CLI，而是给出一套**当前可落地、和本 fork 结论一致**的用法。

重点覆盖：

- AHK 与 whkd 如何选
- AHK v2 应该怎么写
- Quickstart 默认值改动后，推荐工作流是什么
- Rider / 多显示器 / whitelist mode 下怎么更稳地使用

## 1. 先给结论

### 1.1 热键工具怎么选

建议按下面理解：

- `whkd`：当前主推、维护中的标准路径
- AutoHotkey：仍可用，但属于 legacy / EOL 兼容路径

如果你只是需要“普通窗口管理热键”，优先用 `whkd`。

如果你需要：

- 条件热键
- 按应用屏蔽热键
- 和 Rider / JetBrains / 特殊软件共存
- 自定义逻辑、脚本、自动化

那么 AHK v2 更适合。

### 1.2 当前 fork 的默认配置策略

本 fork 已将 Quickstart 默认模板改成：

```json
"whitelist_mode": true,
"force_manage": true
```

这意味着：

- 默认更偏“显式纳管”而不是“见窗就管”
- 手动 `manage` / `unmanage` 会更重要

所以 fork 推荐工作流是：

- 主要配置写在 `komorebi.json`
- 热键层根据需求选择 `whkd` 或 AHK
- 对特殊窗口使用 `manage_rules` / `ignore_rules`
- 日常修补配合 `manage` / `unmanage`

## 2. AutoHotkey 的正确定位

## 2.1 不是主线，但依然好用

当前代码里，`--ahk` 会打印 EOL 提示，因此不要把它理解成“上游仍在重点维护的主线功能”。

但这不代表 AHK 不能用。

对 fork 使用者来说，AHK 的价值主要在于：

- 更强的条件判断
- 对 IDE 做前台屏蔽
- 在双显示器 / 特殊应用场景下做更细的热键编排

### 2.2 AHK 自动加载要满足什么条件

AHK 自动加载不是无条件发生的。

实际优先级是：

1. `komorebi.json`
2. `komorebi.ps1`
3. `komorebi.ahk`

因此：

- 有 `komorebi.json` 时，系统主要走静态配置路线
- legacy loader 里如果 `komorebi.ps1` 存在，会优先于 `komorebi.ahk`
- 所以不要把“放了 `komorebi.ahk` 就一定自动接管全部配置”当成默认事实

### 2.3 AHK 可执行文件

默认找的是 `autohotkey.exe`。

如果你的安装方式导致可执行文件名不同，可以设置：

```powershell
$env:KOMOREBI_AHK_EXE = "AutoHotkey64.exe"
```

更稳妥的做法是把它写进 PowerShell profile。

## 3. AHK v2 推荐模板

下面给一个 **AHK v2** 的 fork 示例，不使用旧版 `Run, ...` 语法。

```autohotkey
#Requires AutoHotkey v2.0
#SingleInstance Force

Komorebic(cmd) {
    RunWait('komorebic.exe ' cmd, , 'Hide')
}

#HotIf !WinActive("ahk_exe rider64.exe")

!h::Komorebic("focus left")
!j::Komorebic("focus down")
!k::Komorebic("focus up")
!l::Komorebic("focus right")

!+h::Komorebic("move left")
!+j::Komorebic("move down")
!+k::Komorebic("move up")
!+l::Komorebic("move right")

!Left::Komorebic("stack left")
!Down::Komorebic("stack down")
!Up::Komorebic("stack up")
!Right::Komorebic("stack right")
!;::Komorebic("unstack")
![::Komorebic("cycle-stack previous")
!]::Komorebic("cycle-stack next")

!^h::Komorebic("resize-axis horizontal decrease")
!^l::Komorebic("resize-axis horizontal increase")
!^k::Komorebic("resize-axis vertical decrease")
!^j::Komorebic("resize-axis vertical increase")

#HotIf

#+m::Komorebic("manage")
#+n::Komorebic("unmanage")

#[::Komorebic("focus-monitor 0")
#]::Komorebic("focus-monitor 1")

#1::Komorebic("focus-workspace 0")
#2::Komorebic("focus-workspace 1")
#3::Komorebic("focus-workspace 2")
#4::Komorebic("focus-workspace 3")
#5::Komorebic("focus-workspace 4")
```

这套模板体现的是 fork 推荐思路：

- Rider 前台时，屏蔽大部分窗口操作热键
- monitor 切换、workspace 切换、manage/unmanage 仍然保留
- stack 相关热键用 `Alt + 方向键`

## 4. 启动与自启动建议

## 4.1 fork 推荐顺序

### 推荐方案 A：主流稳定路径

```powershell
komorebic quickstart
komorebic start --whkd --bar
```

适合：

- 想尽量接近上游主推路径
- 不需要复杂脚本条件

### 推荐方案 B：fork 的 AHK 工作流

```powershell
komorebic start --ahk --bar
```

适合：

- 你明确知道自己在用 legacy AHK 路线
- 需要按窗口上下文屏蔽热键
- 要兼容 Rider / JetBrains 等 IDE

### 4.2 自启动

如果你选择 whkd：

```powershell
komorebic enable-autostart --whkd --bar
```

如果你选择 AHK：

```powershell
komorebic enable-autostart --ahk --bar
```

但请记住：AHK 这条路属于 fork 主动采用的高级用法，不代表上游仍在重点维护。

## 5. whitelist mode / force manage 的使用方式

## 5.1 现在默认是开启的

在本 fork 当前 Quickstart 默认模板里，以下两项已经默认开启：

```json
"whitelist_mode": true,
"force_manage": true
```

### 5.2 这会带来什么行为变化

- 不在允许规则里的窗口，默认更容易不被管理
- `manage_rules` 变得更重要
- 日常“临时纳管/取消纳管”操作会更常见

### 5.3 实用命令

```powershell
komorebic manage
komorebic unmanage
komorebic state
```

如果你觉得某个窗口本该被管理却没有被管理，优先检查：

- 是否命中了 `ignore_rules`
- 是否缺少 `manage_rules`
- 是否需要手动 `manage`

## 6. 多显示器工作流建议

## 6.1 为什么会感觉切 workspace 不对劲

最常见误解是：

> 我已经点了另一块屏的窗口，所以 `focus-workspace` 应该切那块屏。

但 `focus-workspace` 的真实语义是：

- 切 **当前 focused monitor** 上的 workspace

不是“光标所在屏幕”，也不是“我肉眼以为当前操作的那块屏”。

### 6.2 fork 推荐热键策略

先显式切 monitor，再切 workspace：

```text
Win + [  -> focus-monitor 0
Win + ]  -> focus-monitor 1
```

如果你想一步到位：

```text
Win + Alt + 1 -> focus-monitor-workspace 0 0
Win + Alt + 2 -> focus-monitor-workspace 0 1
Win + Alt + Q -> focus-monitor-workspace 1 0
Win + Alt + W -> focus-monitor-workspace 1 1
```

### 6.3 排查命令

```powershell
komorebic query focused-monitor-index
komorebic query focused-workspace-index
```

先确认 monitor 是否真的切过去，再判断 workspace 行为。

## 7. Border 的推荐理解

## 7.1 style

```powershell
komorebic border-style square
komorebic border-style rounded
komorebic border-style system
```

推荐理解：

- `rounded`：圆角
- `square`：直角
- `system`：跟系统

### 7.2 implementation

```powershell
komorebic border-implementation komorebi
komorebic border-implementation windows
```

推荐理解：

- `komorebi`：可调边框，更明显
- `windows`：更原生，更轻

### 7.3 fork 推荐组合

如果你要明显可见的焦点边框：

```powershell
komorebic border-implementation komorebi
komorebic border-style square
```

## 8. 日志与故障排查

## 8.1 当前日志位置

当前运行代码实际会写：

- `%TEMP%\komorebi_plaintext.log.YYYY-MM-DD`
- `%TEMP%\komorebi.log.YYYY-MM-DD`

不要只盯 `%LOCALAPPDATA%\komorebi`。

### 8.2 推荐排查步骤

```powershell
Get-Content "$env:TEMP\komorebi_plaintext.log.$((Get-Date).ToString('yyyy-MM-dd'))" -Tail 200
```

搜关键字：

```powershell
Select-String -Path "$env:TEMP\komorebi_plaintext.log.$((Get-Date).ToString('yyyy-MM-dd'))" -Pattern 'panic|deadlock|error|warn' -CaseSensitive:$false
```

### 8.3 如果怀疑不是 crash 而是 stop

注意查看日志里有没有：

- `received stop command`
- `restoring all hidden windows and terminating process`

如果有，通常是被正常停止，而不是“自己崩了”。

## 9. 常用正确命令示例

### 9.1 AHK app specific 配置生成

旧内部文档里有无参数示例，那是不对的。

当前命令要求：

```powershell
komorebic ahk-app-specific-configuration <PATH> [OVERRIDE_PATH]
```

例如：

```powershell
komorebic ahk-app-specific-configuration "$env:USERPROFILE\some-asc.yaml"
```

### 9.2 whkd 配置文件位置

实用上应按当前代码理解为：

```text
%USERPROFILE%\.config\whkdrc
```

不要再沿用旧写法：

```text
%USERPROFILE%\.config\whkd\whkdrc
```

## 10. fork 最终建议

### 如果你追求稳定、少踩上游变更

- `komorebi.json` 管配置
- `whkd` 管热键
- 用 `manage_rules` / `ignore_rules` 控制窗口归类

### 如果你追求灵活、尤其是 IDE 场景

- `komorebi.json` 管窗口规则
- AHK v2 管热键与上下文逻辑
- 保留少量全局热键，避免 Rider 抢键冲突

### 如果你在双显示器下频繁切 workspace

- 不要只依赖 `focus-workspace`
- 显式绑定 `focus-monitor` / `focus-monitor-workspace`

这份文档作为 fork 使用建议，优先级高于旧的 `whitelist_dev/advanced_usage_guide.md`。
