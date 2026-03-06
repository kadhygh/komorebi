# 项目分析（Fork 版）

## 文档目的

这份文档用于替代 `whitelist_dev/project_analysis.md` 中已经过时或不完整的内容，面向当前这个 fork 的实际使用和维护场景。

它不试图覆盖上游全部能力，而是重点说明：

- 核心架构如何组织
- 配置如何加载，尤其是 `komorebi.json`、`komorebi.ps1`、`komorebi.ahk` 的优先级
- `komorebic quickstart` 的默认模板行为
- AutoHotkey / whkd 在当前代码中的真实状态
- 日志实际写到哪里
- border 当前有哪些 style / implementation
- 多显示器下 workspace 焦点语义为什么容易让人误判

## 1. 核心结构

### 1.1 层级模型

`komorebi` 的核心层级仍然是：

```text
Monitor
  └── Workspace
        └── Container
              └── Window
```

其中：

- `Monitor` 表示物理显示器
- `Workspace` 是“挂在某个显示器上的工作区”
- `Container` 是平铺布局里的容器
- `Window` 是对 Win32 窗口句柄的封装

这意味着：**workspace 不是全局统一的一层，而是每个 monitor 各自维护自己的 workspace 列表。**

### 1.2 进程模型

```text
用户/脚本
  ↓
komorebic.exe    # CLI / 控制端
  ↓ Named Pipe / SocketMessage
komorebi.exe     # 后台守护进程
  ↑ WinEvent Hook
Windows
```

职责划分：

- `komorebi`：维护窗口状态、显示器状态、布局、规则、焦点
- `komorebic`：把用户命令转换成 `SocketMessage` 发给后台
- 外部热键工具（`whkd` / AHK）：本质上都只是驱动 `komorebic.exe ...`

## 2. 配置加载路径

### 2.1 静态配置优先

`komorebi` 启动时，首先会尝试确定静态配置文件：

- 如果命令行传了 `--config`，使用显式指定路径
- 否则尝试默认路径下的 `komorebi.json`

一旦存在静态配置，`komorebi` 会按静态配置路径启动窗口管理器。

### 2.2 legacy 配置加载器

当 **没有静态配置** 时，后台会调用 legacy 配置加载器：

- 先检查 `komorebi.ps1`
- 如果没有，再检查 `komorebi.ahk`

也就是说，优先级是：

1. `komorebi.json`
2. `komorebi.ps1`
3. `komorebi.ahk`

这点很重要，因为很多“AHK 会不会自动加载”的讨论，只有在这个前提下才成立。

### 2.3 配置目录

默认配置目录是用户主目录；如果设置了 `KOMOREBI_CONFIG_HOME`，则改用该目录。

在当前 fork 里，实操上要记住：

- `komorebi.json`
- `komorebi.ahk`
- `komorebi.ps1`
- `applications.json`

都会受到 `KOMOREBI_CONFIG_HOME` 影响。

## 3. Quickstart 的真实行为

### 3.1 模板来源

`komorebic quickstart` 当前直接把 `docs/komorebi.example.json` 通过 `include_str!` 编进二进制，再写入用户目录。

这意味着：

- 改 `docs/komorebi.example.json` 后
- **必须重新编译 / 重新安装 `komorebic`**
- 新的 `quickstart` 才会生成新的默认值

### 3.2 当前 fork 已做的默认值调整

在当前 fork 里，我们已经把 Quickstart 默认模板改成：

```json
"whitelist_mode": true,
"force_manage": true
```

对应含义：

- `whitelist_mode = true`：默认只管理白名单/规则允许管理的窗口
- `force_manage = true`：允许手动 `manage` / `unmanage` 操作更直接地覆盖规则约束

### 3.3 白名单示例模板

`docs/komorebi.whitelist.example.json` 不是 Quickstart 主路径，但现在也已被同步改成显式开启：

- `whitelist_mode: true`
- `force_manage: true`

这样文档示例和 Quickstart 默认值一致。

## 4. AutoHotkey / whkd 支持现状

## 4.1 结论先说

当前代码里：

- `whkd` 是**主推、持续维护**路径
- AutoHotkey 仍然**可用**
- 但 `--ahk` 已经被明确标记为 **legacy / EOL**

这和很多旧文档里“AHK 完全正常主线支持”的说法不同。

### 4.2 `whkd`

上游和当前代码都更倾向于把 `whkd` 当成标准热键方案：

- `quickstart` 会生成 `whkdrc`
- `start --whkd` / `stop --whkd` 是公开参数
- `komorebi-shortcuts` 也是围绕 `whkdrc` 工作

### 4.3 AutoHotkey

AHK 仍然能用，但要理解它现在属于兼容保留路径：

- `start --ahk`
- `stop --ahk`
- `kill --ahk`
- `enable-autostart --ahk`

这些路径仍然存在，但代码会打印 EOL 警告。

### 4.4 AHK 的真实支持方式

`komorebi` 并没有自己的 AHK 解释层；它支持 AHK 的方式本质上是：

