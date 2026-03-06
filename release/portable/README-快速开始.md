# Komorebi Fork 快速开始

## 这是什么

这是这个 fork 的第一版 `portable zip` 预发布方案，目标是让 Windows 新用户先跑起来：

- 不要求手动配置 `PATH`
- 配置保存在包内 `config\`
- 通过 `start.cmd` / `stop.cmd` 启动和停止
- 提供一个可直接改的 AutoHotkey v2 相对路径示例
- 提供一个可选的 `whkdrc` 示例，给已经安装 `whkd` 的用户

## 包内结构

```text
bin\
  komorebi.exe
  komorebic.exe
  komorebic-no-console.exe
config\
  komorebi.json
  applications.json
  whkdrc
shortcuts\
  komorebi.ahk
start.cmd
start-whkd.cmd
stop.cmd
README-快速开始.md
CHANGELOG.md
```

## 快速开始

1. 下载 `komorebi-fork-v0.1.0-preview1-portable-x64.zip`
2. 解压到任意可写目录
3. 不要解压到需要管理员权限或容易被同步工具锁定的目录
4. 如果你走 AHK 路线，双击 `start.cmd`
5. 如果你走 `whkd` 路线，双击 `start-whkd.cmd`
6. 如果你用 AutoHotkey v2，再运行 `shortcuts\komorebi.ahk`

## 如何确认已经生效

- 默认配置启用了 `whitelist_mode: true`
- 只有命中 `config\komorebi.json` 里 `manage_rules` 的窗口会被平铺管理
- 这份默认规则先包含 `notepad.exe`、`WindowsTerminal.exe`、`Code.exe`、`rider64.exe` 和 `chrome.exe`
- 最简单的验证方式是启动后打开记事本

## 默认热键（AHK）

`shortcuts\komorebi.ahk` 当前默认提供下面这些热键：

- `Win+h/j/k/l`：聚焦左 / 下 / 上 / 右
- `Win+Shift+h/j/k/l`：把当前窗口移动到左 / 下 / 上 / 右
- `Win+1/2/3/4`：切换到工作区 1 到 4
- `Win+Shift+1/2/3/4`：把当前窗口发送到工作区 1 到 4
- `Win+Alt+h/j/k/l`：把窗口压进左 / 下 / 上 / 右方向的 stack
- `Alt+[` / `Alt+]`：在 stack 中向前 / 向后翻页
- `Alt+;`：把当前窗口从 stack 中拆出来
- `Win+Shift+M`：管理当前窗口
- `Win+Shift+N`：取消管理当前窗口

## `whkdrc` 用法

包内提供了 `config\whkdrc` 示例，但 **`whkd.exe` 不在这个 portable zip 里**。

适合下面这类用户：

- 已经安装了 `whkd`
- 想继续用 `whkd`，但不想依赖 `PATH`
- 想让热键直接调用包内的 `bin\komorebic.exe`

这份 `whkdrc` 的设计点是：

- 使用 `.shell powershell`
- 通过 `$Env:WHKD_CONFIG_HOME\..\bin\komorebic.exe` 直接调用包内 CLI
- 快捷键布局尽量和 `shortcuts\komorebi.ahk` 保持一致
- `oem_1 = ;`，`oem_4 = [`，`oem_6 = ]`

### 如何启动 `whkd`

1. 更简单的方式：直接双击 `start-whkd.cmd`
2. 这个脚本会设置 `KOMOREBI_CONFIG_HOME` / `WHKD_CONFIG_HOME`
3. 它会用包内 `komorebic-no-console.exe start --whkd` 启动
4. 如果当前 `bin\` 或你的 `PATH` 里存在 `komorebi-bar.exe`，它还会自动追加 `--bar`

如果你更想手动启动，也可以：

1. 打开 PowerShell，并进入你的 portable 解压目录
2. 执行：`$env:WHKD_CONFIG_HOME = "$PWD\config"`
3. 执行：`$env:KOMOREBI_CONFIG_HOME = "$PWD\config"`
4. 执行：`$env:PATH = "$PWD\bin;" + $env:PATH`
5. 执行：`komorebic-no-console.exe start --whkd`

注意：基础版 `start.cmd` 只是直接启动 `komorebi.exe`，它**不会**自动拉起 `whkd.exe`，也没有 `--bar` 这一层控制。

## 默认热键（whkdrc）

`config\whkdrc` 当前默认提供下面这些热键：

- `win + h/j/k/l`：聚焦左 / 下 / 上 / 右
- `win + shift + h/j/k/l`：移动窗口
- `win + 1/2/3/4`：切换工作区
- `win + shift + 1/2/3/4`：发送窗口到工作区
- `win + alt + h/j/k/l`：`stack left/down/up/right`
- `alt + oem_4` / `alt + oem_6`：`cycle-stack previous` / `cycle-stack next`
- `alt + oem_1`：`unstack`
- `win + shift + m`：`manage`
- `win + shift + n`：`unmanage`

## 如何停止和回退

- 停止 komorebi：双击 `stop.cmd`
- 如果你是用 `start-whkd.cmd` 启动的，建议额外执行：`bin\komorebic.exe stop --whkd --bar`
- 关闭 AHK 快捷键：退出 AutoHotkey 托盘图标中的 `komorebi.ahk`
- 关闭 `whkd` 快捷键：结束 `whkd.exe` 进程或用你自己的重载/停止方式
- 回退：停止 komorebi 后直接删除整个 portable 目录

## 常见失败点

- `start.cmd` 提示缺少 `bin\komorebi.exe`：当前目录不是完整打包结果
- `start-whkd.cmd` 提示找不到 `whkd.exe`：你还没有安装 `whkd`，或者它不在 `PATH` 里
- `start.cmd` 提示缺少 `config\applications.json`：需要重新生成 portable 包
- 启动后没有窗口被管理：先检查你的应用是否在 `manage_rules` 里
- AHK 脚本无法运行：确认安装的是 AutoHotkey v2
- `whkd` 启动后热键没反应：确认已经单独安装 `whkd`，并且当前 PowerShell 已设置 `WHKD_CONFIG_HOME`
- 你以为已经启用了 `--bar`，但没有看到 bar：确认 `komorebi-bar.exe` 在 `bin\` 或 `PATH` 里；`start-whkd.cmd` 只有在它可用时才会追加 `--bar`
- 解压路径带空格时异常：建议重新解压后再试，并保留默认目录结构

## 配置说明

- `KOMOREBI_CONFIG_HOME` 会在 `start.cmd` 里指向当前目录的 `config\`
- `WHKD_CONFIG_HOME` 也会一起指向当前目录的 `config\`
- `app_specific_configuration_path` 已固定到 `$Env:KOMOREBI_CONFIG_HOME/applications.json`
- `config\whkdrc` 是可选示例，不会被 `start.cmd` 自动启动
- `start-whkd.cmd` 会临时把 `bin\` 加进 `PATH`，这样 `komorebic start --whkd` 才能找到包内 `komorebi.exe`

## 给第一次使用的人

如果你只是想确认这套 fork 能不能工作，先不要急着改很多配置。建议顺序是：

1. 先用默认配置启动
2. 先验证记事本是否能被管理
3. 再决定你要用 AHK 还是 `whkd`
4. 再把你自己的常用应用加进 `manage_rules`
5. 最后再改快捷键和工作区布局
