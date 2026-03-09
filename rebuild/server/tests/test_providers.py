import pytest

from app.core.config import Settings
from app.services.providers.anthropic_provider import ClaudeGenerationProvider
from app.services.providers.gemini_provider import GeminiGenerationProvider
from app.services.providers.ollama_provider import OllamaGenerationProvider
from app.services.providers.openai_provider import OpenAIGenerationProvider
from app.services.providers.base import ProviderCapabilityError
from app.services.providers.registry import ProviderRegistry


def _build_settings(*, provider_name: str, model_name: str) -> Settings:
    return Settings(
        app_name="Heyo Provider Test",
        generation_provider=provider_name,
        generation_model=model_name,
        embedding_model="google/embeddinggemma-300m",
        database_url="sqlite:///./provider_test.db",
        default_daily_quota=200,
        enable_embedding_model=False,
        allow_stub_generation=False,
        allow_stub_embeddings=True,
        gemini_api_key="test-gemini-key",
        openai_api_key="test-openai-key",
        anthropic_api_key="test-anthropic-key",
        ollama_url="http://127.0.0.1:11434",
        request_timeout_seconds=5.0,
    )


def test_provider_registry_selects_configured_provider():
    gemini_registry = ProviderRegistry(
        _build_settings(provider_name="gemini", model_name="gemini-test")
    )
    openai_registry = ProviderRegistry(
        _build_settings(provider_name="openai", model_name="openai-test")
    )
    claude_registry = ProviderRegistry(
        _build_settings(provider_name="claude", model_name="claude-test")
    )
    ollama_registry = ProviderRegistry(
        _build_settings(provider_name="ollama", model_name="ollama-test")
    )

    assert isinstance(gemini_registry.get_generation_provider(), GeminiGenerationProvider)
    assert isinstance(openai_registry.get_generation_provider(), OpenAIGenerationProvider)
    assert isinstance(claude_registry.get_generation_provider(), ClaudeGenerationProvider)
    assert isinstance(ollama_registry.get_generation_provider(), OllamaGenerationProvider)


def test_gemini_provider_uses_configured_model_name():
    settings = _build_settings(
        provider_name="gemini",
        model_name="gemini-2.0-flash",
    )
    provider = GeminiGenerationProvider(settings)
    captured: dict[str, object] = {}

    def fake_post_json(*, url: str, headers: dict[str, str], payload: dict) -> dict:
        captured["url"] = url
        captured["headers"] = headers
        captured["payload"] = payload
        return {
            "candidates": [
                {
                    "content": {
                        "parts": [{"text": "Grounded text"}],
                    }
                }
            ]
        }

    provider._post_json = fake_post_json  # type: ignore[method-assign]
    reply = provider.grounded_reply(message="What happened?", retrieved_memories=[])

    assert reply.text == "Grounded text"
    assert settings.generation_model in str(captured["url"])


def test_openai_provider_uses_configured_model_name():
    settings = _build_settings(
        provider_name="openai",
        model_name="gpt-4.1-mini",
    )
    provider = OpenAIGenerationProvider(settings)
    captured: dict[str, object] = {}

    def fake_post_json(*, url: str, headers: dict[str, str], payload: dict) -> dict:
        captured["url"] = url
        captured["headers"] = headers
        captured["payload"] = payload
        return {
            "choices": [
                {
                    "message": {
                        "content": "OpenAI grounded text",
                    }
                }
            ]
        }

    provider._post_json = fake_post_json  # type: ignore[method-assign]
    reply = provider.grounded_reply(message="What happened?", retrieved_memories=[])

    assert reply.text == "OpenAI grounded text"
    assert captured["payload"]["model"] == settings.generation_model


def test_claude_provider_uses_configured_model_name():
    settings = _build_settings(
        provider_name="claude",
        model_name="claude-3-7-sonnet-latest",
    )
    provider = ClaudeGenerationProvider(settings)
    captured: dict[str, object] = {}

    def fake_post_json(*, url: str, headers: dict[str, str], payload: dict) -> dict:
        captured["url"] = url
        captured["headers"] = headers
        captured["payload"] = payload
        return {
            "content": [
                {
                    "type": "text",
                    "text": "Claude grounded text",
                }
            ]
        }

    provider._post_json = fake_post_json  # type: ignore[method-assign]
    reply = provider.grounded_reply(message="What happened?", retrieved_memories=[])

    assert reply.text == "Claude grounded text"
    assert captured["payload"]["model"] == settings.generation_model


def test_ollama_provider_uses_configured_model_name():
    settings = _build_settings(
        provider_name="ollama",
        model_name="gemma3:4b",
    )
    provider = OllamaGenerationProvider(settings)
    captured: dict[str, object] = {}

    def fake_post_json(*, url: str, headers: dict[str, str], payload: dict) -> dict:
        captured["url"] = url
        captured["headers"] = headers
        captured["payload"] = payload
        return {"response": "Ollama grounded text"}

    provider._post_json = fake_post_json  # type: ignore[method-assign]
    reply = provider.grounded_reply(message="What happened?", retrieved_memories=[])

    assert reply.text == "Ollama grounded text"
    assert captured["payload"]["model"] == settings.generation_model


def test_gemini_provider_uses_multimodal_payload_for_image_summary():
    settings = _build_settings(
        provider_name="gemini",
        model_name="gemini-2.0-flash",
    )
    provider = GeminiGenerationProvider(settings)
    captured: dict[str, object] = {}

    def fake_post_json(*, url: str, headers: dict[str, str], payload: dict) -> dict:
        captured["url"] = url
        captured["headers"] = headers
        captured["payload"] = payload
        return {
            "candidates": [
                {
                    "content": {
                        "parts": [{"text": "Gemini image summary"}],
                    }
                }
            ]
        }

    provider._post_json = fake_post_json  # type: ignore[method-assign]
    reply = provider.image_summary(
        message_text="what's in this photo?",
        file_name="photo.jpg",
        mime_type="image/jpeg",
        image_base64="ZmFrZS1pbWFnZS1ieXRlcw==",
    )

    parts = captured["payload"]["contents"][0]["parts"]
    assert reply.text == "Gemini image summary"
    assert settings.generation_model in str(captured["url"])
    assert parts[1]["inline_data"]["mime_type"] == "image/jpeg"
    assert parts[1]["inline_data"]["data"] == "ZmFrZS1pbWFnZS1ieXRlcw=="


def test_ollama_provider_reports_unsupported_image_capability():
    settings = _build_settings(
        provider_name="ollama",
        model_name="gemma3:4b",
    )
    provider = OllamaGenerationProvider(settings)

    with pytest.raises(ProviderCapabilityError):
        provider.image_summary(
            message_text="what's in this photo?",
            file_name="photo.jpg",
            mime_type="image/jpeg",
            image_base64="ZmFrZS1pbWFnZS1ieXRlcw==",
        )
