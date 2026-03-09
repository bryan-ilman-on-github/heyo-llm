from dataclasses import dataclass


@dataclass(frozen=True)
class ScenarioProfile:
    intent_type: str
    strategy: str
    response_style: str


SCENARIO_PROFILES: dict[str, ScenarioProfile] = {
    "emotional_recall": ScenarioProfile(
        intent_type="emotional_recall",
        strategy="tag_vector",
        response_style="cluster_summary",
    ),
    "entity_specific_recall": ScenarioProfile(
        intent_type="entity_specific_recall",
        strategy="entity_keyword_hybrid",
        response_style="chronological_summary",
    ),
    "exact_mention_lookup": ScenarioProfile(
        intent_type="exact_mention_lookup",
        strategy="keyword_only",
        response_style="date_context_list",
    ),
    "quoted_text_lookup": ScenarioProfile(
        intent_type="quoted_text_lookup",
        strategy="keyword_vector_hybrid",
        response_style="best_match_full_memory",
    ),
    "thematic_reflection": ScenarioProfile(
        intent_type="thematic_reflection",
        strategy="time_vector",
        response_style="time_partition_compare",
    ),
    "open_reflective_query": ScenarioProfile(
        intent_type="open_reflective_query",
        strategy="vector_only",
        response_style="pattern_summary",
    ),
}


def resolve_scenario_profile(intent_type: str) -> ScenarioProfile:
    return SCENARIO_PROFILES.get(
        intent_type,
        SCENARIO_PROFILES["open_reflective_query"],
    )
