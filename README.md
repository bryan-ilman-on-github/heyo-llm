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

For Intel Arc GPU support (~27 tok/s vs ~14 tok/s on CPU):

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
| Warm speed | ~27 tok/s |
| Cold start | ~25s |
| Parallel requests | Yes (2 concurrent) |
| GPU memory | ~2.8 GB |

## Files

- `phi3_chat.py` - Chat interface (streaming)
- `requirements.txt` - Python dependencies (for venv, not needed for Ollama)
