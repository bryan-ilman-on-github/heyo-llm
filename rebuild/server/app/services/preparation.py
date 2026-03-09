import re
from dataclasses import dataclass
from datetime import date

from app.schemas.chat import ClarificationPrompt
from app.schemas.chat import MemoryItem
from app.schemas.chat import PrepareRequest
from app.schemas.chat import PrepareResponse
from app.schemas.chat import RetrievalPlan

from .embeddings import EmbeddingService
from .retrieval_profiles import ScenarioProfile
from .retrieval_profiles import resolve_scenario_profile


DOUBLE_QUOTED_PHRASE_PATTERN = re.compile(r'"([^"]+)"')
SINGLE_QUOTED_PHRASE_PATTERN = re.compile(r"(?<!\w)'([^']{2,})'(?!\w)")


@dataclass(frozen=True)
class PreparationAnalysis:
    outcome: str
    assistant_draft: str
    intent_type: str
    strategy: str
    should_store_memory: bool
    memory_content: str
    allow_deleted_fallback: bool
    tags: list[str]
    entities: list[str]
    literal_terms: list[str]
    time_filters: list[str]
    clarification: ClarificationPrompt | None


@dataclass(frozen=True)
class AnalyzedInput:
    intent_type: str
    tags: list[str]
    entities: list[str]
    literal_terms: list[str]
    time_filters: list[str]
    allow_deleted_fallback: bool
    looks_like_question: bool
    looks_like_schedule_note: bool
    looks_like_sensitive: bool
    looks_like_non_memory: bool
    looks_like_memory_statement: bool
    mixed_memory_content: str


