from app.services.providers.base import BaseGenerationProvider
from app.services.providers.base import ProviderConfigurationError
from app.services.providers.base import ProviderRequestError


class OpenAIGenerationProvider(BaseGenerationProvider):
    provider_name = "openai"
    supports_image_inspection = True

    def _generate_text(self, prompt: str) -> str:
        if not self.settings.openai_api_key:
            raise ProviderConfigurationError("OPENAI_API_KEY is required.")

        response_payload = self._post_json(
            url="https://api.openai.com/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {self.settings.openai_api_key}",
                "Content-Type": "application/json",
            },
            payload={
                "model": self.settings.generation_model,
                "messages": [
                    {
                        "role": "system",
                        "content": "You are Heyo. Stay grounded in the supplied memories.",
                    },
                    {
                        "role": "user",
                        "content": prompt,
                    },
                ],
            },
        )

        choices = response_payload.get("choices") or []
        if not choices:
            raise ProviderRequestError("OpenAI did not return a choice.")
        message = choices[0].get("message") or {}
        content = message.get("content")
        if isinstance(content, str) and content.strip():
            return content
        raise ProviderRequestError("OpenAI did not return text content.")

    def _generate_image_text(
        self,
        *,
        prompt: str,
        mime_type: str,
        image_base64: str,
    ) -> str:
        if not self.settings.openai_api_key:
            raise ProviderConfigurationError("OPENAI_API_KEY is required.")

        response_payload = self._post_json(
            url="https://api.openai.com/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {self.settings.openai_api_key}",
                "Content-Type": "application/json",
            },
            payload={
                "model": self.settings.generation_model,
                "messages": [
                    {
                        "role": "system",
                        "content": "You are Heyo. Stay grounded in the supplied attachment.",
                    },
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "text",
                                "text": prompt,
                            },
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:{mime_type};base64,{image_base64}",
                                },
                            },
                        ],
                    },
                ],
            },
        )

        choices = response_payload.get("choices") or []
        if not choices:
            raise ProviderRequestError("OpenAI did not return a choice.")
        message = choices[0].get("message") or {}
        content = message.get("content")
        if isinstance(content, str) and content.strip():
            return content
        raise ProviderRequestError("OpenAI did not return text content.")
