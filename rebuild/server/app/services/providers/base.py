from dataclasses import dataclass

import httpx

from app.core.config import Settings
from app.schemas.chat import AttachmentKind
from app.schemas.chat import EntitySummaryMemory
from app.schemas.chat import RetrievedMemory


@dataclass(frozen=True)
class ProviderReply:
    text: str


class ProviderConfigurationError(RuntimeError):
    pass


class ProviderRequestError(RuntimeError):
    pass


class ProviderCapabilityError(RuntimeError):
    pass


class BaseGenerationProvider:
    provider_name = "base"
    supports_image_inspection = False

    def __init__(self, settings: Settings):
        self.settings = settings

    def grounded_reply(
        self,
        message: str,
        retrieved_memories: list[RetrievedMemory],
        response_style: str = "pattern_summary",
    ) -> ProviderReply:
        if self.settings.allow_stub_generation:
            return self._build_stub_grounded_reply(
                retrieved_memories,
                response_style,
            )

        prompt = self._build_grounded_prompt(
            message,
            retrieved_memories,
            response_style,
        )
        text = self._generate_text(prompt)
        return ProviderReply(text=text.strip())

    def attachment_summary(
        self,
        *,
        message_text: str,
        kind: AttachmentKind,
        file_name: str,
        mime_type: str,
        document_text: str | None = None,
        image_base64: str | None = None,
    ) -> ProviderReply:
        if kind == "document":
            return self.document_summary(
                message_text=message_text,
                file_name=file_name,
                mime_type=mime_type,
                document_text=document_text or "",
            )
        return self.image_summary(
            message_text=message_text,
            file_name=file_name,
            mime_type=mime_type,
            image_base64=image_base64 or "",
        )

    def document_summary(
        self,
        *,
        message_text: str,
        file_name: str,
        mime_type: str,
        document_text: str,
    ) -> ProviderReply:
        normalized_document_text = document_text.strip()
        if not normalized_document_text:
            return ProviderReply(text="")

        if self.settings.allow_stub_generation:
            return self._build_stub_document_summary(
                file_name=file_name,
                document_text=normalized_document_text,
            )

        prompt = self._build_document_summary_prompt(
            message_text=message_text,
            file_name=file_name,
            mime_type=mime_type,
            document_text=normalized_document_text,
        )
        text = self._generate_text(prompt)
        return ProviderReply(text=text.strip())

    def image_summary(
        self,
        *,
        message_text: str,
        file_name: str,
        mime_type: str,
        image_base64: str,
    ) -> ProviderReply:
        if not self.supports_image_inspection:
            raise ProviderCapabilityError(
                f"{self.provider_name} does not support image inspection."
            )
        if not image_base64.strip():
            return ProviderReply(text="")

        if self.settings.allow_stub_generation:
            return self._build_stub_image_summary(
                file_name=file_name,
                message_text=message_text,
            )

        prompt = self._build_image_summary_prompt(
            message_text=message_text,
            file_name=file_name,
            mime_type=mime_type,
        )
        text = self._generate_image_text(
            prompt=prompt,
            mime_type=mime_type,
            image_base64=image_base64,
        )
        return ProviderReply(text=text.strip())

    def entity_summary(
        self,
        entity_name: str,
        aliases: list[str],
        linked_memories: list[EntitySummaryMemory],
    ) -> ProviderReply:
        if not linked_memories:
            return ProviderReply(text="")

        if self.settings.allow_stub_generation:
            return self._build_stub_entity_summary(entity_name, aliases, linked_memories)

        prompt = self._build_entity_summary_prompt(
            entity_name,
            aliases,
            linked_memories,
        )
        text = self._generate_text(prompt)
        return ProviderReply(text=text.strip())

    def _generate_text(self, prompt: str) -> str:
        raise NotImplementedError

    def _generate_image_text(
        self,
        *,
        prompt: str,
        mime_type: str,
        image_base64: str,
    ) -> str:
        raise ProviderCapabilityError(
            f"{self.provider_name} does not support image inspection."
        )

    def _build_grounded_prompt(
        self,
        message: str,
        retrieved_memories: list[RetrievedMemory],
        response_style: str,
    ) -> str:
        memory_lines = self._render_grounded_memories(retrieved_memories)
        scenario_instruction = self._grounded_response_instruction(
            response_style,
        )
        return (
            "You are Heyo. Answer the user using only the retrieved memories. "
            "Do not invent facts. If the memories are insufficient, say that "
            "clearly and briefly.\n\n"
            f"USER MESSAGE:\n{message}\n\n"
            f"RETRIEVED MEMORIES:\n{memory_lines}\n\n"
            f"RETURN:\n{scenario_instruction}"
        )

    def _build_document_summary_prompt(
        self,
        *,
        message_text: str,
        file_name: str,
        mime_type: str,
        document_text: str,
    ) -> str:
        context_line = message_text.strip() or "No user prompt was supplied."
        return (
            "You are Heyo. Summarize this document into one concise grounded memory note. "
            "Use only the supplied document text and user context. Mention the main topic, "
            "important people, chronology if clear, and any open loops. Do not invent facts.\n\n"
            f"USER CONTEXT:\n{context_line}\n\n"
            f"FILE:\n{file_name} ({mime_type})\n\n"
            f"DOCUMENT TEXT:\n{document_text}\n\n"
            "RETURN:\nA single concise paragraph."
        )

    def _build_image_summary_prompt(
        self,
        *,
        message_text: str,
        file_name: str,
        mime_type: str,
    ) -> str:
        context_line = message_text.strip() or "No user prompt was supplied."
        return (
            "You are Heyo. Summarize the visible content of this image into one concise grounded "
            "memory note. Use only what is visible in the image and the user context. Mention "
            "people, objects, setting, mood, and unresolved uncertainty only when grounded.\n\n"
            f"USER CONTEXT:\n{context_line}\n\n"
            f"FILE:\n{file_name} ({mime_type})\n\n"
            "RETURN:\nA single concise paragraph."
        )

    def _build_entity_summary_prompt(
        self,
        entity_name: str,
        aliases: list[str],
        linked_memories: list[EntitySummaryMemory],
    ) -> str:
        alias_text = ", ".join(self._limit_values(aliases, 6))
        memory_lines = self._render_entity_memories(linked_memories)
        return (
            "You are Heyo. Write one concise grounded entity summary using only "
            "the linked memories. Cover chronology, current status, emotional "
            "tone, and open loops. Do not invent details.\n\n"
            f"ENTITY:\n{entity_name}\n\n"
            f"ALIASES:\n{alias_text}\n\n"
            f"LINKED MEMORIES:\n{memory_lines}\n\n"
            "RETURN:\nA single concise paragraph."
        )

    def _build_stub_grounded_reply(
        self,
        retrieved_memories: list[RetrievedMemory],
        response_style: str,
    ) -> ProviderReply:
        if not retrieved_memories:
            return ProviderReply(
                text="I do not have enough grounded memory yet to answer that well."
            )

        if response_style == "cluster_summary":
            return ProviderReply(
                text=self._build_stub_cluster_summary(retrieved_memories)
            )
        if response_style == "chronological_summary":
            return ProviderReply(
                text=self._build_stub_chronological_summary(retrieved_memories)
            )
        if response_style == "date_context_list":
            return ProviderReply(
                text=self._build_stub_date_context_list(retrieved_memories)
            )
        if response_style == "best_match_full_memory":
            return ProviderReply(
                text=self._build_stub_best_match_full_memory(retrieved_memories)
            )
        if response_style == "time_partition_compare":
            return ProviderReply(
                text=self._build_stub_time_partition_compare(retrieved_memories)
            )
        return ProviderReply(
            text=self._build_stub_pattern_summary(retrieved_memories)
        )

    def _build_stub_document_summary(
        self,
        *,
        file_name: str,
        document_text: str,
    ) -> ProviderReply:
        summary = (
            f"Document summary for {file_name}: "
            f"{self._truncate_text(document_text, 180)}"
        )
        return ProviderReply(text=summary)

    def _build_stub_image_summary(
        self,
        *,
        file_name: str,
        message_text: str,
    ) -> ProviderReply:
        context_line = message_text.strip()
        if context_line:
            return ProviderReply(
                text=(
                    f"Image summary for {file_name}: grounded visual summary aligned with "
                    f"the request '{self._truncate_text(context_line, 80)}'."
                )
            )
        return ProviderReply(
            text=f"Image summary for {file_name}: grounded visual summary from the supplied image."
        )

    def _grounded_response_instruction(self, response_style: str) -> str:
        instructions = {
            "cluster_summary": (
                "Write a grouped grounded summary of emotionally related memories. "
                "Group similar memories, mention recency where relevant, and keep "
                "the answer concise."
            ),
            "chronological_summary": (
                "Write a chronological summary centered on the referenced entity. "
                "Move from earlier to later memories and end with the current grounded status."
            ),
            "date_context_list": (
                "List the matching mentions in chronological order with explicit "
                "dates or timestamps and one short grounded context note for each."
            ),
            "best_match_full_memory": (
                "Return the single best matching stored memory in full grounded form. "
                "Do not broaden into a summary."
            ),
            "time_partition_compare": (
                "Compare earlier versus later memories in the relevant time window. "
                "State what changed using only grounded evidence."
            ),
            "pattern_summary": (
                "Synthesize the strongest grounded pattern across the memories. "
                "Mention uncertainty if the evidence is sparse."
            ),
        }
        return instructions.get(
            response_style,
            instructions["pattern_summary"],
        )

    def _build_stub_cluster_summary(
        self,
        retrieved_memories: list[RetrievedMemory],
    ) -> str:
        ordered_memories = self._sort_memories_by_created_at(
            retrieved_memories,
            reverse=True,
        )
        lines = ["Positive memory highlights:"]
        for memory in self._limit_values(ordered_memories, 3):
            lines.append(
                f"{self._format_created_at(memory)} {self._truncate_text(memory.content, 120)}"
                f"{self._render_source_suffix(memory)}"
            )
        return " ".join(lines)

    def _build_stub_chronological_summary(
        self,
        retrieved_memories: list[RetrievedMemory],
    ) -> str:
        ordered_memories = self._sort_memories_by_created_at(
            retrieved_memories,
            reverse=False,
        )
        entity_names = self._collect_entity_names(retrieved_memories)
        subject = ", ".join(entity_names) if entity_names else "this topic"
        lines = [f"Chronology for {subject}:"]
        for memory in self._limit_values(ordered_memories, 3):
            lines.append(
                f"{self._format_created_at(memory)} {self._truncate_text(memory.content, 110)}"
                f"{self._render_source_suffix(memory)}"
            )
        if ordered_memories:
            lines.append(
                "Current status: "
                f"{self._truncate_text(ordered_memories[-1].content, 120)}"
                f"{self._render_source_suffix(ordered_memories[-1])}"
            )
        return " ".join(lines)

    def _build_stub_date_context_list(
        self,
        retrieved_memories: list[RetrievedMemory],
    ) -> str:
        ordered_memories = self._sort_memories_by_created_at(
            retrieved_memories,
            reverse=False,
        )
        lines: list[str] = ["Mention timeline:"]
        for memory in self._limit_values(ordered_memories, 4):
            lines.append(
                f"{self._format_created_at(memory)} {self._truncate_text(memory.content, 100)}"
                f"{self._render_source_suffix(memory)}"
            )
        return " ".join(lines)

    def _build_stub_best_match_full_memory(
        self,
        retrieved_memories: list[RetrievedMemory],
    ) -> str:
        best_memory = max(
            retrieved_memories,
            key=lambda memory: (
                memory.score,
                memory.created_at.isoformat() if memory.created_at else "",
            ),
        )
        return (
            f"Best matching memory: {best_memory.content}"
            f"{self._render_source_suffix(best_memory)}"
        )

    def _build_stub_time_partition_compare(
        self,
        retrieved_memories: list[RetrievedMemory],
    ) -> str:
        ordered_memories = self._sort_memories_by_created_at(
            retrieved_memories,
            reverse=False,
        )
        if len(ordered_memories) == 1:
            only_memory = ordered_memories[0]
            return (
                "There is only one grounded memory in this time range: "
                f"{self._truncate_text(only_memory.content, 140)}"
            )

        midpoint = len(ordered_memories) // 2
        earlier_memory = ordered_memories[0]
        later_memory = ordered_memories[midpoint]
        return (
            "Earlier: "
            f"{self._truncate_text(earlier_memory.content, 110)}"
            f"{self._render_source_suffix(earlier_memory)} "
            "Later: "
            f"{self._truncate_text(later_memory.content, 110)}"
            f"{self._render_source_suffix(later_memory)} "
            "Comparison: the later memories suggest a different grounded direction."
        )

    def _build_stub_pattern_summary(
        self,
        retrieved_memories: list[RetrievedMemory],
    ) -> str:
        entity_names = self._collect_entity_names(retrieved_memories)
        tag_values = self._collect_tag_names(retrieved_memories)
        lead_in = "A recurring grounded pattern is"
        if entity_names:
            lead_in += f" around {', '.join(entity_names)}"
        if tag_values:
            lead_in += f" with {', '.join(tag_values)} themes"
        memory = self._limit_values(retrieved_memories, 1)[0]
        return (
            f"{lead_in}. "
            f"The clearest recent evidence is {self._truncate_text(memory.content, 140)}"
            f"{self._render_source_suffix(memory)}"
        )

    def _build_stub_entity_summary(
        self,
        entity_name: str,
        aliases: list[str],
        linked_memories: list[EntitySummaryMemory],
    ) -> ProviderReply:
        ordered_memories = sorted(
            linked_memories,
            key=lambda memory: memory.created_at.isoformat()
            if memory.created_at is not None
            else "",
        )
        first_memory = ordered_memories[0]
        latest_memory = ordered_memories[-1]
        alias_text = self._render_alias_text(aliases)
        emotional_tone = self._infer_emotional_tone(ordered_memories)
        open_loop_text = self._infer_open_loops(ordered_memories)

        lines = [
            f"{entity_name} appears in {len(ordered_memories)} canon memories.{alias_text}",
            f"Chronology: {self._truncate_text(first_memory.content, 140)}",
        ]
        if latest_memory.id != first_memory.id:
            lines.append(
                f"Current status: {self._truncate_text(latest_memory.content, 140)}"
            )
        else:
            lines.append(
                "Current status: the latest grounded update is "
                f"{self._truncate_text(latest_memory.content, 140)}"
            )
        lines.append(f"Emotional tone: {emotional_tone}.")
        lines.append(f"Open loops: {open_loop_text}")
        return ProviderReply(text=" ".join(lines))

    def _render_grounded_memories(
        self,
        retrieved_memories: list[RetrievedMemory],
    ) -> str:
        rendered_lines: list[str] = []
        for memory in self._limit_values(retrieved_memories, 8):
            created_at = (
                memory.created_at.isoformat() if memory.created_at is not None else ""
            )
            rendered_lines.append(
                f"[{memory.id}] {created_at} | tags={', '.join(memory.tags)} | "
                f"entities={', '.join(memory.entities)}{self._render_prompt_source_segment(memory)} | "
                f"{memory.content}"
            )
        return "\n".join(rendered_lines)

    def _render_entity_memories(
        self,
        linked_memories: list[EntitySummaryMemory],
    ) -> str:
        rendered_lines: list[str] = []
        ordered_memories = sorted(
            linked_memories,
            key=lambda memory: memory.created_at.isoformat()
            if memory.created_at is not None
            else "",
        )
        for memory in ordered_memories:
            created_at = (
                memory.created_at.isoformat() if memory.created_at is not None else ""
            )
            rendered_lines.append(
                f"[{memory.id}] {created_at} | tags={', '.join(memory.tags)} | "
                f"entities={', '.join(memory.entities)} | {memory.content}"
            )
        return "\n".join(rendered_lines)

    def _collect_entity_names(
        self,
        retrieved_memories: list[RetrievedMemory],
    ) -> list[str]:
        entity_names: list[str] = []
        for memory in retrieved_memories:
            for entity_name in memory.entities:
                if entity_name in entity_names:
                    continue
                entity_names.append(entity_name)
        entity_names.sort()
        return entity_names

    def _collect_tag_names(
        self,
        retrieved_memories: list[RetrievedMemory],
    ) -> list[str]:
        tag_names: list[str] = []
        for memory in retrieved_memories:
            for tag_name in memory.tags:
                if tag_name in tag_names:
                    continue
                tag_names.append(tag_name)
        tag_names.sort()
        return tag_names

    def _render_alias_text(self, aliases: list[str]) -> str:
        distinct_aliases: list[str] = []
        for alias in aliases:
            cleaned_alias = alias.strip()
            if not cleaned_alias or cleaned_alias in distinct_aliases:
                continue
            distinct_aliases.append(cleaned_alias)
        limited_aliases = self._limit_values(distinct_aliases, 3)
        if not limited_aliases:
            return ""
        return f" It is also referenced as {', '.join(limited_aliases)}."

    def _infer_emotional_tone(
        self,
        linked_memories: list[EntitySummaryMemory],
    ) -> str:
        tone_votes: list[str] = []
        for memory in linked_memories:
            joined = " ".join([memory.content, *memory.tags]).lower()
            if any(
                token in joined
                for token in ("happy", "love", "great", "amazing", "positive", "warm")
            ):
                tone_votes.append("mostly positive")
            elif any(
                token in joined
                for token in ("sad", "upset", "angry", "anxious", "negative", "tense")
            ):
                tone_votes.append("tense or difficult")
            elif any(
                token in joined
                for token in ("reflect", "thinking", "processing", "wondering")
            ):
                tone_votes.append("reflective")

        if not tone_votes:
            return "neutral or factual"

        score = {
            "mostly positive": tone_votes.count("mostly positive"),
            "tense or difficult": tone_votes.count("tense or difficult"),
            "reflective": tone_votes.count("reflective"),
        }
        return max(score, key=score.get)

    def _infer_open_loops(
        self,
        linked_memories: list[EntitySummaryMemory],
    ) -> str:
        candidates: list[str] = []
        reversed_memories = list(reversed(linked_memories))
        for memory in reversed_memories:
            lowered = memory.content.lower()
            if (
                "?" in memory.content
                or "need to" in lowered
                or "waiting" in lowered
                or "follow up" in lowered
                or "figure out" in lowered
            ):
                candidates.append(self._truncate_text(memory.content, 140))
        if not candidates:
            return "No explicit open loop is recorded."
        return candidates[0]

    def _truncate_text(self, content: str, limit: int) -> str:
        cleaned = " ".join(content.split())
        if len(cleaned) <= limit:
            return cleaned

        truncated_characters: list[str] = []
        for character in cleaned:
            if len(truncated_characters) >= max(0, limit - 3):
                break
            truncated_characters.append(character)
        return "".join(truncated_characters).rstrip() + "..."

    def _sort_memories_by_created_at(
        self,
        memories: list[RetrievedMemory],
        *,
        reverse: bool,
    ) -> list[RetrievedMemory]:
        return sorted(
            memories,
            key=lambda memory: memory.created_at.isoformat()
            if memory.created_at is not None
            else "",
            reverse=reverse,
        )

    def _format_created_at(self, memory: RetrievedMemory) -> str:
        if memory.created_at is None:
            return "Unknown time:"
        return f"{memory.created_at.date().isoformat()}:"

    def _limit_values(self, values: list, limit: int) -> list:
        limited_values: list = []
        for value in values:
            limited_values.append(value)
            if len(limited_values) >= limit:
                break
        return limited_values

    def _render_prompt_source_segment(self, memory: RetrievedMemory) -> str:
        source_bits: list[str] = []
        if memory.source_type:
            source_bits.append(f"source={memory.source_type}")
        if memory.attachment_name:
            source_bits.append(f"attachment={memory.attachment_name}")
        if memory.snippet:
            source_bits.append(
                f"snippet={self._truncate_text(memory.snippet, 140)}"
            )
        if not source_bits:
            return ""
        return " | " + " | ".join(source_bits)

    def _render_source_suffix(self, memory: RetrievedMemory) -> str:
        source_bits: list[str] = []
        if memory.attachment_name:
            source_bits.append(memory.attachment_name)
        elif memory.source_type:
            source_bits.append(memory.source_type.replace("_", " "))
        if memory.snippet:
            source_bits.append(
                f"snippet: {self._truncate_text(memory.snippet, 90)}"
            )
        if not source_bits:
            return ""
        return f" [{' | '.join(source_bits)}]"

    def _post_json(
        self,
        *,
        url: str,
        headers: dict[str, str],
        payload: dict,
    ) -> dict:
        with httpx.Client(timeout=self.settings.request_timeout_seconds) as client:
            response = client.post(url, headers=headers, json=payload)

        try:
            response.raise_for_status()
        except httpx.HTTPStatusError as error:
            raise ProviderRequestError(str(error)) from error

        return response.json()
