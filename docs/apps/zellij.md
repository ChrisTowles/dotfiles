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

## Resources

- [Zellij Official Site](https://zellij.dev/)
- [GitHub Repository](https://github.com/zellij-org/zellij)
- Config: `~/.config/zellij/config.kdl`
