# Komorebi 高级使用指南

## 问题 1：使用 AutoHotkey 替代默认快捷键工具

### 背景

Komorebi 默认使用 **whkd**（Windows Hotkey Daemon）作为快捷键工具，但也支持使用 **AutoHotkey (AHK)** 或 **PowerShell** 来配置快捷键。

### 是否支持 AutoHotkey？

✅ **完全支持！** Komorebi 从一开始就支持 AutoHotkey，并且提供了相关的配置生成工具。

### 如何切换到 AutoHotkey

#### 方法 1：使用现有的 AHK 配置（如果有）

如果你已经有 `komorebi.ahk` 配置文件：

```powershell
# 1. 将 AHK 配置文件放在配置目录
# 默认位置：%USERPROFILE%\komorebi.ahk

# 2. 启动 komorebi 时会自动检测并加载 AHK 配置
komorebic start

# 3. 启用配置文件监视（自动重新加载）
komorebic watch-configuration enable
```

#### 方法 2：生成 AHK 配置模板

```powershell
# 生成应用特定的 AHK 配置
komorebic ahk-app-specific-configuration

# 这会在 %USERPROFILE% 目录生成 applications.json
# 你可以基于这个文件创建自己的 komorebi.ahk
```

#### 方法 3：手动创建 AHK 配置

创建 `%USERPROFILE%\komorebi.ahk` 文件：

```autohotkey
; Komorebi AutoHotkey 配置示例

; 启动/停止 Komorebi
#!k::Run, komorebic.exe start
#!q::Run, komorebic.exe stop

; 切换工作区
!1::Run, komorebic.exe focus-workspace 0
!2::Run, komorebic.exe focus-workspace 1
!3::Run, komorebic.exe focus-workspace 2
!4::Run, komorebic.exe focus-workspace 3

; 移动窗口到工作区
!+1::Run, komorebic.exe move-to-workspace 0
!+2::Run, komorebic.exe move-to-workspace 1
!+3::Run, komorebic.exe move-to-workspace 2
!+4::Run, komorebic.exe move-to-workspace 3

; 发送窗口到工作区（不跟随）
!^1::Run, komorebic.exe send-to-workspace 0
!^2::Run, komorebic.exe send-to-workspace 1
!^3::Run, komorebic.exe send-to-workspace 2
!^4::Run, komorebic.exe send-to-workspace 3

; 窗口焦点移动
!h::Run, komorebic.exe focus left
!j::Run, komorebic.exe focus down
!k::Run, komorebic.exe focus up
!l::Run, komorebic.exe focus right

; 移动窗口位置
!+h::Run, komorebic.exe move left
!+j::Run, komorebic.exe move down
!+k::Run, komorebic.exe move up
!+l::Run, komorebic.exe move right

; 调整窗口大小
!^h::Run, komorebic.exe resize-axis horizontal decrease
!^l::Run, komorebic.exe resize-axis horizontal increase
!^j::Run, komorebic.exe resize-axis vertical increase
!^k::Run, komorebic.exe resize-axis vertical decrease

; 切换浮动模式
!f::Run, komorebic.exe toggle-float

; 切换全屏模式
!m::Run, komorebic.exe toggle-monocle

; 管理/取消管理当前窗口（重要！）
!+m::Run, komorebic.exe manage
!+u::Run, komorebic.exe unmanage

; 重新加载配置
!+r::Run, komorebic.exe reload-configuration

; 白名单模式切换
!+w::Run, komorebic.exe whitelist-mode true
!+e::Run, komorebic.exe whitelist-mode false
```

### AHK vs whkd 对比

| 特性 | whkd | AutoHotkey |
|------|------|------------|
| 配置语法 | 简单的键值对 | AHK 脚本语言 |
| 功能丰富度 | 基础快捷键 | 非常强大，支持复杂逻辑 |
| 性能 | 轻量级 | 稍重一些 |
| 学习曲线 | 平缓 | 中等 |
| 社区支持 | 较小 | 非常大 |
| 推荐场景 | 简单快捷键 | 复杂自动化需求 |

### 启用 AHK 配置的自动加载

```powershell
# 方法 1：启动时自动加载
komorebic start

# 方法 2：启用配置监视（文件改动时自动重新加载）
komorebic watch-configuration enable

# 方法 3：手动重新加载
komorebic reload-configuration
```

### 完整的 AHK 设置流程

```powershell
# 1. 安装 AutoHotkey（如果还没安装）
# 下载：https://www.autohotkey.com/

# 2. 创建配置文件
notepad $env:USERPROFILE\komorebi.ahk

# 3. 粘贴上面的示例配置并保存

# 4. 运行 AHK 脚本
# 双击 komorebi.ahk 文件，或者：
Start-Process "$env:USERPROFILE\komorebi.ahk"

# 5. 启动 komorebi
komorebic start

# 6. 测试快捷键
# 按 Alt+1 切换到工作区 0
# 按 Alt+Shift+M 管理当前窗口
```

