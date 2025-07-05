# Claude Code Settings for `claude`

- install `claude` CLI tool

```bash
curl -sSL https://claude.ai/install.sh | sh
``` 

Start `claude` and login.

```bash
claude login
```


Then ask it for examples of claude's settings file.

using that i created. 

`code $HOME/.claude/settings.json`


#
```json
{
    "maxTokens": 4000,
    "temperature": 0.3,
    "allowedTools": ["bash", "read", "write", "edit", "glob", "grep", "task"],
    "bashAllowList": ["git", "npm", "pnpm", "yarn", "node", "python", "pip", "cargo", "rustc", "go", "docker"],
    "autoApprove": ["git status", "git diff", "git log", "npm test", "pnpm test", "cargo test"],
    "workingDirectory": "~/code/p",
    "requireConfirmation": false,
    "maxFileSize": 1000000
}
```