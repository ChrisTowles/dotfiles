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

## Since we are not on mobile, using the bigger en-us model 
wget https://alphacephei.com/kaldi/models/vosk-model-en-us-0.22.zip
unzip vosk-model-en-us-0.22.zip
mv vosk-model-en-us-0.22 model

## setup python virtual environment
uv venv --python 3.11
source .venv/bin/activate

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

Ok, with that i finally have a Speech that works in the claude code terminal app that i can still Speak to and it will type what i say.

I really looked for a better toggle key solution but even with the OS shortchots, it was not working well. So for now i'm using the command line to start and stop the service. 

best i found was key words to start and stop the service. 
means its always listening, but i can just say "dictation start" or "nerd dictation stop" to control it.

```bash
cp ./config/nerd-dictation.py ~/.config/nerd-dictation/nerd-dictation.py 
```

then using the 'dict-start' and 'dict-stop' commands to control it locateed in the `.zshrc` file.


### Setup Keybindings
- ~~On PopOS, open Settings > Keyboard Shortcuts~~ this method does not work well yet, maybe i'm doing something wrong.
    https://support.system76.com/articles/keyboard-shortcuts/






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


