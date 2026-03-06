# 多显示器配置（Fork 说明）

> 最后核对日期：2026-03-06


## 先记住一个核心点

`komorebic focus-workspace <n>` 只会作用在 **当前 focused monitor** 上。

这也是双屏场景里最常见的误解来源：

- 你以为自己“选中了另一块屏幕上的窗口”
- 但 `komorebi` 内部的 `focused monitor` 不一定已经切过去
- 于是 `focus-workspace` 还是切了当前那块屏的工作区

## 推荐命令

### 1. 明确切显示器

```powershell
komorebic focus-monitor 0
komorebic focus-monitor 1
```

适合：

- 先指定当前操作哪块屏
- 再配合 `focus-workspace` 使用

### 2. 一步切“某屏某工作区”

```powershell
komorebic focus-monitor-workspace 0 0
komorebic focus-monitor-workspace 1 2
```

适合：

- 不想依赖当前焦点状态
- 想明确跳到某块屏上的某个工作区

### 3. 按当前鼠标所在屏切换

```powershell
komorebic focus-monitor-at-cursor
```

适合：

- 你习惯用鼠标确定当前工作屏

## 本 fork 推荐热键策略

### 方案 A：两步式

- `Win+[` / `Win+]`：切 monitor
- `Win+数字`：切当前 monitor 的 workspace

优点：

- 逻辑直观
- 容易记
- 对双屏非常稳

### 方案 B：一步式

直接给常用目标绑定 `focus-monitor-workspace`。

优点：

- 最稳定
- 不依赖“当前 focused monitor 是否同步正确”

## 常见误区

### 误区 1：以为“前台窗口在哪块屏，focused monitor 就一定在哪块屏”

理论上很多情况下会同步，但不要把它当成绝对可靠前提。

### 误区 2：双屏时把第二块屏写成 monitor `2`

在 `komorebi` 里，monitor index 是 **从 0 开始** 的：

- 第一块屏：`0`
- 第二块屏：`1`

## 本 fork 的实用建议

- 如果你经常在双屏之间跳转，不要只依赖 `focus-workspace`
- 优先把 `focus-monitor` 或 `focus-monitor-workspace` 绑定出来
- 如果你在 Rider / IDE 中工作，建议把“切 monitor / 切 workspace”这类真正需要全局可用的热键保留在 IDE 内也可用

## 排查方法

问题出现时，先查当前 focused monitor：

```powershell
komorebic query focused-monitor-index
```

如果结果不是你预期的那块屏，再执行：

```powershell
komorebic focus-monitor 1
```

或直接：

```powershell
komorebic focus-monitor-workspace 1 0
```

## 推荐阅读

- `./troubleshooting.md`
- `./autohotkey.md`
- `./autostart.md`
- `./advanced-usage-guide.md`
