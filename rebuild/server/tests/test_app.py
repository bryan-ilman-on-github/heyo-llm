from datetime import date
from pathlib import Path
import sqlite3

from fastapi.testclient import TestClient

from app.core.config import Settings
from app.main import create_app


def build_settings(
    tmp_path: Path,
    database_name: str,
    **overrides,
) -> Settings:
    database_path = (tmp_path / database_name).resolve()
    settings_kwargs = {
        "app_name": "Heyo Rebuild Server Test",
        "generation_provider": "gemini",
        "generation_model": "gemini-2.0-flash",
        "embedding_model": "google/embeddinggemma-300m",
        "database_url": f"sqlite:///{database_path.as_posix()}",
        "default_daily_quota": 200,
        "enable_embedding_model": False,
        "allow_stub_generation": True,
        "allow_stub_embeddings": True,
        "gemini_api_key": None,
        "openai_api_key": None,
        "anthropic_api_key": None,
        "ollama_url": "http://127.0.0.1:11434",
        "request_timeout_seconds": 5.0,
    }
    settings_kwargs.update(overrides)
    return Settings(**settings_kwargs)


def build_client(
    tmp_path: Path,
    database_name: str,
    **overrides,
) -> TestClient:
    settings = build_settings(tmp_path, database_name, **overrides)
    app = create_app(settings)
    return TestClient(app)


def test_health_endpoint(tmp_path: Path):
    client = build_client(tmp_path, "health.db")
    response = client.get("/health")
    client.close()
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_prepare_memory_only_flow(tmp_path: Path):
    client = build_client(tmp_path, "memory_only.db")
    response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "test-user",
            "message": "Rita's instagram handle is @rita",
            "recent_messages": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["outcome"] == "memory_only"
    assert payload["retrieval_plan"]["intent_type"] == "entity_specific_recall"
    assert payload["retrieval_plan"]["strategy"] == "entity_keyword_hybrid"
    assert payload["memory_write_plans"][0]["content"] == "Rita's instagram handle is @rita"
    assert payload["memory_write_plans"][0]["entities"]
    assert "Rita" in payload["memory_write_plans"][0]["entity_names"]
    assert payload["memory_items"][0]["embedding"]


def test_prepare_clarify_flow(tmp_path: Path):
    client = build_client(tmp_path, "clarify.db")
    response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "test-user",
            "message": "March 12, 3pm dentist.",
            "recent_messages": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["outcome"] == "clarify"
    assert payload["retrieval_plan"]["intent_type"] == "thematic_reflection"
    assert payload["retrieval_plan"]["strategy"] == "time_vector"
    assert payload["clarification"]["title"] == "Store this or answer it?"
    assert payload["memory_items"]
    assert payload["query_embedding"]


def test_prepare_query_flow_and_quota(tmp_path: Path):
    client = build_client(tmp_path, "quota.db")
    prepare_response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "quota-user",
            "message": "What is going on in Rita's life?",
            "recent_messages": [],
        },
    )
    assert prepare_response.status_code == 200
    prepare_payload = prepare_response.json()
    quota_response = client.get("/api/quota", params={"client_id": "quota-user"})
    assert quota_response.status_code == 200
    quota_payload = quota_response.json()
    client.close()
    assert prepare_payload["query_embedding"]
    assert prepare_payload["memory_items"] == []
    assert prepare_payload["retrieval_plan"]["strategy"] == "entity_keyword_hybrid"
    assert quota_payload["prepare_count"] == 1
    assert quota_payload["respond_count"] == 0
    assert quota_payload["entity_summary_count"] == 0
    assert quota_payload["attachment_inspect_count"] == 0
    assert quota_payload["total_used"] == 1
    assert quota_payload["remaining_total"] == 199
    assert quota_payload["remaining_prepare"] == quota_payload["remaining_total"]
    assert quota_payload["remaining_respond"] == quota_payload["remaining_total"]
    assert quota_payload["daily_limit"] == 200
    assert quota_payload["updated_at"]


def test_prepare_mixed_flow_only_stores_memory_clause(tmp_path: Path):
    client = build_client(tmp_path, "mixed.db")
    response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "mixed-user",
            "message": "Rita's instagram handle is @rita, do you know her handle?",
            "recent_messages": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["outcome"] == "mixed"
    assert len(payload["memory_write_plans"]) == 1
    assert payload["memory_write_plans"][0]["content"] == "Rita's instagram handle is @rita"
    assert payload["retrieval_plan"]["strategy"] == "entity_keyword_hybrid"


