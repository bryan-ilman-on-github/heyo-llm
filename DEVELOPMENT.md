# Heyo Development Guide

## Project Overview
Heyo is a Claude/ChatGPT-like AI chat app with tool calling capabilities.

- **Flutter app**: `app/` - Mobile/desktop client
- **Go server**: `server/` - Proxy to Ollama with tool orchestration

## Architecture

### Server (Go + Python tools)
```
server/
├── main.go                 # Entry point, routes
├── handlers/chat.go        # Agent loop with tool orchestration
├── tools/
│   ├── registry.go         # Tool registration
│   ├── executor.go         # Tool execution
│   └── builtin.go          # Calculator & Python tools
```

### Flutter App (Feature-First)
```
app/lib/
├── main.dart
├── core/
│   ├── config/api_config.dart      # Server URL, model config
│   ├── errors/app_exception.dart
│   └── network/stream_parser.dart  # NDJSON parsing
├── features/chat/
│   ├── data/chat_api.dart          # HTTP streaming
│   ├── domain/
│   │   ├── chat_service.dart       # Business logic
│   │   └── models/
│   │       ├── message.dart
│   │       └── tool_call.dart
│   └── presentation/
│       ├── screens/chat_screen.dart
│       └── widgets/
│           ├── message_bubble.dart
│           ├── chat_input.dart
│           ├── empty_chat.dart
│           └── tool_result_card.dart
└── shared/theme/heyo_theme.dart
```

## Current Status

### Completed (Phase 1)
- [x] Server tool system (Go)
- [x] Calculator tool (safe math eval via Python)
- [x] Code interpreter tool (Python execution)
- [x] Flutter feature-first restructure
- [x] Enhanced message model with tool calls
- [x] Streaming parser for tool events
- [x] Tool result UI cards

### TODO (Phase 2+)
- [ ] Python executor service (sandboxed)
- [ ] Web search tool
- [ ] Image generation tool
- [ ] RAG pipeline
- [ ] Speech (STT/TTS)
- [ ] Database queries
- [ ] Task planning agent
- [ ] Multi-model support
- [ ] Conversation persistence

## How to Run

### 1. Start Ollama
```bash
ollama serve
```

### 2. Start Go server
```bash
cd server
go run .
```

### 3. Start Cloudflare tunnel (for mobile testing)
```bash
cloudflared tunnel --url http://localhost:8080
```

### 4. Update tunnel URL in app
Edit `app/lib/core/config/api_config.dart`

### 5. Run Flutter app
```bash
cd app
flutter run
```

## Tool Calling Flow

1. User sends message
2. Server adds system prompt with tool definitions
3. Server calls Ollama with `tools` parameter
4. If LLM returns `tool_calls`:
   - Server executes tools (Python)
   - Results sent back to LLM
   - Loop continues until LLM gives final response
5. Streaming events sent to Flutter:
   - `content`: Text chunks
   - `tool_call`: Tool invocation
   - `tool_result`: Tool output
   - `done`: Stream complete

## Models with Tool Support
- `llama3.1` (recommended)
- `llama3.1:70b`
- `mistral`
- `qwen2.5`
- `command-r`

**Note**: `phi3:mini` does NOT support tools

## Key Files to Know

| Purpose | File |
|---------|------|
| Server entry | `server/main.go` |
| Tool orchestration | `server/handlers/chat.go` |
| Tool definitions | `server/tools/builtin.go` |
| API config | `app/lib/core/config/api_config.dart` |
| Chat logic | `app/lib/features/chat/domain/chat_service.dart` |
| Stream parsing | `app/lib/core/network/stream_parser.dart` |
| Tool UI | `app/lib/features/chat/presentation/widgets/tool_result_card.dart` |

## Continuing Development

In a new Claude Code session, say:
> "Read DEVELOPMENT.md and continue building Heyo. Next: [your task]"

Or reference the full plan:
> "Read .claude/plans/fancy-riding-sunset.md and implement Phase 2"
