from app.schemas.chat import EntitySummaryRequest
from app.schemas.chat import EntitySummaryResponse
from app.services.providers.base import BaseGenerationProvider


class EntitySummaryService:
    def __init__(self, generation_provider: BaseGenerationProvider):
        self.generation_provider = generation_provider

    def summarize(self, request: EntitySummaryRequest) -> EntitySummaryResponse:
        if not request.linked_memories:
            return EntitySummaryResponse(summary="")

        provider_reply = self.generation_provider.entity_summary(
            entity_name=request.entity_name,
            aliases=request.aliases,
            linked_memories=request.linked_memories,
        )
        return EntitySummaryResponse(summary=provider_reply.text.strip())