def test_prepare_short_followup_is_not_stored_as_memory(tmp_path: Path):
    client = build_client(tmp_path, "non_memory.db")
    response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "followup-user",
            "message": "thanks",
            "recent_messages": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["outcome"] == "memory_only"
    assert payload["memory_write_plans"] == []
    assert payload["retrieval_plan"]["intent_type"] == "open_reflective_query"
    assert payload["retrieval_plan"]["strategy"] == "vector_only"


def test_prepare_emotional_recall_flow(tmp_path: Path):
    client = build_client(tmp_path, "emotional.db")
    response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "emotional-user",
            "message": "remind me of my happy memories",
            "recent_messages": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["outcome"] == "query"
    assert payload["retrieval_plan"]["intent_type"] == "emotional_recall"
    assert payload["retrieval_plan"]["strategy"] == "tag_vector"
    assert "positive" in payload["retrieval_plan"]["tag_filters"]
    assert payload["query_embedding"]


def test_prepare_exact_mention_lookup_flow(tmp_path: Path):
    client = build_client(tmp_path, "exact.db")
    response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "exact-user",
            "message": "when did I mention Bhutan?",
            "recent_messages": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["outcome"] == "query"
    assert payload["retrieval_plan"]["intent_type"] == "exact_mention_lookup"
    assert payload["retrieval_plan"]["strategy"] == "keyword_only"
    assert "Bhutan" in payload["retrieval_plan"]["keyword_terms"]
    assert payload["query_embedding"] is None


def test_prepare_quoted_text_lookup_flow(tmp_path: Path):
    client = build_client(tmp_path, "quoted.db")
    response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "quoted-user",
            "message": "my lyrics that go 'fire in the rain' last year",
            "recent_messages": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["outcome"] == "query"
    assert payload["retrieval_plan"]["intent_type"] == "quoted_text_lookup"
    assert payload["retrieval_plan"]["strategy"] == "keyword_vector_hybrid"
    assert "fire in the rain" in payload["retrieval_plan"]["keyword_terms"]
    assert str(date.today().year - 1) in payload["retrieval_plan"]["time_filters"]


def test_prepare_thematic_reflection_flow(tmp_path: Path):
    client = build_client(tmp_path, "thematic.db")
    response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "thematic-user",
            "message": "have I grown more confident this year?",
            "recent_messages": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["outcome"] == "query"
    assert payload["retrieval_plan"]["intent_type"] == "thematic_reflection"
    assert payload["retrieval_plan"]["strategy"] == "time_vector"
    assert str(date.today().year) in payload["retrieval_plan"]["time_filters"]
    assert "positive" in payload["retrieval_plan"]["tag_filters"]


def test_prepare_open_reflective_query_flow(tmp_path: Path):
    client = build_client(tmp_path, "open_reflective.db")
    response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "reflective-user",
            "message": "why do I keep feeling stuck?",
            "recent_messages": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["outcome"] == "query"
    assert payload["retrieval_plan"]["intent_type"] == "open_reflective_query"
    assert payload["retrieval_plan"]["strategy"] == "vector_only"
    assert "negative" in payload["retrieval_plan"]["tag_filters"]


def test_respond_streams_grounded_response(tmp_path: Path):
    client = build_client(tmp_path, "respond.db")
    prepare_response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "stream-user",
            "message": "Do you know Rita's instagram handle?",
            "recent_messages": [],
        },
    )
    assert prepare_response.status_code == 200
    payload = prepare_response.json()
    response = client.post(
        "/api/chat/respond",
        json={
            "client_id": "stream-user",
            "message": "Do you know Rita's instagram handle?",
            "prepare_result": payload,
            "retrieved_memories": [
                {
                    "id": "memory-1",
                    "content": "Rita's instagram handle is @rita",
                    "tags": ["relationship"],
                    "entities": ["Rita"],
                    "score": 1.0,
                    "created_at": "2026-03-08T00:00:00",
                }
            ],
        },
    )
    assert response.status_code == 200
    body = response.text
    client.close()
    assert '"type": "content"' in body
    assert '"type": "done"' in body
    assert "Rita" in body


