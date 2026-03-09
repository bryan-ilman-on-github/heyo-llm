from app.services.providers.base import BaseGenerationProvider
from app.services.providers.base import ProviderConfigurationError
from app.services.providers.base import ProviderRequestError


class ClaudeGenerationProvider(BaseGenerationProvider):
    provider_name = "claude"
    supports_image_inspection = True

    def _generate_text(self, prompt: str) -> str:
        if not self.settings.anthropic_api_key:
            raise ProviderConfigurationError("ANTHROPIC_API_KEY is required.")

        response_payload = self._post_json(
            url="https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": self.settings.anthropic_api_key,
                "anthropic-version": "2023-06-01",
                "Content-Type": "application/json",
            },
            payload={
                "model": self.settings.generation_model,
                "max_tokens": 600,
                "messages": [
                    {
                        "role": "user",
                        "content": prompt,
                    }
                ],
            },
        )

        content_blocks = response_payload.get("content") or []
        text_parts: list[str] = []
        for block in content_blocks:
            if block.get("type") == "text" and block.get("text"):
                text_parts.append(block["text"])
        if not text_parts:
            raise ProviderRequestError("Anthropic did not return text content.")
        return " ".join(text_parts)

    def _generate_image_text(
        self,
        *,
        prompt: str,
        mime_type: str,
        image_base64: str,
    ) -> str:
        if not self.settings.anthropic_api_key:
            raise ProviderConfigurationError("ANTHROPIC_API_KEY is required.")

        response_payload = self._post_json(
            url="https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": self.settings.anthropic_api_key,
                "anthropic-version": "2023-06-01",
                "Content-Type": "application/json",
            },
            payload={
                "model": self.settings.generation_model,
                "max_tokens": 600,
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "text",
                                "text": prompt,
                            },
                            {
                                "type": "image",
                                "source": {
                                    "type": "base64",
                                    "media_type": mime_type,
                                    "data": image_base64,
                                },
                            },
                        ],
                    }
                ],
            },
        )

        content_blocks = response_payload.get("content") or []
        text_parts: list[str] = []
        for block in content_blocks:
            if block.get("type") == "text" and block.get("text"):
                text_parts.append(block["text"])
        if not text_parts:
            raise ProviderRequestError("Anthropic did not return text content.")
        return " ".join(text_parts)
