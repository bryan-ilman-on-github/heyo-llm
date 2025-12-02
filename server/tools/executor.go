package tools

import (
	"encoding/json"
	"fmt"
)

// ToolCall represents a tool invocation from the LLM
type ToolCall struct {
	ID       string                 `json:"id"`
	Name     string                 `json:"name"`
	Arguments map[string]interface{} `json:"arguments"`
}

// ToolResult represents the result of a tool execution
type ToolResult struct {
	ToolCallID string `json:"tool_call_id"`
	Content    string `json:"content"`
	Error      string `json:"error,omitempty"`
}

// Executor handles tool execution
type Executor struct {
	registry *Registry
}

// NewExecutor creates a new tool executor
func NewExecutor(registry *Registry) *Executor {
	return &Executor{registry: registry}
}

// Execute runs a tool and returns the result
func (e *Executor) Execute(call ToolCall) ToolResult {
	tool, ok := e.registry.Get(call.Name)
	if !ok {
		return ToolResult{
			ToolCallID: call.ID,
			Error:      fmt.Sprintf("unknown tool: %s", call.Name),
		}
	}

	result, err := tool.Execute(call.Arguments)
	if err != nil {
		return ToolResult{
			ToolCallID: call.ID,
			Error:      err.Error(),
		}
	}

	return ToolResult{
		ToolCallID: call.ID,
		Content:    result,
	}
}

// ExecuteAll runs multiple tool calls and returns all results
func (e *Executor) ExecuteAll(calls []ToolCall) []ToolResult {
	results := make([]ToolResult, len(calls))
	for i, call := range calls {
		results[i] = e.Execute(call)
	}
	return results
}

// ParseToolCalls extracts tool calls from an Ollama response message
func ParseToolCalls(message map[string]interface{}) ([]ToolCall, error) {
	toolCallsRaw, ok := message["tool_calls"]
	if !ok {
		return nil, nil
	}

	toolCallsList, ok := toolCallsRaw.([]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid tool_calls format")
	}

	calls := make([]ToolCall, 0, len(toolCallsList))
	for i, tc := range toolCallsList {
		tcMap, ok := tc.(map[string]interface{})
		if !ok {
			continue
		}

		call := ToolCall{
			ID: fmt.Sprintf("call_%d", i),
		}

		if fn, ok := tcMap["function"].(map[string]interface{}); ok {
			if name, ok := fn["name"].(string); ok {
				call.Name = name
			}
			if args, ok := fn["arguments"].(map[string]interface{}); ok {
				call.Arguments = args
			} else if argsStr, ok := fn["arguments"].(string); ok {
				// Sometimes arguments come as a JSON string
				json.Unmarshal([]byte(argsStr), &call.Arguments)
			}
		}

		if call.Name != "" {
			calls = append(calls, call)
		}
	}

	return calls, nil
}