def test_respond_streams_emotional_recall_style(tmp_path: Path):
    client = build_client(tmp_path, "respond_emotional.db")
    response = client.post(
        "/api/chat/respond",
        json={
            "client_id": "respond-emotional",
            "message": "remind me of my happy memories",
            "prepare_result": {
                "outcome": "query",
                "assistant_draft": "",
                "tags": ["positive"],
                "entities": [],
                "literal_terms": [],
                "time_filters": [],
                "query_embedding": [0.1, 0.2, 0.3],
                "memory_write_plans": [],
                "retrieval_plan": {
                    "intent_type": "emotional_recall",
                    "strategy": "tag_vector",
                    "allow_deleted_fallback": False,
                    "keyword_terms": [],
                    "entity_filters": [],
                    "tag_filters": ["positive"],
                    "time_filters": [],
                },
            },
            "retrieved_memories": [
                {
                    "id": "memory-1",
                    "content": "I felt happy after finishing the Bhutan trip plan.",
                    "tags": ["positive", "travel"],
                    "entities": [],
                    "score": 0.9,
                    "created_at": "2026-03-08T00:00:00",
                }
            ],
        },
    )
    assert response.status_code == 200
    body = response.text
    client.close()
    assert "Positive memory highlights:" in body


def test_respond_streams_exact_mention_style(tmp_path: Path):
    client = build_client(tmp_path, "respond_exact.db")
    response = client.post(
        "/api/chat/respond",
        json={
            "client_id": "respond-exact",
            "message": "when did I mention Bhutan?",
            "prepare_result": {
                "outcome": "query",
                "assistant_draft": "",
                "tags": [],
                "entities": ["Bhutan"],
                "literal_terms": ["Bhutan"],
                "time_filters": [],
                "query_embedding": None,
                "memory_write_plans": [],
                "retrieval_plan": {
                    "intent_type": "exact_mention_lookup",
                    "strategy": "keyword_only",
                    "allow_deleted_fallback": False,
                    "keyword_terms": ["Bhutan"],
                    "entity_filters": ["Bhutan"],
                    "tag_filters": [],
                    "time_filters": [],
                },
            },
            "retrieved_memories": [
                {
                    "id": "memory-1",
                    "content": "Bhutan trip was amazing",
                    "tags": ["travel"],
                    "entities": ["Bhutan"],
                    "score": 1.0,
                    "created_at": "2024-01-05T00:00:00",
                }
            ],
        },
    )
    assert response.status_code == 200
    body = response.text
    client.close()
    assert "Mention timeline:" in body


def test_respond_streams_quoted_lookup_style(tmp_path: Path):
    client = build_client(tmp_path, "respond_quoted.db")
    response = client.post(
        "/api/chat/respond",
        json={
            "client_id": "respond-quoted",
            "message": "my lyrics that go 'fire in the rain' last year",
            "prepare_result": {
                "outcome": "query",
                "assistant_draft": "",
                "tags": [],
                "entities": [],
                "literal_terms": ["fire in the rain"],
                "time_filters": [str(date.today().year - 1)],
                "query_embedding": [0.1, 0.2, 0.3],
                "memory_write_plans": [],
                "retrieval_plan": {
                    "intent_type": "quoted_text_lookup",
                    "strategy": "keyword_vector_hybrid",
                    "allow_deleted_fallback": False,
                    "keyword_terms": ["fire in the rain"],
                    "entity_filters": [],
                    "tag_filters": [],
                    "time_filters": [str(date.today().year - 1)],
                },
            },
            "retrieved_memories": [
                {
                    "id": "memory-1",
                    "content": "Fire in the rain, we kept moving anyway.",
                    "tags": ["general"],
                    "entities": [],
                    "score": 0.95,
                    "created_at": "2025-06-11T00:00:00",
                }
            ],
        },
    )
    assert response.status_code == 200
    body = response.text
    client.close()
    assert "Best matching memory:" in body


