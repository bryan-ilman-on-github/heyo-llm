package main

import (
	"io"
	"log"
	"net/http"
	"os"
)

var ollamaURL = getEnv("OLLAMA_URL", "http://localhost:11434")

func main() {
	http.HandleFunc("/health", handleHealth)
	http.HandleFunc("/api/generate", handleGenerate)
	http.HandleFunc("/api/chat", handleChat)

	port := getEnv("PORT", "8080")
	log.Printf("Server starting on :%s (proxying to %s)", port, ollamaURL)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("ok"))
}

func handleGenerate(w http.ResponseWriter, r *http.Request) {
	proxyToOllama(w, r, "/api/generate")
}

func handleChat(w http.ResponseWriter, r *http.Request) {
	proxyToOllama(w, r, "/api/chat")
}

func proxyToOllama(w http.ResponseWriter, r *http.Request, path string) {
	if r.Method == http.MethodOptions {
		setCORS(w)
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	req, err := http.NewRequest(http.MethodPost, ollamaURL+path, r.Body)
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
	w.Header().Set("Content-Type", "application/x-ndjson")
	w.Header().Set("Transfer-Encoding", "chunked")
	w.WriteHeader(resp.StatusCode)

	flusher, ok := w.(http.Flusher)
	if !ok {
		io.Copy(w, resp.Body)
		return
	}

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
}

func setCORS(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
