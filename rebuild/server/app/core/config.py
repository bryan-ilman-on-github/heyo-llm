import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    app_name: str
    generation_provider: str
    generation_model: str
    embedding_model: str
    database_url: str
    default_daily_quota: int
    enable_embedding_model: bool
    allow_stub_generation: bool
    allow_stub_embeddings: bool
    gemini_api_key: str | None
    openai_api_key: str | None
    anthropic_api_key: str | None
    ollama_url: str
    request_timeout_seconds: float


def get_settings() -> Settings:
    return Settings(
        app_name=os.getenv("HEYO_APP_NAME", "Heyo Rebuild Server"),
        generation_provider=os.getenv("HEYO_GENERATION_PROVIDER", "gemini"),
        generation_model=os.getenv("HEYO_GENERATION_MODEL", "gemini-2.0-flash"),
        embedding_model=os.getenv("HEYO_EMBEDDING_MODEL", "google/embeddinggemma-300m"),
        database_url=os.getenv("HEYO_DATABASE_URL", "sqlite:///./heyo_server.db"),
        default_daily_quota=int(os.getenv("HEYO_DEFAULT_DAILY_QUOTA", "200")),
        enable_embedding_model=os.getenv("HEYO_ENABLE_EMBEDDING_MODEL", "1") == "1",
        allow_stub_generation=os.getenv("HEYO_ALLOW_STUB_GENERATION", "0") == "1",
        allow_stub_embeddings=os.getenv("HEYO_ALLOW_STUB_EMBEDDINGS", "0") == "1",
        gemini_api_key=os.getenv("GEMINI_API_KEY"),
        openai_api_key=os.getenv("OPENAI_API_KEY"),
        anthropic_api_key=os.getenv("ANTHROPIC_API_KEY"),
        ollama_url=os.getenv("OLLAMA_URL", "http://127.0.0.1:11434"),
        request_timeout_seconds=float(
            os.getenv("HEYO_REQUEST_TIMEOUT_SECONDS", "30")
        ),
    )
