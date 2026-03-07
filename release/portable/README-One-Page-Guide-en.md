# Komorebi Fork Portable One-Page Guide

## What komorebi is for

`komorebi` automatically arranges desktop windows into structured tiling layouts and organizes them into separate workspaces, so you can switch between them quickly with hotkeys. A simple way to think about it is this: you group windows that belong together into a workspace, then jump between workspaces with keyboard shortcuts.

This portable build enables `whitelist_mode` and `force_manage` by default. It is not designed to take over every window automatically. Instead, it guides you to **actively choose the windows you want to manage and build your own workspace layout**.

## Step 1: Install AutoHotkey v2, then start

This build is designed to be used with hotkeys. Without hotkeys, it is technically possible to run, but not practical to use smoothly.

1. Unzip the portable package.
2. Install AutoHotkey v2.
3. Official download page: `https://www.autohotkey.com/download/`
4. After installation, double-click `start.cmd` first.
5. Then double-click `shortcuts\komorebi.ahk`.

This starts both:

- `komorebi`
- the default hotkey layer

To stop everything:

- double-click `stop.cmd`
- then exit `komorebi.ahk` from the AutoHotkey tray icon

## Step 2: Add the windows you want into your workspace

Select the window you want to include in your layout, then press:

- `Win+Shift+M`: manage the current window

If you no longer want that window to stay under `komorebi` management, press:

- `Win+Shift+N`: unmanage the current window

You can add your key windows one by one and gradually build your own workspace.

Once a workspace contains multiple managed windows:

- they will be arranged automatically
- if the package includes `komorebi-bar.exe` and the bar is running, you can switch layouts directly from the bar

## Step 3: Send windows to other workspaces

Select a window that is **already managed**, then press:

- `Win+Shift+1`: send to workspace 1
- `Win+Shift+2`: send to workspace 2
- `Win+Shift+3`: send to workspace 3
- `Win+Shift+4`: send to workspace 4

To switch workspaces directly, use:

- `Win+1`
- `Win+2`
- `Win+3`
- `Win+4`

For example, you can put your editor, browser, terminal, and chat apps into different workspaces, then move between them instantly with these shortcuts.

## Step 4: Move focus between windows

To move focus inside the current workspace:

- `Win+H`: focus left
- `Win+J`: focus down
- `Win+K`: focus up
- `Win+L`: focus right

If you are already comfortable with Vim-style directions, this set of hotkeys will feel very natural.

## A few advanced tips

### 1. Stack and stack cycling

If you want multiple windows to share the same slot, use:

- `Win+Alt+H/J/K/L`: stack the current window to the left / down / up / right
- `Alt+[` : switch to the previous window in the stack
- `Alt+]` : switch to the next window in the stack
- `Alt+;` : remove the current window from the stack

This is useful when you have many windows of the same type but do not want all of them visible at once.

### 2. Multi-monitor and multiple bars

If you use multiple monitors later on:

- each monitor can have its own workspace setup
- each monitor can also run its own bar instance

This is more advanced configuration, so it is best to explore it later:

- `docs/common-workflows/multi-monitor-setup.md:1`
- `docs/common-workflows/multiple-bar-instances.md:1`

### 3. Customizing AHK shortcuts

`shortcuts\komorebi.ahk` is essentially just a mapping from a hotkey to a `komorebic.exe` command.

So if you want to change the keybindings, the easiest way is to follow the existing pattern directly:

- the left side is the AHK hotkey
- the right side is the `komorebic.exe` command

If you want to customize AHK further, these are the best places to continue:

- `release/portable/shortcuts/komorebi.ahk:1`
- `whitelist_dev/doc_fork/autohotkey.md:1`
- `whitelist_dev/doc_fork/advanced-usage-guide.md:1`
