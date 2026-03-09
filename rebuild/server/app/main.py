from fastapi import Request
from fastapi import Depends
from fastapi import FastAPI
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.core.config import get_settings
from app.core.database import build_engine
from app.core.database import build_session_factory
from app.core.database import init_database
from app.core.database import session_dependency
from app.schemas.chat import AttachmentInspectRequest
from app.schemas.chat import AttachmentInspectResponse
from app.schemas.chat import EntitySummaryRequest
from app.schemas.chat import EntitySummaryResponse
from app.schemas.chat import PrepareRequest
from app.schemas.chat import PrepareResponse
from app.schemas.chat import QuotaErrorResponse
from app.schemas.chat import QuotaResponse
from app.schemas.chat import RespondRequest
from app.services.attachment_inspection import AttachmentInspectionService
from app.services.embeddings import EmbeddingService
from app.services.entity_summary import EntitySummaryService
from app.services.preparation import PreparationService
from app.services.providers import ProviderRegistry
from app.services.quota import QuotaExceededError
from app.services.quota import QuotaService
from app.services.responding import RespondingService


def create_app(settings: Settings | None = None) -> FastAPI:
    resolved_settings = settings or get_settings()
    engine = build_engine(resolved_settings)
    session_factory = build_session_factory(engine)
    init_database(engine)
    embedding_service = EmbeddingService(resolved_settings)
    provider_registry = ProviderRegistry(resolved_settings)
    preparation_service = PreparationService(embedding_service)
    quota_service = QuotaService(resolved_settings)
    generation_provider = provider_registry.get_generation_provider()
    responding_service = RespondingService(generation_provider)
    entity_summary_service = EntitySummaryService(generation_provider)
    attachment_inspection_service = AttachmentInspectionService(
        embedding_service=embedding_service,
        generation_provider=generation_provider,
    )

    app = FastAPI(title=resolved_settings.app_name)

    def get_session():
        yield from session_dependency(session_factory)

    @app.exception_handler(QuotaExceededError)
    def handle_quota_exceeded(
        request: Request,
        error: QuotaExceededError,
    ) -> JSONResponse:
        del request
        payload = QuotaErrorResponse(
            error_code="daily_quota_exceeded",
            message="Daily quota exhausted for this client.",
            quota=error.quota,
        )
        return JSONResponse(
            status_code=429,
            content=jsonable_encoder(payload),
        )

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    @app.get("/api/quota", response_model=QuotaResponse)
    def quota(
        client_id: str = "anonymous",
        session: Session = Depends(get_session),
    ) -> QuotaResponse:
        return quota_service.current_quota(session, client_id)

    @app.post("/api/chat/prepare", response_model=PrepareResponse)
    def prepare(
        request: PrepareRequest,
        session: Session = Depends(get_session),
    ) -> PrepareResponse:
        quota_service.reserve_prepare(session, request.client_id)
        return preparation_service.prepare(request)

    @app.post("/api/chat/respond")
    def respond(
        request: RespondRequest,
        session: Session = Depends(get_session),
    ) -> StreamingResponse:
        quota_service.reserve_respond(session, request.client_id)
        response_text = responding_service.build_grounded_response(
            message=request.message,
            prepare_result=request.prepare_result,
            retrieved_memories=request.retrieved_memories,
        )
        return StreamingResponse(
            responding_service.stream_events(response_text),
            media_type="application/x-ndjson",
        )

    @app.post("/api/entities/summarize", response_model=EntitySummaryResponse)
    def summarize_entity(
        request: EntitySummaryRequest,
        session: Session = Depends(get_session),
    ) -> EntitySummaryResponse:
        quota_service.reserve_entity_summary(session, request.client_id)
        return entity_summary_service.summarize(request)

    @app.post("/api/attachments/inspect", response_model=AttachmentInspectResponse)
    def inspect_attachments(
        request: AttachmentInspectRequest,
        session: Session = Depends(get_session),
    ) -> AttachmentInspectResponse:
        attachment_inspection_service.validate_request(request)
        quota_service.reserve_attachment_inspect(session, request.client_id)
        return attachment_inspection_service.inspect(request)

    return app


app = create_app()