def test_respond_attachment_backed_hits_include_snippet_context(tmp_path: Path):
    client = build_client(tmp_path, "respond_attachment.db")
    response = client.post(
        "/api/chat/respond",
        json={
            "client_id": "respond-attachment",
            "message": "my lyrics that go 'fire in the rain' last year",
            "prepare_result": {
                "outcome": "query",
                "assistant_draft": "",
                "tags": [],
                "entities": [],
                "literal_terms": ["fire in the rain"],
                "time_filters": [str(date.today().year - 1)],
                "query_embedding": [0.1, 0.2, 0.3],
                "memory_write_plans": [],
                "retrieval_plan": {
                    "intent_type": "quoted_text_lookup",
                    "strategy": "keyword_vector_hybrid",
                    "allow_deleted_fallback": False,
                    "keyword_terms": ["fire in the rain"],
                    "entity_filters": [],
                    "tag_filters": [],
                    "time_filters": [str(date.today().year - 1)],
                },
            },
            "retrieved_memories": [
                {
                    "id": "memory-1",
                    "content": "Document summary for the lyrics draft.",
                    "tags": ["document"],
                    "entities": [],
                    "score": 0.95,
                    "created_at": "2025-06-11T00:00:00",
                    "source_type": "document_attachment",
                    "attachment_id": "attachment-1",
                    "attachment_name": "lyrics.md",
                    "snippet": "We wrote: fire in the rain and kept moving anyway.",
                }
            ],
        },
    )
    assert response.status_code == 200
    body = response.text
    client.close()
    assert "lyrics.md" in body
    assert "fire in the rain" in body


def test_respond_streams_thematic_reflection_style(tmp_path: Path):
    client = build_client(tmp_path, "respond_thematic.db")
    response = client.post(
        "/api/chat/respond",
        json={
            "client_id": "respond-thematic",
            "message": "have I grown more confident this year?",
            "prepare_result": {
                "outcome": "query",
                "assistant_draft": "",
                "tags": ["positive"],
                "entities": [],
                "literal_terms": [],
                "time_filters": [str(date.today().year)],
                "query_embedding": [0.1, 0.2, 0.3],
                "memory_write_plans": [],
                "retrieval_plan": {
                    "intent_type": "thematic_reflection",
                    "strategy": "time_vector",
                    "allow_deleted_fallback": False,
                    "keyword_terms": [],
                    "entity_filters": [],
                    "tag_filters": ["positive"],
                    "time_filters": [str(date.today().year)],
                },
            },
            "retrieved_memories": [
                {
                    "id": "memory-1",
                    "content": "I felt unsure before the presentation.",
                    "tags": ["negative"],
                    "entities": [],
                    "score": 0.7,
                    "created_at": "2026-01-10T00:00:00",
                },
                {
                    "id": "memory-2",
                    "content": "I felt confident leading the meeting.",
                    "tags": ["positive"],
                    "entities": [],
                    "score": 0.95,
                    "created_at": "2026-09-18T00:00:00",
                },
            ],
        },
    )
    assert response.status_code == 200
    body = response.text
    client.close()
    assert "Earlier:" in body
    assert "Later:" in body


def test_respond_streams_open_reflective_style(tmp_path: Path):
    client = build_client(tmp_path, "respond_reflective.db")
    response = client.post(
        "/api/chat/respond",
        json={
            "client_id": "respond-reflective",
            "message": "why do I keep feeling stuck?",
            "prepare_result": {
                "outcome": "query",
                "assistant_draft": "",
                "tags": ["negative"],
                "entities": [],
                "literal_terms": [],
                "time_filters": [],
                "query_embedding": [0.1, 0.2, 0.3],
                "memory_write_plans": [],
                "retrieval_plan": {
                    "intent_type": "open_reflective_query",
                    "strategy": "vector_only",
                    "allow_deleted_fallback": False,
                    "keyword_terms": [],
                    "entity_filters": [],
                    "tag_filters": ["negative"],
                    "time_filters": [],
                },
            },
            "retrieved_memories": [
                {
                    "id": "memory-1",
                    "content": "I keep putting off the work that matters most.",
                    "tags": ["negative"],
                    "entities": [],
                    "score": 0.91,
                    "created_at": "2026-03-07T00:00:00",
                }
            ],
        },
    )
    assert response.status_code == 200
    body = response.text
    client.close()
    assert "A recurring grounded pattern is" in body


