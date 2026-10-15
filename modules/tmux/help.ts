export const TMUX_HELP = `
── Starting a session ──
  ts         Start or reattach session named after current dir (most common)
  tsn        Force a new session even if one exists for this dir
  tz [query] Fuzzy-pick a frecent dir (z + fzf) and open/attach a session there

── Navigating sessions ──
  ta         Reattach to a session (fzf picker, or ta <name>)
  tss        Switch between sessions while inside tmux
  tl         List all running sessions

── Leaving a session ──
  td         Detach — leave session running in background, come back with ta
  exit       Close current pane — kills session when it's the last pane
  Ctrl+d     Same as exit

── Destroying sessions ──
  tkc        Kill the current session and drop out of tmux
  tk         Kill a session by name or fzf picker (tk <name>)
  tka        Kill tmux server — destroys ALL sessions

── Windows & panes ──
  tw         List windows in current session
  tp         List panes in current window

── Keybindings (prefix = Ctrl+a) ──
  Sessions:
    prefix d       Detach (same as td)
    prefix s       List/pick sessions
    prefix \$       Rename session
    prefix (  )    Previous/next session
  Windows:
    prefix c       New window
    prefix ,       Rename window
    prefix n  p    Next/previous window
    prefix 0-9     Go to window by number
    prefix &       Kill window
  Panes:
    prefix |       Split vertical
    prefix -       Split horizontal
    prefix h/j/k/l Navigate panes (vim-style)
    prefix z       Toggle pane zoom
    prefix x       Kill pane
    prefix {  }    Swap pane left/right
  Other:
    prefix [       Enter copy mode (scroll/copy text)
    prefix :       Command prompt
    prefix ?       List all keybindings
`;
