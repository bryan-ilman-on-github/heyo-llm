from app.core.config import Settings

from .anthropic_provider import ClaudeGenerationProvider
from .base import BaseGenerationProvider
from .gemini_provider import GeminiGenerationProvider
from .ollama_provider import OllamaGenerationProvider
from .openai_provider import OpenAIGenerationProvider


class ProviderRegistry:
    def __init__(self, settings: Settings):
        self.settings = settings
        self._providers: dict[str, BaseGenerationProvider] = {
            "gemini": GeminiGenerationProvider(settings),
            "openai": OpenAIGenerationProvider(settings),
            "claude": ClaudeGenerationProvider(settings),
            "ollama": OllamaGenerationProvider(settings),
        }

    def get_generation_provider(self) -> BaseGenerationProvider:
        return self._providers.get(
            self.settings.generation_provider.lower(),
            self._providers["gemini"],
        )
