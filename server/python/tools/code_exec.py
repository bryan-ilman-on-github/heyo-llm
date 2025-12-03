import sys
import subprocess
import tempfile
import os
from typing import Any, Dict
from pathlib import Path

from .base import BaseTool


class CodeInterpreterTool(BaseTool):
    """Execute Python code in a sandboxed environment."""

    name = "python"
    description = """Execute Python code and return the output. Use for:
- Complex calculations
- Data processing
- String manipulation
- List/dict operations
- Any task that benefits from code execution

Use print() to output results. Common libraries available: math, json, re, datetime, collections, itertools."""

    def __init__(self, timeout: int = 30, max_output: int = 10000):
        self.timeout = timeout
        self.max_output = max_output
        self._sandbox_dir = Path(tempfile.gettempdir()) / "heyo_sandbox"
        self._sandbox_dir.mkdir(exist_ok=True)

    @property
    def parameters(self) -> Dict[str, Any]:
        return {
            "type": "object",
            "required": ["code"],
            "properties": {
                "code": {
                    "type": "string",
                    "description": "Python code to execute. Use print() for output."
                }
            }
        }

    def execute(self, code: str = "", **kwargs) -> str:
        if not code.strip():
            return "Error: No code provided"

        try:
            result = self._run_sandboxed(code)
            return result
        except subprocess.TimeoutExpired:
            return f"Error: Code execution timed out after {self.timeout} seconds"
        except Exception as e:
            return f"Error: {str(e)}"

    def _run_sandboxed(self, code: str) -> str:
        """Run code in a sandboxed subprocess."""
        # Create wrapper script with safety measures
        wrapped_code = self._wrap_code(code)

        # Write to temp file
        script_path = self._sandbox_dir / f"script_{os.getpid()}.py"
        try:
            script_path.write_text(wrapped_code, encoding='utf-8')

            # Run in subprocess with timeout
            result = subprocess.run(
                [sys.executable, str(script_path)],
                capture_output=True,
                text=True,
                timeout=self.timeout,
                cwd=str(self._sandbox_dir),
                env=self._get_safe_env()
            )

            output = ""
            if result.stdout:
                output += result.stdout
            if result.stderr:
                if output:
                    output += "\n"
                output += f"[stderr]: {result.stderr}"

            # Truncate if too long
            if len(output) > self.max_output:
                output = output[:self.max_output] + f"\n... (truncated, {len(output)} total chars)"

            return output.strip() if output.strip() else "(no output)"

        finally:
            # Cleanup
            if script_path.exists():
                try:
                    script_path.unlink()
                except:
                    pass

    def _wrap_code(self, code: str) -> str:
        """Wrap user code with safety imports and restrictions."""
        return f'''
import sys
import io

# Redirect stdout to capture prints
_stdout = io.StringIO()
sys.stdout = _stdout

# Pre-import common modules (these are safe)
import math
import json
import re
from datetime import datetime, date, timedelta
from collections import Counter, defaultdict, deque
import itertools
import functools
import random
import statistics
from decimal import Decimal
from fractions import Fraction

try:
    # User code
{self._indent_code(code)}
except Exception as e:
    print(f"Error: {{type(e).__name__}}: {{e}}")

# Output captured stdout
sys.stdout = sys.__stdout__
print(_stdout.getvalue(), end='')
'''

    def _indent_code(self, code: str) -> str:
        """Indent code for wrapping."""
        lines = code.split('\n')
        return '\n'.join('    ' + line for line in lines)

    def _get_safe_env(self) -> Dict[str, str]:
        """Get a restricted environment for subprocess."""
        safe_env = {
            'PATH': os.environ.get('PATH', ''),
            'PYTHONPATH': '',
            'PYTHONHOME': os.environ.get('PYTHONHOME', ''),
            'SYSTEMROOT': os.environ.get('SYSTEMROOT', ''),  # Windows needs this
            'TEMP': str(self._sandbox_dir),
            'TMP': str(self._sandbox_dir),
        }
        return {k: v for k, v in safe_env.items() if v}
