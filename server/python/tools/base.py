from abc import ABC, abstractmethod
from typing import Any, Dict


class BaseTool(ABC):
    """Base class for all Heyo tools."""

    @property
    @abstractmethod
    def name(self) -> str:
        """Tool name used in API calls."""
        pass

    @property
    @abstractmethod
    def description(self) -> str:
        """Description shown to the LLM."""
        pass

    @property
    def parameters(self) -> Dict[str, Any]:
        """JSON Schema for tool parameters."""
        return {
            "type": "object",
            "properties": {},
            "required": []
        }

    @abstractmethod
    def execute(self, **kwargs) -> str:
        """Execute the tool and return result as string."""
        pass

    def to_schema(self) -> Dict[str, Any]:
        """Convert tool to JSON schema for LLM."""
        return {
            "name": self.name,
            "description": self.description,
            "parameters": self.parameters
        }