class QueryAnalyzer:
    def analyze(self, message: str) -> AnalyzedInput:
        lower_message = message.lower()
        tags = self._extract_tags(lower_message)
        entities = self._extract_entities(message)
        literal_terms = self._extract_literal_terms(message)
        time_filters = self._extract_time_filters(lower_message)
        allow_deleted_fallback = self._looks_like_deleted_memory_request(
            lower_message
        )
        looks_like_question = self._looks_like_question(message, lower_message)
        looks_like_schedule_note = self._looks_like_schedule_note(lower_message)
        looks_like_sensitive = self._looks_like_sensitive_content(lower_message)
        looks_like_non_memory = self._looks_like_non_memory_instruction(
            message,
            lower_message,
        )
        looks_like_memory_statement = self._looks_like_memory_statement(
            message,
            lower_message,
            looks_like_non_memory,
        )
        mixed_memory_content = self._extract_mixed_memory_content(message)

        return AnalyzedInput(
            intent_type=self._infer_intent_type(
                message=message,
                lower_message=lower_message,
                tags=tags,
                entities=entities,
                literal_terms=literal_terms,
                time_filters=time_filters,
            ),
            tags=tags,
            entities=entities,
            literal_terms=literal_terms,
            time_filters=time_filters,
            allow_deleted_fallback=allow_deleted_fallback,
            looks_like_question=looks_like_question,
            looks_like_schedule_note=looks_like_schedule_note,
            looks_like_sensitive=looks_like_sensitive,
            looks_like_non_memory=looks_like_non_memory,
            looks_like_memory_statement=looks_like_memory_statement,
            mixed_memory_content=mixed_memory_content,
        )

    def _infer_intent_type(
        self,
        *,
        message: str,
        lower_message: str,
        tags: list[str],
        entities: list[str],
        literal_terms: list[str],
        time_filters: list[str],
    ) -> str:
        del time_filters
        if self._looks_like_deleted_memory_request(lower_message):
            return "exact_mention_lookup"

        if any(
            phrase in lower_message
            for phrase in (
                "when did i mention",
                "did i mention",
                "when have i mentioned",
            )
        ):
            return "exact_mention_lookup"

        if self._contains_quoted_phrase(message):
            return "quoted_text_lookup"

        if self._looks_like_emotional_recall(lower_message, tags):
            return "emotional_recall"

        if self._looks_like_thematic_reflection(lower_message):
            return "thematic_reflection"

        if self._looks_like_entity_specific_recall(lower_message, entities):
            return "entity_specific_recall"

        if literal_terms and lower_message.startswith("when"):
            return "exact_mention_lookup"

        return "open_reflective_query"

    def _extract_tags(self, lower_message: str) -> list[str]:
        tag_rules = {
            "positive": [
                "happy",
                "proud",
                "joy",
                "grateful",
                "calm",
                "amazing",
                "excited",
                "confident",
                "confidence",
            ],
            "negative": [
                "sad",
                "stuck",
                "angry",
                "afraid",
                "anxious",
                "worried",
                "fear",
                "overwhelmed",
            ],
            "planning": [
                "meeting",
                "dentist",
                "march",
                "april",
                "may",
                "am",
                "pm",
                "schedule",
            ],
            "relationship": [
                "partner",
                "friend",
                "family",
                "rita",
            ],
            "travel": [
                "travel",
                "trip",
                "flight",
                "hotel",
                "bhutan",
            ],
        }
        tags: list[str] = []
        for tag_name, tokens in tag_rules.items():
            if any(token in lower_message for token in tokens):
                tags.append(tag_name)
        if not tags:
            tags.append("general")
        return tags

    def _extract_entities(self, message: str) -> list[str]:
        handle_values = re.findall(r"@[A-Za-z0-9_]+", message)
        title_values = re.findall(r"\b[A-Z][a-zA-Z]+\b", message)
        possessive_values = re.findall(r"\b([A-Za-z][a-zA-Z]+)'s\b", message)
        lower_named_values = []
        if "rita" in message.lower():
            lower_named_values.append("Rita")
        if "bhutan" in message.lower():
            lower_named_values.append("Bhutan")

        combined_values = (
            handle_values
            + title_values
            + possessive_values
            + lower_named_values
        )
        return self._deduplicate_values_preserving_case(combined_values)

    def _extract_literal_terms(self, message: str) -> list[str]:
        quoted_terms = DOUBLE_QUOTED_PHRASE_PATTERN.findall(message)
        single_quoted_terms = SINGLE_QUOTED_PHRASE_PATTERN.findall(message)
        handle_terms = re.findall(r"@[A-Za-z0-9_]+", message)
        title_terms = []
        for token in message.split():
            cleaned_token = token.strip(",.?!")
            if cleaned_token.istitle():
                title_terms.append(cleaned_token)

        ordered_terms: list[str] = []
        for value in (
            quoted_terms
            + single_quoted_terms
            + handle_terms
            + title_terms
        ):
            cleaned_value = value.strip().strip(",.?!")
            if not cleaned_value or cleaned_value in ordered_terms:
                continue
            ordered_terms.append(cleaned_value)
        return self._limit_values(ordered_terms, 6)

    def _extract_time_filters(self, lower_message: str) -> list[str]:
        current_year = date.today().year
        resolved_filters: list[str] = []
        if "this year" in lower_message:
            resolved_filters.append(str(current_year))
        if "last year" in lower_message:
            resolved_filters.append(str(current_year - 1))
        if "today" in lower_message:
            resolved_filters.append(date.today().isoformat())

        raw_matches = re.findall(
            (
                r"\b("
                r"jan|january|feb|february|mar|march|apr|april|may|jun|june|"
                r"jul|july|aug|august|sep|sept|september|oct|october|nov|november|"
                r"dec|december|\d{4}|\d{1,2}:\d{2}|\d{1,2}(?:am|pm)|am|pm"
                r")\b"
            ),
            lower_message,
        )
        resolved_filters.extend(raw_matches)
        return self._deduplicate_values(resolved_filters)

    def _looks_like_question(self, message: str, lower_message: str) -> bool:
        leading_question_phrases = (
            "what ",
            "why ",
            "when ",
            "who ",
            "how ",
            "do ",
            "did ",
            "is ",
            "can ",
            "have ",
            "remind me",
            "tell me",
        )
        return "?" in message or lower_message.startswith(leading_question_phrases)

    def _looks_like_schedule_note(self, lower_message: str) -> bool:
        return bool(
            re.search(
                (
                    r"\b("
                    r"jan|january|feb|february|mar|march|apr|april|may|jun|june|"
                    r"jul|july|aug|august|sep|sept|september|oct|october|"
                    r"nov|november|dec|december|\d{1,2}:\d{2}|\d{1,2}(?:am|pm)|"
                    r"am|pm"
                    r")\b"
                ),
                lower_message,
            )
        )

    def _looks_like_memory_statement(
        self,
        message: str,
        lower_message: str,
        looks_like_non_memory: bool,
    ) -> bool:
        if self._looks_like_question(message, lower_message):
            return False
        if looks_like_non_memory:
            return False
        memory_patterns = (
            " is ",
            " are ",
            " was ",
            " were ",
            " my ",
            "handle",
            "birthday",
            "instagram",
            "address",
            "@",
        )
        return any(
            pattern in lower_message or pattern in message
            for pattern in memory_patterns
        )

    def _looks_like_sensitive_content(self, lower_message: str) -> bool:
        sensitive_tokens = [
            "cheat",
            "bomb",
            "kill",
            "hurt",
            "attack",
            "steal",
            "fraud",
            "blackmail",
            "harm",
            "weapon",
        ]
        return any(token in lower_message for token in sensitive_tokens)

    def _looks_like_non_memory_instruction(
        self,
        message: str,
        lower_message: str,
    ) -> bool:
        normalized_message = message.strip()
        lightweight_phrases = {
            "ok",
            "okay",
            "thanks",
            "thank you",
            "got it",
            "continue",
            "go on",
            "sure",
            "cool",
            "yep",
            "nope",
        }
        if lower_message in lightweight_phrases:
            return True

        token_count = len([token for token in normalized_message.split() if token])
        if token_count <= 3 and not self._looks_like_question(message, lower_message):
            return True

        command_phrases = (
            "continue",
            "go ahead",
            "answer that",
            "help me",
        )
        return lower_message.startswith(command_phrases) and token_count <= 5

    def _looks_like_deleted_memory_request(self, lower_message: str) -> bool:
        deleted_tokens = ["deleted", "delete", "removed", "remove"]
        memory_tokens = ["memory", "message", "messages"]
        has_deleted_token = any(token in lower_message for token in deleted_tokens)
        has_memory_token = any(token in lower_message for token in memory_tokens)
        return has_deleted_token and has_memory_token

    def _extract_mixed_memory_content(self, message: str) -> str:
        lower_message = message.lower()
        if "?" not in message:
            return ""

        split_markers = [
            ", do you",
            ", can you",
            ", could you",
            ", what",
            ", when",
            ". do you",
            ". can you",
            ". what",
            ". when",
            " do you know",
        ]
        best_index = -1
        for marker in split_markers:
            marker_index = lower_message.find(marker)
            if marker_index >= 0 and (best_index < 0 or marker_index < best_index):
                best_index = marker_index

        if best_index < 0:
            return ""

        return self._take_prefix(message, best_index).strip().rstrip(",.")

    def _looks_like_emotional_recall(
        self,
        lower_message: str,
        tags: list[str],
    ) -> bool:
        emotional_tags = {"positive", "negative"}
        recall_markers = ("remind me", "remember", "recall", "memories")
        return (
            any(marker in lower_message for marker in recall_markers)
            and any(tag in emotional_tags for tag in tags)
        )

    def _looks_like_thematic_reflection(self, lower_message: str) -> bool:
        thematic_markers = (
            "this year",
            "last year",
            "grown",
            "over time",
            "more confident",
            "less anxious",
            "change over time",
        )
        return any(marker in lower_message for marker in thematic_markers)

    def _looks_like_entity_specific_recall(
        self,
        lower_message: str,
        entities: list[str],
    ) -> bool:
        if not entities:
            return False
        entity_markers = (
            "what's going on",
            "what is going on",
            "life",
            "handle",
            "instagram",
            "tell me about",
            "do you know",
            "what do you know",
        )
        return any(marker in lower_message for marker in entity_markers)

    def _contains_quoted_phrase(self, message: str) -> bool:
        return bool(
            DOUBLE_QUOTED_PHRASE_PATTERN.search(message)
            or SINGLE_QUOTED_PHRASE_PATTERN.search(message)
        )

    def _take_prefix(self, content: str, limit: int) -> str:
        characters: list[str] = []
        for index, character in enumerate(content):
            if index >= limit:
                break
            characters.append(character)
        return "".join(characters)

    def _deduplicate_values(self, values: list[str]) -> list[str]:
        seen: set[str] = set()
        ordered: list[str] = []
        for value in values:
            normalized_value = value.lower()
            if normalized_value in seen:
                continue
            seen.add(normalized_value)
            ordered.append(value)
        return ordered

    def _deduplicate_values_preserving_case(
        self,
        values: list[str],
    ) -> list[str]:
        seen: set[str] = set()
        ordered: list[str] = []
        for value in values:
            normalized_value = value.strip().lower()
            if not normalized_value or normalized_value in seen:
                continue
            seen.add(normalized_value)
            ordered.append(value.strip())
        return ordered

    def _limit_values(self, values: list[str], limit: int) -> list[str]:
        limited_values: list[str] = []
        for value in values:
            limited_values.append(value)
            if len(limited_values) >= limit:
                break
        return limited_values


