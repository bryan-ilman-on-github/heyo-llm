# Phi-3 Mini Local Chat

Run Phi-3 Mini locally via Ollama.

## Quick Start (CPU)

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

For Intel Arc GPU support, use IPEX-LLM:

1. Install [Miniforge](https://github.com/conda-forge/miniforge/releases)
2. Open Miniforge Prompt as Administrator:
   ```
   conda create -n llm-cpp python=3.11 libuv
   conda activate llm-cpp
   pip install --pre --upgrade ipex-llm[cpp] --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/
   init-ollama.bat
   ```
3. Start Ollama with GPU:
   ```
   set OLLAMA_NUM_GPU=999
   set SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
   ollama serve
   ```

## Files

- `phi3_chat.py` - Chat interface (streaming)
- `requirements.txt` - Python dependencies