### 注意事项

1. **AHK 和 whkd 可以共存**，但建议只使用一个，避免快捷键冲突
2. **AHK 脚本需要单独运行**，不会被 komorebi 自动启动
3. **建议将 AHK 脚本添加到开机自启动**：
   ```powershell
   # 创建快捷方式到启动文件夹
   $startup = [Environment]::GetFolderPath("Startup")
   $target = "$env:USERPROFILE\komorebi.ahk"
   $shortcut = "$startup\komorebi-ahk.lnk"

   $WshShell = New-Object -ComObject WScript.Shell
   $Shortcut = $WshShell.CreateShortcut($shortcut)
   $Shortcut.TargetPath = $target
   $Shortcut.Save()
   ```

---

## 问题 2：管理特定窗口（而不是整个应用）

### 场景说明

你打开了 3 个 Edge 浏览器窗口，但只想管理其中某一个特定的窗口，而不是所有 Edge 窗口。

### 解决方案

Komorebi 提供了 **动态管理特定窗口** 的功能！

### 核心命令

#### 1. `manage` - 强制管理当前聚焦的窗口

```powershell
# 管理当前聚焦的窗口
komorebic manage
```

**用法**：
1. 用鼠标或 Alt+Tab 切换到你想管理的窗口
2. 按快捷键执行 `komorebic manage`
3. 这个窗口会立即被 komorebi 管理

#### 2. `unmanage` - 取消管理当前窗口

```powershell
# 取消管理当前聚焦的窗口
komorebic unmanage
```

**用法**：
1. 切换到你想取消管理的窗口
2. 按快捷键执行 `komorebic unmanage`
3. 这个窗口会变成浮动窗口

### 实际操作示例

#### 场景：管理 3 个浏览器中的 2 个

```powershell
# 1. 打开 3 个 Edge 浏览器窗口
start msedge
start msedge
start msedge

# 2. 确保 Edge 在白名单中（如果使用白名单模式）
komorebic manage-rule exe msedge.exe

# 3. 重启所有 Edge 窗口让规则生效
Stop-Process -Name msedge -Force
start msedge
start msedge
start msedge

# 4. 现在所有 3 个 Edge 窗口都被管理了

# 5. 切换到第 3 个 Edge 窗口（你不想管理的那个）
# 使用 Alt+Tab 或鼠标点击

# 6. 取消管理这个窗口
komorebic unmanage

# 7. 现在只有 2 个 Edge 窗口被管理，第 3 个是浮动的
```

#### 场景：只管理特定的浏览器窗口

```powershell
# 1. 确保白名单模式已启用
komorebic whitelist-mode true

# 2. 不要将 Edge 添加到白名单规则中
# （这样默认所有 Edge 窗口都不被管理）

# 3. 打开多个 Edge 窗口
start msedge
start msedge
start msedge

# 4. 切换到你想管理的第一个窗口
# 使用 Alt+Tab 或鼠标点击

# 5. 强制管理这个窗口
komorebic manage

# 6. 切换到你想管理的第二个窗口

# 7. 强制管理这个窗口
komorebic manage

# 8. 第三个窗口保持不管理（浮动）
```

### 配置快捷键

#### 在 AutoHotkey 中配置

```autohotkey
; 管理当前窗口
!+m::Run, komorebic.exe manage

; 取消管理当前窗口
!+u::Run, komorebic.exe unmanage

; 切换管理状态（自定义脚本）
!+t::
{
    ; 这需要更复杂的逻辑来检测当前状态
    ; 简单版本：总是尝试管理
    Run, komorebic.exe manage
    return
}
```

#### 在 whkd 中配置

编辑 `%USERPROFILE%\.config\whkd\whkdrc`：

```
# 管理当前窗口
alt + shift + m : komorebic manage

# 取消管理当前窗口
alt + shift + u : komorebic unmanage
```

### 工作流程示例

#### 工作流 1：选择性管理浏览器标签页

```powershell
# 场景：你有多个浏览器窗口，每个窗口有不同的用途

# 1. 工作相关的浏览器窗口 → 管理
# 切换到工作浏览器窗口
# 按 Alt+Shift+M 管理

# 2. 娱乐相关的浏览器窗口 → 不管理（浮动）
# 切换到娱乐浏览器窗口
# 按 Alt+Shift+U 取消管理（或者不执行任何操作）

# 3. 参考文档的浏览器窗口 → 管理
# 切换到参考文档窗口
# 按 Alt+Shift+M 管理
```

#### 工作流 2：临时浮动窗口

