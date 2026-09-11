# Omarchy 4 Workgroups (oma4wg)

Omarchy-style Super key binds on Windows.

No tiling WM (yet, possible)

Tray: **Swap Alt and Win** (off by default: physical Win is Super. Check to swap so physical Alt is Super). Persists in gitignored `oma4wg.ini`.

## Install

Needs **Windows 11 24H2+** (virtual-desktop DLL), **AutoHotkey v2**, and **PowerToys** (Command Palette).

Winget:

```text
winget install AutoHotkey.AutoHotkey Microsoft.PowerToys
```

Scoop:

```text
scoop bucket add extras
scoop install extras/autohotkey extras/powertoys
```

Or install [AutoHotkey v2](https://www.autohotkey.com/) and [PowerToys](https://learn.microsoft.com/en-us/windows/powertoys/install) from their sites.

Optional: **Settings → System → Clipboard → Clipboard history** for Super+Ctrl+V.

App launches (X, YouTube, iCloud Mail, Outlook, Photos, Media Player, VS Code) look up names in the Start menu. You must install those apps or PWA/web apps first, or the Super+Shift binds will not find them.

Run (from this repo). Scoop:

```text
"%USERPROFILE%\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe" oma4wg.ahk
```

Winget / official installer:

```text
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" oma4wg.ahk
```

Compile (optional; `*.exe` is gitignored). Point `/base` at the AutoHotkey64.exe from Scoop or Program Files:

```text
Ahk2Exe /in oma4wg.ahk /out oma4wg.exe /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

Autostart: shortcut or a one-line `.cmd` in `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup` that starts `oma4wg.exe` (or the `.ahk` with AutoHotkey64). Right-click the tray icon for **Swap Alt and Win**.

`VirtualDesktopAccessor.dll` must sit next to the script. It is in this repo (MIT). It is **not** a Windows system DLL.

## Current binds

| Super+ | Action |
|---|---|
| Space | PowerToys Command Palette |
| Enter | Windows Terminal |
| F | Fullscreen (F11) |
| Q / W | Close window |
| C / V | Copy / paste |
| Ctrl+V | Clipboard history (Win+V) |
| Z | Undo |
| Shift+Z | Redo |
| A | Select all |
| Shift+Enter / B | Default browser |
| Shift+E | iCloud Mail |
| Shift+F | Explorer |
| Shift+N | VS Code |
| Shift+C | Outlook |
| Shift+M | Media Player |
| Shift+P | Photos |
| Shift+Y | YouTube |
| Shift+X | X app (plain Super+X stays Win+X) |
| 1..9 | Virtual desktop (creates if missing) |
| Shift+1..9 | Move window to desktop and follow |
| Shift+Alt+1..9 | Move window, stay on this desktop |
| Tab | App switcher (Alt+Tab; not Task View) |

`VirtualDesktopAccessor.dll` (Ciantic, MIT) is for Super+1..9 virtual desktops. License: `third_party/VirtualDesktopAccessor/LICENSE.txt`. Source: https://github.com/Ciantic/VirtualDesktopAccessor
