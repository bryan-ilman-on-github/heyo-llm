import json

from app.schemas.chat import PrepareResponse
from app.schemas.chat import RetrievedMemory
from app.services.providers.base import BaseGenerationProvider
from app.services.retrieval_profiles import resolve_scenario_profile


class RespondingService:
    def __init__(self, generation_provider: BaseGenerationProvider):
        self.generation_provider = generation_provider

    def build_grounded_response(
        self,
        message: str,
        prepare_result: PrepareResponse,
        retrieved_memories: list[RetrievedMemory],
    ) -> str:
        if (
            prepare_result.outcome == "brief_refusal"
            and prepare_result.assistant_draft
        ):
            return prepare_result.assistant_draft

        scenario_profile = resolve_scenario_profile(
            prepare_result.retrieval_plan.intent_type
        )
        provider_reply = self.generation_provider.grounded_reply(
            message=message,
            retrieved_memories=retrieved_memories,
            response_style=scenario_profile.response_style,
        )
        return provider_reply.text

    def stream_events(self, response_text: str):
        for chunk in self._chunk_text(response_text):
            yield json.dumps({"type": "content", "delta": chunk}) + "\n"
        yield json.dumps({"type": "done"}) + "\n"

    def _chunk_text(self, response_text: str) -> list[str]:
        words = response_text.split()
        if not words:
            return []

        chunks: list[str] = []
        current_chunk: list[str] = []
        current_length = 0
        for word in words:
            if current_length + len(word) + 1 > 40 and current_chunk:
                chunks.append(" ".join(current_chunk))
                current_chunk = [word]
                current_length = len(word)
            else:
                current_chunk.append(word)
                current_length += len(word) + 1
        if current_chunk:
            chunks.append(" ".join(current_chunk))
        return chunks
