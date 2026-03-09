from fastapi import HTTPException

from app.schemas.chat import AttachmentInspectItemRequest
from app.schemas.chat import AttachmentInspectItemResponse
from app.schemas.chat import AttachmentInspectRequest
from app.schemas.chat import AttachmentInspectResponse
from app.schemas.chat import MemoryItem
from app.services.embeddings import EmbeddingService
from app.services.preparation import QueryAnalyzer
from app.services.providers.base import BaseGenerationProvider
from app.services.providers.base import ProviderCapabilityError
from app.services.providers.base import ProviderConfigurationError
from app.services.providers.base import ProviderRequestError


class AttachmentInspectionService:
    max_image_attachments = 10

    def __init__(
        self,
        embedding_service: EmbeddingService,
        generation_provider: BaseGenerationProvider,
    ):
        self.embedding_service = embedding_service
        self.generation_provider = generation_provider
        self.query_analyzer = QueryAnalyzer()

    def inspect(self, request: AttachmentInspectRequest) -> AttachmentInspectResponse:
        self.validate_request(request)
        items: list[AttachmentInspectItemResponse] = []
        for attachment in request.attachments:
            items.append(
                self._inspect_attachment(
                    message_text=request.message_text,
                    attachment=attachment,
                )
            )
        return AttachmentInspectResponse(items=items)

    def validate_request(self, request: AttachmentInspectRequest) -> None:
        image_count = sum(
            1 for attachment in request.attachments if attachment.kind == "image"
        )
        if image_count > self.max_image_attachments:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"At most {self.max_image_attachments} image attachments are "
                    "allowed per request."
                ),
            )

    def _inspect_attachment(
        self,
        *,
        message_text: str,
        attachment: AttachmentInspectItemRequest,
    ) -> AttachmentInspectItemResponse:
        try:
            provider_reply = self.generation_provider.attachment_summary(
                message_text=message_text,
                kind=attachment.kind,
                file_name=attachment.file_name,
                mime_type=attachment.mime_type,
                document_text=attachment.document_text,
                image_base64=attachment.image_base64,
            )
        except ProviderCapabilityError as error:
            return self._failure_item(
                attachment=attachment,
                failure_reason=str(error),
            )
        except (ProviderConfigurationError, ProviderRequestError, RuntimeError) as error:
            return self._failure_item(
                attachment=attachment,
                failure_reason=str(error),
            )

        summary = provider_reply.text.strip()
        if not summary:
            return self._failure_item(
                attachment=attachment,
                failure_reason=(
                    "Attachment inspection did not return a grounded summary."
                ),
            )

        memory_write_plan = self._build_memory_write_plan(
            attachment=attachment,
            summary=summary,
        )
        return AttachmentInspectItemResponse(
            client_attachment_id=attachment.client_attachment_id,
            kind=attachment.kind,
            status="ready",
            summary=summary,
            failure_reason=None,
            memory_write_plan=memory_write_plan,
        )

    def _failure_item(
        self,
        *,
        attachment: AttachmentInspectItemRequest,
        failure_reason: str,
    ) -> AttachmentInspectItemResponse:
        return AttachmentInspectItemResponse(
            client_attachment_id=attachment.client_attachment_id,
            kind=attachment.kind,
            status="failed",
            summary="",
            failure_reason=failure_reason,
            memory_write_plan=None,
        )

    def _build_memory_write_plan(
        self,
        *,
        attachment: AttachmentInspectItemRequest,
        summary: str,
    ) -> MemoryItem:
        analysis = self.query_analyzer.analyze(summary)
        tag_values: list[str] = []
        base_tag = "image" if attachment.kind == "image" else "document"
        tag_values.append(base_tag)
        for tag in analysis.tags:
            if tag not in tag_values:
                tag_values.append(tag)

        return MemoryItem(
            content=summary,
            tags=tag_values,
            entities=analysis.entities,
            embedding=self.embedding_service.embed_text(summary),
        )
