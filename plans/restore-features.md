# Restore oma4wg features without breaking typing

Follow this in order. After each phase, **stop and wait for the user to confirm**. If typing, Start, or an existing bind breaks, revert that phase before continuing.

## Hard rules

- Super binds are `#` (Win) hotkeys only. Never `LAlt & key` / `RAlt & key` — those make Alt a prefix and eat typing.
- Do not `LoadLibrary` `VirtualDesktopAccessor.dll` at script start. Lazy-load on first desktop bind only.
- Start/reload the script with WMI `Win32_Process.Create` as in `AGENTS.md`. Do not kill-then-start from the agent shell.
- One phase per change. Do not stack Tab + desktops + new remaps in one commit.

## Swap toggle (always available)

Alt↔Win is optional so a broken Super layout can be turned off without exiting the script.

- Default **off** (physical Win is Super). Check tray **Swap Alt and Win** for laptop layout (physical Alt = Super).
- File: `oma4wg.ini` (gitignored) key `SwapAltWin=1` or `0`.
- `#` hotkeys always use Win after remap (or native Win if swap is off).

## Phases

### 0 — Remap + current binds (done)

Alt↔Win, terminal, F11, close, copy/paste, undo/redo, select all. This is the last known-good baseline.

**Verify:** typing; Super tap opens Start; Super+Enter Terminal; Super+W closes; Super+C/V copy/paste.

### 1 — Swap toggle

Ship the tray/ini toggle. Confirm both states.

**Verify:** swap on → physical Alt is Super. Swap off → physical Alt is Alt, physical Win is Super for the same `#` binds. Typing works in both.

### 2 — Super+X

Super+X is already native Win+X via the remap. **Do not bind `#x`.** Intercepting it broke the menu before.

- Super+Shift+X → X app only (`#+x`). Leave `#x` alone.

**Verify:** Super+X, release Super, then a letter (e.g. I). Super+Shift+X opens the X app if that bind is added.

### 3 — Super+Shift app launches (done)

Port from the old skhd, one bind group:

- Super+Shift+Enter / B → Edge
- Super+Shift+E → iCloud Mail
- Super+Shift+F → Explorer
- Super+Shift+N → VS Code
- Super+Shift+C → Outlook
- Super+Shift+M → Media Player
- Super+Shift+P → Photos
- Super+Shift+Y → YouTube

**Verify:** each launch; Super+F (no Shift) is still F11, not Explorer.

### 4 — Virtual desktops Super+1..9 (done)

Use `VirtualDesktopAccessor.dll` next to the script. `GetProcAddress` on first Super+1..9 only.

- Super+1..9 → `GoToDesktopNumber(n-1)`, `CreateDesktop` if count < n.
- Mask / lift Win before the call so Start does not open.
- Debounce only a repeat of the **same** desktop. Do not lift Win after a jump — hold Super and tap 1 then 2 must switch to 2.

**Verify:** Super+2 / Super+3 jump; missing desktops are created; Super+F and typing still work. If the DLL fails, TrayTip and do nothing (do not fall back to a key-spam loop in this phase).

### 5 — Super+Shift+1..9 move window (done)

`MoveWindowToDesktopNumber(hwnd, n-1)` then go to that desktop (Omarchy `movetoworkspace`).

**Verify:** Super+Shift+2 moves the active window and follows. Super+2 (no Shift) still only switches.

### 6 — Super+Tab app switcher (done)

Win+Tab is Task View. Replace with Alt+Tab **without** `LAlt & Tab`.

Use `#Tab` after the remap (Win is already down). Lift Win, send Alt+Tab, release Alt when physical Alt goes up (timer on `GetKeyState("LAlt","P")`, not a prefix hotkey).

**Verify:** hold Super, tap Tab to cycle, release Super to switch. Typing and Super+F still work. If this phase fails, revert only this phase.

## Out of scope until asked

PowerToys Run / Super+Space, Super+Ctrl+T duplicates, Kitty, compiling as a required step (exe is optional, gitignored).
