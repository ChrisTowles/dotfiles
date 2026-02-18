#!/usr/bin/env bun

import pc from "picocolors";

const h = (s: string) => pc.bold(pc.yellow(s));
const cmd = (name: string, desc: string) => `  ${pc.green(name.padEnd(20))}${desc}`;
const dim = (s: string) => pc.dim(s);

console.log(pc.bold(pc.cyan("━━━ Dotfiles Help ━━━")));
console.log();

console.log(h("Shell"));
console.log(cmd("ez", "Reload shell (exec zsh)"));
console.log(cmd("zsh-dotfiles-setup", "Bootstrap all tools (DOTFILES_SETUP=1)"));
console.log(cmd("zsh-load", "Reload with timing debug"));
console.log(cmd("ls", "ls -al"));
console.log();

console.log(h("Git"));
console.log(cmd("g", "lazygit"));
console.log(cmd("gc / gcm", "AI commit message (Claude + fuzzy selector)"));
console.log(cmd("gca", "git add . + AI commit"));
console.log(cmd("ga", "git add ."));
console.log(cmd("gp", "git push"));
console.log(cmd("gs", "git status"));
console.log(cmd("gmain", "Switch to main/master + pull"));
console.log(cmd("dif <a> <b>", "Diff two files with syntax highlighting (delta)"));
console.log();

console.log(h("GitHub CLI"));
console.log(cmd("gw", "Open repo in browser"));
console.log(cmd("gpr / pr-list", "List PRs"));
console.log(cmd("pr", "Push + open PR creation"));
console.log(cmd("gco <n>", "Stash, switch to main, checkout PR"));
console.log(cmd("gi", "Create issue (web)"));
console.log(cmd("gib", "Browse issues + checkout branch (fzf)"));
console.log(cmd("ghci", "Last CI run"));
console.log();

console.log(h("Tmux Aliases"));
console.log(cmd("ts", "Attach/create session (named after dir)"));
console.log(cmd("tsn", "Always create new session"));
console.log(cmd("tss", "Switch session (fzf)"));
console.log(cmd("ta [name]", "Attach to session (fzf if no args)"));
console.log(cmd("tk [name]", "Kill session (current if no args)"));
console.log(cmd("tka", "Kill all sessions"));
console.log(cmd("tl / tw / tp", "List sessions / windows / panes"));
console.log(cmd("tmux-help", "Full tmux keybinding reference"));
console.log();

console.log(h("Tmux Keybindings") + dim("  (prefix = Ctrl+a)"));
console.log(cmd("prefix |  or  \\", "Split vertical"));
console.log(cmd("prefix -  or  _", "Split horizontal"));
console.log(cmd("prefix h/j/k/l", "Navigate panes (vim-style)"));
console.log(cmd("prefix c", "New window"));
console.log(cmd("prefix n / p", "Next / previous window"));
console.log(cmd("prefix 1-9", "Go to window by number"));
console.log(cmd("prefix d", "Detach"));
console.log(cmd("prefix s", "List sessions"));
console.log(cmd("prefix z", "Toggle pane zoom"));
console.log(cmd("prefix I", "Install TPM plugins"));
console.log(cmd("prefix U", "Update TPM plugins"));
console.log();

console.log(h("Navigation"));
console.log(cmd("z <query>", "Smart cd (zoxide, learns from usage)"));
console.log(cmd("zi", "Interactive directory picker (fzf)"));
console.log(cmd("i p/w/f", "Quick cd to ~/code/{personal,work,fork}"));
console.log(cmd("ii", "Interactive project picker (fzf)"));
console.log(cmd("fh", "Fuzzy search home dir, open in $EDITOR"));
console.log();

console.log(h("Fzf Keybindings"));
console.log(cmd("Ctrl+T", "Paste file/dir path"));
console.log(cmd("Ctrl+R", "Search command history"));
console.log(cmd("Alt+C", "cd into directory"));
console.log();

console.log(h("Claude Code"));
console.log(cmd("c", "claude --dangerously-skip-permissions"));
console.log(cmd("cr", "claude --resume (skip permissions)"));
console.log();

console.log(h("Other"));
console.log(cmd("code", "VS Code Insiders"));
console.log(cmd("bat", "Syntax-highlighted cat (cat stays plain)"));
console.log(cmd("nerd-fonts-setup", "Reinstall Nerd Fonts"));
console.log(cmd("starship-setup", "Regenerate starship prompt config"));
console.log(cmd("gh-alias-setup", "Reset gh CLI aliases"));
console.log();

console.log(dim("Lazygit: press 'c' to AI commit staged files"));
