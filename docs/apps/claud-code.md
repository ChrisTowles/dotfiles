# Claude Code Settings for `claude`


Nevermind, just follow this!!! https://claudelog.com/installation

## Additonal MCP Servers


https://docs.anthropic.com/en/docs/claude-code/mcp


Setup Brave Search, GitHub, and Postgres servers using the Model Context Protocol (MCP) with `claude`.






## Typescript Project

```bash

```bash

ni

export CLAUDE_FILESYSTEM_PATH="${pwd}

# installable js/ts servers
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem "$CLAUDE_FILESYSTEM_PATH"

claude --dangerously-skip-permissions


```





## Python Project



```bash
uv sync
source .venv/bin/activate

export CLAUDE_FILESYSTEM_PATH="${pwd}

# installable js/ts servers
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem "${pwd}"
#claude mcp add brave-search -e BRAVE_API_KEY=$BRAVE_API_KEY -- npx -y @modelcontextprotocol/server-brave-search
#claude mcp add e2b -e E2B_API_KEY=$E2B_API_KEY -- npx -y @e2b/mcp-server 

# installable python servers
claude mcp add fetch uvx mcp-server-fetch

claude --dangerously-skip-permissions


```


