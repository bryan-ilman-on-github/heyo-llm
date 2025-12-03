# Heyo Server

Backend server for Heyo AI chat app with tool execution support.

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Flutter   │────▶│  Go Server  │────▶│   Ollama    │
│     App     │     │  (port 8080)│     │ (port 11434)│
└─────────────┘     └──────┬──────┘     └─────────────┘
                          │
                          ▼
                   ┌─────────────┐
                   │   Python    │
                   │  Executor   │
                   │ (port 8002) │
                   └─────────────┘
```

## Components

| Component | Port | Description |
|-----------|------|-------------|
| Go Server | 8080 | Main API, chat orchestration, tool routing |
| Python Executor | 8002 | Sandboxed tool execution (calculator, code interpreter) |
| Ollama | 11434 | LLM inference |

## Quick Start

### 1. Start Ollama
```bash
ollama serve
# or with Intel Arc GPU:
conda activate llm-cpp && set OLLAMA_NUM_GPU=999 && ollama serve
```

### 2. Start Python Executor
```bash
cd python
python executor.py
```

### 3. Start Go Server
```bash
go build -o heyo-server.exe .
./heyo-server.exe
```

### 4. (Optional) Cloudflare Tunnel
```bash
cloudflared tunnel --url http://localhost:8080
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/api/chat` | POST | Chat with tool support (streaming NDJSON) |
| `/api/tools` | GET | List available tools |
| `/api/generate` | POST | Direct proxy to Ollama |

## Tools

### Calculator (`calculate`)
Safe mathematical expression evaluator using AST parsing.

```json
{"tool": "calculate", "args": {"expression": "sqrt(189)"}}
// Returns: "13.7477270848675"
```

Supported: `+`, `-`, `*`, `/`, `**`, `sqrt`, `sin`, `cos`, `tan`, `log`, `log10`, `abs`, `round`, `pi`, `e`, etc.

### Python Code Interpreter (`python`)
Sandboxed Python execution with timeout protection.

```json
{"tool": "python", "args": {"code": "for i in range(5): print(i)"}}
// Returns: "0\n1\n2\n3\n4"
```

Available libraries: `math`, `json`, `re`, `datetime`, `collections`, `itertools`, `functools`, `random`, `statistics`, `decimal`, `fractions`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Go server port |
| `OLLAMA_URL` | `http://localhost:11434` | Ollama API URL |
| `PYTHON_EXECUTOR_URL` | `http://localhost:8002` | Python executor URL |

## Directory Structure

```
server/
├── main.go              # Entry point, routing
├── handlers/
│   └── chat.go          # Chat handler with agent loop
├── tools/
│   ├── registry.go      # Tool registration
│   ├── executor.go      # Tool execution
│   ├── parser.go        # Tool call parsing
│   └── builtin.go       # Built-in tool definitions
└── python/
    ├── executor.py      # HTTP server for tool execution
    └── tools/
        ├── base.py      # Base tool class
        ├── calculator.py # Math expression evaluator
        └── code_exec.py  # Python code interpreter
```

## Intel Arc GPU Acceleration

For faster inference with Intel Arc GPU:

```bash
# One-time setup
conda create -n llm-cpp python=3.11 libuv
conda activate llm-cpp
pip install --pre --upgrade ipex-llm[cpp] --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/
init-ollama.bat

# Each time
conda activate llm-cpp
set OLLAMA_NUM_GPU=999
set SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
ollama serve
```

## Recommended Models

| Model | Size | Best For |
|-------|------|----------|
| `qwen2.5-coder:7b` | 4.7GB | Code generation |
| `llama3.1:8b` | 4.7GB | General chat |
| `deepseek-coder-v2:16b` | 9GB | Complex coding |
