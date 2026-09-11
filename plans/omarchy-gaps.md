# Omarchy gaps vs oma4wg

Compare [Omarchy hotkeys](https://omarchy.org/manual/hotkeys/) and default/user bindings (`~/.config/hypr/bindings.lua`, Omarchy `applications.lua` / `tiling.lua` / `clipboard.lua`) to `oma4wg.ahk`.

Restore-features (`plans/restore-features.md`) is **done**. This plan is what is still missing or different. Same hard rules: `#` hotkeys only, no `LAlt &`, lazy-load the desktop DLL, WMI reload, one phase at a time.

Sources: manual 2026-09; user’s overlay uses iCloud Mail and Apple Music instead of HEY/Spotify.

## Already close enough

| Omarchy | oma4wg |
|---|---|
| Super+Return terminal | Super+Enter → Windows Terminal |
| Super+F fullscreen | Super+F → F11 |
| Super+Q / Super+W close | same |
| Super+C / Super+V copy/paste | CUA Insert chords |
| Super+Z / Super+Shift+Z / Super+A | undo / redo / select all |
| Super+1..9 workspaces | virtual desktops (creates if missing) |
| Super+Shift+1..9 move+follow | same |
| Super+Shift+Return / B browser | Edge |
| Super+Shift+F files | Explorer |
| Super+Shift+E email | iCloud Mail (matches user overlay) |
| Super+Shift+C calendar | Outlook (user has HEY on Linux; Outlook is the Windows stand-in) |
| Super+Shift+N editor | VS Code (Omarchy: Neovim) |
| Super+Shift+X / Y | X app / YouTube |
| Super+Shift+P photos | Windows Photos (Omarchy: Google Photos) |
| Super+Shift+M music | Media Player (Omarchy user overlay: Apple Music webapp) |
| Alt↔Win swap + tray toggle | laptop Super on physical Alt |

## Intentional divergences (do not “fix” unless asked)

| Chord | Omarchy | oma4wg | Why |
|---|---|---|---|
| Super+Tab | **Next workspace** | **App switcher** (Alt+Tab) | We built Mac-style switcher; Omarchy uses Alt+Tab for windows and Super+Tab for workspaces |
| Super+Shift+Tab | Previous workspace | Reverse app switcher | Same |
| Super+X | **Cut** | Native **Win+X** menu | Intercepting `#x` broke the menu; cut stays Ctrl+X |
| Super+0 | Workspace 10 | Unbound | User asked 1–9 only |
| Super+Ctrl+T | Activity (btop) | Unbound (was Terminal once) | Win+Ctrl+T is PowerToys Always On Top by default |
| Super+Arrow / Shift+Arrow | Focus / swap tiled windows | Win+Arrow **snap** | Leave unbound; snap is not tiling |
| Tiling WM | Hypr layout, scratchpad, grouping, resize | None | **Out of scope for first pass** |
| Tmux / Ghostty / Neovim / CapsLock compose | Those apps | Skip | Not AHK’s job |

## First pass (no tiling)

Each item is a phase. Confirm before the next. Do not implement tiling, scratchpad, grouping, or Super+Tab-as-workspace in this pass.

### A — Launcher and lock (high)

| Chord | Omarchy | Windows stand-in |
|---|---|---|
| Super+Space | Omarchy menu / walker | **Done:** `#Space` launches Command Palette. CmdPal Win+Alt+Space and Run Alt+Space cleared so AHK owns Super+Space |
| Super+Alt+Space | Apps menu | Start, or PowerToys Run |
| Super+Escape | System menu | Win+X already on Super+X; or a small power menu |
| Super+Ctrl+L | Lock | Win+L is OS-reserved; may need `rundll32 user32 LockWorkStation` on a non-Win+L chord, or document that lock stays Win+L |
| Super+K | Show keybindings | MsgBox / open this plan or a cheatsheet |

### B — Clipboard leftovers

| Chord | Omarchy | Notes |
|---|---|---|
| Super+Ctrl+V | Clipboard manager | **Done:** `^#v` sends Win+V (history). Super+V stays paste |
| Super+X cut | Cut | Conflicts with Win+X. Only add if user accepts losing the power-user menu, or use Super+Shift+X for cut (but that is the X app now) |

### C — App launches still missing (medium)

Omarchy defaults / user overlay not in oma4wg:

| Chord | Omarchy / user | Suggested Windows |
|---|---|---|
| Super+Shift+S | Google Maps | Maps URL or app (`#+s` is **not** bound; Snipping Tool is Win+Shift+S — will steal screenshots) |
| Super+Shift+A | ChatGPT | Browser to chatgpt.com |
| Super+Shift+Alt+A | Grok | grok.com |
| Super+Shift+G | Signal | Signal if installed |
| Super+Shift+/ | 1Password | 1Password |
| Super+Shift+O | Obsidian | Obsidian |
| Super+Shift+D | LazyDocker | skip or Windows Terminal `lazydocker` |
| Super+Shift+W | Omawrite | skip or Notepad |
| Super+Shift+Alt+B | Browser private | `msedge --inprivate` |
| Super+Shift+Alt+E | New email | iCloud Mail compose if we have a URL |
| Super+Alt+Return | Tmux terminal | skip or WT |
| Super+Ctrl+Return | Herdr | skip |

Call out **Super+Shift+S** vs Snipping Tool before binding it.

### D — Capture (medium)

| Chord | Omarchy | Windows |
|---|---|---|
| Print Screen | Screenshot | Already Snipping / PrtScn |
| Super+Shift+S | (maps on Omarchy; screenshot on many Win setups) | Keep Snipping unless user wants maps |
| Super+Print | Color picker | PowerToys Color Picker if present |
| Super+Ctrl+Print | OCR | PowerToys Text Extractor (Win+Shift+T) |
| Super+Ctrl+C | Capture menu | Small menu or Snipping |

### E — Silent desktop move (medium, not tiling)

| Chord | Omarchy | Windows |
|---|---|---|
| Super+Shift+Alt+1..9 | Move window, do not follow | **Done:** `#!+1`..`#!+9` move only |

### F — System panels (low)

| Chord | Omarchy | Windows |
|---|---|---|
| Super+Ctrl+A/B/W/P | Audio / BT / Wi-Fi / Power | ms-settings: or Quick Settings |
| Super+Ctrl+E | Emoji picker | Win+. (native). Super+Ctrl+E could send `#.` |
| Super+Ctrl+, | Notifications silence | skip or Focus assist |
| Super+, | Dismiss notification | no simple API |

### G — Out of scope until there is a tiling WM

Leave these until a Windows tiling layer exists (Komorebi, GlazeWM, FancyZones, etc.):

- Super+T / J / O / L / P / G — float, layout, sticky, grouping
- Super+S / Grave — scratchpad
- Super+Arrow / Super+Shift+Arrow — focus and swap in a tiled stack (Win+Arrow snap stays native; do not rebind)
- Super+Minus / Equal — Hypr resize
- Super+Alt+Tab — cycle group
- Super+Tab as **next workspace** (would replace the current app switcher)
- Super+Shift+Alt+Arrows — move workspace to monitor
- FancyZones-only swap/focus

Also skip for now: monitor scale Super+/, Hypr zoom, waybar, nightlight, idle lock, webcam overlay, CapsLock compose, tmux/neovim/ghostty tables.

## Suggested first-pass order

1. Super+Ctrl+V clipboard history (done).
2. Super+Space launcher (done): AHK `#Space` launches PowerToys Run; PT Alt+Space unbound.
3. Super+Shift+Alt+1..9 silent move (done).
4. Missing app launches the user actually has (1Password, Obsidian, Signal, ChatGPT) — ask which.
5. Capture/OCR only if PowerToys modules are on.
6. Super+K cheatsheet / Super+Escape system menu if useful.

Do not start tiling or Super+Tab-as-workspace in this pass.
