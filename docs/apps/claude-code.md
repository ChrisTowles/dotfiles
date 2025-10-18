# Claude Code


Run claude in the root of this repository to get started.

then `/doctor` command, if it says to run `migrate-installer` do it. 

```bash
code ~/.claude/settings.json
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


After seeing how many tokens, [github mcp](https://github.com/github/github-mcp-server) was taking. I've pretty much removed every MCP server except playwritht only because it can give claude access see to local web pages.

### Github

Just use the `gh` commands.


### Playwright


```bash
claude mcp add -s user playwright npx '@playwright/mcp@latest'
```




## Python Project



```bash
uv sync
source .venv/bin/activate

export CLAUDE_FILESYSTEM_PATH="${pwd}"


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


