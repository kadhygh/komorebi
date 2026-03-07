# v0.1.0-preview1 Portable Release Notes

这是当前 fork 的第一版 portable 预发布版本，目标是让新用户先快速跑起来，再逐步构建自己的工作空间。

这个 portable 版本默认启用了 `whitelist_mode` 和 `force_manage`：它不会粗暴接管所有窗口，而是更鼓励你**主动选择想管理的窗口**，把常用界面组织进自己的 workspace。

推荐搭配 **AutoHotkey v2** 使用：

- 双击 `start.cmd` 启动 `komorebi`
- 双击 `shortcuts\komorebi.ahk` 启动默认快捷键
- 双击 `stop.cmd` 停止 `komorebi`

如果包内存在 `komorebi-bar.exe`，启动脚本会自动带上 `--bar`。
bar 主要用于辅助查看和切换布局，而工作空间的核心体验仍然是：**把你真正想用的窗口组织起来，然后用快捷键快速切换、聚焦和转移。**

这次预发布主要面向：

- 想先体验 portable 形态的用户
- 想尝试 `whitelist_mode + force_manage` 工作流的用户
- 想通过 AHK 快捷键逐步搭建自己 workspace 的用户
