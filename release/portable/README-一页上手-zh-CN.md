# Komorebi Fork Portable 一页上手

## komorebi 是做什么的

`komorebi` 可以把桌面上的窗口按固定方式自动排布，并把这些窗口组织进不同的工作空间里，方便你用快捷键快速切换。你可以把它理解成：把一组经常一起使用的窗口绑定成一个工作空间，然后用快捷键在不同工作空间之间快速来回切换。

这个 portable 版本默认已经开启 `whitelist_mode` 和 `force_manage`。它的思路不是自动接管所有窗口，而是**由你主动挑选想用的窗口，把它们组织进自己的工作空间**。

## 第一步：先装 AutoHotkey v2，再启动

这个版本默认更适合配合快捷键使用；如果没有快捷键，基本上没法顺手使用。

1. 先解压 portable 包
2. 去安装 AutoHotkey v2
3. 官方下载页：`https://www.autohotkey.com/download/`
4. 安装完成后，先双击 `start.cmd`
5. 再双击 `shortcuts\komorebi.ahk`

这样就同时启动了：

- `komorebi`
- 默认快捷键

如果你想退出：

- 双击 `stop.cmd`
- 然后退出 AutoHotkey 托盘里的 `komorebi.ahk`

## 第二步：把你想要的窗口加入工作空间

选中你当前想纳入布局的窗口，然后按：

- `Win+Shift+M`：管理当前窗口

如果你之后不想让它继续被 `komorebi` 管理，可以按：

- `Win+Shift+N`：解绑当前窗口

你可以把几个常用窗口一个个加入进来，逐步搭出自己的工作空间。

当一个工作空间里有多个窗口后：

- 窗口会自动排布
- 如果当前包里带了 `komorebi-bar.exe` 并成功启动了 bar，你可以直接在 bar 里切换布局

## 第三步：把窗口发到别的工作空间

先选中一个**已经在管理中的窗口**，然后按：

- `Win+Shift+1`：发送到工作区 1
- `Win+Shift+2`：发送到工作区 2
- `Win+Shift+3`：发送到工作区 3
- `Win+Shift+4`：发送到工作区 4

如果你想直接切换工作空间，就按：

- `Win+1`
- `Win+2`
- `Win+3`
- `Win+4`

你可以把“编辑器 / 浏览器 / 终端 / IM”分开放在不同工作空间里，再用这组快捷键来回切换。

## 第四步：用快捷键切换焦点窗口

在当前工作空间里切换焦点：

- `Win+H`：看左边
- `Win+J`：看下边
- `Win+K`：看上边
- `Win+L`：看右边

如果你已经习惯了 Vim 方向键，这组会非常顺手。

## 几个进阶技巧

### 1. stack / stack 切换

如果你想把多个窗口压进同一个位置，可以用：

- `Win+Alt+H/J/K/L`：把当前窗口 stack 到左 / 下 / 上 / 右
- `Alt+[`：切到上一个 stack 窗口
- `Alt+]`：切到下一个 stack 窗口
- `Alt+;`：把当前窗口从 stack 里拆出来

适合“同一类窗口很多，但不想全部摊开”的场景。

### 2. 多显示器和多 bar

如果你以后要用多显示器：

- 每个显示器都可以有自己的工作空间
- 每个显示器也可以单独跑自己的 bar

这部分已经属于进阶配置，建议后面再看：

- `docs/common-workflows/multi-monitor-setup.md:1`
- `docs/common-workflows/multiple-bar-instances.md:1`

### 3. 改 AHK 快捷键

`shortcuts\komorebi.ahk` 本质上就是“按一个快捷键，执行一条 `komorebic.exe` 命令”。

所以如果你想改键位，最简单的办法就是直接照着现有格式改：

- 左边是 AHK 热键
- 右边是 `komorebic.exe` 命令

如果你准备自己定制 AHK，可以从这里继续看：

- `release/portable/shortcuts/komorebi.ahk:1`
- `whitelist_dev/doc_fork/autohotkey.md:1`
- `whitelist_dev/doc_fork/advanced-usage-guide.md:1`
