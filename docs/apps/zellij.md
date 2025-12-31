# Zellij Tutorial for Beginners

Zellij is a terminal multiplexer - it lets you run multiple terminal sessions in one window, split your screen, and keep sessions alive even if you close your terminal.

## Why Zellij?

Instead of opening 10 terminal tabs:
```
[Tab: server] [Tab: logs] [Tab: git] [Tab: tests] ...
```

You get one organized workspace:
```
┌─────────────────┬─────────────────┐
│  npm run dev    │  git status     │
│                 │                 │
├─────────────────┼─────────────────┤
│  tail -f logs   │  vim file.ts    │
│                 │                 │
└─────────────────┴─────────────────┘
```

Plus: sessions persist. Close terminal, reopen, reattach - everything is still there.

---

## Core Concepts

### 1. Sessions
A session is your entire workspace. You can have multiple sessions (e.g., "work", "personal").

```bash
zellij                    # Start/attach to default session
zellij -s myproject       # Start named session
zellij attach myproject   # Attach to existing session
zellij list-sessions      # See all sessions
```

### 2. Tabs
Like browser tabs. Each tab can have multiple panes.

### 3. Panes
Splits within a tab. Horizontal or vertical divisions.

---

## Your First Session

### Step 1: Start zellij
```bash
zellij
```

You'll see the status bar at bottom showing current mode and shortcuts.

### Step 2: Split the screen
```
Ctrl+a |    # Split vertically (side by side)
```

Now you have two panes. The cursor is in the new one.

### Step 3: Run something in each pane
```bash
# In right pane
htop

# Press Ctrl+a h to go left
# In left pane
watch -n1 date
```

### Step 4: Navigate between panes
```
Ctrl+a h/j/k/l   # vim-style movement
```

### Step 5: Detach and reattach
```
Ctrl+a d         # Detach - session keeps running!
```

Later:
```bash
zellij attach    # You're back, everything still running
```

---

## Common Workflows

### Dev Environment
```bash
zellij -s myapp
# Pane 1: npm run dev
# Pane 2: git / file editing
# Pane 3: logs
# Pane 4: tests
```

### Quick Layout
```
Ctrl+a |         # Split right
Ctrl+a -         # Split bottom (in right pane)
Ctrl+a h         # Go to left pane
Ctrl+a -         # Split bottom (in left pane)
```
Result: 4 panes in a grid.

---

## Shell Aliases (already configured)

```bash
zj              # zellij
zja             # zellij attach
zjl             # zellij list-sessions
zjk             # zellij kill-session
zjka            # zellij kill-all-sessions
```

---

## Tips

1. **Mouse works** - Click panes to focus, drag borders to resize
2. **Scroll mode** - `Ctrl+a [` then arrow keys, `q` to exit
3. **Zoom pane** - `Ctrl+a z` to focus one pane fullscreen, again to restore
4. **Auto-start** - Your shell auto-starts zellij (disable with `ZELLIJ_AUTO_START=false zsh`)

---

## Quick Reference Card

```
PREFIX = Ctrl+a

PANES                    TABS                   SESSION
──────                   ────                   ───────
|  split right           c  new tab             d  detach
-  split down            n  next tab            [  scroll mode
x  close pane            p  prev tab
z  zoom/fullscreen       ,  rename tab
h/j/k/l  navigate
```

---

## Resources

- [Zellij Official Site](https://zellij.dev/)
- [GitHub Repository](https://github.com/zellij-org/zellij)
- Config: `~/.config/zellij/config.kdl`
