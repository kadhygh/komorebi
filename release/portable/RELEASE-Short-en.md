# v0.1.0-preview1 Portable Release Notes

This is the first portable preview release of the current fork. The goal is to help new users get started quickly, then gradually build their own workspace workflow.

This portable build enables `whitelist_mode` and `force_manage` by default. Instead of aggressively taking over every window, it is designed to encourage you to **actively choose the windows you want to manage** and organize them into your own workspaces.

Using it with **AutoHotkey v2** is strongly recommended:

- Double-click `start.cmd` to start `komorebi`
- Double-click `shortcuts\komorebi.ahk` to enable the default hotkeys
- Double-click `stop.cmd` to stop `komorebi`

If `komorebi-bar.exe` is present in the package, the start script will automatically add `--bar`.
The bar is mainly there to help visualize and switch layouts, while the core workspace experience is still this: **organize the windows you actually want, then use hotkeys to switch, focus, and move them efficiently.**

This preview release is mainly for users who want to:

- try the portable packaging format first
- explore the `whitelist_mode + force_manage` workflow
- build a workspace-driven setup with AHK hotkeys
