package tools

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os/exec"
	"strings"
	"time"
)

// RegisterBuiltinTools adds all built-in tools to the registry
func RegisterBuiltinTools(registry *Registry, pythonExecutorURL string) {
	// Calculator tool - calls Python executor
	registry.Register(&Tool{
		Name:        "calculate",
		Description: "Evaluate mathematical expressions accurately. Use this for ANY math calculations including arithmetic, algebra, trigonometry, logarithms, square roots, etc. Always use this tool instead of calculating yourself.",
		Parameters: map[string]interface{}{
			"type":     "object",
			"required": []string{"expression"},
			"properties": map[string]interface{}{
				"expression": map[string]interface{}{
					"type":        "string",
					"description": "Mathematical expression to evaluate, e.g., 'sqrt(189)', '2+2*3', 'sin(3.14159/2)', 'log(100, 10)'",
				},
			},
		},
		Execute: func(args map[string]interface{}) (string, error) {
			expr, ok := args["expression"].(string)
			if !ok {
				return "", fmt.Errorf("expression must be a string")
			}
			return callPythonTool(pythonExecutorURL, "calculate", map[string]interface{}{
				"expression": expr,
			})
		},
	})

	// Python code interpreter tool
	registry.Register(&Tool{
		Name:        "python",
		Description: "Execute Python code and return the output. Use for complex calculations, data processing, or any task that benefits from code execution. The code runs in a sandboxed environment with common libraries available (math, numpy, etc).",
		Parameters: map[string]interface{}{
			"type":     "object",
			"required": []string{"code"},
			"properties": map[string]interface{}{
				"code": map[string]interface{}{
					"type":        "string",
					"description": "Python code to execute. Use print() to output results.",
				},
			},
		},
		Execute: func(args map[string]interface{}) (string, error) {
			code, ok := args["code"].(string)
			if !ok {
				return "", fmt.Errorf("code must be a string")
			}
			return callPythonTool(pythonExecutorURL, "python", map[string]interface{}{
				"code": code,
			})
		},
	})
}

// callPythonTool calls the Python executor service
func callPythonTool(baseURL, toolName string, args map[string]interface{}) (string, error) {
	payload := map[string]interface{}{
		"tool": toolName,
		"args": args,
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Post(baseURL+"/execute", "application/json", bytes.NewReader(body))
	if err != nil {
		// Fallback: try direct Python execution if executor isn't running
		return executePythonDirect(toolName, args)
	}
	defer resp.Body.Close()

	var result struct {
		Success bool   `json:"success"`
		Result  string `json:"result"`
		Error   string `json:"error"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	if !result.Success {
		return "", fmt.Errorf(result.Error)
	}

	return result.Result, nil
}

// executePythonDirect is a fallback that runs Python directly
func executePythonDirect(toolName string, args map[string]interface{}) (string, error) {
	var code string

	switch toolName {
	case "calculate":
		expr, _ := args["expression"].(string)
		// Safe math expression evaluation
		code = fmt.Sprintf(`
import math
from math import *

def safe_eval(expr):
    allowed = {
        'sqrt': math.sqrt, 'sin': math.sin, 'cos': math.cos, 'tan': math.tan,
        'log': math.log, 'log10': math.log10, 'log2': math.log2,
        'exp': math.exp, 'pow': pow, 'abs': abs, 'round': round,
        'floor': math.floor, 'ceil': math.ceil,
        'pi': math.pi, 'e': math.e,
        'asin': math.asin, 'acos': math.acos, 'atan': math.atan,
        'sinh': math.sinh, 'cosh': math.cosh, 'tanh': math.tanh,
        'degrees': math.degrees, 'radians': math.radians,
        'factorial': math.factorial, 'gcd': math.gcd,
    }
    return eval(expr, {"__builtins__": {}}, allowed)

result = safe_eval(%q)
print(result)
`, expr)

	case "python":
		code, _ = args["code"].(string)

	default:
		return "", fmt.Errorf("unknown tool: %s", toolName)
	}

	cmd := exec.Command("python", "-c", code)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		errMsg := strings.TrimSpace(stderr.String())
		if errMsg == "" {
			errMsg = err.Error()
		}
		return "", fmt.Errorf("execution error: %s", errMsg)
	}

	return strings.TrimSpace(stdout.String()), nil
}
