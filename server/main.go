package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"heyo/handlers"
	"heyo/tools"
)

var (
	ollamaURL         = getEnv("OLLAMA_URL", "http://localhost:11434")
	pythonExecutorURL = getEnv("PYTHON_EXECUTOR_URL", "http://localhost:8002")
)

func main() {
	// Initialize tool registry
	registry := tools.NewRegistry()
	tools.RegisterBuiltinTools(registry, pythonExecutorURL)

	log.Printf("Registered %d tools", len(registry.GetAll()))
	for _, tool := range registry.GetAll() {
		log.Printf("  - %s: %s", tool.Name, truncate(tool.Description, 50)+"...")
	}

	// Create chat handler with tool support
	chatHandler := handlers.NewChatHandler(ollamaURL, registry)

	// Routes
	http.HandleFunc("/health", handleHealth)
	http.Handle("/api/chat", chatHandler)
	http.HandleFunc("/api/generate", handlers.ProxyToOllama(ollamaURL))

	// Tool info endpoint
	http.HandleFunc("/api/tools", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")

		toolList := registry.GetAll()
		toolInfo := make([]map[string]interface{}, len(toolList))
		for i, t := range toolList {
			toolInfo[i] = map[string]interface{}{
				"name":        t.Name,
				"description": t.Description,
				"parameters":  t.Parameters,
			}
		}

		data, _ := json.Marshal(toolInfo)
		w.Write(data)
	})

	port := getEnv("PORT", "8080")
	log.Printf("Server starting on :%s (Ollama: %s)", port, ollamaURL)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("ok"))
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n]
}
