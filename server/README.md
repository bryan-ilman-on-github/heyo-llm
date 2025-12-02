# Phi-3 Mini Local Chat

Run Phi-3 Mini locally via Ollama with Intel Arc GPU acceleration.

## Quick Start (CPU-only)

1. Install [Ollama](https://ollama.com/download)
2. Pull the model:
   ```
   ollama pull phi3:mini
   ```
3. Run:
   ```
   python phi3_chat.py
   ```

## GPU Acceleration (Intel Arc)

For Intel Arc GPU support (~26 tok/s vs ~14 tok/s on CPU):

### Setup (one-time)

1. Install [Miniforge](https://github.com/conda-forge/miniforge/releases) - download `Miniforge3-Windows-x86_64.exe`
2. Open **Miniforge Prompt as Administrator**:
   ```
   conda create -n llm-cpp python=3.11 libuv
   conda activate llm-cpp
   pip install --pre --upgrade ipex-llm[cpp] --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/
   init-ollama.bat
   ```

### Running (each time)

Open a **fresh** Miniforge Prompt as Administrator:
```
conda activate llm-cpp
set OLLAMA_NUM_GPU=999
set SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
set ZES_ENABLE_SYSMAN=1
ollama serve
```

Then use `phi3_chat.py` or the Ollama API at `http://localhost:11434`.

## Do's and Don'ts

### Do
- Always open a **fresh** Miniforge Prompt window before starting
- Run Miniforge Prompt **as Administrator**
- Wait for model warm-up on first query (~25s cold start, then fast)
- Use streaming for better UX on longer responses

### Don't
- Don't set `GGML_SYCL_DISABLE_OPT=0` - causes SYCL crashes
- Don't set `GGML_SYCL_DISABLE_GRAPH=0` - causes SYCL crashes
- Don't set `OLLAMA_INTEL_GPU=true` - not needed, may cause issues
- Don't run regular Ollama and IPEX-LLM Ollama at the same time (port conflict)

## Performance

Tested on Intel Arc 130V (integrated GPU, 8GB shared):

| Metric | Value |
|--------|-------|
| Warm speed | ~26 tok/s |
| Cold start | ~24s |
| Parallel requests | Yes (2 concurrent) |
| GPU memory | ~2.8 GB |

## Files

- `phi3_chat.py` - Chat interface (streaming)
- `main.go` - Go backend server (proxy to Ollama)
- `requirements.txt` - Python dependencies (for venv, not needed for Ollama)

## Go Backend + Cloudflare Tunnel

### Build & Run

```bash
# Build
go build -o server.exe main.go

# Run (Ollama must be running)
./server.exe
# or with custom port
PORT=3000 ./server.exe
```

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/api/generate` | POST | Proxy to Ollama generate (streaming) |
| `/api/chat` | POST | Proxy to Ollama chat (streaming) |

### Cloudflare Tunnel Setup

1. **Install cloudflared**
   ```bash
   # Windows (winget)
   winget install cloudflare.cloudflared

   # Or download from https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/
   ```

2. **Quick tunnel (no account needed, temporary URL)**
   ```bash
   cloudflared tunnel --url http://localhost:8080
   ```
   This gives you a temporary `https://xxx.trycloudflare.com` URL.

3. **Persistent tunnel (recommended, requires free Cloudflare account)**
   ```bash
   # Login (one-time)
   cloudflared tunnel login

   # Create tunnel
   cloudflared tunnel create phi3-api

   # Run tunnel
   cloudflared tunnel run --url http://localhost:8080 phi3-api
   ```

4. **Custom domain (optional)**

   Add a CNAME record in Cloudflare DNS pointing to your tunnel:
   ```
   api.yourdomain.com -> <tunnel-id>.cfargotunnel.com
   ```

### Running Everything

Terminal 1 (Ollama with GPU):
```bash
conda activate llm-cpp
set OLLAMA_NUM_GPU=999
ollama serve
```

Terminal 2 (Go backend):
```bash
./server.exe
```

Terminal 3 (Tunnel):
```bash
cloudflared tunnel --url http://localhost:8080
```

### Example Request

```bash
curl -X POST https://your-tunnel-url.trycloudflare.com/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "phi3:mini", "prompt": "Hello!", "stream": true}'
```
