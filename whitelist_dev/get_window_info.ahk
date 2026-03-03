#Requires AutoHotkey v2.0.2

; 按 Ctrl+Alt+I 查看当前窗口信息
^!i:: {
    MouseGetPos ,, &WindowID
    ProcessName := WinGetProcessName("A")
    WindowTitle := WinGetTitle("A")
    WindowClass := WinGetClass("A")

    info := "
    (
    进程名: " ProcessName "
    窗口标题: " WindowTitle "
    窗口类名: " WindowClass "
    窗口ID: " WindowID "
    )"

    MsgBox info, "当前窗口信息"
}
