# 配置示例（Fork 版）

## 说明

这份文档只记录当前这个 fork 下最常用、最值得优先维护的 `komorebi.json` 配置片段。

目标不是覆盖上游所有配置项，而是回答下面几个高频问题：

- 如何默认开启 `whitelist_mode`
- 如何默认开启 `force_manage`
- 如何切换 border 的样式和实现方式
- 多显示器下，应该如何组织 `monitors` / `workspaces`

## 当前 fork 的默认方向

目前这个 fork 已经把 Quickstart 生成模板中的以下两个字段默认改为 `true`：

```json
{
  "whitelist_mode": true,
  "force_manage": true
}
```

这意味着：

- `whitelist_mode: true`：只有命中 `manage_rules` 的窗口才会被平铺管理
- `force_manage: true`：手动 `manage` / `unmanage` 的行为更容易覆盖默认规则和边界情况

## 示例 1：最小可用白名单模式

适合只想管理少数几个开发工具窗口的场景。

```json
{
  "$schema": "https://raw.githubusercontent.com/LGUG2Z/komorebi/v0.1.41/schema.json",
  "whitelist_mode": true,
  "force_manage": true,
  "manage_rules": [
    {
      "kind": "exe",
      "id": "WindowsTerminal.exe",
      "matching_strategy": "equals"
    },
    {
      "kind": "exe",
      "id": "Code.exe",
      "matching_strategy": "equals"
    },
    {
      "kind": "exe",
      "id": "rider64.exe",
      "matching_strategy": "equals"
    }
  ]
}
```

建议：

- 先只加最常用窗口，确认平铺行为稳定后再逐步扩展
- 对容易出问题的软件，优先通过 `visible-windows` 观察 `exe` / `class` / `title`

## 示例 2：带 border 的常用桌面配置

当前代码支持两个维度：

- `border_style`
  - `system`
  - `rounded`
  - `square`
- `border_implementation`
  - `komorebi`
  - `windows`

一个偏清晰、适合开发场景的例子：

```json
{
  "border": true,
  "border_width": 8,
  "border_offset": -1,
  "border_style": "square",
  "border_implementation": "komorebi"
}
```

说明：

- `square` 更接近 Windows 10 风格直角边框
- `rounded` 更接近 Windows 11 风格圆角边框
- `komorebi` 实现更适合做明显、可调的高亮边框
- `windows` 实现更接近系统自带细边框

## 示例 3：双显示器基础配置

`monitors` 是零基索引概念：

- 第一块显示器通常是 `0`
- 第二块显示器通常是 `1`

下面是一个双显示器、每块屏 3 个工作区的例子：

```json
{
  "monitors": [
    {
      "workspaces": [
        { "name": "I", "layout": "BSP" },
        { "name": "II", "layout": "VerticalStack" },
        { "name": "III", "layout": "Rows" }
      ]
    },
    {
      "workspaces": [
        { "name": "A", "layout": "BSP" },
        { "name": "B", "layout": "VerticalStack" },
        { "name": "C", "layout": "Rows" }
      ]
    }
  ]
}
```

## 多显示器下最重要的行为说明

`focus-workspace` 只作用于 **当前 focused monitor**。

也就是说：

- `komorebic focus-workspace 1`
- 只会切换“当前聚焦显示器”上的 workspace 1
- 不会自动切到另一块屏的 workspace 1

如果你是双显示器使用者，更推荐把下面两类命令配上快捷键：

```powershell
komorebic focus-monitor 0
komorebic focus-monitor 1
komorebic focus-monitor-workspace 0 0
komorebic focus-monitor-workspace 1 0
```

建议：

- `focus-monitor`：先明确切操作目标屏
- `focus-monitor-workspace`：一步到位切到指定屏的指定工作区

## 示例 4：适合本 fork 的开发工作流配置片段

这是一个更贴近当前 fork 使用方向的组合示例：

```json
{
  "whitelist_mode": true,
  "force_manage": true,
  "border": true,
  "border_style": "square",
  "border_implementation": "komorebi",
  "manage_rules": [
    { "kind": "exe", "id": "WindowsTerminal.exe", "matching_strategy": "equals" },
    { "kind": "exe", "id": "Code.exe", "matching_strategy": "equals" },
    { "kind": "exe", "id": "rider64.exe", "matching_strategy": "equals" },
    { "kind": "exe", "id": "chrome.exe", "matching_strategy": "equals" }
  ],
  "monitors": [
    {
      "workspaces": [
        { "name": "Main", "layout": "BSP" },
        { "name": "Debug", "layout": "VerticalStack" },
        { "name": "Web", "layout": "Rows" }
      ]
    },
    {
      "workspaces": [
        { "name": "Chat", "layout": "BSP" },
        { "name": "Docs", "layout": "Rows" },
        { "name": "Misc", "layout": "Grid" }
      ]
    }
  ]
}
```

## 维护建议

- 以 `docs/komorebi.example.json` 为 Quickstart 模板事实来源
- 如果修改 Quickstart 默认值，需要重新编译 `komorebic`
- 如果只是改你自己的 `%USERPROFILE%\komorebi.json`，不需要重新编译
- 对边框、多显示器、白名单模式的更细节说明，优先参考本目录下：
  - `multi-monitor-setup.md`
  - `project-analysis.md`
  - `advanced-usage-guide.md`
