# COSMIC Desktop Environment (Pop!_OS)

Reference for configuring System76's COSMIC desktop environment (Rust-based, Wayland-native).

## Detection

```bash
echo "$XDG_CURRENT_DESKTOP"  # Returns "COSMIC" if active
```

## Config Location

All COSMIC config lives under `~/.config/cosmic/` with this structure:
```
~/.config/cosmic/<component-id>/v1/<setting-name>
```

Each setting is a **separate file** (not one big config file). Values use RON (Rusty Object Notation) format.

### Key Component IDs

| Component | Path |
|-----------|------|
| Shortcuts | `com.system76.CosmicSettings.Shortcuts` |
| Compositor | `com.system76.CosmicComp` |
| Panel (top bar) | `com.system76.CosmicPanel.Panel` |
| Dock | `com.system76.CosmicPanel.Dock` |

System defaults: `/usr/share/cosmic/<component-id>/v1/defaults`

## Keyboard Shortcuts

### File Locations

- **Defaults**: `/usr/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1/defaults`
- **Custom overrides**: `~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom`

### RON Syntax

```ron
{
    (modifiers: [Alt], key: "grave"): Spawn("bash -c 'some command'"),
    (modifiers: [Super, Shift], key: "s"): Spawn("/usr/bin/some-app"),
    (modifiers: [Super], key: "t"): System(Terminal),
}
```

### Available Modifiers

`Super`, `Alt`, `Shift`, `Ctrl`

### Available Actions

| Action | Description |
|--------|-------------|
| `Spawn("command")` | Run a shell command via `/bin/sh -c` |
| `System(Terminal)` | Open default terminal |
| `System(WebBrowser)` | Open default browser |
| `System(HomeFolder)` | Open file manager |
| `System(AppLibrary)` | Open app launcher |
| `System(Launcher)` | Open COSMIC launcher |
| `System(WorkspaceOverview)` | Show workspace overview |
| `System(Screenshot)` | Take screenshot |
| `System(LockScreen)` | Lock screen |
| `System(LogOut)` | Log out |
| `Close` | Close focused window |
| `Maximize` | Toggle maximize |
| `Fullscreen` | Toggle fullscreen |
| `ToggleWindowFloating` | Float/tile window |
| `ToggleTiling` | Toggle tiling mode |
| `ToggleStacking` | Toggle stacking |
| `Focus(Left/Right/Up/Down)` | Move focus |
| `Move(Left/Right/Up/Down)` | Move window |
| `Workspace(N)` | Switch to workspace N |
| `MoveToWorkspace(N)` | Move window to workspace N |
| `NextWorkspace` / `PreviousWorkspace` | Cycle workspaces |
| `SwitchOutput(Left/Right/Up/Down)` | Focus another monitor |
| `MoveToOutput(Left/Right/Up/Down)` | Move window to another monitor |
| `Resizing(Outwards/Inwards)` | Resize focused window |
| `SwapWindow` | Swap window position |
| `Terminate` | Force quit compositor (Super+Alt+Escape) |
| `Debug` | Toggle debug mode |

### Special Key Names

| Key | RON name |
|-----|----------|
| `` ` `` (backtick) | `"grave"` |
| Print Screen | `"Print"` |
| F1-F12 | `"F1"` - `"F12"` |
| Space | `"space"` |
| `/` | `"slash"` |
| `=` | `"equal"` |
| `-` | `"minus"` |
| `.` | `"period"` |
| `,` | `"comma"` |
| Arrow keys | `"Left"`, `"Right"`, `"Up"`, `"Down"` |
| Tab | `"Tab"` |
| Escape | `"Escape"` |

### Important Notes

- The `custom` file **replaces** existing bindings if the same key combo is used
- Changes take effect after COSMIC restart or re-login
- The `Spawn` action runs commands via `/bin/sh -c` — shell functions from `.zshrc` are NOT available
- Use full paths or inline commands in `Spawn`

## Autostart

COSMIC respects XDG autostart entries:

```
~/.config/autostart/my-app.desktop
```

Example `.desktop` file:
```ini
[Desktop Entry]
Name=My App
Comment=Description
Exec=/usr/bin/my-app --flag
Type=Application
X-GNOME-Autostart-enabled=true
```

## CLI Tools

```bash
cosmic-settings                    # Open settings GUI
cosmic-settings keyboard           # Keyboard settings page
cosmic-settings accessibility      # Accessibility settings
```

## Spawn Command Details

The `Spawn` action:
1. Creates an XDG activation token for proper window focus
2. Sets `WAYLAND_DISPLAY`, `DISPLAY`, and `XDG_ACTIVATION_TOKEN` environment variables
3. Runs the command via `/bin/sh -c` in a separate thread
4. This means shell pipes, redirects, and subshells all work
