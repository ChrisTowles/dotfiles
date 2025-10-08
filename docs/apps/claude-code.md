# Claude Code Settings for `claude`


Come good info can come from this!!! https://claudelog.com/installation


Run claude in the root of this repository to get started.

then `/doctor` command, if it says to run `migrate-installer` do it. 

```bash
code ~/.claude/settings.json
```

contents something like this, note that.

```json

{
    "includeCoAuthoredBy": false,

    "permissions": {
        "allow": ["bash(*)", "read(*)", "write(*)", "edit(*)", "glob(*)", "grep(*)", "task(*)", "websearch(*)"]
    },
   "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0",
  }
}
```
If using bedrock

```json
{
    "includeCoAuthoredBy": false,
    "env": {
        "CLAUDE_CODE_ENABLE_TELEMETRY": "0",
        "CLAUDE_CODE_USE_BEDROCK": "1",
        "AWS_PROFILE": "PROFILE_NAME",
    },
}
```



Issues update 
https://github.com/anthropics/claude-code/issues/40

```bash
export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/ca-certificates.crt"


# Enable Bedrock integration
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1  # or your preferred region

# Optional: Override the region for the small/fast model (Haiku)
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2
```
## Hook to play music when done

Audio hook for Claude code

```jsonc
{
// Add hook to play music when its ready for more input
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/code/p/dotfiles/config/claude/notify.sh"
          }
        ]
      }
    ]
  }

}
```

## Add Status Line

Add status line to include the model and branch, etc.

```json
{

  "statusLine": {
    "type": "command",
    "command": "$HOME/code/p/dotfiles/config/claude/status-line.sh"
  },
}

```

## Additional MCP Servers

https://docs.anthropic.com/en/docs/claude-code/mcp


Setup Brave Search, GitHub, and Postgres servers using the Model Context Protocol (MCP) with `claude`.

### Github

Just use the `gh` commands.


### Playwright


```bash
claude mcp add playwright npx '@playwright/mcp@latest'
```



### Context7 MCP Server

- https://github.com/upstash/context7 as a great MCP server for various APIs, including Postgres, 
Keith called this one out for me and now i've seen it everywhere!  Redis, and more.

```bash
claude mcp add -s user context7 -- npx -y @upstash/context7-mcp
claude mcp remove -s user context7
```

### Brave Search MCP Server

```bash
claude mcp add -s user brave-search -- npx -y @modelcontextprotocol/server-brave-search -e BRAVE_API_KEY=$BRAVE_API_KEY
claude mcp remove -s user brave-search
```

### Server Sequential Thinking MCP Server

```bash
claude mcp add -s user server-sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking 
claude mcp remove -s user server-sequential-thinking
```


```bash

## remove MCP Servers

```bash
claude mcp remove filesystem
claude mcp remove github-server
```


## Typescript Projects with MCP Servers


```bash

ni

export CLAUDE_FILESYSTEM_PATH="${pwd}"
# mcp servers
#claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem "$CLAUDE_FILESYSTEM_PATH"
# Add an SSE or HTTP server that requires OAuth
#claude mcp add --transport sse github-server https://api.github.com/mcp

```





## Python Project



```bash
uv sync
source .venv/bin/activate

export CLAUDE_FILESYSTEM_PATH="${pwd}"


```

installable js/ts servers

```bash

claude mcp add --transport sse github-server https://api.github.com/mcp

claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem "${pwd}"
#claude mcp add brave-search -e BRAVE_API_KEY=$BRAVE_API_KEY -- npx -y @modelcontextprotocol/server-brave-search
#claude mcp add e2b -e E2B_API_KEY=$E2B_API_KEY -- npx -y @e2b/mcp-server 

# installable python servers
claude mcp add fetch uvx mcp-server-fetch

claude --dangerously-skip-permissions


```


## Boris Cherny Resources

- [Boris Cherny's LinkedIn Profile](https://www.linkedin.com/in/bcherny/)
  - give his profile a follow, he is the author of the O'Reilly book "Programming TypeScript" and making your Typescript scale.
- [Boris Cherny's GitHub Profile](https://github.com/bcherny)
    - check out his projects, especially the `ts-mcp` project which is a TypeScript implementation of the Model Context Protocol (MCP).
- [Boris Cherny's Website](https://borischerny.com/)
    - doesn't updated it much lately, but has some good resources.
- [Frontend Interview Questions](https://borischerny.com/javascript/%22functional/programming%22/2017/06/09/Frontend-Interview-Questions.html)
    - [Frontend Interview Questions - Answers](https://github.com/bcherny/frontend-interview-questions)
    - Comprehensive collection of frontend interview questions and answers
- 


