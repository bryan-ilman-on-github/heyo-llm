package tools

import "sync"

// Tool represents a callable tool with its schema
type Tool struct {
	Name        string                 `json:"name"`
	Description string                 `json:"description"`
	Parameters  map[string]interface{} `json:"parameters"`
	Execute     func(args map[string]interface{}) (string, error) `json:"-"`
}

// OllamaTool is the format Ollama expects for tool definitions
type OllamaTool struct {
	Type     string `json:"type"`
	Function struct {
		Name        string                 `json:"name"`
		Description string                 `json:"description"`
		Parameters  map[string]interface{} `json:"parameters"`
	} `json:"function"`
}

// Registry manages available tools
type Registry struct {
	mu    sync.RWMutex
	tools map[string]*Tool
}

// NewRegistry creates a new tool registry
func NewRegistry() *Registry {
	return &Registry{
		tools: make(map[string]*Tool),
	}
}

// Register adds a tool to the registry
func (r *Registry) Register(tool *Tool) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.tools[tool.Name] = tool
}

// Get retrieves a tool by name
func (r *Registry) Get(name string) (*Tool, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	tool, ok := r.tools[name]
	return tool, ok
}

// GetAll returns all registered tools
func (r *Registry) GetAll() []*Tool {
	r.mu.RLock()
	defer r.mu.RUnlock()
	tools := make([]*Tool, 0, len(r.tools))
	for _, tool := range r.tools {
		tools = append(tools, tool)
	}
	return tools
}

// ToOllamaFormat converts all tools to Ollama's expected format
func (r *Registry) ToOllamaFormat() []OllamaTool {
	r.mu.RLock()
	defer r.mu.RUnlock()

	ollamaTools := make([]OllamaTool, 0, len(r.tools))
	for _, tool := range r.tools {
		ot := OllamaTool{Type: "function"}
		ot.Function.Name = tool.Name
		ot.Function.Description = tool.Description
		ot.Function.Parameters = tool.Parameters
		ollamaTools = append(ollamaTools, ot)
	}
	return ollamaTools
}

// DefaultRegistry is the global tool registry
var DefaultRegistry = NewRegistry()
