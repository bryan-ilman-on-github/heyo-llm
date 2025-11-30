import requests
import sys

def main():
    print("Phi-3 Mini (via Ollama) - Type 'quit' to exit\n")

    while True:
        user_input = input("You: ").strip()

        if user_input.lower() in ['quit', 'exit', 'q']:
            print("Goodbye!")
            break

        if not user_input:
            continue

        # Call Ollama API with streaming
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={
                "model": "phi3:mini",
                "prompt": user_input,
                "stream": True
            },
            stream=True
        )

        print("\nPhi-3: ", end="", flush=True)
        for line in response.iter_lines():
            if line:
                data = __import__('json').loads(line)
                print(data.get('response', ''), end="", flush=True)
        print("\n")

if __name__ == "__main__":
    main()
