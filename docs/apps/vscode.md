# VSCode





## Continue.dev - LLM autocomplete and chatgpt in vscode

https://marketplace.visualstudio.com/items?itemName=Continue.continue


###  setup ollama

https://github.com/ollama/ollama/tree/main


```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama run llama3:8b # for chat
ollama run deepseek-coder:6.7b # for code completion



code ~/.continue/config.json
```

Now setup in config file with the chat model and autocomplete model.

> [!NOTE]
>  you can't use comments in `~/.continue/config.json`.

```json
{ 
    
"models": [
    {
      "title": "Ollama llama3:8b",
      "provider": "ollama",
      "model": "llama3:8b"
    }
    // other models...
  ],

 "tabAutocompleteModel": {
    "title": "deepseek-coder-6.7b",
    "provider": "ollama",
    "model": "deepseek-coder:6.7b"
  },
  // other settings...
}
```
