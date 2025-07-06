# Claude Code Settings for `claude`


Come good info can come from this!!! https://claudelog.com/installation


Run claude in the root of this repository to get started.

then `/doctor` command, if it says to run `migrate-installer` do it. 



```bash
code ~/.claude/settings.json
```
contents

```json

{
    "includeCoAuthoredBy": false,

    "permissions": {
        "allow": ["bash(*)", "read(*)", "write(*)", "edit(*)", "glob(*)", "grep(*)", "task(*)", "websearch(*)"]
    }
}
```
## 

Setup OS level dictation 

- https://github.com/arunk140/gnome-command-menu
- https://www.youtube.com/watch?v=Cw1SESc8sdA
- leading to https://github.com/ggml-org/whisper.cpp
- after lots of research, I found that the best way to get dictation working on Linux is to use the `whisper.cpp` project, which provides a command line interface for Whisper models.
- in the PopOS store, the last placed i looked, i found, https://github.com/chidiwilliams/buzz



```bash 


git clone https://github.com/ideasman42/nerd-dictation.git
cd nerd-dictation
wget https://alphacephei.com/kaldi/models/vosk-model-small-en-us-0.15.zip
unzip vosk-model-small-en-us-0.15.zip
mv vosk-model-small-en-us-0.15 model

## setup python virtual environment
uv venv --python 3.11
source source .venv/bin/activate

# isntall single dependencies
uv pip install vosk 

## move model so we don't have to specify it every time
mkdir -p ~/.config/nerd-dictation
mv ./model ~/.config/nerd-dictation
```

# Start the dictation service

```bash
cd $HOME/code/f/nerd-dictation && source .venv/bin/activate && ./nerd-dictation begin &
```

stop it

```bash
cd $HOME/code/f/nerd-dictation && source .venv/bin/activate && ./nerd-dictation end
```


### Setup Keybindings
- On PopOS, open Settings > Keyboard Shortcuts
    https://support.system76.com/articles/keyboard-shortcuts/

 hello talking one two three
```

## Additonal MCP Servers

https://docs.anthropic.com/en/docs/claude-code/mcp


Setup Brave Search, GitHub, and Postgres servers using the Model Context Protocol (MCP) with `claude`.


### Add MCP Servers
```bash
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem "${pwd}"
claude mcp add github-server --transport sse https://api.github.com/mcp

```


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


