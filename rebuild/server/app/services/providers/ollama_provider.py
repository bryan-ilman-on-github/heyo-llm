from app.services.providers.base import BaseGenerationProvider
from app.services.providers.base import ProviderRequestError


class OllamaGenerationProvider(BaseGenerationProvider):
    provider_name = "ollama"

    def _generate_text(self, prompt: str) -> str:
        response_payload = self._post_json(
            url=f"{self.settings.ollama_url}/api/generate",
            headers={
                "Content-Type": "application/json",
            },
            payload={
                "model": self.settings.generation_model,
                "prompt": prompt,
                "stream": False,
            },
        )
        response_text = response_payload.get("response")
        if isinstance(response_text, str) and response_text.strip():
            return response_text
        raise ProviderRequestError("Ollama did not return response text.")
