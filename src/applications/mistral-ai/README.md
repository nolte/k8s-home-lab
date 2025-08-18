

```
docker run --runtime nvidia --gpus all \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=<secret>" \
    -p 8000:8000 \
    --ipc=host \
    vllm/vllm-openai:latest \
    --model mistralai/Mistral-7B-v0.1


docker run \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=" \
    -p 8000:8000 \
    --ipc=host \
    vllm/vllm-openai:latest \
    --model mistralai/Mistral-7B-v0.1 --device cpu
```


docker run --rm -it \
  -v ~/models/mistral:/models \
  -p 8000:8000 \
  ghcr.io/ggerganov/llama.cpp:full \
  ./server -m /models/mistral-7b-instruct-v0.1.Q4_K_M.gguf --host 0.0.0.0 --port 8000