def test_entity_summary_returns_grounded_text(tmp_path: Path):
    client = build_client(tmp_path, "entity_summary.db")
    response = client.post(
        "/api/entities/summarize",
        json={
            "client_id": "entity-user",
            "entity_name": "Rita",
            "aliases": ["@rita", "rita"],
            "linked_memories": [
                {
                    "id": "memory-1",
                    "content": "Rita started a new job in January and felt excited about it.",
                    "tags": ["career", "positive"],
                    "entities": ["Rita"],
                    "created_at": "2026-01-10T09:00:00",
                },
                {
                    "id": "memory-2",
                    "content": "Rita is waiting to hear back about her first big project.",
                    "tags": ["career"],
                    "entities": ["Rita"],
                    "created_at": "2026-02-14T18:30:00",
                },
            ],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert "Rita appears in 2 canon memories." in payload["summary"]
    assert "Current status:" in payload["summary"]
    assert "waiting to hear back" in payload["summary"]
    assert "Open loops:" in payload["summary"]


def test_attachment_inspect_returns_grounded_document_summary(tmp_path: Path):
    client = build_client(tmp_path, "attachments_document.db")
    response = client.post(
        "/api/attachments/inspect",
        json={
            "client_id": "attachment-user",
            "message_text": "remember this note",
            "attachments": [
                {
                    "client_attachment_id": "attachment-1",
                    "kind": "document",
                    "file_name": "rita-note.docx",
                    "mime_type": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                    "document_text": "Rita mentioned Bhutan during archived travel planning notes.",
                }
            ],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["items"][0]["status"] == "ready"
    assert "rita-note.docx" in payload["items"][0]["summary"]
    assert payload["items"][0]["memory_write_plan"]["embedding"]
    assert "document" in payload["items"][0]["memory_write_plan"]["tags"]


def test_attachment_inspect_returns_grounded_image_summary(tmp_path: Path):
    client = build_client(tmp_path, "attachments_image.db")
    response = client.post(
        "/api/attachments/inspect",
        json={
            "client_id": "attachment-image-user",
            "message_text": "what's in these photos?",
            "attachments": [
                {
                    "client_attachment_id": "attachment-1",
                    "kind": "image",
                    "file_name": "photo.jpg",
                    "mime_type": "image/jpeg",
                    "image_base64": "ZmFrZS1pbWFnZS1ieXRlcw==",
                }
            ],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["items"][0]["status"] == "ready"
    assert "photo.jpg" in payload["items"][0]["summary"]
    assert "image" in payload["items"][0]["memory_write_plan"]["tags"]


def test_attachment_inspect_rejects_more_than_ten_images(tmp_path: Path):
    client = build_client(tmp_path, "attachments_limit.db")
    response = client.post(
        "/api/attachments/inspect",
        json={
            "client_id": "attachment-limit-user",
            "message_text": "what's in these photos?",
            "attachments": [
                {
                    "client_attachment_id": f"attachment-{index}",
                    "kind": "image",
                    "file_name": f"photo-{index}.jpg",
                    "mime_type": "image/jpeg",
                    "image_base64": "ZmFrZS1pbWFnZS1ieXRlcw==",
                }
                for index in range(11)
            ],
        },
    )
    client.close()
    assert response.status_code == 400
    assert "At most 10 image attachments" in response.json()["detail"]


def test_attachment_inspect_reports_unsupported_image_provider(tmp_path: Path):
    client = build_client(
        tmp_path,
        "attachments_unsupported.db",
        generation_provider="ollama",
    )
    response = client.post(
        "/api/attachments/inspect",
        json={
            "client_id": "attachment-unsupported-user",
            "message_text": "what's in this photo?",
            "attachments": [
                {
                    "client_attachment_id": "attachment-1",
                    "kind": "image",
                    "file_name": "photo.jpg",
                    "mime_type": "image/jpeg",
                    "image_base64": "ZmFrZS1pbWFnZS1ieXRlcw==",
                }
            ],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["items"][0]["status"] == "failed"
    assert "does not support image inspection" in payload["items"][0]["failure_reason"]


def test_entity_summary_and_attachment_inspect_increment_quota(tmp_path: Path):
    client = build_client(tmp_path, "quota_counts.db")
    entity_response = client.post(
        "/api/entities/summarize",
        json={
            "client_id": "quota-counter-user",
            "entity_name": "Rita",
            "aliases": ["@rita"],
            "linked_memories": [
                {
                    "id": "memory-1",
                    "content": "Rita started a new job in January.",
                    "tags": ["career"],
                    "entities": ["Rita"],
                    "created_at": "2026-01-10T09:00:00",
                }
            ],
        },
    )
    assert entity_response.status_code == 200

    attachment_response = client.post(
        "/api/attachments/inspect",
        json={
            "client_id": "quota-counter-user",
            "message_text": "remember this note",
            "attachments": [
                {
                    "client_attachment_id": "attachment-1",
                    "kind": "document",
                    "file_name": "note.txt",
                    "mime_type": "text/plain",
                    "document_text": "Rita mentioned Bhutan during archived planning.",
                }
            ],
        },
    )
    assert attachment_response.status_code == 200

    quota_response = client.get(
        "/api/quota",
        params={"client_id": "quota-counter-user"},
    )
    assert quota_response.status_code == 200
    quota_payload = quota_response.json()
    client.close()

    assert quota_payload["prepare_count"] == 0
    assert quota_payload["respond_count"] == 0
    assert quota_payload["entity_summary_count"] == 1
    assert quota_payload["attachment_inspect_count"] == 1
    assert quota_payload["total_used"] == 2
    assert quota_payload["remaining_total"] == 198


def test_requests_beyond_daily_limit_return_quota_error(tmp_path: Path):
    client = build_client(
        tmp_path,
        "quota_limit.db",
        default_daily_quota=1,
    )
    first_prepare = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "quota-limit-user",
            "message": "What is going on in Rita's life?",
            "recent_messages": [],
        },
    )
    assert first_prepare.status_code == 200

    blocked_prepare = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "quota-limit-user",
            "message": "when did I mention Bhutan?",
            "recent_messages": [],
        },
    )
    payload = blocked_prepare.json()
    client.close()

    assert blocked_prepare.status_code == 429
    assert payload["error_code"] == "daily_quota_exceeded"
    assert payload["quota"]["daily_limit"] == 1
    assert payload["quota"]["total_used"] == 1
    assert payload["quota"]["remaining_total"] == 0


def test_invalid_requests_do_not_consume_quota(tmp_path: Path):
    client = build_client(tmp_path, "quota_invalid.db")
    invalid_response = client.post(
        "/api/attachments/inspect",
        json={
            "client_id": "quota-invalid-user",
            "message_text": "too many images",
            "attachments": [
                {
                    "client_attachment_id": f"attachment-{index}",
                    "kind": "image",
                    "file_name": f"photo-{index}.jpg",
                    "mime_type": "image/jpeg",
                    "image_base64": "ZmFrZS1pbWFnZS1ieXRlcw==",
                }
                for index in range(11)
            ],
        },
    )
    assert invalid_response.status_code == 400

    quota_response = client.get(
        "/api/quota",
        params={"client_id": "quota-invalid-user"},
    )
    quota_payload = quota_response.json()
    client.close()

    assert quota_payload["total_used"] == 0
    assert quota_payload["attachment_inspect_count"] == 0


def test_daily_quota_uses_one_row_per_client_and_day(tmp_path: Path):
    database_name = "quota_rows.db"
    client = build_client(tmp_path, database_name)
    prepare_response = client.post(
        "/api/chat/prepare",
        json={
            "client_id": "quota-row-user",
            "message": "What is going on in Rita's life?",
            "recent_messages": [],
        },
    )
    assert prepare_response.status_code == 200
    respond_response = client.post(
        "/api/chat/respond",
        json={
            "client_id": "quota-row-user",
            "message": "What is going on in Rita's life?",
            "prepare_result": prepare_response.json(),
            "retrieved_memories": [],
        },
    )
    assert respond_response.status_code == 200
    client.close()

    database_path = (tmp_path / database_name).resolve()
    with sqlite3.connect(database_path) as connection:
        cursor = connection.execute(
            "SELECT COUNT(*) FROM daily_quota WHERE client_id = ?",
            ("quota-row-user",),
        )
        row_count = cursor.fetchone()[0]

    assert row_count == 1


def test_entity_summary_returns_empty_for_empty_linked_memories(tmp_path: Path):
    client = build_client(tmp_path, "entity_summary_empty.db")
    response = client.post(
        "/api/entities/summarize",
        json={
            "client_id": "entity-user",
            "entity_name": "Rita",
            "aliases": [],
            "linked_memories": [],
        },
    )
    assert response.status_code == 200
    payload = response.json()
    client.close()
    assert payload["summary"] == ""
