from app.services.providers.base import BaseGenerationProvider
from app.services.providers.base import ProviderConfigurationError
from app.services.providers.base import ProviderRequestError


class GeminiGenerationProvider(BaseGenerationProvider):
    provider_name = "gemini"
    supports_image_inspection = True

    def _generate_text(self, prompt: str) -> str:
        if not self.settings.gemini_api_key:
            raise ProviderConfigurationError("GEMINI_API_KEY is required.")

        url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            f"{self.settings.generation_model}:generateContent"
        )
        payload = {
            "contents": [
                {
                    "role": "user",
                    "parts": [{"text": prompt}],
                }
            ]
        }
        response_payload = self._post_json(
            url=url,
            headers={
                "x-goog-api-key": self.settings.gemini_api_key,
                "Content-Type": "application/json",
            },
            payload=payload,
        )

        candidates = response_payload.get("candidates") or []
        if not candidates:
            raise ProviderRequestError("Gemini did not return a candidate.")
        content = candidates[0].get("content") or {}
        parts = content.get("parts") or []
        text_parts: list[str] = []
        for part in parts:
            if "text" in part and part["text"]:
                text_parts.append(part["text"])
        if not text_parts:
            raise ProviderRequestError("Gemini did not return text content.")
        return " ".join(text_parts)

    def _generate_image_text(
        self,
        *,
        prompt: str,
        mime_type: str,
        image_base64: str,
    ) -> str:
        if not self.settings.gemini_api_key:
            raise ProviderConfigurationError("GEMINI_API_KEY is required.")

        url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            f"{self.settings.generation_model}:generateContent"
        )
        payload = {
            "contents": [
                {
                    "role": "user",
                    "parts": [
                        {"text": prompt},
                        {
                            "inline_data": {
                                "mime_type": mime_type,
                                "data": image_base64,
                            }
                        },
                    ],
                }
            ]
        }
        response_payload = self._post_json(
            url=url,
            headers={
                "x-goog-api-key": self.settings.gemini_api_key,
                "Content-Type": "application/json",
            },
            payload=payload,
        )

        candidates = response_payload.get("candidates") or []
        if not candidates:
            raise ProviderRequestError("Gemini did not return a candidate.")
        content = candidates[0].get("content") or {}
        parts = content.get("parts") or []
        text_parts: list[str] = []
        for part in parts:
            if "text" in part and part["text"]:
                text_parts.append(part["text"])
        if not text_parts:
            raise ProviderRequestError("Gemini did not return text content.")
        return " ".join(text_parts)
