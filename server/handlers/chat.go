package handlers

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"

	"heyo/tools"
)

const maxToolIterations = 10

// ChatHandler handles chat requests with tool support
type ChatHandler struct {
	ollamaURL string
	registry  *tools.Registry
	executor  *tools.Executor
}

// NewChatHandler creates a new chat handler
func NewChatHandler(ollamaURL string, registry *tools.Registry) *ChatHandler {
	return &ChatHandler{
		ollamaURL: ollamaURL,
		registry:  registry,
		executor:  tools.NewExecutor(registry),
	}
}

// ChatRequest is the incoming request format
type ChatRequest struct {
	Model    string                   `json:"model"`
	Messages []map[string]interface{} `json:"messages"`
	Stream   bool                     `json:"stream"`
}

// ServeHTTP handles the chat endpoint
func (h *ChatHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		setCORS(w)
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req ChatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Add system message with tool instructions if not present
	req.Messages = h.ensureSystemMessage(req.Messages)

	setCORS(w)
	w.Header().Set("Content-Type", "application/x-ndjson")
	w.Header().Set("Transfer-Encoding", "chunked")

	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "Streaming not supported", http.StatusInternalServerError)
		return
	}

	// Agent loop
	for iteration := 0; iteration < maxToolIterations; iteration++ {
		// Call Ollama with tools
		response, err := h.callOllama(req, w, flusher)
		if err != nil {
			h.sendError(w, flusher, err.Error())
			return
		}

		// Check for tool calls
		if response.Message != nil {
			toolCalls, _ := tools.ParseToolCalls(response.Message)
			if len(toolCalls) > 0 {
				// Send tool call info to client
				for _, tc := range toolCalls {
					h.sendEvent(w, flusher, map[string]interface{}{
						"type": "tool_call",
						"id":   tc.ID,
						"name": tc.Name,
						"args": tc.Arguments,
					})
				}

				// Execute tools
				results := h.executor.ExecuteAll(toolCalls)

				// Send tool results to client
				for _, result := range results {
					h.sendEvent(w, flusher, map[string]interface{}{
						"type":    "tool_result",
						"id":      result.ToolCallID,
						"content": result.Content,
						"error":   result.Error,
					})
				}

				// Add assistant message with tool calls to history
				req.Messages = append(req.Messages, response.Message)

				// Add tool results to history
				for _, result := range results {
					content := result.Content
					if result.Error != "" {
						content = "Error: " + result.Error
					}
					req.Messages = append(req.Messages, map[string]interface{}{
						"role":         "tool",
						"tool_call_id": result.ToolCallID,
						"content":      content,
					})
				}

				// Continue the loop - let LLM respond to tool results
				continue
			}
		}

		// No tool calls, we're done
		break
	}

	// Send done event
	h.sendEvent(w, flusher, map[string]interface{}{"type": "done"})
}

// OllamaResponse represents a parsed Ollama response
type OllamaResponse struct {
	Message map[string]interface{} `json:"message"`
	Done    bool                   `json:"done"`
}

// callOllama calls Ollama and streams the response
func (h *ChatHandler) callOllama(req ChatRequest, w http.ResponseWriter, flusher http.Flusher) (*OllamaResponse, error) {
	// Build Ollama request with tools
	ollamaReq := map[string]interface{}{
		"model":    req.Model,
		"messages": req.Messages,
		"stream":   true,
		"tools":    h.registry.ToOllamaFormat(),
	}

	body, err := json.Marshal(ollamaReq)
	if err != nil {
		return nil, err
	}

	resp, err := http.Post(h.ollamaURL+"/api/chat", "application/json", bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("ollama unavailable: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("ollama error: %s", string(bodyBytes))
	}

	// Stream response and collect final message
	var finalResponse OllamaResponse
	scanner := bufio.NewScanner(resp.Body)
	// Increase buffer size for large responses
	buf := make([]byte, 0, 64*1024)
	scanner.Buffer(buf, 1024*1024)

	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			continue
		}

		var chunk map[string]interface{}
		if err := json.Unmarshal([]byte(line), &chunk); err != nil {
			continue
		}

		// Stream content to client
		if msg, ok := chunk["message"].(map[string]interface{}); ok {
			if content, ok := msg["content"].(string); ok && content != "" {
				h.sendEvent(w, flusher, map[string]interface{}{
					"type":  "content",
					"delta": content,
				})
			}

			// Keep track of tool_calls - don't overwrite if we already have them
			if _, hasToolCalls := msg["tool_calls"]; hasToolCalls {
				finalResponse.Message = msg
			} else if finalResponse.Message == nil {
				// Only set message if we don't have one yet (preserve tool_calls)
				finalResponse.Message = msg
			}
		}

		if done, ok := chunk["done"].(bool); ok && done {
			finalResponse.Done = true
		}
	}

	return &finalResponse, nil
}

// ensureSystemMessage adds a system message if not present
func (h *ChatHandler) ensureSystemMessage(messages []map[string]interface{}) []map[string]interface{} {
	for _, msg := range messages {
		if role, ok := msg["role"].(string); ok && role == "system" {
			return messages
		}
	}

	systemMsg := map[string]interface{}{
		"role": "system",
		"content": `You are Heyo, a helpful AI assistant. You have access to tools that you MUST use when appropriate:

1. **calculate**: Use this for ANY mathematical calculation. NEVER calculate math yourself - always use this tool.
2. **python**: Use this to execute Python code for complex tasks or computations.

IMPORTANT: When you receive a tool result, you MUST use the EXACT value returned. Do NOT round, approximate, or modify the result. Simply report the exact number from the tool.

Example:
- Tool returns: 13.74772708486752
- You say: "The square root of 189 is 13.74772708486752"
- Do NOT say: "approximately 13.75" or round the number`,
	}

	return append([]map[string]interface{}{systemMsg}, messages...)
}

// sendEvent sends a JSON event to the client
func (h *ChatHandler) sendEvent(w http.ResponseWriter, flusher http.Flusher, event map[string]interface{}) {
	data, _ := json.Marshal(event)
	w.Write(data)
	w.Write([]byte("\n"))
	flusher.Flush()
}

// sendError sends an error event to the client
func (h *ChatHandler) sendError(w http.ResponseWriter, flusher http.Flusher, message string) {
	h.sendEvent(w, flusher, map[string]interface{}{
		"type":  "error",
		"error": message,
	})
}

func setCORS(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

// Legacy handler for simple proxy mode (no tools)
func ProxyToOllama(ollamaURL string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodOptions {
			setCORS(w)
			w.WriteHeader(http.StatusOK)
			return
		}

		path := strings.TrimPrefix(r.URL.Path, "/api")
		req, err := http.NewRequest(r.Method, ollamaURL+"/api"+path, r.Body)
		if err != nil {
			http.Error(w, "Failed to create request", http.StatusInternalServerError)
			return
		}
		req.Header.Set("Content-Type", "application/json")

		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			http.Error(w, "Ollama unavailable", http.StatusBadGateway)
			return
		}
		defer resp.Body.Close()

		setCORS(w)
		w.Header().Set("Content-Type", resp.Header.Get("Content-Type"))
		w.WriteHeader(resp.StatusCode)

		if flusher, ok := w.(http.Flusher); ok {
			buf := make([]byte, 256)
			for {
				n, err := resp.Body.Read(buf)
				if n > 0 {
					w.Write(buf[:n])
					flusher.Flush()
				}
				if err != nil {
					break
				}
			}
		} else {
			io.Copy(w, resp.Body)
		}
	}
}