```powershell
# 场景：你正在编码，需要临时查看一个窗口但不想它被平铺

# 1. 窗口正常被管理（平铺状态）

# 2. 需要临时查看时
# 按 Alt+Shift+U 取消管理
# 窗口变成浮动，可以自由移动和调整大小

# 3. 查看完毕后
# 按 Alt+Shift+M 重新管理
# 窗口回到平铺状态
```

### 高级技巧

#### 技巧 1：结合工作区使用

```powershell
# 1. 管理特定窗口
komorebic manage

# 2. 立即移动到特定工作区
komorebic move-to-workspace 2

# 3. 这个窗口现在在工作区 2 中被管理
```

#### 技巧 2：批量管理

```powershell
# 创建一个脚本来批量管理窗口
# manage-multiple.ps1

# 获取所有 Edge 窗口
$edgeWindows = Get-Process msedge | Where-Object {$_.MainWindowHandle -ne 0}

# 对每个窗口执行操作
foreach ($window in $edgeWindows) {
    # 激活窗口
    [void][Window]::SetForegroundWindow($window.MainWindowHandle)
    Start-Sleep -Milliseconds 200

    # 管理窗口
    komorebic manage
    Start-Sleep -Milliseconds 200
}
```

### 与白名单模式的配合

#### 策略 1：白名单 + 动态管理

```powershell
# 1. 启用白名单模式
komorebic whitelist-mode true

# 2. 不添加浏览器到白名单
# （默认所有浏览器窗口都不被管理）

# 3. 手动选择要管理的窗口
# 切换到窗口 → komorebic manage
```

**优点**：
- 完全控制哪些窗口被管理
- 适合需要精细控制的场景

#### 策略 2：白名单 + 例外处理

```powershell
# 1. 启用白名单模式
komorebic whitelist-mode true

# 2. 添加浏览器到白名单
komorebic manage-rule exe msedge.exe

# 3. 重启浏览器（所有窗口都被管理）

# 4. 对不想管理的窗口执行
komorebic unmanage
```

**优点**：
- 大部分窗口自动管理
- 少数例外手动处理

### 注意事项

1. **`manage` 命令是临时的**
   - 窗口关闭后，下次打开需要重新执行
   - 不会保存到配置文件

2. **与规则的优先级**
   - `manage` 命令的优先级高于白名单规则
   - 即使应用不在白名单中，`manage` 也能强制管理

3. **重启 komorebi 后失效**
   - 动态管理的状态不会持久化
   - 重启 komorebi 后需要重新执行

4. **建议的使用场景**
   - ✅ 临时需要管理某个窗口
   - ✅ 测试窗口管理效果
   - ✅ 特殊情况的例外处理
   - ❌ 不适合作为主要的管理方式（应该用规则）

### 完整示例脚本

创建 `manage-specific-window.ps1`：

```powershell
# 管理特定窗口的辅助脚本

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "manage"  # manage 或 unmanage
)

Write-Host "=== Komorebi 窗口管理工具 ===" -ForegroundColor Green
Write-Host ""
Write-Host "请切换到你想要 $Action 的窗口..." -ForegroundColor Yellow
Write-Host "按任意键继续..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "执行: komorebic $Action" -ForegroundColor Cyan
komorebic $Action

Write-Host ""
Write-Host "完成！" -ForegroundColor Green

# 显示当前被管理的窗口
Write-Host ""
Write-Host "当前被管理的窗口:" -ForegroundColor Green
komorebic visible-windows
```

使用方法：

```powershell
# 管理窗口
.\manage-specific-window.ps1 -Action manage

# 取消管理窗口
.\manage-specific-window.ps1 -Action unmanage
```

---

## 总结

### 问题 1：AutoHotkey 支持
- ✅ 完全支持 AutoHotkey
- ✅ 可以替代 whkd
- ✅ 提供更强大的自动化能力
- ✅ 需要单独运行 AHK 脚本

### 问题 2：特定窗口管理
- ✅ 使用 `komorebic manage` 管理当前窗口
- ✅ 使用 `komorebic unmanage` 取消管理
- ✅ 可以精确控制每个窗口
- ✅ 适合临时和特殊情况

### 推荐配置

```autohotkey
; 在 komorebi.ahk 中添加
!+m::Run, komorebic.exe manage      ; Alt+Shift+M 管理当前窗口
!+u::Run, komorebic.exe unmanage    ; Alt+Shift+U 取消管理
!+w::Run, komorebic.exe whitelist-mode true   ; 启用白名单模式
!+e::Run, komorebic.exe whitelist-mode false  ; 禁用白名单模式
```

现在你可以：
1. 使用 AutoHotkey 配置所有快捷键
2. 精确控制每个窗口是否被管理
3. 结合白名单模式实现灵活的窗口管理策略
