#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook
Persistent
InstallKeybdHook
A_MenuMaskKey := "vkE8"

Log("start")
OnExit ExitLog

AppSwitcher := false
SwapAltWin := IniRead(A_ScriptDir "\oma4wg.ini", "oma4wg", "SwapAltWin", "0") != "0"
SwapPaused := false
SwapPausedExe := ""
NoSwapExe := Map()
LoadNoSwap()
UpdateTip()
A_TrayMenu.Insert("1&", "Swap Alt and Win", ToggleSwap)
if SwapAltWin
    A_TrayMenu.Check("Swap Alt and Win")
TrayTip "oma4wg", "Loaded " FormatTime(, "HH:mm:ss")
WatchNoSwap()
SetTimer WatchNoSwap, 250

; Swap is off while a NoSwapExe process exists. Super binds stay on physical Win.
#HotIf SwapAltWin && !SwapPaused
$LAlt::LWin
$LWin::LAlt
$RAlt::RWin
$RWin::RAlt
#HotIf

Mask() {
    SendEvent "{Blind}{vkE8}"
}

; Mask, release Win and Shift, then the chord, in one SendEvent. Blind does not press Win again.
SendChord(keys) {
    SendEvent "{Blind}{vkE8}{LWin up}{RWin up}{Shift up}" keys
}

#Enter:: {
    Mask()
    NewTerminal()
}
#Space:: {
    Mask()
    OpenCommandPalette()
}
#f:: {
    SendChord("{F11}")
}
#q::
#w:: {
    Mask()
    WinClose "A"
}

; Super+Tab app switcher (not Task View). No LAlt& prefix.
#Tab:: SuperTab()
+#Tab:: SuperTab(true)
#InputLevel 1
#HotIf AppSwitcher
$Tab:: SuperTab()
$+Tab:: SuperTab(true)
#HotIf
#InputLevel 0
#c:: {
    SendChord("{Ctrl down}{Insert}{Ctrl up}")
}
; Level 1 so Super+Ctrl+V can Send "#v" without retriggering paste.
#InputLevel 1
#v:: {
    SendChord("{Shift down}{Insert}{Shift up}")
}
#InputLevel 0
^#v:: {
    SendEvent "{Blind}{vkE8}{Ctrl up}#v"
}
#z:: {
    SendChord("^z")
}
#+z:: {
    SendChord("^y")
}
#a:: {
    SendChord("^a")
}

; Super+Shift apps (do not bind #x — native Win+X menu)
#+Enter::
#+b:: {
    Mask()
    Run "https://"
}
#+c:: {
    Mask()
    LaunchAppByName("Outlook")
}
#+e:: {
    Mask()
    LaunchAppByName("iCloud Mail")
}
#+f:: {
    Mask()
    Run "explorer.exe"
}
#+n:: {
    Mask()
    Run "code"
}
#+m:: {
    Mask()
    LaunchAppByName("Media Player")
}
#+p:: {
    Mask()
    LaunchAppByName("Photos")
}
#+y:: {
    Mask()
    LaunchAppByName("YouTube")
}
#+x:: {
    Mask()
    LaunchAppByName("X")
}

; Super+1..9 virtual desktops (DLL lazy-loaded; not at start)
#1:: GoToDesktop(1)
#2:: GoToDesktop(2)
#3:: GoToDesktop(3)
#4:: GoToDesktop(4)
#5:: GoToDesktop(5)
#6:: GoToDesktop(6)
#7:: GoToDesktop(7)
#8:: GoToDesktop(8)
#9:: GoToDesktop(9)
#+1:: MoveWindowToDesktop(1)
#+2:: MoveWindowToDesktop(2)
#+3:: MoveWindowToDesktop(3)
#+4:: MoveWindowToDesktop(4)
#+5:: MoveWindowToDesktop(5)
#+6:: MoveWindowToDesktop(6)
#+7:: MoveWindowToDesktop(7)
#+8:: MoveWindowToDesktop(8)
#+9:: MoveWindowToDesktop(9)
#!+1:: MoveWindowToDesktopSilent(1)
#!+2:: MoveWindowToDesktopSilent(2)
#!+3:: MoveWindowToDesktopSilent(3)
#!+4:: MoveWindowToDesktopSilent(4)
#!+5:: MoveWindowToDesktopSilent(5)
#!+6:: MoveWindowToDesktopSilent(6)
#!+7:: MoveWindowToDesktopSilent(7)
#!+8:: MoveWindowToDesktopSilent(8)
#!+9:: MoveWindowToDesktopSilent(9)

