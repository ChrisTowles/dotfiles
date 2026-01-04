# Claude Code
some notes on claude-code setup and configuration

## Configuration

Edit your Claude Code settings:

```bash
code ~/.claude/settings.json
```

## Environment Setup

For SSL certificate issues, see [this GitHub issue](https://github.com/anthropics/claude-code/issues/40).

```bash
export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/ca-certificates.crt"
```

### AWS Bedrock Integration

To use Claude Code with AWS Bedrock:

```bash
# Enable Bedrock integration
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1  # or your preferred region

```

## Hooks

### Audio Notification Hook

Play audio when Claude is ready for more input:

```jsonc
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bun run \"$HOME/code/p/dotfiles/config/claude/notify.ts\""
          }
        ]
      }
    ]
  }
}
```


### Status Line Hook

Display model and git branch information in the status line:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bun run \"$HOME/code/p/dotfiles/config/claude/statusline.ts\""
  },
}
```

## MCP Servers

See [Claude Code MCP documentation](https://docs.anthropic.com/en/docs/claude-code/mcp) for details.

After being shocked at it token usage, the [GitHub MCP server](https://github.com/github/github-mcp-server) consumes significant tokens. I've removed most MCP servers except Playwright, which allows Claude to access local web pages.

### GitHub Integration

Use the built-in `gh` CLI commands instead of the GitHub MCP server.

### Playwright MCP Server

```bash
claude mcp add -s user playwright npx '@playwright/mcp@latest'
```

## Python Project Setup

For Python projects, set up the virtual environment:

```bash
uv sync
source .venv/bin/activate
export CLAUDE_FILESYSTEM_PATH="${pwd}"
```

## Dictation Setup

I tried a few things but currently just using the built-in VSCODE Speech feature. I have a doc on it here: [VSCode Dictation](./vscode.md)

## Braintrust Integration

Trace Claude Code conversations, tool calls, and sessions to Braintrust for observability.

See [Braintrust Claude Code documentation](https://www.braintrust.dev/docs/integrations/sdk-integrations/claude-code) for details.

### Setup

Run the Braintrust setup on site, after the curl installation of braintrust. it tell you to run something like.

```bash
bun run ~/code/p/dotfiles/config/claude/braintrust-setup.ts
```

This configures hooks in `.claude/settings.local.json`:
- **SessionStart** - Creates trace root when session begins
- **UserPromptSubmit** - Creates Turn container for each user message
- **PostToolUse** - Captures tool calls as children of Turn
- **Stop** - Creates LLM span and finalizes Turn
- **SessionEnd** - Finalizes trace when session ends

### Viewing Traces

View traces at: https://www.braintrust.dev/app/claude-code/logs

### Debugging

View hook logs:

```bash
tail -f ~/.claude/state/braintrust_hook.log
```

### Boris Cherny



- [LinkedIn Profile](https://www.linkedin.com/in/bcherny/)
- [GitHub Profile](https://github.com/bcherny) - Check out `ts-mcp`, a TypeScript implementation of the Model Context Protocol (MCP)
- [Personal Website](https://borischerny.com/) - Useful resources and articles
- [Frontend Interview Questions](https://borischerny.com/javascript/%22functional/programming%22/2017/06/09/Frontend-Interview-Questions.html)
  - [Answers Repository](https://github.com/bcherny/frontend-interview-questions) - Comprehensive collection of frontend interview questions and answers
