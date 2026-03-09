from datetime import datetime
from typing import Literal

from pydantic import BaseModel
from pydantic import Field
from pydantic import model_validator


PrepareOutcome = Literal["memory_only", "query", "clarify", "mixed", "brief_refusal"]
AttachmentKind = Literal["document", "image"]
AttachmentInspectStatus = Literal["ready", "failed"]


class RecentMessage(BaseModel):
    id: str
    role: str
    content: str
    created_at: datetime | None = None


class MemoryItem(BaseModel):
    content: str
    tags: list[str] = Field(default_factory=list)
    entities: list[str] = Field(default_factory=list)
    entity_names: list[str] = Field(default_factory=list)
    embedding: list[float] | None = None

    @model_validator(mode="before")
    @classmethod
    def normalize_entities(cls, value):
        if not isinstance(value, dict):
            return value

        entity_values = value.get("entity_names") or value.get("entities") or []
        value["entities"] = entity_values
        value["entity_names"] = entity_values
        return value


class ClarificationPrompt(BaseModel):
    title: str
    message: str
    original_text: str


class PrepareRequest(BaseModel):
    client_id: str = "anonymous"
    message: str
    recent_messages: list[RecentMessage] = Field(default_factory=list)


class RetrievalPlan(BaseModel):
    intent_type: str
    strategy: str
    allow_deleted_fallback: bool = False
    keyword_terms: list[str] = Field(default_factory=list)
    entity_filters: list[str] = Field(default_factory=list)
    tag_filters: list[str] = Field(default_factory=list)
    time_filters: list[str] = Field(default_factory=list)


class PrepareResponse(BaseModel):
    outcome: PrepareOutcome
    assistant_draft: str = ""
    tags: list[str] = Field(default_factory=list)
    entities: list[str] = Field(default_factory=list)
    literal_terms: list[str] = Field(default_factory=list)
    time_filters: list[str] = Field(default_factory=list)
    query_embedding: list[float] | None = None
    clarification: ClarificationPrompt | None = None
    memory_items: list[MemoryItem] = Field(default_factory=list)
    memory_write_plans: list[MemoryItem] = Field(default_factory=list)
    retrieval_plan: RetrievalPlan

    @model_validator(mode="after")
    def normalize_memory_lists(self):
        if self.memory_items and not self.memory_write_plans:
            self.memory_write_plans = self.memory_items
        if self.memory_write_plans and not self.memory_items:
            self.memory_items = self.memory_write_plans
        return self


class RetrievedMemory(BaseModel):
    id: str
    content: str
    tags: list[str] = Field(default_factory=list)
    entities: list[str] = Field(default_factory=list)
    score: float = 0.0
    created_at: datetime | None = None
    source_type: str | None = None
    attachment_id: str | None = None
    attachment_name: str | None = None
    snippet: str | None = None


class RespondRequest(BaseModel):
    client_id: str = "anonymous"
    message: str
    prepare_result: PrepareResponse
    retrieved_memories: list[RetrievedMemory] = Field(default_factory=list)


class EntitySummaryMemory(BaseModel):
    id: str
    content: str
    tags: list[str] = Field(default_factory=list)
    entities: list[str] = Field(default_factory=list)
    created_at: datetime | None = None


class EntitySummaryRequest(BaseModel):
    client_id: str = "anonymous"
    entity_name: str
    aliases: list[str] = Field(default_factory=list)
    linked_memories: list[EntitySummaryMemory] = Field(default_factory=list)


class EntitySummaryResponse(BaseModel):
    summary: str = ""


class AttachmentInspectItemRequest(BaseModel):
    client_attachment_id: str
    kind: AttachmentKind
    file_name: str
    mime_type: str
    document_text: str | None = None
    image_base64: str | None = None

    @model_validator(mode="after")
    def validate_payload(self):
        if self.kind == "document":
            if not (self.document_text or "").strip():
                raise ValueError("document_text is required for document attachments.")
            self.image_base64 = None
        if self.kind == "image":
            if not (self.image_base64 or "").strip():
                raise ValueError("image_base64 is required for image attachments.")
            self.document_text = None
        return self


class AttachmentInspectRequest(BaseModel):
    client_id: str = "anonymous"
    message_text: str = ""
    attachments: list[AttachmentInspectItemRequest] = Field(default_factory=list)


class AttachmentInspectItemResponse(BaseModel):
    client_attachment_id: str
    kind: AttachmentKind
    status: AttachmentInspectStatus
    summary: str = ""
    failure_reason: str | None = None
    memory_write_plan: MemoryItem | None = None


class AttachmentInspectResponse(BaseModel):
    items: list[AttachmentInspectItemResponse] = Field(default_factory=list)


class QuotaResponse(BaseModel):
    client_id: str
    quota_day: str
    daily_limit: int
    total_used: int
    remaining_total: int
    prepare_count: int
    respond_count: int
    entity_summary_count: int
    attachment_inspect_count: int
    updated_at: datetime | None = None
    remaining_prepare: int
    remaining_respond: int


class QuotaErrorResponse(BaseModel):
    error_code: str
    message: str
    quota: QuotaResponse
