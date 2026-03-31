# Ollama

Local LLM inference server using [Ollama](https://ollama.ai/).

## Helm Chart

- **Chart:** [otwld/ollama-helm](https://github.com/otwld/ollama-helm)
- **Repository:** `https://otwld.github.io/ollama-helm/`

## Configuration

- Pre-pulls the `llama3.2` model on startup
- Persistent storage (50Gi) for downloaded models
- No GPU acceleration configured by default

## Access

```bash
kubectl port-forward svc/ollama 11434:11434 -n ollama
```

API available at `http://localhost:11434`.
