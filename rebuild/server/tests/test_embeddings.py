import pytest

from app.core.config import Settings
from app.services.embeddings import EmbeddingService


def _build_settings(*, allow_stub_embeddings: bool) -> Settings:
    return Settings(
        app_name="Heyo Embedding Test",
        generation_provider="gemini",
        generation_model="gemini-2.0-flash",
        embedding_model="google/embeddinggemma-300m",
        database_url="sqlite:///./embedding_test.db",
        default_daily_quota=200,
        enable_embedding_model=False,
        allow_stub_generation=True,
        allow_stub_embeddings=allow_stub_embeddings,
        gemini_api_key=None,
        openai_api_key=None,
        anthropic_api_key=None,
        ollama_url="http://127.0.0.1:11434",
        request_timeout_seconds=5.0,
    )


def test_embedding_service_allows_explicit_stub_fallback():
    service = EmbeddingService(_build_settings(allow_stub_embeddings=True))

    vector = service.embed_text("Rita's instagram handle is @rita")

    assert len(vector) == 16


def test_embedding_service_rejects_disabled_stub_fallback():
    service = EmbeddingService(_build_settings(allow_stub_embeddings=False))

    with pytest.raises(RuntimeError):
        service.embed_text("Rita's instagram handle is @rita")
