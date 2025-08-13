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


# https://github.com/upstash/context7


## Setup OS level dictation 

This turned out way more complicated than i thought it would be.


- https://github.com/arunk140/gnome-command-menu
- https://www.youtube.com/watch?v=Cw1SESc8sdA
- leading to https://github.com/ggml-org/whisper.cpp
- after lots of research, I found that the best way to get dictation working on Linux is to use the `whisper.cpp` project, which provides a command line interface for Whisper models.
- in the PopOS store, the last placed i looked, i found, https://github.com/chidiwilliams/buzz
- finally back to just using the `nerd-dictation` project. Then 


```bash 


git clone https://github.com/ideasman42/nerd-dictation.git
cd nerd-dictation
# change to PR https://github.com/ideasman42/nerd-dictation/pull/147 to get the hotkey logic
gco 147

## Since we are not on mobile, using the bigger en-us model 
rm -rf ./model
rm -rf ~/.config/nerd-dictation/model
https://alphacephei.com/vosk/models/vosk-model-en-us-0.42-gigaspeech.zip
model_name="vosk-model-en-us-0.42-gigaspeech" # using the best model i can run locally. 
curl -O https://alphacephei.com/vosk/models/$model_name.zip
unzip $model_name.zip
mv $model_name model

## setup python virtual environment
uv venv --python 3.12 --native-tls
source .venv/bin/activate

# isntall single dependencies
uv pip install vosk pynput

## move model so we don't have to specify it every time
mkdir -p ~/.config/nerd-dictation
mv ./model ~/.config/nerd-dictation
```



## Additonal MCP Servers



https://docs.anthropic.com/en/docs/claude-code/mcp


Setup Brave Search, GitHub, and Postgres servers using the Model Context Protocol (MCP) with `claude`.


### Add MCP Servers

# https://github.com/modelcontextprotocol/servers/tree/main?tab=readme-ov-file

```bash
FILESYSTEM_PATH="$(pwd)"
echo ${FILESYSTEM_PATH}
claude mcp add -s project filesystem -- npx -y @modelcontextprotocol/server-filesystem "${FILESYSTEM_PATH}"
claude mcp remove  -s project filesystem
```


### GitHub MCP Server

https://github.com/github/github-mcp-server/blob/main/docs/installation-guides/install-claude.md


With the GitHub MCP server the access token is required to access the GitHub API. 

[Install Guide](https://github.com/github/github-mcp-server/blob/main/docs/installation-guides/install-claude.md#installation-1)


```bash
claude mcp add -s user github -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server
YOUR_GITHUB_PERSONAL_ACCESS_TOKEN=your_token_here

# now update its environment variable
claude mcp update -s user  github -e GITHUB_PERSONAL_ACCESS_TOKEN=$YOUR_GITHUB_PERSONAL_ACCESS_TOKEN

claude mcp remove -s user github

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

export CLAUDE_FILESYSTEM_PATH="${pwd}

# installable js/ts servers
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


