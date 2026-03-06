#Requires AutoHotkey v2.0.2

Komorebic(args) {
    local executable := A_ScriptDir . "\..\bin\komorebic.exe"
    if !FileExist(executable) {
        MsgBox "Missing komorebic.exe in " . A_ScriptDir . "\..\bin", "komorebi portable", "Icon!"
        return
    }

    RunWait(Format('"{}" {}', executable, args), , "Hide")
}

#h::Komorebic("focus left")
#j::Komorebic("focus down")
#k::Komorebic("focus up")
#l::Komorebic("focus right")

#+h::Komorebic("move left")
#+j::Komorebic("move down")
#+k::Komorebic("move up")
#+l::Komorebic("move right")

#1::Komorebic("focus-workspace 0")
#2::Komorebic("focus-workspace 1")
#3::Komorebic("focus-workspace 2")
#4::Komorebic("focus-workspace 3")

#+1::Komorebic("send-to-workspace 0")
#+2::Komorebic("send-to-workspace 1")
#+3::Komorebic("send-to-workspace 2")
#+4::Komorebic("send-to-workspace 3")

#!h::Komorebic("stack left")
#!j::Komorebic("stack down")
#!k::Komorebic("stack up")
#!l::Komorebic("stack right")

![::Komorebic("cycle-stack previous")
!]::Komorebic("cycle-stack next")
!;::Komorebic("unstack")

#+m::Komorebic("manage")
#+n::Komorebic("unmanage")