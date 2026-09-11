# oma4wg — agent notes

Work from the repo root (this directory). Feature work: `plans/restore-features.md` (done). Remaining Omarchy gaps: `plans/omarchy-gaps.md`. One phase at a time; wait for confirmation.

Script: `oma4wg.ahk` (AutoHotkey v2)  
AHK: `%USERPROFILE%\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe`  
Compiler: `%USERPROFILE%\scoop\apps\autohotkey\current\Compiler\Ahk2Exe.exe`

## Do not break typing

- Super is physical Alt via `$LAlt::LWin` / `$LWin::LAlt` (same for right keys).
- Never add `LAlt & key` / `RAlt & key` combos. They make Alt a prefix and eat typing.
- Extra binds are `#` (Win) hotkeys only. Add one feature at a time and wait for the user to confirm.

## Start / reload (must outlive the agent)

Agent shells kill child processes. Do **not** `Start-Process` AHK and expect it to stay up. Do **not** `Stop-Process AutoHotkey*` then start — that race leaves nothing running.

Start or replace the running instance with WMI (breaks away from the job). Paths are relative to the repo root:

```powershell
$root = (Resolve-Path .).Path
$exe = Join-Path $root "oma4wg.exe"
$ahk = "$env:USERPROFILE\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe"
$script = Join-Path $root "oma4wg.ahk"
$cmd = if (Test-Path $exe) { "`"$exe`"" } else { "`"$ahk`" `"$script`"" }
Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
  CommandLine = $cmd
  CurrentDirectory = $root
}
```

`#SingleInstance Force` replaces an older copy of the **same** path. Then confirm:

```powershell
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'oma4wg' }
Get-Content .\oma4wg.log -Tail 5
```

Log lines: `start` on launch, `exit reason=...` on shutdown. `Single` means a new instance replaced this one.

## Compile

From the repo root:

```powershell
$root = (Resolve-Path .).Path
& "$env:USERPROFILE\scoop\apps\autohotkey\current\Compiler\Ahk2Exe.exe" `
  /in "$root\oma4wg.ahk" /out "$root\oma4wg.exe" `
  /base "$env:USERPROFILE\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe"
```

`*.exe` and `*.log` are gitignored. Startup (this machine) prefers the exe if present:

`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\skhd-hotkeys.cmd`

## DLL

`VirtualDesktopAccessor.dll` is third-party (not a Windows system DLL). Super+1..9 lazy-loads it on first use (`InitVda`). Do not `LoadLibrary` at script start.