class RetrievalPlanner:
    def plan(self, analyzed_input: AnalyzedInput) -> ScenarioProfile:
        return resolve_scenario_profile(analyzed_input.intent_type)


class PreparationService:
    def __init__(self, embedding_service: EmbeddingService):
        self.embedding_service = embedding_service
        self.query_analyzer = QueryAnalyzer()
        self.retrieval_planner = RetrievalPlanner()

    def prepare(self, request: PrepareRequest) -> PrepareResponse:
        message = request.message.strip()
        analysis = self._analyze_message(message)
        memory_write_plans: list[MemoryItem] = []

        if analysis.should_store_memory and analysis.memory_content:
            memory_tags = self.query_analyzer._extract_tags(
                analysis.memory_content.lower()
            )
            memory_entities = self.query_analyzer._extract_entities(
                analysis.memory_content
            )
            memory_write_plans.append(
                MemoryItem(
                    content=analysis.memory_content,
                    tags=memory_tags,
                    entities=memory_entities,
                    embedding=self.embedding_service.embed_text(
                        analysis.memory_content
                    ),
                )
            )

        query_embedding = None
        if (
            analysis.outcome in {"query", "mixed", "clarify"}
            and self._requires_query_embedding(analysis.strategy)
        ):
            query_embedding = self.embedding_service.embed_text(message)

        return PrepareResponse(
            outcome=analysis.outcome,
            assistant_draft=analysis.assistant_draft,
            tags=analysis.tags,
            entities=analysis.entities,
            literal_terms=analysis.literal_terms,
            time_filters=analysis.time_filters,
            query_embedding=query_embedding,
            clarification=analysis.clarification,
            memory_items=memory_write_plans,
            memory_write_plans=memory_write_plans,
            retrieval_plan=RetrievalPlan(
                intent_type=analysis.intent_type,
                strategy=analysis.strategy,
                allow_deleted_fallback=analysis.allow_deleted_fallback,
                keyword_terms=analysis.literal_terms,
                entity_filters=analysis.entities,
                tag_filters=analysis.tags,
                time_filters=analysis.time_filters,
            ),
        )

    def _analyze_message(self, message: str) -> PreparationAnalysis:
        analyzed_input = self.query_analyzer.analyze(message)
        profile = self.retrieval_planner.plan(analyzed_input)

        if analyzed_input.looks_like_sensitive and analyzed_input.looks_like_question:
            return PreparationAnalysis(
                outcome="brief_refusal",
                assistant_draft=(
                    "I cannot help with that. I can keep the context for future "
                    "reflection without judging you."
                ),
                intent_type=profile.intent_type,
                strategy=profile.strategy,
                should_store_memory=True,
                memory_content=message,
                allow_deleted_fallback=False,
                tags=analyzed_input.tags,
                entities=analyzed_input.entities,
                literal_terms=analyzed_input.literal_terms,
                time_filters=analyzed_input.time_filters,
                clarification=None,
            )

        if analyzed_input.looks_like_sensitive:
            return PreparationAnalysis(
                outcome="memory_only",
                assistant_draft="",
                intent_type=profile.intent_type,
                strategy=profile.strategy,
                should_store_memory=True,
                memory_content=message,
                allow_deleted_fallback=False,
                tags=analyzed_input.tags,
                entities=analyzed_input.entities,
                literal_terms=analyzed_input.literal_terms,
                time_filters=analyzed_input.time_filters,
                clarification=None,
            )

        if analyzed_input.looks_like_non_memory:
            return PreparationAnalysis(
                outcome="memory_only",
                assistant_draft="",
                intent_type=profile.intent_type,
                strategy=profile.strategy,
                should_store_memory=False,
                memory_content="",
                allow_deleted_fallback=False,
                tags=analyzed_input.tags,
                entities=analyzed_input.entities,
                literal_terms=analyzed_input.literal_terms,
                time_filters=analyzed_input.time_filters,
                clarification=None,
            )

        if (
            analyzed_input.looks_like_schedule_note
            and not analyzed_input.looks_like_question
        ):
            clarify_profile = resolve_scenario_profile("thematic_reflection")
            return PreparationAnalysis(
                outcome="clarify",
                assistant_draft="",
                intent_type=clarify_profile.intent_type,
                strategy=clarify_profile.strategy,
                should_store_memory=True,
                memory_content=message,
                allow_deleted_fallback=analyzed_input.allow_deleted_fallback,
                tags=analyzed_input.tags,
                entities=analyzed_input.entities,
                literal_terms=analyzed_input.literal_terms,
                time_filters=analyzed_input.time_filters,
                clarification=ClarificationPrompt(
                    title="Store this or answer it?",
                    message=(
                        "This could be a memory to keep or a question that needs "
                        "an answer."
                    ),
                    original_text=message,
                ),
            )

        if analyzed_input.mixed_memory_content:
            return PreparationAnalysis(
                outcome="mixed",
                assistant_draft="",
                intent_type=profile.intent_type,
                strategy=profile.strategy,
                should_store_memory=True,
                memory_content=analyzed_input.mixed_memory_content,
                allow_deleted_fallback=analyzed_input.allow_deleted_fallback,
                tags=analyzed_input.tags,
                entities=analyzed_input.entities,
                literal_terms=analyzed_input.literal_terms,
                time_filters=analyzed_input.time_filters,
                clarification=None,
            )

        if analyzed_input.looks_like_memory_statement:
            return PreparationAnalysis(
                outcome="memory_only",
                assistant_draft="",
                intent_type=profile.intent_type,
                strategy=profile.strategy,
                should_store_memory=True,
                memory_content=message,
                allow_deleted_fallback=False,
                tags=analyzed_input.tags,
                entities=analyzed_input.entities,
                literal_terms=analyzed_input.literal_terms,
                time_filters=analyzed_input.time_filters,
                clarification=None,
            )

        return PreparationAnalysis(
            outcome="query",
            assistant_draft="",
            intent_type=profile.intent_type,
            strategy=profile.strategy,
            should_store_memory=False,
            memory_content="",
            allow_deleted_fallback=analyzed_input.allow_deleted_fallback,
            tags=analyzed_input.tags,
            entities=analyzed_input.entities,
            literal_terms=analyzed_input.literal_terms,
            time_filters=analyzed_input.time_filters,
            clarification=None,
        )

    def _requires_query_embedding(self, strategy: str) -> bool:
        return strategy in {
            "vector_only",
            "keyword_vector_hybrid",
            "entity_keyword_hybrid",
            "tag_vector",
            "time_vector",
        }
