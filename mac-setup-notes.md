# Mac only stuff

adding some Mac specific setup notes here.

## Apps

### Macy

This or copyq is a must1, you always should be using a clipboard manager.


### Karabiner Elements

Powerful keyboard remapping tool for macOS.

```bash
brew install --cask karabiner-elements
```

Essential Modifier Swaps


  Swap Ctrl and Cmd (most impactful change):
  - Makes Ctrl+C/V/X work for copy/paste like Linux
  - Ctrl+T for new tab, Ctrl+W to close, etc.

  Swap Option and Cmd (alternative):
  - Some prefer this to keep muscle memory for Alt-based shortcuts

  Home/End Key Behavior

  Linux: Home/End go to beginning/end of line
  macOS: Home/End go to beginning/end of document

  Add rules to make Home/End behave like Linux (line-based navigation).

  Terminal-Specific Rules

  Keep Cmd as Ctrl only in Terminal/iTerm2, so you get:
  - Ctrl+C to interrupt processes
  - Ctrl+D to exit
  - Ctrl+R for reverse search

  Common Complex Modifications

  Search the Karabiner complex modifications gallery for:
  - "PC-Style Shortcuts" - comprehensive Linux/Windows-like behavior




### Starship
https://starship.rs/


53K stars on GitHub

```
brew install starship
```

Create the config file at [starship config](~/.config/starship.toml)

To use one:

```bash
# Minimal (no special font needed)
cp ./config/starship-minimal.toml ~/.config/starship.toml

# Nerd font version (requires Nerd Font like JetBrainsMono NF)
cp ./config/starship-nerd.toml ~/.config/starship.toml

```