- 运行 `komorebi.ahk`
- 让脚本去调用 `komorebic.exe ...`

所以 AHK 的优势来自：

- 条件判断
- 窗口上下文
- 更灵活的热键编排
- 对 IDE / 特殊应用做局部屏蔽

而不是来自 `komorebi` 对 AHK 有额外的一等公民支持。

## 5. 日志与运行状态

## 5.1 实际日志位置

README 里关于日志的描述和当前代码不完全一致。

当前运行代码实际使用：

- `%TEMP%\komorebi_plaintext.log.YYYY-MM-DD`
- `%TEMP%\komorebi.log.YYYY-MM-DD`

而不是我们直觉上以为的 `%LOCALAPPDATA%\komorebi\komorebi.log`。

### 5.2 另一个仍然重要的状态目录

虽然日志在 `%TEMP%`，但以下运行状态文件仍然常见于 `%LOCALAPPDATA%\komorebi`：

- `komorebi.hwnd.json`
- bar / socket 相关运行时文件

### 5.3 如何判断“崩了”还是“被 stop”

在实际排查中：

- 如果是 panic，日志里通常会留下异常痕迹
- 如果是 deadlock，常见表现是日志和进程一起冻结
- 如果是正常停止，日志里会看到类似 `received stop command` 的记录

这个判断方式在 fork 日常排查里非常有用。

## 6. Border 能力

### 6.1 style

当前 `border-style` 有三种：

- `system`
- `rounded`
- `square`

直觉上可以理解为：

- `rounded`：更像 Windows 11 圆角风格
- `square`：更像 Windows 10 直角风格
- `system`：尽量跟系统样式保持一致

### 6.2 implementation

当前 `border-implementation` 有两种：

- `komorebi`
- `windows`

可粗略理解为：

- `komorebi`：可调宽度、偏移、颜色的自绘边框
- `windows`：更原生、更薄的 accent border

### 6.3 fork 视角建议

如果你想要更明显的焦点提示：

- `border-implementation komorebi`
- `border-style square`

如果你想要更接近系统：

- `border-implementation windows`
- `border-style system`

## 7. 多显示器与 workspace 焦点语义

### 7.1 最容易踩坑的点

`focus-workspace <n>` 作用的是：

- **当前 focused monitor 上的 workspace**
- 不是“全局第 n 个 workspace”
- 也不是“鼠标所在屏幕的 workspace”

所以双显示器场景中，用户经常会误以为：

- 我刚刚点了另一块屏的窗口
- 所以 `focus-workspace` 应该切那块屏

但如果 `focused monitor` 没有同步过去，命令仍然会作用在旧 monitor 上。

### 7.2 当前代码里的同步机制

`komorebi` 会在一些窗口事件上尝试同步 `focused monitor`：

- `FocusChange`
- `Show`
- `MoveResizeEnd`

它会根据窗口所在 monitor 调用 `focus_monitor(monitor_idx)`。

这说明：

- 理论上点击窗口应当能同步 monitor 焦点
- 但在复杂应用、特殊窗口、某些异常事件链下，不一定总符合人的预期

### 7.3 实操建议

在双显示器工作流里，不要完全依赖“点击窗口自动切 monitor 语义”，更稳妥的方式是显式绑定：

- `focus-monitor <idx>`
- `focus-monitor-workspace <monitor> <workspace>`

例如：

```text
Win + [  -> focus-monitor 0
Win + ]  -> focus-monitor 1
```

以及：

```text
Win + Alt + 1 -> focus-monitor-workspace 0 0
Win + Alt + 2 -> focus-monitor-workspace 0 1
Win + Alt + Q -> focus-monitor-workspace 1 0
Win + Alt + W -> focus-monitor-workspace 1 1
```

### 7.4 排查方法

当你怀疑切 workspace 没切到预期显示器时，先查：

```powershell
komorebic query focused-monitor-index
komorebic query focused-workspace-index
```

如果 monitor index 没切过去，问题不在 workspace 命令本身，而在 monitor 焦点语义。

## 8. Fork 维护建议

### 8.1 建议的热键层分工

基于当前代码状态，fork 推荐：

- 窗口管理配置：`komorebi.json`
- 常规热键：优先 `whkd`
- 复杂条件热键 / IDE 屏蔽 / 特殊自动化：AHK v2

### 8.2 Rider / JetBrains 场景

对于 Rider 这类快捷键密集型 IDE，fork 经验是：

- 不要让一整套全局窗口管理热键在 Rider 前台时继续抢键
- 更推荐 AHK 做上下文屏蔽，例如 `#HotIf !WinActive("ahk_exe rider64.exe")`
- 保留少数必须全局可用的热键，例如：
  - monitor 切换
  - workspace 快速跳转
  - `manage` / `unmanage`

### 8.3 这份分析和旧文档的关系

如果你在看旧的 `whitelist_dev/project_analysis.md`，请把它当作：

- 对窗口管理结构的旧梳理
- 但不是 fork 当前运行行为的最终依据

以当前这份 `project-analysis.md` 为准。