NewTerminal() {
    try Run "wt.exe -w new"
    catch
        Run "wt.exe"
}

OpenCommandPalette() {
    static exe := ""
    if exe = "" {
        Loop Files "C:\Program Files\WindowsApps\Microsoft.CommandPalette_*\Microsoft.CmdPal.UI.exe"
            exe := A_LoopFileFullPath
    }
    if exe != ""
        Run exe
    else
        Run "explorer.exe shell:AppsFolder\Microsoft.CommandPalette_8wekyb3d8bbwe!App"
}

LaunchAppByName(needle) {
    shell := ComObject("Shell.Application")
    apps := shell.NameSpace("shell:AppsFolder")
    if !apps
        return false
    needle := StrLower(needle)
    fallback := 0
    for item in apps.Items {
        name := StrLower(item.Name)
        if (name = needle) {
            item.InvokeVerb()
            return true
        }
        if !fallback && InStr(name, needle)
            fallback := item
    }
    if fallback {
        fallback.InvokeVerb()
        return true
    }
    return false
}

SuperTab(backward := false) {
    global AppSwitcher
    if !AppSwitcher {
        AppSwitcher := true
        Mask()
        Send "{Blind}{LWin up}{RWin up}{Alt down}"
        SetTimer WatchAppSwitcher, 15
    }
    Send backward ? "{Blind}+{Tab}" : "{Blind}{Tab}"
}

WatchAppSwitcher() {
    if SuperHeld()
        return
    SetTimer WatchAppSwitcher, 0
    EndAppSwitcher()
}

SuperHeld() {
    return GetKeyState("LAlt", "P") || GetKeyState("RAlt", "P")
        || GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
}

EndAppSwitcher() {
    global AppSwitcher
    if !AppSwitcher
        return
    AppSwitcher := false
    SetTimer WatchAppSwitcher, 0
    Send "{Blind}{Alt up}"
}

GoToDesktopAt := 0
GoToDesktopLast := 0
VdaGoTo := 0
VdaCount := 0
VdaCreate := 0
VdaMove := 0

InitVda() {
    global VdaGoTo, VdaCount, VdaCreate, VdaMove
    if VdaGoTo
        return true
    dll := A_ScriptDir "\VirtualDesktopAccessor.dll"
    if !FileExist(dll)
        return false
    h := DllCall("LoadLibrary", "Str", dll, "Ptr")
    if !h
        return false
    VdaGoTo := DllCall("GetProcAddress", "Ptr", h, "AStr", "GoToDesktopNumber", "Ptr")
    VdaCount := DllCall("GetProcAddress", "Ptr", h, "AStr", "GetDesktopCount", "Ptr")
    VdaCreate := DllCall("GetProcAddress", "Ptr", h, "AStr", "CreateDesktop", "Ptr")
    VdaMove := DllCall("GetProcAddress", "Ptr", h, "AStr", "MoveWindowToDesktopNumber", "Ptr")
    return VdaGoTo && VdaCount
}

