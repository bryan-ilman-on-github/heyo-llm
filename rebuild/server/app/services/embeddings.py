import hashlib
import math
from functools import cached_property

from app.core.config import Settings


class EmbeddingService:
    def __init__(self, settings: Settings):
        self.settings = settings

    @cached_property
    def _model(self):
        if not self.settings.enable_embedding_model:
            if self.settings.allow_stub_embeddings:
                return None
            raise RuntimeError("EmbeddingGemma is required but disabled.")

        try:
            from sentence_transformers import SentenceTransformer
        except Exception as error:
            if self.settings.allow_stub_embeddings:
                return None
            raise RuntimeError(
                "SentenceTransformer is required for EmbeddingGemma."
            ) from error

        try:
            return SentenceTransformer(self.settings.embedding_model)
        except Exception as error:
            if self.settings.allow_stub_embeddings:
                return None
            raise RuntimeError(
                f"Failed to load embedding model {self.settings.embedding_model}."
            ) from error

    def embed_text(self, text: str) -> list[float]:
        normalized_text = text.strip()
        if not normalized_text:
            return [0.0] * 16

        if self._model is not None:
            vector = self._model.encode(
                normalized_text,
                normalize_embeddings=True,
            )
            return [float(value) for value in vector.tolist()]

        if not self.settings.allow_stub_embeddings:
            raise RuntimeError("Embedding fallback is disabled.")

        digest = hashlib.sha256(normalized_text.encode("utf-8")).digest()
        values = [
            ((byte / 255.0) * 2.0) - 1.0
            for byte in self._first_digest_bytes(digest, 16)
        ]
        magnitude = math.sqrt(sum(value * value for value in values))
        if magnitude == 0.0:
            return values
        return [value / magnitude for value in values]

    def _first_digest_bytes(self, digest: bytes, limit: int) -> list[int]:
        values: list[int] = []
        for byte in digest:
            values.append(byte)
            if len(values) >= limit:
                break
        return values
