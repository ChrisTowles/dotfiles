# Open WebUi


https://github.com/open-webui/open-webui


Running with GPU and Ollama support

```bash
docker run -d -p 3000:8080 --gpus=all -v ollama:/
root/.ollama -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama

```

```bash


docker run -d -p 3000:8080 -e WEBUI_AUTH=False -e OLLAMA_BASE_URL=http://host.docker.internal:11434 -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:main
```

