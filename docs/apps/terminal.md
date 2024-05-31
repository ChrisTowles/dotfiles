# Terminl Tools


## shell-ask
still unsure about this. 
https://github.com/egoist/shell-ask

```
npm i -g shell-ask
code ~/.config/shell-ask/config.json
```




```json
{
    "default_model": "ollama-llama3:8b",
    "commands": [
        {
            "command": "cm",
            "description": "Generate git commit message based on git diff output",
            "prompt": "Generate git commit message following Conventional Commits specification based on the git diff output in stdin\nYou must return a commit message only, without any other text or quotes."
        }
    ]
}
```

test that it works:
```bash
git diff HEAD | ask cm

ifconfig | ask "give me this as markdown table with Interface and IP Address"

```