GoToDesktop(n) {
    global GoToDesktopAt, GoToDesktopLast, VdaGoTo, VdaCount, VdaCreate
    if (GoToDesktopLast = "g" n && A_TickCount - GoToDesktopAt < 200)
        return
    GoToDesktopAt := A_TickCount
    GoToDesktopLast := "g" n
    Mask()
    if !InitVda() {
        TrayTip "oma4wg", "VirtualDesktopAccessor.dll failed to load"
        return
    }
    while DllCall(VdaCount, "Int") < n && VdaCreate
        DllCall(VdaCreate, "Int")
    DllCall(VdaGoTo, "Int", n - 1, "Int")
}

MoveWindowToDesktop(n) {
    global GoToDesktopAt, GoToDesktopLast, VdaGoTo, VdaCount, VdaCreate, VdaMove
    if (GoToDesktopLast = "m" n && A_TickCount - GoToDesktopAt < 200)
        return
    GoToDesktopAt := A_TickCount
    GoToDesktopLast := "m" n
    Mask()
    if !InitVda() || !VdaMove {
        TrayTip "oma4wg", "VirtualDesktopAccessor.dll failed to load"
        return
    }
    hwnd := WinExist("A")
    if !hwnd
        return
    while DllCall(VdaCount, "Int") < n && VdaCreate
        DllCall(VdaCreate, "Int")
    DllCall(VdaMove, "Ptr", hwnd, "Int", n - 1, "Int")
    DllCall(VdaGoTo, "Int", n - 1, "Int")
}

MoveWindowToDesktopSilent(n) {
    global GoToDesktopAt, GoToDesktopLast, VdaCount, VdaCreate, VdaMove
    if (GoToDesktopLast = "s" n && A_TickCount - GoToDesktopAt < 200)
        return
    GoToDesktopAt := A_TickCount
    GoToDesktopLast := "s" n
    Mask()
    if !InitVda() || !VdaMove {
        TrayTip "oma4wg", "VirtualDesktopAccessor.dll failed to load"
        return
    }
    hwnd := WinExist("A")
    if !hwnd
        return
    while DllCall(VdaCount, "Int") < n && VdaCreate
        DllCall(VdaCreate, "Int")
    DllCall(VdaMove, "Ptr", hwnd, "Int", n - 1, "Int")
}

LoadNoSwap() {
    global NoSwapExe
    raw := IniRead(A_ScriptDir "\oma4wg.ini", "oma4wg", "NoSwapExe", "")
    NoSwapExe := Map()
    for part in StrSplit(raw, ",") {
        name := StrLower(Trim(part))
        if name = ""
            continue
        if !InStr(name, ".")
            name .= ".exe"
        NoSwapExe[name] := true
    }
    Log("noswap " (raw = "" ? "(none)" : raw))
}

WatchNoSwap() {
    global SwapPaused, SwapPausedExe, NoSwapExe
    hit := ""
    for name, unused in NoSwapExe {
        if ProcessExist(name) {
            hit := name
            break
        }
    }
    on := hit != ""
    if (on = SwapPaused && (!on || hit = SwapPausedExe))
        return
    SwapPaused := on
    SwapPausedExe := hit
    UpdateTip()
    Log("swap " (on ? "off " hit : "on"))
}

UpdateTip() {
    global SwapAltWin, SwapPaused, SwapPausedExe
    if SwapAltWin && SwapPaused
        A_IconTip := "oma4wg swap off (" SwapPausedExe ")"
    else if SwapAltWin
        A_IconTip := "oma4wg Alt=Win"
    else
        A_IconTip := "oma4wg (no Alt/Win swap)"
}

ToggleSwap(*) {
    global SwapAltWin
    SwapAltWin := !SwapAltWin
    IniWrite SwapAltWin ? "1" : "0", A_ScriptDir "\oma4wg.ini", "oma4wg", "SwapAltWin"
    A_TrayMenu.ToggleCheck("Swap Alt and Win")
    UpdateTip()
}

Log(msg) {
    try FileAppend FormatTime(, "HH:mm:ss") " " msg "`n", A_ScriptDir "\oma4wg.log"
}

ExitLog(reason, code) {
    try EndAppSwitcher()
    Log("exit reason=" reason " code=" code)
}
